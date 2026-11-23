# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-11-02

### Fixed

- Route `tls.termination` lowercase `reencrypt`. The API server normalizes it, so the capitalized value showed as a permanent diff in Argo CD.

## [1.0.0] - 2026-04-28

### Added

- Initial release
