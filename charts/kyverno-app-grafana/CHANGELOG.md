# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.19, `ClusterPolicy` migrated to CEL, name kept so existing ClusterRoleBindings are adopted
- background controller can get/list/watch ClusterRoleBindings (Kyverno >= 1.19 watches synchronized downstream resources)

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.0.0] - 2026-04-07

_Initial release._
