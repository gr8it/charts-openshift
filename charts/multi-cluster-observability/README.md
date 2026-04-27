# multi-cluster-observability

This chart packages ACM multi-cluster observability resources that were previously managed as static manifests.

## Included resources

- `MultiClusterObservability` (`observability.open-cluster-management.io/v1beta2`)
- `ObjectBucketClaim` for Thanos object storage
- Kyverno `Policy` generating Thanos bucket secret info
- Optional `NetworkPolicy` for egress control
- Metrics allowlist `ConfigMap` resources
- Grafana dashboard `ConfigMap` resources included from `files/grafana-dashboards/*.yaml`

## Values philosophy

The chart is opinionated by default. Only values that are likely to vary between environments/customers are exposed:

- enable/disable toggles per resource group
- object storage and policy target settings
- metrics allowlist ConfigMap definitions

Environment-specific enablement and overrides are expected to be handled in GitOps component values, not inside chart environment logic.

## Validation

```bash
gmake build CHARTFOLDER=multi-cluster-observability
```
