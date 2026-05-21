# Veeam Exporter

This chart takes over the OpenShift/Grafana-operator part of the Veeam Prometheus exporter setup.

## Rendered resources

The chart renders only Kubernetes/OpenShift resources that Argo CD should manage:

- `GrafanaDashboard` for Veeam Backup & Replication v12 monitoring
- `PrometheusRule` alerts for Veeam Backup job/reporting health

It must not render the Windows exporter scripts as a `ConfigMap`, `Secret`, or any other cluster resource. Those scripts are consumed on the Veeam Backup server, not inside OpenShift.

## Windows exporter files

The `windows-exporter/` folder is packaged with the chart as source/reference material for the Windows-side exporter deployment. It is intentionally outside `templates/`, so Helm packages it but does not apply it to the cluster.

Current packaged files:

- `windows-exporter/CONFIG.ps1` - main Pushgateway/exporter configuration file

Customer-specific values such as `GROUP`, `BASE_URL`, and `JobRunVisualizationWindowSeconds` must be set in the customer GitOps repository copy of `CONFIG.ps1`, not in this shared chart.

The upstream project is Windows-side software: `https://github.com/DoTheEvo/veeam-prometheus-grafana`. It does not provide a Helm chart, so it is not added as a Helm dependency. The OpenShift chart keeps only a reference to it, matching the old deployment model where the exporter is installed on the Veeam server and pushes metrics to Pushgateway.

The full exporter deployment normally also includes PowerShell modules, push/wipe scripts, scheduled task XML definitions, token encryption setup, and optional Prometheus alert rules. OpenShift-side alert rules are now managed by this Helm chart so they are not missed by Argo CD.

## Timing alignment

Keep these intervals aligned when deploying the Windows exporter:

- Windows scheduled task interval in `veeam_prometheus_info_push.xml`
- `JobRunVisualizationWindowSeconds` in `CONFIG.ps1`
- Grafana Status History panel interval in the dashboard JSON

For the current dashboard, the Grafana query interval is `30m`, so a matching Windows task interval is 30 minutes and `JobRunVisualizationWindowSeconds` is usually `1800`.

## Alert Rules

The chart renders Prometheus alert rules for:

- scheduled backup failed or warning
- backup repository over 80 percent full
- no Veeam metrics for 2 hours
- no backup completed for 2 days

The live resource migrated from `hub01` is `prometheus-pushgateway/veeam-alerts`. Alert labels are configurable through `prometheusRule.labels`.

Customer-specific labels such as `customerName` must be overridden by the customer GitOps values, for example `conf-socpoist/gitops/components/veeam-exporter/values.hub01.yaml.gotmpl`. The chart default is only a placeholder.
