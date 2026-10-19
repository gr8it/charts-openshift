# cluster-instance-hcp

Deploys a HyperShift Hosted Control Plane (HCP) cluster on an ACM hub cluster. Creates all hub-side resources: HostedCluster, NodePool, ManagedCluster, KlusterletAddonConfig, worker machine configs, and optional identity provider integrations.

## Prerequisites

- ACM with HyperShift enabled
- External Secrets Operator with a ClusterSecretStore pointing to Vault
- cert-manager with a ClusterIssuer configured
- `cluster-infraenv` chart deployed for the matching InfraEnv
- Pull secret provisioned in Vault at `<KVmountPlatform>/<environmentShort>/hcp/<clusterName>/pullSecret` with property `.dockerconfigjson`
- Identity provider secrets provisioned in Vault at `<KVmountPlatform>/<environmentShort>/hcp/<clusterName>/identityProvider/<secretName>`. The property is `bindPassword` for LDAP and `clientSecret` for OpenID.

## Values

| Parameter | Description | Default |
|---|---|---|
| `clusterName` | HCP cluster name (namespace, infraID, ManagedCluster name). **Required.** | — |
| `clusterSet` | ACM ManagedClusterSet label; defaults to `clusterName` with trailing digits removed | `""` |
| `releaseImage` | OCP release image FQDN with tag | `quay.io/openshift-release-dev/ocp-release:4.17.11-multi` |
| `channel` | OCP update channel | `eus-4.18` |
| `infrastructureNamespace` | Infra namespace override; defaults to `infrastructure-<clusterName>` | `""` |
| `etcd.storageClassName` | StorageClass for ETCD PV | `lvms-vg1` |
| `etcd.storageSize` | ETCD PV size | `8Gi` |
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

## Features

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

## Global values used

pridat required flag ku vsetkemu, co je naozaj required ????????????????????????

| Global value | Description |
|---|---|
| `global.apc.cluster.rootDomain` | Base domain for the HCP cluster (e.g. `cloud.example.com`) |
| `global.apc.sshAuthorizedKeys` | List of SSH public keys for worker nodes **required** |
| `global.apc.ntpServers` | NTP server list for worker chrony config |
| `global.apc.proxy` | HTTP/HTTPS proxy URL |
| `global.apc.noProxy` | noProxy list |
| `global.apc.caCertificates` | CA certificates bundle |
| `global.apc.imageProxy.host` | Mirror registry hostname (enables image mirroring) |
| `global.apc.imageProxy.sources` | Source registries to mirror |
| `global.apc.adIntegration` | Deprecated Active Directory IDP config |
| `global.apc.ldapIntegration` | Deprecated Bastion LDAP IDP config |
| `global.apc.identityProviders` | OpenShift OAuth identity provider list |
| `global.apc.services.externalSecretsOperator.defaultClusterSecretStore` | ClusterSecretStore for ExternalSecrets |
| `global.apc.services.vault.KVmountPlatform` | Vault KV mount path prefix |
| `global.apc.services.certManager.defaultClusterIssuer` | ClusterIssuer for API server certificate |
| `global.apc.environmentShort` | Environment short name used in Vault paths |

## Services

popisat: ?????????????????????????

- API = LB, zvysok NodePort
- kvoli bezpecnosti, t.j. aby prod, test, dev, nehovorili na rovnake endpointy = dev nemohol dotazovat prod!
