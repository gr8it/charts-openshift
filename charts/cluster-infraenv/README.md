# cluster-infraenv

Deploys an `InfraEnv` and related resources for a Hosted Control Plane (HCP) cluster. Installs on the ACM hub cluster and manages bare-metal agent discovery for an HCP deployment using the Agent platform.

## Prerequisites

- ACM with HyperShift and Assisted Service (agent-install.openshift.io CRDs)
- External Secrets Operator with a ClusterSecretStore pointing to Vault
- The pull-secret for Red Hat private registries in Vault secret `apc-platform/<env-short-name>/infraenv/infrastructure-<envName>`, key `.dockerconfigjson`

## Values

| Parameter | Description | Default |
|---|---|---|
| `envName` | Environment name. **Required.** | `""` |
| `agentEnvironment` | Agent label environment override. Defaults to `envName` when omitted. | `""` |
| `infraEnvName` | Name used for the InfraEnv, Namespace, and NMStateConfig selector. | `infrastructure-{{ .envName }}` |
| `cpuArchitecture` | CPU architecture for agent discovery | `x86_64` |
| `ipxeScriptType` | iPXE script type | `DiscoveryImageAlways` |
| `osImageVersion` | **Required.** OpenShift version for the InfraEnv OS image. It must match an OpenShift version available in the AgentServiceConfig OS image list. For single-node clusters on OpenShift versions before 4.16, use the cluster version. Do not set this together with `ClusterRef`. [Documentation](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.10/html/clusters/cluster_mce_overview#create-host-inventory-cli) | — |
| `nmStateConfigs` | Per-node static network configurations, i.e. nmstateconfig CR **Required.**| `[]` |
| `nmStateConfigs.name` | nmstateconfig.metadata.name **Required.**| `""` |
| `nmStateConfigs.config` | nmstateconfig.spec.config **Required.**| `{}` |
| `nmStateConfigs.interfaces` | nmstateconfig.spec.interfaces **Required.**| `[]` |

## Global values used

| Global value | Description |
|---|---|
| `global.apc.proxy` | HTTP/HTTPS proxy URL injected into InfraEnv |
| `global.apc.noProxy` | noProxy list injected into InfraEnv, ensure to list all primary internal and node-level subnets,127.0.0.1 and localhost,169.254.169.254 - for Cloud Provider IaaS,.svc and .cluster.local,Internal API Server URL,[HCP serviceCIDR](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22/html/networking_overview/cidr-range-definitions#hcp-cidr-ranges_cidr-range-definitions) |
| `global.apc.environmentShort` | Environment short name used in Vault paths |
| `global.apc.ntpServers` | NTP servers to be used |
| `global.apc.sshAuthorizedKeys` | List of SSH public keys to be added to authorized_keys |
| `global.apc.services.externalSecretsOperator.defaultClusterSecretStore` | ClusterSecretStore for ExternalSecret |
| `global.apc.services.vault.KVmountPlatform` | Vault KV mount path prefix |

## NMStateConfig structure

Each entry in `nmStateConfigs` creates one `NMStateConfig` resource:

```yaml
nmStateConfigs:
  - name: my-node-hostname
    interfaces:
      - macAddress: "aa:bb:cc:dd:ee:ff"
        name: ens7f0np0
      - macAddress: "aa:bb:cc:dd:ee:ff"
        name: ens13f0np0
    config:          # raw nmstate network config
      interfaces: [...]
      dns-resolver: {...}
      routes: {...}
```
