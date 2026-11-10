# Operator Readiness

Deploys the `readiness-engine` collector on the ACM hub. Every interval it reads the operator inventory of all
managed clusters (ACM Search API, ManagedClusterView), the OCP upgrade graph, the Red Hat Lifecycle API and
the Red Hat Ecosystem Catalog (Pyxis), evaluates upgrade readiness against the policy, serves
an HTML page on `/`, `/summary`, `/report`, `/history`, `/diff` and `/metrics` (ServiceMonitor, PrometheusRule, GrafanaDashboard) and, when `snapshot.repository` is set, pushes a snapshot to Quay.

Engine and image (`ghcr.io/gr8it/operators-guard`): [apc-operators-guard/engine](https://github.com/gr8it/apc-operators-guard/blob/main/engine/README.md).
Design: [apc-operators-guard/docs/02-design.md](https://github.com/gr8it/apc-operators-guard/blob/main/docs/02-design.md).

## Prerequisites

- User workload monitoring enabled on the hub.
- Only with `snapshot.repository`: Secret (`kubernetes.io/dockerconfigjson`) with Quay robot push credentials in the release namespace.
- grafana-operator and a Grafana instance labeled `dashboards: <instanceName>` (when `grafanaDashboard.enabled`).
- Egress to `access.redhat.com`, `api.openshift.com` and `catalog.redhat.com` (through `global.apc.proxy` when the cluster has no direct internet access).
  With `global.apc.proxyCIDRs` the chart creates a NetworkPolicy that allows egress to the proxy (platform namespaces deny it by default).
- Ingress to `search-search-api` (port 4010) in `open-cluster-management` from the release namespace
  (newer ACM versions restrict it with a NetworkPolicy).

## Chart Variables

> [!NOTE]
> `policy` is mandatory; `snapshot.*` are optional (`pushSecret` is mandatory once `repository` is set). RBAC is a ClusterRole limited to what the engine calls
> (ManagedClusters, hub ClusterVersion, APIRequestCounts, hub OperatorPolicies, ManagedClusterViews, and list on Subscriptions, CSVs and Deployments because ACM Search authorizes the hub's own objects against the caller's RBAC).

Global values (apc-global-overrides): `global.apc.proxy` sets `HTTPS_PROXY` / `HTTP_PROXY`; `global.apc.noProxy` sets `NO_PROXY`,
with `.svc`, `.cluster.local` and the API service IP appended (the engine uses Python urllib, which ignores CIDRs);
`global.apc.proxyCIDRs` creates the NetworkPolicy `<release>-allow-proxy` with egress to these CIDRs.

|Variable                     | Type | Default                                   | Notes |
|:---                         |:---  |:---                                       |:---   |
| image                       | str  | `ghcr.io/gr8it/operators-guard` | Image without a tag; the tag is the chart appVersion (ghcr.io is private; mirror it to a registry the cluster can pull from) |
| imagePullSecrets            | list | `[]`                                      | Existing dockerconfigjson Secrets used to pull the image |
| nodeSelector                | obj  | `{}`                                      | Optional pod nodeSelector |
| interval                    | str  | `1h`                                      | Collector interval (Go duration) |
| historyKeep                 | int  | `24`                                      | Report-only local history entries; `0` disables. The cache is an `emptyDir`, so history is lost on pod restart. A chart change would be needed to mount a PVC. |
| policy                      | obj  |                                           | Readiness policy, `policy.strategy` is mandatory (`eus`, `next-minor`, `pinned`) |
| policy.owners               | obj  | `{}`                                      | Package to owner; null also uses the empty map. Used in report rows, metric labels and alerts |
| policy.defaultOwner         | str  | `unassigned`                              | Owner when a package has no mapping or exception owner; null uses the default |
| snapshot.repository         | str  |                                           | Optional OCI repository in hub Quay; pushes a UTC timestamp tag, then tags it `:latest`. Verify pushes before relying on remote history. |
| snapshot.pushSecret         | str  |                                           | Existing dockerconfigjson Secret with Quay push credentials; mandatory when `snapshot.repository` is set |
| grafanaDashboard.enabled    | bool | `true`                                    | Creates GrafanaDashboard CR |
| grafanaDashboard.instanceName | str | `apc-grafana`                            | Value of the `dashboards` label on the Grafana instance |

## Metrics and alerts

The ClusterRole gets hub InstallPlans by name when a Subscription references one. Managed cluster reads use named ManagedClusterViews.

Metrics, including the `readiness_engine_predictions` gauge, are listed in [engine/README.md](https://github.com/gr8it/apc-operators-guard/blob/main/engine/README.md#metrics). Alerts: `OperatorUnsupportedNow`,
`OperatorUpgradeBlocker`, `OperatorSupportEnded`, `OperatorBelowMinVersion`, `OperatorPinStale`, `OperatorVersionBehind`, `OperatorPredictionMismatch`, `OperatorStalePendingInstallPlan` (known plan age over 14 days, `for: 1h`), `OperatorStalePendingInstallPlanNoTimestamp` (unknown age, `for: 7d`), `OperatorExceptionExpiring` (0–29 days left), `OperatorExceptionExpired`, `OperatorReadinessCollectStale`, `OperatorReadinessNoData`, `OperatorReadinessSourceDown`.
Operator alerts carry the metric's `owner` label; the dashboard can filter by owner.

```sh
oc -n apc-operators-guard port-forward svc/operators-guard 8080:8080 &
curl -s localhost:8080/summary
```

HTML page with filters: open `http://localhost:8080/` while the port-forward runs.

## Dashboard

The Grafana dashboard shows prediction counts and a detail table with namespace, Subscription and plan age; separate counts for expiring and expired exceptions; exception expiry sorted by days left; and per-source health. Cluster, package and owner filters apply to operator metrics. Exceptions have package and owner labels; prediction totals and sources have no operator labels.

## Example Deployment

See [values.example.yaml](values.example.yaml).

```sh
$ helm -n apc-operators-guard install -f values.example.yaml operators-guard .
```
