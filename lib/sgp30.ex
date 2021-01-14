defmodule Sgp30 do
  use GenServer

  require Logger

  alias Circuits.I2C

  defstruct address: 0x58, serial: nil, tvoc: 0, eco2: 0, i2c: nil, h2_raw: nil, ethanol_raw: nil

  @spec start_link(bus_name: String.t()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    bus_name = opts[:bus_name] || "i2c-1"
    {:ok, i2c} = I2C.open(bus_name)
    {:ok, %__MODULE__{i2c: i2c}, {:continue, :serial}}
  end

  def state(name \\ __MODULE__) do
    GenServer.call(name, :get_state)
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_continue(:serial, %{address: address, i2c: i2c} = state) do
    state =
      case I2C.write_read(i2c, address, <<0x3682::size(16)>>, 9) do
        {:ok, <<word1::size(16), _crc1, word2::size(16), _crc2, word3::size(16), _crc3>>} ->
          %{state | serial: <<word1::size(16), word2::size(16), word3::size(16)>>}

        err ->
          log_it("serial read error: #{inspect(err)}", :error)
          state
      end

    I2C.write(i2c, address, <<0x20, 0x03>>)
    Process.send_after(self(), :measure, 1_000)

    {:noreply, state}
  end

  def handle_info(:measure, %{address: address, i2c: i2c} = state) do
    I2C.write(i2c, address, <<0x20, 0x08>>)
    :timer.sleep(10)

    state =
      case I2C.read(i2c, address, 6) do
        {:ok, <<eco2::size(16), _crc, tvoc::size(16), _crc2>>} ->
          %{state | eco2: eco2, tvoc: tvoc}

        err ->
          log_it("measure error: #{inspect(err)}", :error)
          state
      end

    I2C.write(i2c, address, <<0x20, 0x50>>)
    :timer.sleep(20)

    state =
      case I2C.read(i2c, address, 6) do
        {:ok, <<h2_raw::size(16), _crc, ethanol_raw::size(16), _crc2>>} ->
          %{state | h2_raw: h2_raw, ethanol_raw: ethanol_raw}

        err ->
          log_it("raw measure error: #{inspect(err)}", :error)
          state
      end

    Process.send_after(self(), :measure, 1_000)
    {:noreply, state}
  end

  defp log_it(str, level) do
    apply(Logger, level, ["[#{__MODULE__}] - " <> str])
  end
end
