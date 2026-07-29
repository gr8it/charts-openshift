# cluster-instance-hcp

Deploys a HyperShift Hosted Control Plane (HCP) cluster on an ACM hub cluster. Creates all hub-side resources: HostedCluster, NodePool, ManagedCluster, KlusterletAddonConfig, worker machine configs, and optional identity provider integrations.

## Prerequisites

- ACM with HyperShift enabled
- External Secrets Operator with a ClusterSecretStore pointing to Vault
- `cluster-infraenv` chart deployed for the matching InfraEnv
- Required Vault secrets provisioned before deployment ############### TOTO SU KTORE !? VYPISAT

## Values

| Parameter | Description | Default |
|---|---|---|
| `clusterName` | HCP cluster name (namespace, infraID, ManagedCluster name). **Required.** | `""` |
| `clusterSet` | ACM ManagedClusterSet label | `""` |
| `releaseImage` | OCP release image FQDN with tag | `quay.io/openshift-release-dev/ocp-release:4.17.11-multi` |
| `baseDomain` | DNS base domain for the HCP cluster. **Required.** | `""` |
| `infrastructureNamespace` | Infra namespace override; defaults to `infrastructure-<clusterName>` | `""` |
| `etcd.storageClassName` | StorageClass for ETCD PV. **Required.** | `""` |
| `etcd.storageSize` | ETCD PV size | `8Gi` |
| `nodePool.replicas` | Number of worker nodes | `2` |
| `nodePool.upgradeType` | Upgrade strategy (`InPlace` or `Replace`) | `InPlace` |
| `nodePool.autoRepair` | Enable automatic node repair | `false` |
| `nodePool.nodeLabels` | Labels applied to worker nodes | `{}` |
| `networking.clusterCIDR` | Pod network CIDR | `172.26.0.0/16` |
| `networking.clusterHostPrefix` | Host prefix for pod network | `21` |
| `networking.serviceCIDR` | Service network CIDR | `172.25.64.0/18` |
| `networking.networkType` | CNI type | `OVNKubernetes` |
| `services.oauthPort` | NodePort for OAuthServer | `30102` |
| `services.konnectivityPort` | NodePort for Konnectivity | `30103` |
| `services.ignitionPort` | NodePort for Ignition | `30104` |
| `services.oidcPort` | NodePort for OIDC | `30101` |
| `ntpServers` | NTP servers for worker chrony config | `[]` |
| `vault.pullSecretKey` | Vault key for cluster pull secret. **Required.** | `""` |
| `vault.sshKeyKey` | Vault key for SSH public key. **Required.** | `""` |

## Feature flags

### `proxy.enabled`

Enables proxy configuration in the HostedCluster. Creates a `user-ca-bundle` ConfigMap from `global.apc.caCertificates`. Proxy URLs are taken from `global.apc.proxy` and `global.apc.noProxy`.

### `apiServerCert.enabled`

Creates an ExternalSecret for a custom API server TLS certificate and configures `namedCertificates` in the HostedCluster.

| Parameter | Description |
|---|---|
| `apiServerCert.names` | SANs; defaults to `api.<clusterName>.<baseDomain>` |
| `apiServerCert.vaultKey` | Vault key path. **Required when enabled.** |
| `apiServerCert.vaultTLSCrt` | Property name for the certificate | 
| `apiServerCert.vaultTLSKey` | Property name for the private key |

### `imageProxy.enabled`

Enables image registry mirroring. Creates `registry-ca-bundle` ConfigMap and `machineconfig-mirror-registries`. Adds `imageContentSources` to the HostedCluster.

| Parameter | Description |
|---|---|
| `imageProxy.registryHost` | Mirror registry hostname. **Required when enabled.** |
| `imageProxy.sources` | Source registries to mirror |
| `imageProxy.caCert` | CA cert PEM for the registry; falls back to `global.apc.caCertificates` |

### `adIntegration.enabled`

Adds an Active Directory LDAP identity provider to the HostedCluster OAuth. Creates `ad-ldap-ca` ConfigMap and `ad-ldap-bind-secret` ExternalSecret.

### `ldapIntegration.enabled`

Adds a bastion LDAP identity provider to the HostedCluster OAuth. Creates `bastion-ldap-ca` ConfigMap and `bastion-ldap-bind-secret` ExternalSecret.

## Global values used

| Global value | Description |
|---|---|
| `global.apc.proxy` | HTTP/HTTPS proxy URL (used when `proxy.enabled`) |
| `global.apc.noProxy` | noProxy list (used when `proxy.enabled`) |
| `global.apc.caCertificates` | CA certificates bundle for user-ca-bundle and registry-ca-bundle fallback |
| `global.apc.services.externalSecretsOperator.defaultClusterSecretStore` | ClusterSecretStore for all ExternalSecrets |
| `global.apc.services.vault.KVmountPlatform` | Vault KV mount path prefix |
| `global.apc.environmentShort` | Environment short name used in Vault paths |
