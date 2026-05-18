# Changelog

## [1.0.0] - 2026-04-20

### Added

- Initial release (renamed from `netobserv-helm`)
- `Namespace` with `apc.namespace.type: platform` and `openshift.io/cluster-monitoring: "true"` labels
- `NetworkPolicy` for flowlogs-pipeline (eBPF agent ingress on port 2055)
- `NetworkPolicy` for netobserv-plugin (console UI ingress on port 9001)
- `LokiStack` for network flow storage (mode: `openshift-network`)
- `ObjectBucketClaim` for S3 bucket (OCS/RHODF RGW)
- `FlowCollector` with eBPF agent and configurable resources and sampling
