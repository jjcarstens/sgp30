# sgp30
Interface with SGP30 gas sensor with elixir.

For more info on the sensor, see the [datasheet](https://www.mouser.com/datasheet/2/682/Sensirion_Gas_Sensors_SGP30_Datasheet_EN-1148053.pdf).

Currently tested with the [Adafruit breakout board](https://www.adafruit.com/product/3709),
but others should work as well.

# Installation

```elixir
def deps do
  {:sgp30, "~> 0.1"}
end
```

# Usage

According to the [datasheet](https://www.mouser.com/datasheet/2/682/Sensirion_Gas_Sensors_SGP30_Datasheet_EN-1148053.pdf), the sensor must 
be initialized and the caller must start a measurement every second.
`Sgp30` handles this for you once initialized it will take a measurement
every second and you would simply call `Sgp30.state` to get the
most current results.

```elixir
iex()> {:ok, sgp} = Sgp30.start_link()
iex()> Sgp30.state
%Sgp30{
  address: 88,
  eco2: 421,
  ethenol_raw: 17934,
  h2_raw: 13113,
  i2c: #Reference<0.7390235.92137012.02842>,
  serial: <<0, 0, 0, 253, 127, 15>>,
  tvoc: 17
}
```

## TODO
- [ ] Support registering a listening process to receive the
measurement every second
- [ ] Support setting humidity to adjust measurements.