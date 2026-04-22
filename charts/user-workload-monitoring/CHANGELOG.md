# Changelog

## [1.0.0] - 2026-04-20

### Added

- Initial release — split z `metrics-helm`, pokrýva len `openshift-user-workload-monitoring` namespace
- `UserWorkloadMonitoringConfig` ConfigMap — s voliteľným remoteWrite, thanosRuler storage
- `ExternalSecret` `alertmanager-uwm-receivers` cez ESO/Vault — credentials pre UWM AlertManager receivers (msteams, healthchecks, opsgenie) ako samostatné súbory
- `Secret` `alertmanager-user-workload` — UWM AlertManager config s file-based refs (`webhook_url_file`, `url_file`, `api_key_file`)
- `PrometheusRule` WatchdogUWMthanos pre `apc-observability` namespace
- `NetworkPolicy` pre proxy egress v `openshift-user-workload-monitoring`
- `openshift-adp-backups` ako subchart dependency (podmienený cez `backups.enabled`)
