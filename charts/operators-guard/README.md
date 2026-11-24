# Operators Guard

Deploys the `readiness-engine` collector on the ACM hub. Every interval it reads the operator inventory of all
managed clusters (ACM Search API, ManagedClusterView), the OCP upgrade graph, the Red Hat Lifecycle API and
the Red Hat Ecosystem Catalog (Pyxis), evaluates upgrade readiness against the policy, serves
an HTML page on `/`, `/summary`, `/report`, `/history`, `/diff` and `/metrics` (ServiceMonitor, PrometheusRule, GrafanaDashboard) and, when `snapshot.repository` is set, pushes a snapshot to Quay.

Engine and image (`ghcr.io/gr8it/operators-guard`): [engine/](https://github.com/gr8it/apc-operators-guard/blob/operators-guard-chart-0.11.0/engine/README.md).
Design: [docs/02-design.md](https://github.com/gr8it/apc-operators-guard/blob/operators-guard-chart-0.11.0/docs/02-design.md).

## Prerequisites

- User workload monitoring enabled on the hub.
- Only with `snapshot.repository`: Secret (`kubernetes.io/dockerconfigjson`) with Quay robot push credentials in the release namespace.
- grafana-operator and a Grafana instance labeled `dashboards: <instanceName>` (when `grafanaDashboard.enabled`).
- Egress to `access.redhat.com`, `api.openshift.com` and `catalog.redhat.com` (through `global.apc.proxy` when the cluster has no direct internet access).
- Set `global.apc.proxy` and `global.apc.noProxy` in the conf repo when the hub needs a proxy. Set `global.apc.proxyCIDRs` to render a NetworkPolicy
  allowing the collector's egress to that proxy (the APC BaselineAdminNetworkPolicy denies it otherwise).
  That NetworkPolicy isolates the collector's egress, so all other egress must be allowed elsewhere: label the release namespace
  `apc.namespace.type: platform` with `default-network-policies` `createPlatformPolicies: true` (its AdminNetworkPolicy allows in-cluster
  and private-CIDR egress), or add NetworkPolicies for DNS, the Kubernetes API, `search-search-api` port 4010 and any `noProxy` host
  the collector reaches directly (e.g. the snapshot registry).
- Ingress to `search-search-api` (port 4010) in `open-cluster-management` from the release namespace
  (newer ACM versions restrict it with a NetworkPolicy).

## Chart Variables

> [!NOTE]
> `policy` is mandatory; `snapshot.*` are optional (`pushSecret` is mandatory once `repository` is set). RBAC is a ClusterRole limited to what the engine calls
> (ManagedClusters, hub ClusterVersion, APIRequestCounts, hub OperatorPolicies, ManagedClusterViews, and list on Subscriptions, CSVs and Deployments because ACM Search authorizes the hub's own objects against the caller's RBAC).

|Variable                     | Type | Default                                   | Notes |
|:---                         |:---  |:---                                       |:---   |
| image.repository            | str  | `ghcr.io/gr8it/operators-guard`           | readiness-engine image repository (ghcr.io is private; mirror it to a registry the cluster can pull from) |
| image.tag                   | str  | `""`                                      | Image tag; empty uses the chart `appVersion` |
| imagePullSecrets            | list | `[]`                                      | Existing dockerconfigjson Secrets used to pull the image |
| global.apc.proxy            | str  | absent                                    | Optional egress proxy for HTTP and HTTPS, supplied by the conf repo |
| global.apc.noProxy          | str  | absent                                    | Additional bypass hosts; the chart appends `.svc`, `.cluster.local` and the API service IP |
| global.apc.proxyCIDRs       | list | `[]`                                      | Proxy CIDRs allowed by the optional egress NetworkPolicy |
| interval                    | str  | `1h`                                      | Collector interval: `h`, `m`, `s` in this order, each at most once (`1h`, `30m`, `1h30m`); `OperatorsGuardReadinessCollectStale` fires after three intervals, at least 3 h |
| brief.enabled               | bool | `false` | Write `brief.md` and `pins.yaml` to `/var/cache/readiness/brief` beside the snapshot; copy them out before the pod restarts. Uses the existing cache and RBAC. |
| historyKeep                 | int  | `24`                                      | Report-only local history entries; `0` disables. The cache is an `emptyDir`, so history is lost on pod restart. A chart change would be needed to mount a PVC. |
| policy                      | obj  |                                           | Readiness policy, `policy.strategy` is mandatory (`eus`, `next-minor`, `pinned`) |
| policy.workflow             | obj | absent | Optional runtime destinations: chartsRepo (path, remote, baseBranch default main), confRepos (path, disjoint clusters, envs mapping), ticketPrefix, push (ask default or allowed). Missing fields require user answers before edits. Never commit destination data. |
| policy.brief.excludeClusters | list | `[]` | Omit named clusters from work-order targets/gates, retaining their known installed CSVs in versions; unknown names fail. Reports and snapshots stay complete. |
| policy.owners               | obj  | `{}`                                      | Package to owner; null also uses the empty map. Used in report rows, metric labels and alerts |
| policy.defaultOwner         | str  | `unassigned`                              | Owner when a package has no mapping or exception owner; null uses the default |
| snapshot.repository         | str  |                                           | Optional OCI repository in hub Quay; pushes a UTC timestamp tag, then tags it `:latest`. Verify pushes before relying on remote history. |
| snapshot.pushSecret         | str  |                                           | Existing dockerconfigjson Secret with Quay push credentials; mandatory when `snapshot.repository` is set |
| grafanaDashboard.enabled    | bool | `true`                                    | Creates GrafanaDashboard CR |
| grafanaDashboard.instanceName | str | `apc-grafana`                            | Value of the `dashboards` label on the Grafana instance |

## Metrics and alerts

The ClusterRole gets hub InstallPlans by name when a Subscription references one. Managed cluster reads use named ManagedClusterViews.

Metrics, including the `readiness_engine_predictions` gauge, are listed in [engine/README.md](https://github.com/gr8it/apc-operators-guard/blob/operators-guard-chart-0.11.0/engine/README.md#metrics). Alerts: `OperatorsGuardUnsupportedNow`,
`OperatorsGuardUpgradeBlocker`, `OperatorsGuardSupportEnded`, `OperatorsGuardBelowMinVersion`, `OperatorsGuardPinStale`, `OperatorsGuardVersionBehind`, `OperatorsGuardPredictionMismatch`, `OperatorsGuardStalePendingInstallPlan` (known plan age over 14 days, `for: 1h`), `OperatorsGuardStalePendingInstallPlanNoTimestamp` (unknown age, `for: 7d`), `OperatorsGuardExceptionExpiring` (0–29 days left), `OperatorsGuardExceptionExpired`, `OperatorsGuardReadinessCollectStale`, `OperatorsGuardReadinessNoData`, `OperatorsGuardReadinessSourceDown`.
Operator alerts carry the metric's `owner` label; the dashboard can filter by owner.

The reports (`/`, `/summary`, `/report`, `/history`, `/diff`) have no authentication, so the engine serves them only on
`127.0.0.1:8080` in the pod; the Service and the ServiceMonitor use the metrics listener on port 9090
(`/metrics`, `/healthz`, `/readyz` only). The ServiceMonitor scrapes every minute. Read the reports through a port-forward to the pod:

```sh
oc -n <namespace> port-forward deploy/operators-guard 8080:8080 &
curl -s localhost:8080/summary
```

HTML page with filters: open `http://localhost:8080/` while the port-forward runs.

## Dashboard

The Grafana dashboard shows prediction counts and a detail table with namespace, Subscription and plan age; separate counts for expiring and expired exceptions; exception expiry sorted by days left; and per-source health. Cluster, package and owner filters apply to operator metrics. Exceptions have package and owner labels; prediction totals and sources have no operator labels.

## Local validation

```sh
helm lint charts/operators-guard -f charts/operators-guard/values.example.yaml
helm template operators-guard charts/operators-guard -f charts/operators-guard/values.example.yaml
helm unittest --strict charts/operators-guard
sh charts/operators-guard/tests/schema_test.sh
```

Run from the repository root. The schema script tests invalid inputs separately because helm-unittest rejects
schema failures before it can evaluate assertions.

## Example Deployment

See [values.example.yaml](values.example.yaml).

```sh
helm -n apc-operators-guard install -f values.example.yaml operators-guard .
```

Work orders are self-contained instructions for a separate executor: one charts PR per operator, then a render
and PR per operator in each mapped conf repo. The engine does not edit repositories, render components, push or
open PRs. Runtime workflow precedence and strict validation are documented in [engine usage](https://github.com/gr8it/apc-operators-guard/blob/operators-guard-chart-0.11.0/engine/README.md#chart-work-order).
