defmodule SGP30 do
  use GenServer

  require Logger

  alias Circuits.I2C

  @polling_interval_ms 900

  defstruct address: 0x58,
            serial: 0,
            tvoc_ppb: 0,
            co2_eq_ppm: 0,
            i2c: nil,
            h2_raw: 0,
            ethanol_raw: 0

  @type t() :: %__MODULE__{
          address: I2C.address(),
          serial: non_neg_integer(),
          tvoc_ppb: non_neg_integer(),
          co2_eq_ppm: non_neg_integer(),
          i2c: I2C.bus() | nil,
          h2_raw: non_neg_integer(),
          ethanol_raw: non_neg_integer()
        }

  @spec start_link(bus_name: String.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    bus_name = opts[:bus_name] || "i2c-1"
    {:ok, i2c} = I2C.open(bus_name)
    {:ok, %__MODULE__{i2c: i2c}, {:continue, :serial}}
  end

  @spec state(GenServer.server()) :: t()
  def state(name \\ __MODULE__) do
    GenServer.call(name, :get_state)
  end

  @impl GenServer
  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_continue(:serial, %{address: address, i2c: i2c} = state) do
    state =
      case I2C.write_read(i2c, address, <<0x3682::size(16)>>, 9) do
        {:ok, <<word1::size(16), _crc1, word2::size(16), _crc2, word3::size(16), _crc3>>} ->
          %{state | serial: serial_as_integer(word1, word2, word3)}

        err ->
          log_it("serial read error: #{inspect(err)}", :error)
          state
      end

    _ = I2C.write(i2c, address, <<0x20, 0x03>>)
    Process.send_after(self(), :measure, @polling_interval_ms)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:measure, state) do
    state =
      state
      |> track_event(:measure)
      |> track_event(:measure_raw)

    Process.send_after(self(), :measure, @polling_interval_ms)
    {:noreply, state}
  end

  defp execute_event(event, state) do
    case event do
      :measure -> measure(state)
      :measure_raw -> measure_raw(state)
    end
  end

  defp measure(state) do
    _ = I2C.write(state.i2c, state.address, <<0x20, 0x08>>)
    :timer.sleep(10)

    case I2C.read(state.i2c, state.address, 6) do
      {:ok, <<co2_eq_ppm::16, _crc, tvoc_ppb::16, _crc2>>} ->
        %{state | co2_eq_ppm: co2_eq_ppm, tvoc_ppb: tvoc_ppb}

      {:error, err} ->
        log_it("measure error: #{inspect(err)}", :error)
        {:error, err, state}
    end
  end

  defp measure_raw(state) do
    _ = I2C.write(state.i2c, state.address, <<0x20, 0x50>>)
    :timer.sleep(20)

    case I2C.read(state.i2c, state.address, 6) do
      {:ok, <<h2_raw::16, _crc, ethanol_raw::16, _crc2>>} ->
        %{state | h2_raw: h2_raw, ethanol_raw: ethanol_raw}

      {:error, err} ->
        log_it("raw measure error: #{inspect(err)}", :error)
        {:error, err, state}
    end
  end

  defp log_it(str, level) do
    Logger.bare_log(level, ["[#{__MODULE__}] - ", str])
  end

  defp serial_as_integer(word1, word2, word3) do
    <<serial::48>> = <<word1::16, word2::16, word3::16>>
    serial
  end

  defp track_event(state, event) do
    name = [:sgp30, event]

    :telemetry.span(name, %{}, fn ->
      case execute_event(event, state) do
        {:error, err, state} ->
          {state, %{error: err}}

        updated ->
          :telemetry.execute(name, updated, %{system_time: System.monotonic_time()})
          {updated, %{}}
      end
    end)
  end
end
