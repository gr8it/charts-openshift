# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.20; `blackbox-exporter-app-probe-promrules` migrated from `ClusterPolicy` to CEL `GeneratingPolicy` (`policies.kyverno.io/v1`), name kept so existing PrometheusRules are adopted
- removed the duplicate `description` annotation of `BBAppHttpCodeWarn` (rejected by the strict YAML parser of Kyverno templates); the effective value is unchanged

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.0.0] - 2026-01-13

_([SPEXAPC-7741]https://aspecta.atlassian.net/browse/SPEXAPC-7741)_
_Initial release._
