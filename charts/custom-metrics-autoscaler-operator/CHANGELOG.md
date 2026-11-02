# Changelog

All notable changes to this chart are documented in this file.

## [1.0.1] - 2026-09-11

### Fixed

- Corrected subscription `name` and `startingCSV` to match the actual package/CSV published in the `redhat-operators` catalog (`openshift-custom-metrics-autoscaler-operator` / `custom-metrics-autoscaler.v2.19.0-3`), fixing `ResolutionFailed` errors.

## [1.0.0] - 2026-09-07

### Added

- Initial chart to install Custom Metrics Autoscaler Operator `2.19.0-3` using ACM OperatorPolicy.
