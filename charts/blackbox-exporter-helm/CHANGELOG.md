# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-10-28

### Fixed

- Add `target` label to `openshift-api` and `openshift-console` Probes, required by the availability dashboards (spoke clusters were missing from them since 1.0.0)


## [1.1.0] - 2026-10-23

_([SPEXAPC-27137](https://aspecta.atlassian.net/browse/SPEXAPC-27137))_

### Added

- Probe `hw-xca` for Lenovo XClarity Administrator, rendered only when `hwXcaUrl` is set

### Changed

- README: document Probes instead of `serviceMonitor.targets`

## [1.0.7] - 2026-01-22

### Fixed

- Fix prometheus-blackbox-exporter.podSecurityContext

## [1.0.6] - 2026-01-20

### Fixed

- Fix clusterpolicy

## [1.0.5] - 2026-01-19

### Added

- Added proxy configmap and as env to BBE

## [1.0.4] - 2026-01-16

### Fixed

- Fix typo in openshift-api probe

## [1.0.3] - 2026-01-16

### Fixed

- Fix typo in probes

## [1.0.2] - 2026-01-13

### Fixed

- Fix typo in cluster roles

## [1.0.1] - 2026-01-13

### Fixed

- Fix probe name typo and added labels to probes

## [1.0.0] - 2025-12-23

_([SPEXAPC-10252]https://aspecta.atlassian.net/browse/SPEXAPC-10252)_
_Initial release._