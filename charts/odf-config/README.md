# odf-config

This chart renders full ODF cluster configuration that is applied after the ODF operator is installed:

- ODF entries in `Network/cluster.spec.additionalNetworks` (namespace fixed to `openshift-storage`);
- `StorageCluster`, `StorageSystem`, `LocalVolumeDiscovery` and one `LocalVolumeSet` per `storageCluster.localVolumeSetCount`;
- optional host `MachineConfig` enabling promiscuous mode on the ODF bond interface, rendered directly on standalone clusters or as a ConfigMap for hosted-cluster distribution on hub clusters (`apc-global-overrides.clusterIsHub`).

`StorageCluster`/`StorageSystem`/`LocalVolumeDiscovery`/`LocalVolumeSet` and the device sets they imply are fully owned by this chart (normal apply, not server-side); only `storageCluster.name`, `nodeCount`, `localVolumeSetCount`, `resources` and `cephCluster` are configurable, everything else follows the fixed spec observed across existing ODF clusters.

`Network/cluster.spec.additionalNetworks` is co-owned: this chart only ever sets its own entries via server-side apply (merge-keyed by `name`), so other owners (e.g. `openshift-virtualization-config`'s CNV entries) are left intact. The `StorageCluster` network selector is derived from the first `additionalNetworks` entry's name.

Host network interfaces required by the ODF additional network (e.g. bonds/VLANs via `NodeNetworkConfigurationPolicy`) are out of scope for this chart and must be configured separately.

Set cluster-specific values in the conf repo; see [values.example.yaml](values.example.yaml). `nodeCount` and `localVolumeSetCount` must match the actual ODF node/local-volume-set count on the cluster (compare against `oc get storagecluster ocs-storagecluster -oyaml` before rollout).
