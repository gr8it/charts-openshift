# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-08-19

### Changed

- Upgrade tempo-operator to v0.21.0-3 ([SPEXAPC-19807](https://aspecta.atlassian.net/browse/SPEXAPC-19807)) — fixes pods not restarting after certificate rotation, which caused expired-certificate TLS errors. v0.21.0-3 (rather than the v0.20.0) is used because the `stable` channel's subscription always resolves to the latest available CSV regardless of `startingCSV`/`versions` pinning — confirmed on huba QA

## [1.0.0] - 2026-05-12

_Initial release._
