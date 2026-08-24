# odf-config

This chart renders ODF cluster configuration that is applied after the ODF operator is installed:

- ODF entries in `Network/cluster.spec.additionalNetworks` (namespace fixed to `openshift-storage`);
- partial `StorageCluster.spec.resources` overrides;
- optional host `MachineConfig` enabling promiscuous mode on the ODF bond interface, rendered directly on standalone clusters or as a ConfigMap for hosted-cluster distribution on hub clusters (`apc-global-overrides.clusterIsHub`).

`Network/cluster.spec.additionalNetworks` is co-owned: this chart only ever sets its own entries via server-side apply (merge-keyed by `name`), so other owners (e.g. `openshift-virtualization-config`'s CNV entries) are left intact.

Host network interfaces required by the ODF additional network (e.g. bonds/VLANs via `NodeNetworkConfigurationPolicy`) are out of scope for this chart and must be configured separately.

Set cluster-specific values in the conf repo; see [values.example.yaml](values.example.yaml).
