# cluster-instance-hcp

Deploys a HyperShift Hosted Control Plane (HCP) cluster on an ACM hub cluster. Creates all hub-side resources: HostedCluster, NodePool, ManagedCluster, KlusterletAddonConfig, worker machine configs, and optional identity provider integrations.

## Prerequisites

- ACM with HyperShift enabled
- External Secrets Operator with a ClusterSecretStore pointing to Vault
- cert-manager with a ClusterIssuer configured
- `cluster-infraenv` chart deployed for the matching InfraEnv
- Configure `global.apc.services.externalSecretsOperator.defaultClusterSecretStore`, `global.apc.services.vault.KVmountPlatform`, and `global.apc.environmentShort` for the Vault ExternalSecrets.
- Provision the pull secret in Vault at `<KVmountPlatform>/<environmentShort>/hcp/<clusterName>/pullSecret` with the `.dockerconfigjson` property. This secret is required for every cluster.
- For each configured identity provider that references a credential secret, provision a Vault secret at `<KVmountPlatform>/<environmentShort>/hcp/<clusterName>/identityProvider/<secretName>`. The `<secretName>` must match the name in the identity provider configuration. Required Vault properties by provider type:

  | Identity provider type | Vault properties |
  |---|---|
  | LDAP | `bindPassword` |
  | HTPasswd | `fileData` |
  | Keystone | `tlsClientCert` and `tlsClientKey` |
  | BasicAuth, GitHub, GitLab, Google, OpenID | `clientSecret` |

  These identity-provider secrets are required only when the corresponding provider credential reference is configured.

## Values

| Parameter | Description | Default |
|---|---|---|
| `clusterName` | HCP cluster name (namespace, infraID, ManagedCluster name). **Required.** | — |
| `clusterSet` | ACM ManagedClusterSet label | `default` |
| `releaseImage` | OCP release image FQDN with tag | `quay.io/openshift-release-dev/ocp-release:4.17.11-multi` |
| `channel` | OCP update channel; omitted from the HostedCluster when empty | `eus-4.18` |
| `apiServerAuditProfile` | HostedCluster API server audit profile (`None`, `Default`, `WriteRequestBodies`, or `AllRequestBodies`) | `Default` |
| `infrastructureNamespace` | Infra namespace override; defaults to `infrastructure-<clusterName>` | `""` |
| `etcd.storageClassName` | StorageClass for ETCD PV | `lvms-vg1` |
| `etcd.storageSize` | ETCD PV size | `8Gi` |
| `etcd.backup.enabled` | Create resources for scheduled Hosted Control Plane etcd backups | `false` |
| `etcd.backup.schedule` | Cron schedule for etcd backups | `"0 0 * * *"` |
| `etcd.backup.paused` | Suspend the etcd backup CronJob | `false` |
| `etcd.backup.retentionDays` | Number of days to retain snapshots in object storage | `3` |
| `etcd.backup.etcdStatefulSetName` | Hosted Control Plane etcd StatefulSet name | `etcd` |
| `etcd.backup.compressSnapshot` | Compress etcd snapshots before upload | `false` |
| `etcd.backup.objectBucketClaim.create` | Create an ObjectBucketClaim for storing etcd backups | `false` |
| `etcd.backup.objectBucketClaim.name` | ObjectBucketClaim name; defaults to `etcd-hcp-<clusterName>-backup` | `""` |
| `etcd.backup.objectBucketClaim.storageClass` | StorageClass used when creating the ObjectBucketClaim | `ocs-storagecluster-ceph-rgw` |
| `nodePool.replicas` | Number of worker nodes | `2` |
| `nodePool.upgradeType` | Upgrade strategy (`InPlace` or `Replace`) | `InPlace` |
| `nodePool.autoRepair` | Enable automatic node repair | `false` |
| `nodePool.nodeLabels` | Labels applied to worker nodes | `{}` |
| `kubeletConfig` | KubeletConfig settings applied to worker nodes | see `values.yaml` |
| `networking.clusterCIDR` | Pod network CIDR | `172.26.0.0/16` |
| `networking.clusterHostPrefix` | Host prefix for pod network | `21` |
| `networking.serviceCIDR` | Service network CIDR | `172.25.64.0/18` |
| `services.oauthPort` | NodePort for OAuthServer. **Required.** | — |
| `services.konnectivityPort` | NodePort for Konnectivity. **Required.** | — |
| `services.ignitionPort` | NodePort for Ignition. **Required.** | — |
| `services.oidcPort` | NodePort for OIDC. **Required.** | — |
| `backup.enabled` | Create a Velero Schedule for the HostedCluster namespace | `false` |
| `backup.schedule` | Cron schedule for the Velero backup | `"0 0 * * *"` |
| `backup.paused` | Pause the Velero Schedule | `false` |
| `backup.ttl` | Backup retention duration as a Go duration, e.g. `168h0m0s` for seven days | `"336h0m0s"` |

## Features

### Velero backup

When `backup.enabled` is true, creates a Velero Schedule and resource-policy ConfigMap in the `openshift-adp` namespace. The schedule backs up the HostedCluster's namespace and its related `<clusterName>-<clusterName>` and `klusterlet-<clusterName>` namespaces. The resource policy skips selected bootstrap kubeconfig Secrets. Velero/OADP must be installed.

### Hosted Control Plane etcd backup

When `etcd.backup.enabled` is true, creates a CronJob and the required scripts ConfigMap, ServiceAccount, Role, RoleBinding, NetworkPolicy, and PrometheusRule for etcd snapshots. Backups are uploaded to an S3-compatible ObjectBucketClaim in the release namespace; by default the claim must already exist and be named `etcd-hcp-<clusterName>-backup`. Set `etcd.backup.objectBucketClaim.create: true` to have the chart create it. The CronJob accesses the Hosted Control Plane etcd StatefulSet in the conventional `<clusterName>-<clusterName>` namespace. The `etcd.backup` settings are independent of the Velero `backup` settings.

### `apiServerCert`

Creates a cert-manager `Certificate` for the API server TLS, with SANs `api.<clusterName>.<rootDomain>` and `oauth.<clusterName>.<rootDomain>`. Configures `namedCertificates` in the HostedCluster. Requires `global.apc.services.certManager.defaultClusterIssuer`.

### `adIntegration`

Deprecated. Legacy Active Directory configuration is no longer used by the HostedCluster OAuth. Configure providers with `global.apc.identityProviders`.

### `ldapIntegration`

Deprecated. Legacy LDAP configuration is no longer used by the HostedCluster OAuth. Configure providers with `global.apc.identityProviders`.

### `identityProviders`

Configures the HostedCluster OAuth identity providers using OpenShift OAuth provider entries. LDAP entries receive the same default attribute mappings as the `cluster-config-standalone` OAuth template. When identity providers are configured, the chart creates an `oauth-idp-ca-bundle` ConfigMap from `global.apc.caCertificates`; LDAP and OpenID providers reference this shared bundle.

Creates an ExternalSecret for each identity-provider secret reference supported by `cluster-config-standalone`. Secrets are retained when the ExternalSecret is removed.

### Image registry mirroring

Enabled when `global.apc.imageProxy.host` is set. Creates `registry-ca-bundle` ConfigMap and `machineconfig-mirror-registries`. Adds `imageContentSources` to the HostedCluster.

### Proxy

Enabled when `global.apc.proxy` is set. Creates `user-ca-bundle` ConfigMap from `global.apc.caCertificates`. Configures proxy settings in the HostedCluster.

### `kubeletConfig`

Applies the configured Kubelet settings to worker nodes. Set `kubeletConfig.autoSizingReserved: true` to have system resource reservations calculated automatically from each node's capacity. This is useful when worker nodes have different sizes or you want to avoid maintaining fixed `systemReserved` values; use manual reservations when workloads need more specific amounts. This chart explicitly defaults `autoSizingReserved` to `false`, so automatic reservation must be enabled here even though OpenShift 4.21 enables it by default on newly installed clusters. Clusters upgraded from earlier OpenShift versions may also have automatic reservation disabled.

See the [OpenShift node resource configuration documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/nodes/working-with-nodes#nodes-nodes-resources-configuring-setting_nodes-nodes-resources-configuring) and Red Hat's [recommended system reservation values](https://access.redhat.com/solutions/5843241).

## Global values used

| Global value | Description |
|---|---|
| `global.apc.cluster.rootDomain` | **Required.** Base domain for the HCP cluster (e.g. `cloud.example.com`) |
| `global.apc.sshAuthorizedKeys` | Optional list of SSH public keys for worker nodes |
| `global.apc.ntpServers` | NTP server list for worker chrony config |
| `global.apc.proxy` | HTTP/HTTPS proxy URL |
| `global.apc.noProxy` | noProxy list injected into InfraEnv, ensure to list all primary internal and node-level subnets,127.0.0.1 and localhost,169.254.169.254 - for Cloud Provider IaaS,.svc and .cluster.local,Internal API Server URL,CNI Service CIDR,CNI Pod CIDR, 172.20.0.1- [KB 7127777](https://access.redhat.com/solutions/7127777) |
| `global.apc.caCertificates` | CA certificates bundle |
| `global.apc.imageProxy.host` | Mirror registry hostname (enables image mirroring) |
| `global.apc.imageProxy.sources` | Source registries to mirror |
| `global.apc.identityProviders` | OpenShift OAuth identity provider list |
| `global.apc.services.externalSecretsOperator.defaultClusterSecretStore` | **Required.** ClusterSecretStore for ExternalSecrets |
| `global.apc.services.vault.KVmountPlatform` | **Required.** Vault KV mount path prefix |
| `global.apc.services.certManager.defaultClusterIssuer` | **Required.** ClusterIssuer for API server certificate |
| `global.apc.environmentShort` | **Required.** Environment short name used in Vault paths |

## Services

The API server is published through a LoadBalancer. OAuthServer, Konnectivity, Ignition, and OIDC use NodePort with addresses based on `<service>.<clusterName>.<rootDomain>` and the configured ports. Ensure DNS and network/firewall rules route these endpoints to the intended cluster; NodePort ports must be unique for clusters sharing the hub.
