# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.9] - 2026-02-27

### Changed

- Added standard `monitoring.labels` to `clusterrole-admission-controller.yaml` for consistent resource tracking

## [1.0.8] - 2026-02-25

_([SPEXAPC-12860](https://aspecta.atlassian.net/browse/SPEXAPC-12860))_

### Changed

- Bump dependency on `monitoring-prometheusrules` to 1.0.6
- Added missing labels to Prometheus rules

## [1.0.7] - 2026-02-13

_([SPEXAPC-8954](https://aspecta.atlassian.net/browse/SPEXAPC-8954))_

### Changed

- Bump dependency on `monitoring-prometheusrules` to 1.0.5

## [1.0.6] - 2026-02-02

_([SPEXAPC-8954](https://aspecta.atlassian.net/browse/SPEXAPC-8954))_

### Changed

- Bump dependency on `monitoring-prometheusrules` to 1.0.4

## [1.0.5] - 2025-11-14

### Changed

- added verbs into prometheusrules resource

## [1.0.4] - 2025-11-12

### Changed

- added skipBackgroundRequests

## [1.0.3] - 2025-11-07

_chart type and clusterole_

### Changed

- added chart type: application
- added clusterrole-admission-controller.yaml
- bump version of dependency chart monitoring-prometheusrules

## [1.0.2] - 2025-10-30

_([SPEXAPC-7193](https://aspecta.atlassian.net/jira/software/c/projects/SPEXAPC/boards/109?selectedIssue=SPEXAPC-7193))_

### Changed

- Bump dependency on `monitoring-prometheusrules` from 1.0.0 to 1.0.3
- Bump dependency on `apc-global-overrides` from 1.3.0 to 1.4.0
