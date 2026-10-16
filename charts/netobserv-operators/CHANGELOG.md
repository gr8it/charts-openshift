# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-10-06

### Changed

- Update `startingCSV` to `network-observability-operator.v1.12.3` and allow all `versions` from v1.8.0 to v1.12.3

## [1.2.0] - 2026-07-10

### Changed

- Remove `operatorGroup` from default values — not required when OperatorGroup already exists on cluster

## [1.1.0] - 2026-04-23

### Changed

- Remove alias and condition from `acm-operatorpolicy` dependency
- Change `upgradeApproval` to `Automatic`
- Update `startingCSV` and `versions` to `network-observability-operator.v1.8.0`

## [1.0.0] - 2026-04-20

_Initial release._
