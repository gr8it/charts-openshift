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
| `infraEnvName` | Name used for the InfraEnv, Namespace, and NMStateConfig selector. | `infrastructure-{{ .envName }}` |
| `cpuArchitecture` | CPU architecture for agent discovery | `x86_64` |
| `ipxeScriptType` | iPXE script type | `DiscoveryImageAlways` |
| `nmStateConfigs` | Per-node static network configurations, i.e. nmstateconfig CR **Required.**| `[]` |
| `nmStateConfigs.name` | nmstateconfig.metadata.name **Required.**| `""` |
| `nmStateConfigs.config` | nmstateconfig.spec.config **Required.**| `{}` |
| `nmStateConfigs.interfaces` | nmstateconfig.spec.interfaces **Required.**| `[]` |

## Global values used

| Global value | Description |
|---|---|
| `global.apc.proxy` | HTTP/HTTPS proxy URL injected into InfraEnv |
| `global.apc.noProxy` | noProxy list injected into InfraEnv |
| `global.apc.environmentShort` | Environment short name used in Vault paths |
| `global.apc.ntpServers` | NTP servers to be used |
| `global.apc.sshAuthorizedKeys` | SSH public key(s) to be added to authorized_keys. One per line |
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
