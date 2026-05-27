# openshift-distributed-tracing

Helm chart for deploying Red Hat OpenShift distributed tracing (Tempo) together with Kyverno policies that keep tenants, RBAC, and RoleBindings in sync with application namespaces.

## Overview

The chart deploys a `TempoStack` and a set of Kyverno `ClusterPolicy` / `ClusterCleanupPolicy` resources. Tenants and per-namespace RBAC are not managed in Git — they are reconciled automatically from labelled namespaces so that adding or removing an application namespace transparently updates Tempo.

A namespace participates in tracing when it carries the configured label, by default:

```
apc.namespace.type: application
```

## Prerequisites

- Red Hat OpenShift cluster (or Kubernetes >= 1.16)
- [Tempo Operator](https://docs.openshift.com/container-platform/latest/observability/distr_tracing/distr_tracing_tempo/distr-tracing-tempo-installing.html) installed
- [Kyverno](https://kyverno.io/) installed (>= 1.13.0)
- An object storage class for Tempo backend (default: `ocs-storagecluster-ceph-rgw` via `ObjectBucketClaim`)
- The chart dependency `apc-global-overrides` (declared in `Chart.yaml`)

## What gets installed

### Tempo
- **`TempoStack`** — the Tempo deployment configured by `.Values.tempoStack`. Tenant mode is `openshift`. A placeholder tenant `application` is created at install time and is subsequently overridden by Kyverno (ArgoCD ignores tenant drift since Kyverno is the source of truth for that field).
- **`ObjectBucketClaim`** — provisions the S3 bucket used as Tempo backend storage.
- **`NetworkPolicy`** — restricts ingress/egress for the Tempo components.

### Static RBAC (for Kyverno controllers)
- `clusterrole-admission-controller.yaml` — grants Kyverno's admission controller access to `TempoStack`.
- `clusterrole-background-controller.yaml` — grants Kyverno's background controller access to `TempoStack`.
- `clusterrole-read.yaml` - ClusterRole - read metrics, traces for all tenants - used by apc-grafana


### Kyverno policies (the reconciliation engine)

| Policy | Trigger | Effect |
|---|---|---|
| `tempo-sync-tenants` | Namespace CREATE with selector label | Adds a tenant to `TempoStack.spec.tenants.authentication` |
| `tempo-cleanup-tenants` | Namespace DELETE with selector label | Removes the matching tenant from `TempoStack.spec.tenants.authentication` |
| `generate-tenant-clusterrole-read` | Namespace with selector label | Generates a `ClusterRole` `<stack>-reader-<namespace>` granting `get` on tenant traces |
| `generate-tenant-clusterrole-write` | Namespace with selector label | Generates a `ClusterRole` `<stack>-writer-<namespace>` granting `create` on tenant traces (optionally labelled for OTel collector aggregation) |
| `generate-tenant-rolebindings-read` | Namespace with selector label | Generates a `RoleBinding` in the application namespace binding the reader ClusterRole to environment groups (`APC-<ENV>-<ns>-PJA`, `APC-<ENV>-<ns>-DEV`) |
| `cleanup-tempo-reader-clusterroles` | Daily cron `0 12 * * *` | `ClusterCleanupPolicy` that removes generated ClusterRoles whose namespace no longer exists or no longer has the selector label |

### Lifecycle summary

```
Namespace created  with label apc.namespace.type=application
    │
    ├─► tempo-sync-tenants            → adds tenant in TempoStack
    ├─► generate-tenant-clusterrole-read   → ClusterRole <stack>-reader-<ns>
    ├─► generate-tenant-clusterrole-write  → ClusterRole <stack>-writer-<ns>
    └─► generate-tenant-rolebindings-read  → RoleBinding in <ns>

Namespace deleted (or label removed)
    │
    └─► tempo-cleanup-tenants               → removes tenant from TempoStack
```

## Configuration

Key values (see [values.yaml](values.yaml) for full reference):

| Key | Default | Description |
|---|---|---|
| `tempoStack.name` | `apc-tempo-stack` | Name of the `TempoStack` resource; used as prefix for generated roles |
| `tempoStack.storageSize` | `200Mi` | Per-component storage size |
| `tempoStack.storage.tls.enabled` | `true` | Use TLS to object storage |
| `tempoStack.storage.tls.caName` | `openshift-service-ca.crt` | CA configmap name |
| `tempoStack.retention.global.traces` | `48h0m0s` | Trace retention window |
| `tempoStack.tenants.mode` | `openshift` | Tempo multitenancy mode |
| `tempoStack.template.<component>.resources` | see values | CPU/memory per Tempo component (compactor, distributor, gateway, ingester, querier, queryFrontend) |
| `tempoStack.template.gateway.enabled` | `true` | Enables the Tempo gateway with OpenShift `Route` |
| `tempoStack.template.queryFrontend.jaegerQuery.enabled` | `true` | Exposes Jaeger UI through queryFrontend |
| `tempoStack.objectBucket.type` | `s3` | Object storage type |
| `tempoStack.objectBucket.storageClassName` | `ocs-storagecluster-ceph-rgw` | Storage class for the `ObjectBucketClaim` |
| `otelCollector.role.aggregation.enabled` | `true` | Add aggregation label to generated writer ClusterRoles |
| `otelCollector.role.aggregation.clusterRoleName` | `rbac.authorization.k8s.io/apc-opentelemetry-collector-apc-observability-cluster-role` | Aggregation label key |
| `namespaceSelector.key` | `apc.namespace.type` | Label key that selects application namespaces |
| `namespaceSelector.value` | `application` | Label value that selects application namespaces |

## Operations

### ArgoCD / Red Hat OpenShift GitOps Sync Status and Health Checks

If using this helm chart with ArgoCD / Red Hat OpenShift GitOps then make sure that manifests Application.argoproj.io includes:

``` yaml
spec:
  ignoreDifferences:
    - group: tempo.grafana.com
      kind: TempoStack
      jqPathExpressions:
        - '.spec.tenants.authentication'
```

The `ignoreDifferences` block is required because the Kyverno Policy mutates the `TempoStack` custom resource after it is applied, injecting runtime fields into `.spec.tenants.authentication`. Without this configuration, ArgoCD continuously detects these fields as drift and marks the Application as `OutOfSync`, even though the desired state in Git is unchanged. This in turn can trigger unwanted auto-sync loops that revert the kyverno's mutations, leading to a fight between ArgoCD and the Kyverno that destabilizes the TempoStack. By instructing ArgoCD to ignore differences on these specific jq paths, the Application remains `Synced` and `Healthy` while still allowing the Kyverno to manage dynamic configuration. This pattern is the recommended way to integrate operator-owned or Kyverno-owned CRDs with GitOps tooling, where ownership of certain fields is intentionally split between Git and the controller.

### Onboard a namespace for tracing

```bash
kubectl label namespace <ns> apc.namespace.type=application
```

This triggers Kyverno to create the tenant, ClusterRoles, and RoleBinding.

### List generated ClusterRoles

```bash
kubectl get clusterrole -l 'generated-by in (generate-reader-clusterrole-for-application-namespace,generate-writer-clusterrole-for-application-namespace)'
```

### Inspect current tenants

```bash
kubectl -n apc-observability get tempostack apc-tempo-stack \
  -o jsonpath='{.spec.tenants.authentication[*].tenantName}'
```

### Off-board a namespace

Remove the label or delete the namespace:

```bash
kubectl label namespace <ns> apc.namespace.type-
# or
kubectl delete namespace <ns>
```

Tenant removal is immediate via the `tempo-cleanup-tenants` policy. Stale ClusterRoles are reaped by the daily cleanup policy at `0 12 * * *`.

## Testing

Unit-test snapshots live under [tests/](tests/) and run with [helm-unittest](https://github.com/helm-unittest/helm-unittest):

```bash
helm unittest charts/openshift-distributed-tracing
```
## TODO list

List of future improvements

- Update policy clusterpolicy-tempo-cleanup-tenant.yaml
  - another way to implement this would be to store the tenant list in step 1 as a dictionary (e.g. configmap keys), and than in step 2 have a separate policy looping through the dictionary to get the full list of tenants and write it as a list to the CR, i.e. instead of having partial changes to the CR always create the full list and update it as whole.