# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-03-03

### Added

- add optional StackRox/RHACS break-glass mutation policies directly in `kyverno` chart (`stackroxAdmissionBreakGlass`)
- include auto-labeling support for break-glass namespaces (for example `apc-debug`)
- include bootstrap policy to annotate existing workloads and cronjobs for first rollout

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
