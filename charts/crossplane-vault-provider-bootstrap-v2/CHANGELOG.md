# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-10-15

_([SPEXAPC-26776](https://aspecta.atlassian.net/browse/SPEXAPC-26776))_

### Added

- `mountPath` in the Kubernetes auth ProviderConfig, so every cluster logs in via its own auth mount (requires provider-vault >= v4.0.0)
- `vaultKubernetesRoleExtraPolicies` value to assign additional Vault policies to the Kubernetes role

### Changed

- Kubernetes role is bound to the provider service account (`vaultProviderServiceAccount`) instead of any service account in the Crossplane namespace
- Bumped `apc-global-overrides` to 1.10.0

### Removed

- Unused `sys/mounts/auth/kubernetes` path from the Kubernetes role policy

## [2.0.0] - 2025-10-14

_Initial release of the Kubernetes auth bootstrap._
