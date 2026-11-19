# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** Kyverno 1.15.2 → 1.19.2 (upstream chart 3.5.2 → 3.9.2); `policies.kyverno.io` CEL policies run alongside the legacy `kyverno.io` policies, so both can be tested in parallel before moving to 1.20
- `upgrade.acknowledgeLegacyPoliciesNotEnforced: true`, so the upgrade is not blocked by legacy policies still present on the cluster (they can only be replaced once 1.20 runs)
- alerts use the Kyverno 1.20 metrics: `KyvernoPolicyResultsError`/`KyvernoPolicyResultsFail` count the `kyverno_*_policy_results_total` metrics (plus DeletingPolicy errors), `KyvernoPolicyRuleSlowExecution` the `kyverno_*_policy_execution_duration_seconds` histograms (per policy, CEL policies have no rules)
- `KyvernoBackgroundPolicyDeleted` replaced by `KyvernoLegacyPoliciesPresent` (`kyverno_policy_changes_total` no longer exists)
- removed values of components and metrics no longer present in the upstream chart (`policyReportsCleanup`, `kyverno_policy_rule_info_total`)

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.6.1] - 2026-09-30

### Changed

- `backgroundScanInterval` back to `5m` (was `1h`)

### Fixed

- `KyvernoReportsControllerDown` only rendered when `kyverno.reportsController.enabled` is true (false alert on clusters with the reports controller disabled)
- Renamed `KyvernoUpdateRequestsDropped` to `KyvernoBreakerDroppingEntries`, grouped by `circuit_name`, description no longer claims UpdateRequests

_([SPEXAPC-2578](https://aspecta.atlassian.net/browse/SPEXAPC-2578))_

## [1.6.0] - 2026-09-22

### Added

- Added Kyverno Grafana dashboard and PrometheusRule alerts for UpdateRequest backlog

### Changed

- `backgroundScanInterval` 5m → 1h

_([SPEXAPC-2578](https://aspecta.atlassian.net/browse/SPEXAPC-2578))_

## [1.5.1] - 2026-04-21

### Changed

- Updated prometheus rule so it doesn't create false alarms.

## [1.5.0] - 2026-02-12

### Added

- Added `KyvernoBackgroundControllerDown` alert — detects background controller outage (responsible for generating resources for existing namespaces)
- Added `KyvernoAdmissionControllerDown` alert — detects admission controller outage (responsible for generating resources for new namespaces)

### Fixed

- Fixed KyvernoPolicyResultsFail alert rate window from `[5d]` to `[15m]` — 5-day window was keeping alert active long after a single historical failure

## [1.4.1] - 2026-02-09

### Changed

- Updated memory limit for `apc-kyverno-controller` in `values.yaml` (key `resources.limits.memory`)

## [1.4.0] - 2026-02-26

### Added

- Added Prometheus rules for Kyverno policy failures and errors

## [1.3.1] - 2026-01-14

- Patch version update of HC to 3.5.2
- Increased CPU and Memory limits

_([SPEXAPC-11169](https://aspecta.atlassian.net/browse/SPEXAPC-11169))_

## [1.3.0] - 2025-11-10

### Changed

- Increased memory limit

_([SPEXAPC-8236](https://aspecta.atlassian.net/browse/SPEXAPC-8236))_
