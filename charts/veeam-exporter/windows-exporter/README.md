# Windows Exporter Reference

The Veeam exporter runs on the Windows Veeam Backup server. These files are packaged with the Helm chart for GitOps traceability, but they are not rendered by Helm and are not applied to OpenShift.

OpenShift receives only:

- `GrafanaDashboard`
- `PrometheusRule`

Exporter flow:

1. Windows scheduled task runs the PowerShell exporter on the Veeam server.
2. The exporter reads its local `CONFIG.ps1`.
3. The exporter pushes metrics to Prometheus Pushgateway.
4. OpenShift Prometheus scrapes Pushgateway.
5. Grafana dashboard and Prometheus alerts are managed by this Helm chart.

The upstream exporter reference is `https://github.com/DoTheEvo/veeam-prometheus-grafana`. Customer-specific values must be set in the customer GitOps repository or Windows deployment copy, not in the shared chart.
