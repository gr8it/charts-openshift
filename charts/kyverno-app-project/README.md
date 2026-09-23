# Kyverno app project

## Overview

Kyverno policies that apply to application projects - every namespace labelled
`apc.namespace.type: application`. They set the defaults a project gets without
asking for them: quotas, limit ranges, the internet proxy ConfigMap, the Vault
groups, and the ownership metadata described below.

| Policy | Trigger | Effect |
| --- | --- | --- |
| `app-project-quotas` | Namespace | Generates the default ResourceQuota objects. |
| `app-project-limitrange` | Namespace | Generates the default LimitRange. |
| `app-project-internetproxy-cm` | Namespace | Generates the `proxy` ConfigMap. |
| `app-project-vault-groups` | Namespace | Generates the Vault policy and auth backend groups. |
| `app-project-vault-groups-cleanup` | - | ClusterCleanupPolicy removing them again. |
| `app-project-namespace-metadata` | `project-metadata` ConfigMap | Copies every usable key onto the Namespace as a label. |
| `app-project-require-metadata-configmap` | Namespace | **Audit.** Reports an application namespace in which no `project-metadata` ConfigMap exists. Never blocks. |

## Project ownership metadata

Metrics carry `team` and `vendor` from `prometheusK8s.externalLabels` in the
`cluster-monitoring-config` ConfigMap (`team: platform`, `vendor: aspecta`).
External labels are applied to every metric of the cluster, so every workload -
including the application projects of other teams and vendors - is reported as
platform-owned, and filtering or reporting by real owner is impossible.

These two policies put the real owner on the Namespace, where monitoring can pick
it up. `externalLabels` stays untouched as the platform default: a label on the
series wins over an external label, so the per-namespace value overrides the
global one for that namespace only.

The team declares ownership in a ConfigMap it creates and maintains itself.
Kyverno only copies it onto the Namespace and reports the projects that have no
such ConfigMap. It creates nothing on the team's behalf and blocks nothing.

### 1. Declare who owns the project

Create a ConfigMap called `project-metadata` in your own namespace:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: project-metadata
  namespace: myproject
data:
  # every key below becomes a Namespace label, as long as its value is a
  # valid Kubernetes LABEL value:
  #   - letters, digits, '-', '_', '.'
  #   - max 63 characters
  #   - must start and end with an alphanumeric character (not '-'/'_'/'.')
  #   - NO spaces, NO "@", NO "/", NO other special characters
  team: alfa-team
  vendor: acme
  # any further key you want to report on is copied too
  cost-center: cc-4711
  tier: production
  # a value that cannot be a label - an e-mail address, free text - is simply
  # skipped; the keys above still land
  email: alfa-team@example.com
```

Within a moment the namespace carries `team`, `vendor`, `cost-center` and
`tier` as labels. The policy is not tied to a fixed set of keys: it rebuilds the
label map from whatever the ConfigMap holds, so adding a key needs no change to
the platform.

### 2. Put the owner on your metrics

Your ServiceMonitor decides which labels reach the metrics. Take the owner from
the Service's own label if it has one, and from the Namespace otherwise:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: demo-monitor
  namespace: myproject
spec:
  selector:
    matchLabels:
      app: demo
  endpoints:
    - port: metrics
      interval: 30s
      relabelings:
        # the Namespace value is the default
        - sourceLabels: [__meta_kubernetes_namespace_label_team]
          targetLabel: team
        # the Service's own label overrides it where it is set - the regex does
        # not match an empty source, so an unlabelled Service keeps the default
        - sourceLabels: [__meta_kubernetes_service_label_team]
          regex: (.+)
          targetLabel: team
        - sourceLabels: [__meta_kubernetes_namespace_label_vendor]
          targetLabel: vendor
        - sourceLabels: [__meta_kubernetes_service_label_vendor]
          regex: (.+)
          targetLabel: vendor
```

A PodMonitor is the same with `__meta_kubernetes_pod_label_*` in place of
`__meta_kubernetes_service_label_*`.

> [!IMPORTANT]
> The `__meta_kubernetes_namespace_label_*` half does not work yet - see
> [Namespace meta labels](#namespace-meta-labels) below. Until the platform
> catches up, a project that needs the owner on its metrics today has to carry
> `team` and `vendor` as labels on the **Service** (or Pod) itself. The
> relabelings above are written so that nothing has to change when the namespace
> half starts working.

### Namespace meta labels

Prometheus service discovery exposes the labels of the Service, the Pod and the
Ingress, and of the Namespace only the **name**, as
`__meta_kubernetes_namespace`. `__meta_kubernetes_namespace_label_team` does not
exist on the clusters as they stand today. Checked on the QA cluster across all
350 active targets, the only namespace-related meta label present is
`__meta_kubernetes_namespace`.

Two things have to land before it works, and neither is in place:

- **Prometheus >= 3.6.** Namespace metadata in `kubernetes_sd` was merged in
  [prometheus#16831](https://github.com/prometheus/prometheus/pull/16831) in July
  2025. OpenShift 4.19 ships Prometheus 3.2.1.
- **A prometheus-operator that can turn it on.** The scrape config is generated
  by the operator, which has to emit `attach_metadata: {namespace: true}`. In
  prometheus-operator 0.81.0 the ServiceMonitor CRD exposes `attachMetadata.node`
  only - there is no `attachMetadata.namespace` to set.

A relabeling on a meta label that does not exist is **not an error**. The source
is the empty string, the rule does not match, and the metric silently keeps the
`externalLabels` default. Nothing shows up in the Prometheus UI or in the logs,
which is why the relabelings above put the Service leg after the Namespace leg:
the chain is correct either way, and gains the namespace default the day the
cluster is able to provide it.

### Finding projects without a metadata ConfigMap

The audit policy looks the ConfigMap up directly - a `GET` on a ConfigMap that
does not exist is an error, and `apiCall.default` turns that into the empty
string the rule reports on. Findings land in the PolicyReport of each namespace:

```bash
# namespaces with a failing result
oc get policyreport -A

# what exactly failed in one of them
oc describe policyreport -n <namespace>
```

This needs the Kyverno reports controller to be running on the cluster.

### Known limitations

- **Removing a key does not remove the label.** Deleting `vendor` from the
  ConfigMap leaves the namespace label in place; the mutation only ever sets
  values. Deleting the label is a manual step.
- **A value that cannot be a label is dropped without a word.** It is skipped so
  that it cannot fail the patch for the other keys, but nothing reports it: the
  ConfigMap exists, so the audit is satisfied, and the namespace simply never
  gets that label. A ConfigMap in which *no* value is usable leaves the namespace
  untouched and still counts as present.
- **Alert labels are not covered.** An alert inherits the labels of the series
  that fired it, so alerts on application metrics do pick up the owner - but only
  where the PrometheusRule does not set `team`/`vendor` itself. Rules that set
  them explicitly, such as the ones generated by
  `user-workload-monitoring-policy`, keep their own values.
