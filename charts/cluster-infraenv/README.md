# cluster-infraenv

Deploys an `InfraEnv` and related resources for a Hosted Control Plane (HCP) cluster. Installs on the ACM hub cluster and manages bare-metal agent discovery for an HCP deployment using the Agent platform.

## Prerequisites

- ACM with HyperShift and Assisted Service (agent-install.openshift.io CRDs)
- External Secrets Operator with a ClusterSecretStore pointing to Vault
- The pull-secret for Red Hat private registries in Vault secret `apc-platform/<env-short-name>/infraenv/infrastructure<envName>`, key `.dockerconfigjson`

## Values

| Parameter | Description | Default |
|---|---|---|
| `envName` | Environment name. **Required.** | `""` |
| `infraEnvName` | Name used for the InfraEnv, Namespace, and NMStateConfig selector. | `infrastructure-{{ .envName }}` |
| `cpuArchitecture` | CPU architecture for agent discovery | `x86_64` |
| `ipxeScriptType` | iPXE script type | `DiscoveryImageAlways` |
| `sshAuthorizedKey` | SSH public key injected into discovered agents. **Required.** | `""` |
| `ntpServers` | NTP server addresses for agents. **Required.** | `[]` |
| `nmStateConfigs` | Per-node static network configurations | `[]` |

## Global values used

| Global value | Description |
|---|---|
| `global.apc.proxy` | HTTP/HTTPS proxy URL injected into InfraEnv |
| `global.apc.noProxy` | noProxy list injected into InfraEnv |
| `global.apc.services.externalSecretsOperator.defaultClusterSecretStore` | ClusterSecretStore for ExternalSecret |
| `global.apc.services.vault.KVmountPlatform` | Vault KV mount path prefix |
| `global.apc.environmentShort` | Environment short name used in Vault paths |

## NMStateConfig structure

Each entry in `nmStateConfigs` creates one `NMStateConfig` resource:

```yaml
nmStateConfigs:
  - name: my-node-hostname
    macInterfaceMappings:
      - macAddress: "aa:bb:cc:dd:ee:ff"
        logicalNICName: ens7f0np0
      - macAddress: "aa:bb:cc:dd:ee:ff"
        logicalNICName: ens13f0np0
    networkConfig:          # raw nmstate network config
      interfaces: [...]
      dns-resolver: {...}
      routes: {...}
```
