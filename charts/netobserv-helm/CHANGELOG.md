# Changelog

## [1.0.0] - 2026-04-20

### Added

- Initial release
- `FlowCollector` (cluster-scoped singleton) — eBPF agent + processor with configurable resources and sampling
- `LokiStack` for storing network flows (mode: `openshift-network`)
- `ObjectBucketClaim` for S3 bucket (OCS/RHODF RGW)
- `ExternalSecret` for S3 credentials from Vault (`<platform>/<env>/<namespace>/netobserv-s3`)
