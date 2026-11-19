# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.20; `app-project-networkpolicy` and `platform-project-networkpolicy` migrated from `ClusterPolicy` to CEL `GeneratingPolicy` (`policies.kyverno.io/v1`), names kept so existing NetworkPolicies are adopted

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.5.1] - 2026-02-03

### Fixed

- Corrected label selector indentation in Kyverno policies to ensure proper application of network policies.

## [1.5.0] - 2026-01-30

### Changed

- Refactor Kyverno policies to use label selectors instead of preconditions for namespace type filtering.

## [1.0.0] - 2025-08-23

_Initial release._
