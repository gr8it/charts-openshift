# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-10-29

_([JIRA-843](https://example.atlassian.net/browse/JIRA-843))_
_If you are upgrading: please see [`UPGRADING.md`](UPGRADING.md)._

### Changed

- **Breaking:** emit `close` event after `end`
- Bump `xml-parser` from 6.x to 8.x
- Refactor `sort()` internals to improve performance

### Removed

- **Breaking:** drop support of Node.js 8

## [1.1.0] - 2025-09-13

### Fixed

- Fix infinite loop

### Added

- Support of CentOS ([JIRA-837](https://example.atlassian.net/browse/JIRA-837))

## [1.0.0] - 2025-08-23

_Initial release._
