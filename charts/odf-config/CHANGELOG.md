# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-17

_Initial release._

- `additionalNetworks`, `StorageCluster`, `StorageSystem`, `LocalVolumeDiscovery` and `LocalVolumeSet` rendering.
- Dedicated `odf-network` `NodeNetworkConfigurationPolicy` for ODF host interfaces.
- Optional promiscuous-mode `MachineConfig`; on hub clusters (`apc-global-overrides.clusterIsHub`) it is rendered as a ConfigMap for hosted clusters.
