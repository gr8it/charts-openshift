# Veeam Exporter

This chart manages only the OpenShift-side resources for the Veeam exporter setup. It renders a `GrafanaDashboard` and a `PrometheusRule` for metrics that are pushed from the Windows Veeam server into Pushgateway.

## Rendered resources

- `GrafanaDashboard` for Veeam Backup monitoring
- `PrometheusRule` alerts for Veeam Backup job and repository health

It does not package or render the Windows exporter scripts. Those belong to the Windows-side exporter project and deployment workflow.

## Windows exporter

Upstream exporter project:

- [gr8it/veeam-prometheus-exporter](https://github.com/gr8it/veeam-prometheus-exporter)

Exporter flow:

1. Windows scheduled task runs the PowerShell exporter on the Veeam server.
2. The exporter reads its local `CONFIG.ps1`.
3. The exporter pushes metrics to Prometheus Pushgateway.
4. OpenShift Prometheus scrapes Pushgateway.
5. Grafana dashboard and Prometheus alerts are managed by this Helm chart.

Customer-specific Windows configuration such as `GROUP`, `BASE_URL`, task interval, credentials, and token handling must stay with the Windows exporter deployment, not in this shared chart.

## Timing alignment

Keep these intervals aligned:

- Windows scheduled task interval in the upstream exporter deployment
- `JobRunVisualizationWindowSeconds` in the Windows exporter configuration
- Grafana Status History panel interval in the dashboard JSON

For the current dashboard, the Grafana query interval is `30m`, so the Windows task interval should usually match that cadence.

## Alert rules

The chart renders alerts for:

- scheduled backup failed or warning
- backup repository over 80 percent full
- no Veeam metrics for 2 hours
- no backup completed for 2 days

The `customerName` alert label is taken from `apc-global-overrides.customer`.
