# odf-config

This chart renders ODF cluster configuration that is applied after the ODF operator is installed:

- host network interfaces via `NodeNetworkConfigurationPolicy`;
- ODF entries in `Network/cluster.spec.additionalNetworks`;
- partial `StorageCluster.spec.resources` overrides.
- optional host `MachineConfig` setup, either directly or as a hosted-cluster ConfigMap.

`Network/cluster.spec.additionalNetworks` is co-owned: this chart only ever sets its own entries via server-side apply (merge-keyed by `name`), so other owners (e.g. `openshift-virtualization-config`'s CNV entries) are left intact. Set cluster-specific values in the conf repo; see [values.example.yaml](values.example.yaml).
