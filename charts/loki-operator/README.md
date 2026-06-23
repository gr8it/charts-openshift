# Loki Operator

This Helm chart installs the Red Hat **Loki Operator** using an ACM `OperatorPolicy`.

It replaces the previously hand-applied static manifests
(`observability/logging/02-loki-operator.yaml`) with a GitOps-managed
Helm release, consistent with the other operator charts in this repository.

## Components

This chart creates an `OperatorPolicy` (via the `acm-operatorpolicy` dependency) that
manages the Loki Operator `Subscription` in the `openshift-operators-redhat` namespace.

## How it works

The chart uses `acm-operatorpolicy` as a dependency:

```yaml
acm-operatorpolicy:
  subscription:
    channel: stable-6.1
    name: loki-operator
    namespace: openshift-operators-redhat
    source: redhat-operators
    sourceNamespace: openshift-marketplace
    startingCSV: loki-operator.v6.1.4
  upgradeApproval: None
  versions: []
```

### Namespace / OperatorGroup adoption

`openshift-operators-redhat` is a shared namespace that already exists and already
owns a single `OperatorGroup`. `operatorGroup` is intentionally **left unset** so the
`OperatorPolicy` adopts the existing `OperatorGroup` rather than creating a second one
(OLM allows only one `OperatorGroup` per namespace).

## Migration / adoption

`1.0.0` reproduces the current `stable-6.1` install with manual install-plan approval
(`upgradeApproval: None`), so adopting the live `Subscription` is a no-op. The OCP 4.19
unblock — moving to channel `stable-6.2` — is performed as a separate, explicit version
bump once adoption has been validated.

## Prerequisites

- OpenShift 4.x cluster
- Access to the Red Hat Operators catalog
- ACM `OperatorPolicy` support (config-policy-controller) on the target cluster
