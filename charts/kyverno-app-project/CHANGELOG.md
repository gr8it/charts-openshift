# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-03-03

### Added

- add automatic break-glass namespace labeling policy (`app-project-stackrox-breakglass-namespace-labels`)
- add `stackroxAdmissionBreakGlass.autoNamespaceLabeling` values to manage namespace labels from chart config
- add bootstrap policy for existing workloads (`app-project-stackrox-breakglass-bootstrap-existing`) with background-only mutation

### Changed

- change break-glass matching to OR semantics across `namespaces`, `namespaceSelector`, and `workloadSelector`
- make `workloadSelector` empty by default so namespace-level targeting does not require workload labels

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
