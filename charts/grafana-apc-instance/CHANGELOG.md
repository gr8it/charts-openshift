# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2026-04-09

### Fixed

- Removed cluster-scoped `namespaces` access from the namespace-scoped `view-all-logs` Role

### Removed

- Removed the unused `system:auth-delegator` ClusterRoleBinding from the chart

## [1.2.0] - 2026-04-07

### Added

- Added `namespaceScoped` deployment mode using namespace-scoped `Role` and `RoleBinding` resources instead of cluster-scoped bindings

## [1.1.0] - 2026-02-23

### Changed

- Replaced cookie-secret with cookie-secret-file in ose-oauth-proxy
- cookie-secret-file is using mounted secret, which is provided by generator

## [1.0.1] - 2025-12-23

### Fixed

- Fix Lint and updated dependency

## [1.0.0] - 2025-08-23

_Initial release._
