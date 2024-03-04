# Changelog

## v0.2.4

### Changed

- Allow circuits_i2c 2.0 to be used (Thanks @fhunleth!)

## v0.2.3

### Added

- Allow I2C address to be set with `:address` option (Thanks @fhunleth!)

## v0.2.2

This update just allows `circuits_i2c ~> 1.0` and `telemetry ~> 1.0`
but introduces no functional changes. (thanks @krns! :heart:)

## v0.2.1

### Added

- CRC's are now checked after reads

## 0.2.0

* Breaking Changes
  * module renamed from `Sgp30` => `SGP30`
  * values now include units
    * `tvoc` => `tvoc_ppb`
    * `eco2` => `co2_eq_ppm`
  * `:serial` is now an 48bit integer

* Enhancments
  * added support for `:telemetry` - `start`, `stop`, and `exception`
    events are reported along with the measurements. See `README.md`
    for more details.

## 0.1.1

* Bug Fixes
  * Fix `Logger.debug/1` undefined error
  * Adjusted polling time for more accurate measurements
  * Fixed `ethanol` misspelling

* Enhancements
  * Remove then "measuring..." log message to keep logs clean

## 0.1.0

* Initial release
