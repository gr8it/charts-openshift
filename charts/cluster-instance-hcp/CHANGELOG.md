All notable changes to this component will be documented in this file.
The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-15

### Changed

- Configure HostedCluster OAuth identity providers from `global.apc.identityProviders`.
- Create ExternalSecrets for configured identity-provider secret references.
- Create a shared OAuth identity-provider CA bundle ConfigMap for configured providers.
- Render LDAP identity providers in the HostedCluster OAuth API format and reference their bind-password secrets.
- Read worker SSH keys from the `global.apc.sshAuthorizedKeys` list

## [1.0.0] - 2026-08-03

_Initial release._
