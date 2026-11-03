# Operator Readiness

Deploys the `readiness-engine` collector on the ACM hub. Every interval it reads the operator inventory of all
managed clusters (ACM Search API, ManagedClusterView), the OCP upgrade graph, the Red Hat Lifecycle API and
the Red Hat Ecosystem Catalog (Pyxis), evaluates upgrade readiness against the policy, serves
an HTML page on `/`, `/summary`, `/report` and `/metrics` (ServiceMonitor, PrometheusRule, GrafanaDashboard) and, when `snapshot.repository` is set, pushes a snapshot to Quay.

Engine and image (`ghcr.io/gr8it/readiness-engine`): [apc-operators-guard/engine](https://github.com/gr8it/apc-operators-guard/blob/main/engine/README.md).
Design: [apc-operators-guard/docs/02-design.md](https://github.com/gr8it/apc-operators-guard/blob/main/docs/02-design.md).

## Prerequisites

- User workload monitoring enabled on the hub.
- Only with `snapshot.repository`: Secret (`kubernetes.io/dockerconfigjson`) with Quay robot push credentials in the release namespace.
- grafana-operator and a Grafana instance labeled `dashboards: <instanceName>` (when `grafanaDashboard.enabled`).
- Egress to `access.redhat.com`, `api.openshift.com` and `catalog.redhat.com` (through `global.apc.proxy` when the cluster has no direct internet access).
- Ingress to `search-search-api` (port 4010) in `open-cluster-management` from the release namespace
  (newer ACM versions restrict it with a NetworkPolicy).

## Chart Variables

Global values (apc-global-overrides): `global.apc.proxy` sets `HTTPS_PROXY` / `HTTP_PROXY`; `global.apc.noProxy` sets `NO_PROXY`,
with `.svc`, `.cluster.local` and the API service IP appended (the engine uses Python urllib, which ignores CIDRs).

> [!NOTE]
> `policy` is mandatory; `snapshot.*` are optional (`pushSecret` is mandatory once `repository` is set). RBAC is a ClusterRole limited to what the engine calls
> (ManagedClusters, hub ClusterVersion, APIRequestCounts, hub OperatorPolicies, ManagedClusterViews, and list on Subscriptions, CSVs and Deployments because ACM Search authorizes the hub's own objects against the caller's RBAC).

|Variable                     | Type | Default                                   | Notes |
|:---                         |:---  |:---                                       |:---   |
| image                       | str  | `ghcr.io/gr8it/readiness-engine:0.6.0`    | readiness-engine container image (ghcr.io is private; mirror it to a registry the cluster can pull from) |
| imagePullSecrets            | list | `[]`                                      | Existing dockerconfigjson Secrets used to pull the image |
| nodeSelector                | obj  | `{}`                                      | Optional pod nodeSelector |
| interval                    | str  | `1h`                                      | Collector interval (Go duration) |
| policy                      | obj  |                                           | Readiness policy, `policy.strategy` is mandatory (`eus`, `next-minor`, `pinned`) |
| snapshot.repository         | str  |                                           | Optional OCI repository in hub Quay for the snapshot; empty = no push |
| snapshot.pushSecret         | str  |                                           | Existing dockerconfigjson Secret with Quay push credentials; mandatory when `snapshot.repository` is set |
| grafanaDashboard.enabled    | bool | `true`                                    | Creates GrafanaDashboard CR |
| grafanaDashboard.instanceName | str | `apc-grafana`                            | Value of the `dashboards` label on the Grafana instance |

## Metrics and alerts

Metrics are listed in [engine/README.md](https://github.com/gr8it/apc-operators-guard/blob/main/engine/README.md#metrics). Alerts: `OperatorUnsupportedNow`,
`OperatorUpgradeBlocker`, `OperatorSupportEnded`, `OperatorBelowMinVersion`, `OperatorPinStale`, `OperatorVersionBehind`, `OperatorReadinessCollectStale`, `OperatorReadinessNoData`, `OperatorReadinessSourceDown`.

```sh
oc -n apc-operator-readiness port-forward svc/operator-readiness 8080:8080 &
curl -s localhost:8080/summary
```

HTML page with filters: open `http://localhost:8080/` while the port-forward runs.

## Example Deployment

See [values.example.yaml](values.example.yaml).

```sh
$ helm -n apc-operator-readiness install -f values.example.yaml operator-readiness .
```
