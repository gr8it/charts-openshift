# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.20; `app-project-roles` migrated from `ClusterPolicy` to CEL `GeneratingPolicy` (`policies.kyverno.io/v1`), name kept so existing RoleBindings are adopted; the RoleBindings are rendered by Helm instead of Kyverno `foreach`

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.2.0] - 2026-02-03

### Changed

- added cluster route-editor

## [1.1.0] - 2026-02-03

### Changed

- fix preconditions with label selector to target only application namespaces

## [1.0.0] - 2025-08-23

_Initial release._
