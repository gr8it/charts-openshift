# Changelog

## [1.0.0] - 2026-04-20

### Added

- Initial release
- `FlowCollector` (cluster-scoped singleton) — eBPF agent + processor s konfigurovateľnými resources a samplingom
- `LokiStack` pre ukladanie network flows (mode: `openshift-network`)
- `ObjectBucketClaim` pre S3 bucket (OCS/RHODF RGW)
- `ExternalSecret` pre S3 credentials z Vault (`<platform>/<env>/<namespace>/netobserv-s3`)
- `UIPlugin` (type: `NetworkObservability`) pre OpenShift Console integráciu
