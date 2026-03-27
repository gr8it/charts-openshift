# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2026-03-27

### Fixed

- Removed Helm hook annotations from service account token secret so Argo CD applies it as a regular resource
- Disabled namespace-scoped monitoring `RoleBinding` generation by default to avoid Argo CD RBAC reconcile failures

## [1.2.0] - 2026-03-26

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
