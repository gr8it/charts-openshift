# Veeam Exporter

This chart manages only the OpenShift-side monitoring resources for Veeam Backup metrics.

## Rendered resources

- `GrafanaDashboard` for Veeam Backup monitoring
- `PrometheusRule` alerts for Veeam Backup job and repository health

The chart does not package, render, or deploy exporter runtime files. It expects Veeam metrics to already be available in Prometheus through Pushgateway.

## Related exporter project

- [gr8it/veeam-prometheus-exporter](https://github.com/gr8it/veeam-prometheus-exporter)

## Timing alignment

Keep these intervals aligned between the metrics producer and dashboard:

- Grafana Status History panel interval in the dashboard JSON
- the Veeam job metric reporting interval

For the current dashboard, the Grafana query interval is `30m`, so the reporting interval should usually match that cadence.

## Alert rules

The chart renders alerts for:

- scheduled backup failed or warning
- backup repository over 80 percent full
- no Veeam metrics for 2 hours
- no backup completed for 2 days

The `customerName` alert label is taken from `apc-global-overrides.customer`.
