# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-08-24

- Removed `NodeNetworkConfigurationPolicy` rendering (out of scope, not a good fit for GitOps with nmstate).
- Hardcoded the `openshift-storage` namespace for `additionalNetworks` and `StorageCluster`.
- `MachineConfig` is now controlled by a single `enabled` boolean, with content rendered directly in the template; the hosted-cluster ConfigMap vs. direct-apply choice is now driven by `apc-global-overrides.clusterIsHub` instead of a separate values flag, and the ConfigMap namespace is derived from `apc-global-overrides.clusterName`.

## [1.0.0] - 2026-08-17

_Initial release._
