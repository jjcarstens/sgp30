defmodule SGP30.CRC do
  def check(data_crc_tuples) when is_list(data_crc_tuples) do
    data_crc_tuples
    |> Enum.all?(&check/1)
  end

  def check({data, crc}) do
    calculate(data) == crc
  end

  def calculate(data) do
    <<data::16>>
    |> CRC.calculate(%{
      width: 8,
      poly: 0x31,
      init: 0xFF,
      refin: false,
      refout: false,
      xorout: 0x00
    })
  end
end
