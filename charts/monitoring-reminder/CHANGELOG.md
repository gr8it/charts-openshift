# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2026-08-07

### Fixed

- fix invalid PromQL scalar comparison by wrapping expression in `vector()` to produce an instant vector

## [2.0.1] - 2026-07-23

### Fixed

- fixed schema to allow usage as a subchart with global values defined

## [2.0.0] - 2026-07-15

### Changed

- make reminders an object to allow setup decoupling of dateTime from other parameters

Note: this would be normally a major change with upgrade paths documented, however as the chart is not yet used, making it a minor one

## [1.0.0] - 2026-07-02

_Initial release._
