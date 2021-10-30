defmodule SGP30.CRC do
  @crc_alg :cerlc.init({8, 0x31, 0xFF, 0x00, false})

  def check(data_crc_tuples) when is_list(data_crc_tuples) do
    Enum.all?(data_crc_tuples, &check/1)
  end

  def check({data, crc}) do
    calculate(data) == crc
  end

  def calculate(data) do
    :cerlc.calc_crc(<<data::16>>, @crc_alg)
  end
end
