# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-09-23

### Added

- `app-project-namespace-metadata` copies every key of the `project-metadata` configmap onto the Namespace as a label, so that metrics can be attributed to the project instead of the `prometheusK8s.externalLabels` platform default. Entries whose value is not a valid Kubernetes label value are skipped instead of failing the patch
- `app-project-require-metadata-configmap` reports, in Audit mode, an application namespace in which no `project-metadata` ConfigMap exists
- aggregated ClusterRole letting the background controller patch Namespace labels

## [1.4.1] - 2026-02-03

### Fixed

- fix preconditions with label selector to target only application namespaces for cluster policy app-project-quotas

## [1.4.0] - 2026-02-03

### Changed

- replace preconditions with label selector to target only application namespaces

## [1.3.1] - 2025-12-23

### Changed

_([SPEXAPC-10277]https://aspecta.atlassian.net/browse/SPEXAPC-10277)_
- update dependency
- bump count replicaset for default quota from 30 to 100

## [1.0.0] - 2025-12-23
_Initial release._
