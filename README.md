# SGP30
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
`SGP30` handles this for you once initialized it will take a measurement
every second and you would simply call `SGP30.state` to get the
most current results.

```elixir
iex()> {:ok, sgp} = SGP30.start_link()
iex()> SGP30.state
%SGP30{
  address: 88,
  co2_eq_ppm: 421,
  ethanol_raw: 17934,
  h2_raw: 13113,
  i2c: #Reference<0.7390235.92137012.02842>,
  serial: 16613135,
  tvoc_ppb: 17
}
```

## Monitoring

Each measurement uses `:telemetry.span/3` for duration and error tracking and
also emits an event on successful measurement with the current system time in
the metadata. This allows you to use the `:telemetry` tooling to track reported
values over time and monitor the results of the sensor.

`SGP30` also measures the raw values at the same time. This are typically not
needed, but are useful in calibration and tracking potential hardware failures.

Expected events reported ¬

| name | measurement | meta |
| --- | --- | --- |
| `[:sgp30, :measure]` | `%SGP30{}` | `%{system_time: System.monotonic_time()}` |
| `[:sgp30, :measure, :start]` | `%{system_time: System.monotonic_time()}` | `%{}` |
| `[:sgp30, :measure, :stop]` | `%{duration: integer()}` | `%{optional(:error) => any()}` |
| `[:sgp30, :measure, :exception]` | `%{duration: integer()}` | `%{kind: :throw\:error\:exit, reason: term(), stacktrace: list()}` |
| `[:sgp30, :measure_raw]` | `%SGP30{}` | `%{system_time: System.monotonic_time()}` |
| `[:sgp30, :measure_raw, :start]` | `%{system_time: System.monotonic_time()}` | `%{}` |
| `[:sgp30, :measure_raw, :stop]` | `%{duration: integer()}` | `%{optional(:error) => any()}` |
| `[:sgp30, :measure_raw, :exception]` | `%{duration: integer()}` | `%{kind: :throw\:error\:exit, reason: term(), stacktrace: list()}` |


**Note:** The `:stop` event will only include the `:error` key in the meta data
on I2C read errors that are reported, but not neccesarily thrown as an exception.
Also, a `:stop` event after a successful read will not include the `:error` key.
