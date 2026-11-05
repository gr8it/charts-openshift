# odf-config

This chart renders full ODF cluster configuration that is applied after the ODF operator is installed:

- a dedicated `NodeNetworkConfigurationPolicy` (`odf-network`) for the host interfaces the ODF network needs (bond/VLAN), rendered only when `nodeNetworkConfigurationPolicy.interfaces` is set;
- a `NetworkAttachmentDefinition` per `additionalNetworks` entry (namespace fixed to `openshift-storage`), used as the Multus network of the `StorageCluster`;
- `StorageCluster`, `StorageSystem`, `LocalVolumeDiscovery` and one `LocalVolumeSet` per `storageCluster.localVolumeSetCount`;
- optional host `MachineConfig` enabling promiscuous mode on the ODF bond interface, rendered directly on standalone clusters or as a ConfigMap for hosted-cluster distribution on hub clusters (`apc-global-overrides.clusterIsHub`).

`StorageCluster`/`StorageSystem`/`LocalVolumeDiscovery`/`LocalVolumeSet` and the device sets they imply are fully owned by this chart (normal apply, not server-side); only `storageCluster.name`, `nodeCount`, `localVolumeSetCount`, `deviceMinSize`, `resourceProfile`, `resources` and `cephCluster` are configurable, everything else follows the fixed spec observed across existing ODF clusters. `deviceMinSize` defaults to `6000Gi` and `resourceProfile` defaults to `balanced` (the values observed on most clusters at the time of writing) — override either in the conf repo for clusters that differ (e.g. smaller QA disks, or a `performance` profile).

The `StorageCluster` network selector is derived from the first `additionalNetworks` entry's name. The NADs are created directly (not via the Cluster Network Operator), so the `Network/cluster` object and the CNV networks in it are not touched; an `odf` entry that already exists in `Network/cluster.spec.additionalNetworks` (static manifests) must be removed there when this chart takes over, otherwise the CNO keeps recreating its own NAD of the same name.

The `odf-network` NNCP only manages ODF's own interfaces; other host network config belongs in its own NNCP. nmstate does not remove an interface when it disappears from the spec: to remove one, set `state: absent` on it, let it sync, then delete the entry from values. This is a rare, manual-in-git step.

Set cluster-specific values in the conf repo; see [values.example.yaml](values.example.yaml). `nodeCount` and `localVolumeSetCount` must match the actual ODF node/local-volume-set count on the cluster (compare against `oc get storagecluster ocs-storagecluster -oyaml` before rollout).
