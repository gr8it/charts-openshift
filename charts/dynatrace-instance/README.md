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

Configure `oneAgent`, `activeGate`, and `metadataEnrichment` only when their defaults need to change. Cluster and environment values are supplied through `global.apc` by the configuration repository.