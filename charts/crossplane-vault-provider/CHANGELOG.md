# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-10-15

_([SPEXAPC-26776](https://aspecta.atlassian.net/browse/SPEXAPC-26776))_

### Changed

- Provider runs under a stable service account name `crossplane-vault-provider` instead of a per-revision one, so the Vault kubernetes auth role can be bound to it
- Bumped `apc-global-overrides` to 1.10.0 (Chart.lock was still at 1.5.0)
- Default provider-vault bumped to v4.0.0 (required by crossplane-vault-provider-bootstrap >= 2.1.0 mountPath)

## [1.5.1] - 2026-02-26

### Changed

- increased memory limits
- increased apc-global-overrides subchart version

## [1.5.0] - 2026-02-24

_([SPEXAPC-12787](https://aspecta.atlassian.net/browse/SPEXAPC-12787))_

### Fixed

- create CA from globals and use for trust

## [1.4.0] - 2025-09-29

...

## [1.0.0] - 2025-06-27

_Initial release._
