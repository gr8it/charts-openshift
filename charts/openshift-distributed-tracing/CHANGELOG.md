# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-07-10

### Changed
- Updated cluster role tokenreviews for kyverno background controller service account, required for due to breaking change in Tempo operator [tempo-operator](https://github.com/grafana/tempo-operator/blob/main/CHANGELOG.md#0160)
- Added missing cluster role for clusterrolebindings

## [1.0.0] - 2026-05-12

_Initial release._
