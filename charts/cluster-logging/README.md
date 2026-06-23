# Cluster Logging Operator

This Helm chart installs the Red Hat **OpenShift Logging (Cluster Logging)** Operator
using an ACM `OperatorPolicy`.

It replaces the previously hand-applied static manifests
(`ocp-<cluster>/observability/logging/06-logging-operator.yaml`; on conf-socpoist dev01
`06-openshift-logging-operator.yaml`) with a GitOps-managed Helm release, consistent
with the other operator charts in this repository.

## Components

This chart creates an `OperatorPolicy` (via the `acm-operatorpolicy` dependency) that
manages the Cluster Logging Operator `Subscription` in the `openshift-logging` namespace.

## How it works

The chart uses `acm-operatorpolicy` as a dependency:

```yaml
acm-operatorpolicy:
  subscription:
    channel: stable-6.1
    name: cluster-logging
    namespace: openshift-logging
    source: redhat-operators
    sourceNamespace: openshift-marketplace
  upgradeApproval: None
  versions: []
```

### Namespace / OperatorGroup adoption

`openshift-logging` is a dedicated namespace that already exists and already owns a
single `OperatorGroup`. That OperatorGroup was originally created with
`generateName: cluster-logging-`, so its name differs per cluster (e.g.
`cluster-logging-bz7gt` on conf-socpoist clusters, plain `cluster-logging` on
conf-sp-qa). `operatorGroup` is intentionally **left unset** so the `OperatorPolicy`
adopts whichever single `OperatorGroup` already exists rather than creating a second
one (OLM allows only one `OperatorGroup` per namespace). The namespace itself is not
managed by this chart.

## Migration / adoption

`1.0.0` reproduces the current install with manual install-plan approval
(`upgradeApproval: None`), so adopting the live `Subscription` is a no-op.

`startingCSV` is intentionally **omitted**: the live Subscriptions set no `startingCSV`,
and the installed CSV differs per cluster (v6.1.3 / v6.1.4 / v6.2.9). `startingCSV` is
install-time only, so omitting it makes the managed `Subscription` render identical to
the live object on every cluster. Version is controlled by `channel` + `upgradeApproval`.

The chart default carries the conf-socpoist baseline (`stable-6.1`); the only
per-environment override is the conf-sp-qa channel:

| cluster | conf repo | channel | installed CSV (at migration) | override |
|---------|-----------|---------|------------------------------|----------|
| hub01   | conf-socpoist | stable-6.1 | cluster-logging.v6.1.3 | none |
| prod01  | conf-socpoist | stable-6.1 | cluster-logging.v6.1.4 | none |
| test01  | conf-socpoist | stable-6.1 | cluster-logging.v6.1.4 | none |
| dev01   | conf-socpoist | stable-6.1 | cluster-logging.v6.1.4 | none |
| huba    | conf-sp-qa | stable-6.2 | cluster-logging.v6.2.9 | channel: stable-6.2 |
| spokea1 | conf-sp-qa | stable-6.2 | cluster-logging.v6.2.9 | channel: stable-6.2 |

## Prerequisites

- OpenShift 4.x cluster
- Access to the Red Hat Operators catalog
- ACM `OperatorPolicy` support (config-policy-controller) on the target cluster
