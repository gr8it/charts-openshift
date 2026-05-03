# multi-cluster-observability

This chart packages ACM multi-cluster observability resources that were previously managed as static manifests.

## Included resources

- `MultiClusterObservability` (`observability.open-cluster-management.io/v1beta2`)
- `ObjectBucketClaim` for Thanos object storage
- Kyverno `Policy` generating the `thanos-object-storage` `Secret` from OBC-provided bucket data
- Metrics allowlist `ConfigMap` resources
- Grafana dashboard `ConfigMap` resources included from `files/grafana-dashboards/*.json`

## Values philosophy

The chart is intentionally opinionated. Static resource names, mandatory annotations, dashboard loading, and the `MultiClusterObservability` spec are kept in templates instead of being exposed as values.

Only values that are expected to vary between installations are exposed:

- metrics allowlist ConfigMap definitions

Environment-specific behavior should be handled through GitOps component values and shared APC global overrides.

Proxy-related network policies should be handled outside this chart by the cluster or component that owns those egress exceptions.

## Validation

```bash
gmake build CHARTFOLDER=multi-cluster-observability
```
