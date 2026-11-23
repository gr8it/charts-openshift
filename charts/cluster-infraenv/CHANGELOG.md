All notable changes to this component will be documented in this file.
The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.1] - 2026-11-12

### Fixed

- Allow documented local global-override values in the chart schema.
- Document the complete Vault path for the InfraEnv pull secret.

## [2.1.0] - 2026-10-26

### Added

- Add optional Velero backup Schedule for the InfraEnv namespace

## [2.0.0] - 2026-10-15

### Changed

- Require `osImageVersion` for the InfraEnv OS image
- Read SSH public keys from the `global.apc.sshAuthorizedKeys` list

## [1.0.0] - 2026-08-03

_Initial release._
