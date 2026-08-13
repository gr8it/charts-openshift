# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-08-11

### Fixed

- Remove `environment="infrastructure"` from alert expressions — HW/infra syslog ingested into the `audit` tenant does not carry this label, so the alerts never fired.

## [1.0.0] - 2026-07-29

_Initial release._
_([SPEXAPC-20757](https://aspecta.atlassian.net/browse/SPEXAPC-20757))_
