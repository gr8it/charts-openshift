# Changelog

## [1.0.0] - 2026-04-20

### Added

- Initial release — split z `metrics-helm`, pokrýva len `openshift-monitoring` namespace
- `ClusterMonitoringConfig` ConfigMap — parametrizovaný per-cluster (UUID, retention, storage, externalLabels)
- `ExternalSecret` `alertmanager-receivers` cez ESO/Vault — credentials pre AlertManager receivers (msteams, healthchecks, opsgenie) ako samostatné súbory
- `Secret` `alertmanager-main` — AlertManager config s file-based refs (`webhook_url_file`, `url_file`, `api_key_file`)
- Hub-specific receivers (`atlassian_aspecta_security`, `atlassian_aspecta_logs`) podmienené cez `hub.enabled`
- `AlertingRule` PodRepeatedOOMKilled pre cluster monitoring
- `NetworkPolicy` pre proxy egress v `openshift-monitoring`
- `openshift-adp-backups` ako subchart dependency (podmienený cez `backups.enabled`)
