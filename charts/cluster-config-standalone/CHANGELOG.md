# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2026-11-03

### Fixed

- Preserve the final newline in the dedicated etcd storage setup script.

## [1.2.0] - 2026-11-02

### Added

- Assemble the Chrony configuration in the chart template using the `ntpServers` helper.
- Added master and worker Chrony configuration and optional dedicated etcd storage MachineConfigs; upgrading can roll affected machine pools.

## [1.1.2] - 2026-01-30

### Fixed

- Fixed typo in external secret configuration for data

## [1.1.1] - 2026-01-29

### Fixed

- Fixed typo in external secret configuration for ClusterSecretStore

## [1.1.0] - 2026-01-25

### Added

- Added Identity provider setup for Openshift Oauth

## [1.0.0] - 2025-08-23

_Initial release._
