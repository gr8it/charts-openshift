# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Fixed

- Fixed KyvernoPolicyResultsFail alert rate window from `[5d]` to `[15m]` — 5-day window was keeping alert active long after a single historical failure

## [1.4.0] - 2026-02-26

### Added

- Added Prometheus rules for Kyverno policy failures and errors

## [1.3.1] - 2026-01-14

- Patch version update of HC to 3.5.2
- Increased CPU and Memory limits

_([SPEXAPC-11169](https://aspecta.atlassian.net/browse/SPEXAPC-11169))_

## [1.3.0] - 2025-11-10

### Changed

- Increased memory limit

_([SPEXAPC-8236](https://aspecta.atlassian.net/browse/SPEXAPC-8236))_
