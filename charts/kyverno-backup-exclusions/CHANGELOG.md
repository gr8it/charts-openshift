# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-28

### Added

- ClusterPolicy labelling ACM registration credentials with `velero.io/exclude-from-backup` so Velero skips them and ACM regenerates them on restore
