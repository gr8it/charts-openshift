All notable changes to this component will be documented in this file.
The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.19] - 2026-11-10

### Fixed

- Allow fresh NodePool installation before cluster operators are available while keeping existing NodePool upgrades gated on HostedCluster release completion.

## [2.0.18] - 2026-11-10

### Fixed

- Allow the NodePool release check to pass when an available HostedCluster reports the target version, even while cluster operators are converging.

## [2.0.17] - 2026-11-10

### Fixed

- Run the NodePool release-check Job at sync wave 0.

## [2.0.16] - 2026-11-10

### Fixed

- Allow initial NodePool installation before HostedCluster cluster operators are available.

## [2.0.15] - 2026-11-09

### Changed

- Rename NodePool release-check templates to use `release-check` in their filenames.

## [2.0.14] - 2026-11-09

### Changed

- Add UTC timestamps to NodePool release-check Job log messages.

## [2.0.13] - 2026-11-09

### Fixed

- Run the NodePool release check after the HostedCluster sync and before the NodePool sync.

## [2.0.12] - 2026-11-09

### Changed

- Configure `ose-cli` image tags with the `oseCliImageTag` value, defaulting to `4.15`.

## [2.0.11] - 2026-11-09

### Fixed

- Mount a writable `/tmp` in the PreSync check job while keeping the container root filesystem read-only.

## [2.0.10] - 2026-11-09

### Changed

- Derive the PreSync check's OpenShift CLI image version from `releaseImage`.

## [2.0.9] - 2026-11-09

### Added

- Gate NodePool upgrades with a PreSync check for the HostedCluster's completed target release.

## [2.0.8] - 2026-11-06

### Changed

- annotation hypershift.openshift.io/force-upgrade-to
- Sync the HostedCluster and ManagedCluster before the NodePool in Argo CD.
- Document the Argo CD HostedCluster health check needed to gate later sync waves on upgrade completion.

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
