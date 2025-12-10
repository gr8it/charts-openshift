# Compliance Operator

This chart installs the OpenShift Compliance Operator via ACM `OperatorPolicy`. All runtime configuration (namespaces, ScanSettings, ScanSettingBindings, TailoredProfiles) now lives in the separate `compliance-config` chart.

## Components

This chart creates:

1. **Compliance Operator** – Enforced by the `acm-operatorpolicy` dependency.
   - ACM creates the operator namespace, OperatorGroup, Subscription, and ensures the desired CSV/channel.

> Install `compliance-config` alongside this chart to provide ScanSettings, bindings, and TailoredProfiles.

## Configuration

```yaml
acm-operatorpolicy:
  subscription:
    channel: stable
    name: compliance-operator-sub
    config:
      nodeSelector:
        node-role.kubernetes.io/worker: ""
      env:
      - name: PLATFORM
        value: "HyperShift"
  operatorGroup:
    name: compliance-operator
    namespace: openshift-compliance
    targetNamespaces:
    - openshift-compliance
```

### Customization

Adjust the subscription/channel, OperatorGroup, or CSV allow-list through the `acm-operatorpolicy` values above. Use `compliance-config` to customize scan storage, schedules, profile bindings, or TailoredProfiles per cluster.

## Prerequisites

- OpenShift 4.x cluster
- Access to Red Hat Operators catalog
- ACM (Advanced Cluster Management) for policy enforcement
