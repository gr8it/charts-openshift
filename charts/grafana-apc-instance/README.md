# Grafana APC instance

## Overview

This Helm chart deploys a Grafana instance for APC workloads on OpenShift.

The chart creates:

- a `Grafana` custom resource with OpenShift OAuth proxy sidecar
- Grafana datasources for metrics, logs and traces
- RBAC for Grafana service account
- supporting secrets, config maps and network policies

## Deployment modes

The chart supports two RBAC modes controlled by `namespaceScoped`.

- `namespaceScoped: false`
  - deploys cluster-wide RBAC for monitoring, logs and traces
  - uses the default Thanos querier endpoint on port `9091`

- `namespaceScoped: true`
  - deploys namespace-scoped `Role` and `RoleBinding` resources where supported
  - uses the project-scoped Thanos querier endpoint on port `9092`
  - configures the Thanos datasource with namespace query parameters

## Datasources

The chart can create these datasources:

- Thanos / Prometheus
- Loki application logs
- Tempo traces

Each datasource can be disabled by setting the corresponding URL value to `null`.

## Important values

Main configuration is defined in [values.yaml](./values.yaml).

Most important values are:

- `namespaceScoped`
- `datasourceThanosUrl`
- `datasourceThanosScopedUrl`
- `datasourceLokiUrl`
- `datasourceTempoUrl`
- `dashboardFilter`
- `dashboardFolderOverride`
- `storageClassName`
- `storageSize`

## Notes

- Namespace-scoped metrics access uses Thanos querier on port `9092` together with namespace-local RBAC.
- Application logs still use the standard OpenShift Logging application tenant endpoint.
- Dashboards are loaded from the local [dashboards](./dashboards) directory.
