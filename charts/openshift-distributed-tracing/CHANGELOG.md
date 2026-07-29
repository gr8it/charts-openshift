# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-07-10

### Changed
- Added tokenreviews (authentication.k8s.io) and subjectaccessreviews (authorization.k8s.io) permissions to the Kyverno background controller ClusterRole, required due to a breaking change in ([Tempo operator 0.16.0](https://github.com/grafana/tempo-operator/blob/main/CHANGELOG.md#0160))
- Added missing clusterrolebindings permissions to the Kyverno background controller ClusterRole

## [1.0.0] - 2026-05-12

_Initial release._
