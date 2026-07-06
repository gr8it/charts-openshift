# vector-helm

Helm chart for deploying [Vector](https://vector.dev/) as a log/event collector on OpenShift clusters managed by Aspecta Private Cloud.

## Prerequisites

### 1. Vault secret — SIEM token

Before deploying, create the SIEM token in Vault. The chart reads it via ExternalSecret using the path:

```
<vaultKVmountPlatform>/<environmentShort>/vector/siem-token
```

Example for `apc-platform` mount, `h` environment:

```
vault kv put apc-platform/h/vector/siem-token token=<your-splunk-hec-token>
```

The ExternalSecret syncs this into a Kubernetes Secret named `siem-token` in the release namespace. Deployment will fail if the Vault path does not exist.

### 2. External DNS record

The certificate issued for Vector includes the cluster-external FQDN:

```
vector.<clusterBaseDomain>
```

This DNS record **must be created manually** and pointed at the MetalLB VIP configured in `vectorMetalLB.addresses`. The chart does not create DNS records.

## Configuration

Key values to set per environment (in the conf repo, not in this chart):

| Value | Description |
|---|---|
| `vectorMetalLB.addresses` | MetalLB VIP CIDR for the Vector LoadBalancer service |
| `vectorSiem.endpoint` | SIEM HEC endpoint URL |
| `vectorNetworkPolicy.syslogUdpCidrs` | CIDRs allowed to send UDP syslog |
| `vectorNetworkPolicy.syslogTcpCidrs` | CIDRs allowed to send TCP syslog |
| `vectorNetworkPolicy.webhookCidrs` | CIDRs allowed to reach the webhook port |
| `vectorServiceCertificate.additionalDnsNames` | Extra SANs for the service certificate. The chart already includes the in-cluster svc names and `vector.<clusterBaseDomain>`; set this only when clients reach Vector via other DNS names |
| `vector.fullnameOverride` | Set in conf repo when legacy resource names must be preserved for ArgoCD adoption |

## Vault path convention

```
<vaultKVmountPlatform>/<environmentShort>/vector/siem-token  →  key: token
```
