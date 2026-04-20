# Changelog

## [1.0.0] - 2026-04-20

### Added

- Initial release
- `ClusterMonitoringConfig` ConfigMap (openshift-monitoring) — parametrizovaný per-cluster (UUID, retention, storage, externalLabels)
- `UserWorkloadMonitoringConfig` ConfigMap (openshift-user-workload-monitoring) — s voliteľným remoteWrite
- `ExternalSecret` pre `alertmanager-main` cez ESO/Vault s target.template
- `ExternalSecret` pre `alertmanager-user-workload` cez ESO/Vault s target.template
- Hub-specific receivers (`atlassian_aspecta_security`, `atlassian_aspecta_logs`) podmienené cez `hub.enabled`
- `PrometheusRule` WatchdogUWMthanos pre apc-observability namespace
- `AlertingRule` PodRepeatedOOMKilled pre cluster monitoring
- `NetworkPolicy` pre proxy egress v openshift-monitoring + openshift-user-workload-monitoring
