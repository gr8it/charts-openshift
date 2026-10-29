All notable changes to this component will be documented in this file.
The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.7] - 2026-10-29

### Added

- Add optional Hosted Control Plane etcd snapshot backups to S3

## [2.0.6] - 2026-10-26

### Added

- Restore the Velero resource-policy ConfigMap and reference it from the Schedule

## [2.0.5] - 2026-10-26

### Changed

- Remove the Velero resource-policy ConfigMap and its Schedule reference

## [2.0.4] - 2026-10-26

### Added

- Add a Velero resource policy to exclude selected secrets from HostedCluster backups

## [2.0.3] - 2026-10-26

### Added

- Exclude the import ConfigMap from Velero backups using Argo CD server-side apply

## [2.0.2] - 2026-10-26

### Added

- Add an optional Velero Schedule for the HostedCluster namespace

## [2.0.1] - 2026-10-20

### Changed

- Omit the HostedCluster update channel when `channel` is empty.
- Set the default HostedCluster and ManagedCluster cluster set label to `default`.
- Make the HostedCluster API server audit profile configurable.

## [2.0.0] - 2026-10-15

### Changed

- Make the HostedCluster update channel configurable.
- Configure HostedCluster OAuth identity providers from `global.apc.identityProviders`.
- Create ExternalSecrets for configured identity-provider secret references.
- Create a shared OAuth identity-provider CA bundle ConfigMap for configured providers.
- Render LDAP identity providers in the HostedCluster OAuth API format and reference their bind-password secrets.
- Read worker SSH keys from the `global.apc.sshAuthorizedKeys` list

## [1.0.0] - 2026-08-03

_Initial release._
