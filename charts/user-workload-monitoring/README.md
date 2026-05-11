# user-workload-monitoring

Helm chart to configure OpenShift user workload monitoring for APC-managed clusters.

## Overview

Deploys and configures the `UserWorkloadMonitoringConfig` and supporting resources for the `openshift-user-workload-monitoring` namespace. Designed for hub and spoke clusters managed via ArgoCD GitOps.

## Deployed resources

| Resource | Namespace | Description |
|---|---|---|
| `ConfigMap/user-workload-monitoring-config` | `openshift-user-workload-monitoring` | Configures UWM Prometheus (retention, storage, remoteWrite, externalLabels) and ThanosRuler storage |
| `ExternalSecret/alertmanager-uwm-receivers` | `openshift-user-workload-monitoring` | Pulls AlertManager credentials from Vault via ESO (`dataFrom.extract`) |
| `Secret/alertmanager-user-workload` | `openshift-user-workload-monitoring` | AlertManager configuration with file-based credential references |
| `PrometheusRule/watchdog-uwm-thanos` | `apc-observability` | Heartbeat alert for UWM Thanos Ruler + Prometheus pipeline |
| `NetworkPolicy` | `openshift-user-workload-monitoring` | Allows proxy egress for AlertManager and remoteWrite traffic |
| `openshift-adp-backups` (subchart) | `openshift-adp` | Velero backup schedules for monitoring PVCs (optional) |

## Dependencies

- `apc-global-overrides` — global cluster values (customer, environment, cluster name, proxy, ESO store)
- `openshift-adp-backups` — optional, enabled via `backups.enabled: true`

## Key values

| Value | Default | Description |
|---|---|---|
| `alertmanager.eso.vault.secretPath` | `""` | Required. Full Vault path to the alertmanager credentials secret |
| `userWorkloadMonitoring.prometheus.retention` | `14d` | Prometheus retention period |
| `userWorkloadMonitoring.prometheus.remoteWrite.enabled` | `true` | Enable Red Hat telemetry remoteWrite |
| `backups.enabled` | `false` | Enable Velero backup schedules |

## Usage

```yaml
# values.yaml (environment-specific overrides only)
global:
  apc:
    customer: mycustomer
    environment: prod
    cluster:
      name: prod01
    proxy: http://proxy.example.com:8080
    noProxy: .example.com,.svc,.cluster.local,localhost,127.0.0.1
    services:
      externalSecretsOperator:
        defaultClusterSecretStore: apc

alertmanager:
  eso:
    vault:
      secretPath: customers/mycustomer/monitoring/alertmanager-uwm

backups:
  enabled: true
```
