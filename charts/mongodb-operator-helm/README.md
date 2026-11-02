# MongoDB Operator

Helm chart for deploying the MongoDB Community Operator, wrapping the upstream `mongodb-kubernetes` chart with OpenShift-friendly defaults (metrics, alerting rules, and an optional per-instance report).

## Configuration

Configuration is done through specifying options in values.yaml file.

### Configuration options

Most important configuration options, for full list consult values.yaml file.

| Value/Section | Default setting | Description |
|-------|---------------|-------------|
| mongodb-kubernetes.operator.watchNamespace | `*` | Namespaces the operator watches for MongoDB resource changes |
| mongodb-kubernetes.managedSecurityContext | `true` | Whether the cluster manages Pod SecurityContext (set `true` on OpenShift) |
| mongodb-kubernetes.operator.telemetry.enabled | `false` | Enable operator telemetry reporting to MongoDB |
| instanceReport.enabled | `true` | Deploy the MongoDB instance report: a kube-state-metrics instance reporting inventory and `status.phase` for MongoDBCommunity custom resources cluster-wide |
| instanceReport.image.repository / .tag | `registry.k8s.io/kube-state-metrics/kube-state-metrics` / `v2.13.0` | kube-state-metrics image used by the instance report |
| instanceReport.ports.metrics / .telemetry | `8080` / `8081` | Ports the instance report exposes for scraped metrics and its own self-monitoring telemetry |
| instanceReport.scrapeInterval | `30s` | ServiceMonitor scrape interval for the instance report metrics endpoint |
| instanceReport.resources | requests: 100m/300Mi, limits: 200m/512Mi | Resource requests/limits for the instance report container |
