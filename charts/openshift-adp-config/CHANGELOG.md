# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.19; the cloud credentials `ClusterPolicy` migrated to CEL `GeneratingPolicy` and the DPA `Policy` to `NamespacedGeneratingPolicy` (`policies.kyverno.io/v1`), names kept so existing Secrets and the DPA are adopted
- the generated DataProtectionApplication now carries the chart labels (they were mis-indented before and dropped)
- background controller can get/list/watch DataProtectionApplications cluster-wide (Kyverno >= 1.19 watches synchronized downstream resources)

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.0.4] - 2026-11-05

- OADP v1.5.8

## [1.0.3] - 2025-11-18

### Fixed

- Formatting openshift.io/oadp label to True in transform-restore-secret kyverno rule

## [1.0.2] - 2025-11-17

### Fixed

- Formatting openshift.io/oadp label to True

## [1.0.1] - 2025-11-07

### Fixed

- Fix ArgoCD sync drift due to auto-generated missing : skipBackgroundRequests: true

## [1.0.0] - 2025-10-31

_Initial release._
