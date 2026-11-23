# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.19; `<fullname>-sync-tenants` and `<fullname>-cleanup-tenants` migrated from `ClusterPolicy` to CEL `MutatingPolicy` (`policies.kyverno.io/v1`) mutating the existing OpenTelemetryCollector
- cleanup removes the `otlp_grpc/<namespace>` exporter of a deleted namespace (it only removed the pre-rename `otlp/<namespace>` before)

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.2.1] - 2026-08-10

### Fixed

- OTLP Loki endpoint for application logs
- replaced deprecated OTEL aliases

### Added

- CRB to collector to write application logs

## [1.2.0] - 2026-05-13

### Removed

- remove Kyverno clusterpolicies 

### Added

-  multitenancy support defined using extension headers_setter

## [1.1.0] - 2026-04-29

### Added

- Kyverno clusterpolicies for multitenancy support

## [1.0.0] - 2026-08-23

_Initial release._
