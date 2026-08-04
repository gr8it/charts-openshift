All notable changes to this component will be documented in this file.
The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-07-29

### Changed

- `ntpServers` moved to `global.apc.services.ntp.servers` via `apc-global-overrides` helper; removed from local values
- Feature flags `apiServerCert.enabled`, `imageProxy.enabled`, `adIntegration.enabled`, `ldapIntegration.enabled` removed; features are now implicitly enabled by setting a non-empty `vaultKey` (or `registryHost` for imageProxy)
- `apiServerCert.names` removed; SANs are now hardcoded as `api.<clusterName>.<baseDomain>` and `oauth.<clusterName>.<baseDomain>`

## [1.0.0] - 2026-07-28

_Initial release._
