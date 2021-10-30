defmodule SGP30.CRC do
  @crc_alg :cerlc.init({8, 0x31, 0xFF, 0x00, false})

  def check(data_crc_tuples) when is_list(data_crc_tuples) do
    data_crc_tuples
    |> Enum.all?(&check/1)
  end

  def check({data, crc}) do
    calculate(data) == crc
  end

  def calculate(data) do
    <<data::16>>
    |> :cerlc.calc_crc(@crc_alg)
  end
end
