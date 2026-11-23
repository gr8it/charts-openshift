# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.19; `patch-l2advertisement` migrated from `ClusterPolicy` to CEL `MutatingPolicy` (`policies.kyverno.io/v1`)

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.1.0] - 2026-02-24

_([SPEXAPC-12700](https://aspecta.atlassian.net/browse/SPEXAPC-12700))_

### Fixed

- spoke clusters IPAddressPool and L2Advertisement rendering
