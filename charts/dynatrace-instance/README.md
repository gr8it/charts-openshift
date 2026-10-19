# dynatrace-instance

Deploys a Dynatrace `DynaKube` resource and an `ExternalSecret` that supplies its API and data-ingest tokens.

## Prerequisites

- Dynatrace Operator installed in the target namespace.
- External Secrets Operator configured with the default ClusterSecretStore supplied through `apc-global-overrides`.
- A Vault entry at `<KVmountPlatform>/<environmentShort>/apc-dynatrace/token` containing `apiToken` and `dataIngestToken`.

## Install or upgrade

```bash
helm upgrade --install dynatrace-instance charts/dynatrace-instance \
  --namespace dynatrace \
  --values values.example.yaml
```

## Uninstall

```bash
helm uninstall dynatrace-instance --namespace dynatrace
```

## Configuration

Set `apiUrl` to the Dynatrace environment API URL. The token Secret is created by the chart's `ExternalSecret` and is always named after the Helm release.

| Value | Default | Description |
|---|---|---|
| `apiUrl` | `""` | Dynatrace environment API URL. Must be set. |
| `hostGroup` | `""` | Dynatrace host group. When empty, defaults to `os-` followed by the cluster name, or the Helm release name if no cluster name is configured. |
| `annotations` | `{}` | Additional annotations applied to the DynaKube resource. |
| `skipCertCheck` | `false` | Whether to skip TLS certificate validation for the Dynatrace API connection. |
| `metadataEnrichment.enabled` | `false` | Enables DynaKube metadata enrichment. |
| `activeGate` | See [`values.yaml`](./values.yaml) | ActiveGate configuration, including capabilities, image, and resource requests and limits. |
| `externalSecret.refreshInterval` | `1h` | Interval for refreshing Dynatrace tokens from the external secret store. |

Configure trusted CA certificates with `global.apc.caCertificates`. The chart stores them in a release-named ConfigMap and references that ConfigMap from the DynaKube; the `trustedCAs` value is not configurable.

To include an application's namespace in Dynatrace application monitoring, label the namespace with `apc.namespace.telemetry=external-dynatrace`:

```bash
oc label namespace <namespace> apc.namespace.telemetry=external-dynatrace
```

Configure `activeGate` and `metadataEnrichment` only when their defaults need to change. Cluster and environment values are supplied through `global.apc` by the configuration repository.
