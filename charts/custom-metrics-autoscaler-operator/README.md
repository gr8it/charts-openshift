# Custom Metrics Autoscaler Operator

This Helm chart installs the Red Hat Custom Metrics Autoscaler Operator using an ACM `OperatorPolicy`.

## Prerequisites

- OpenShift 4.x
- Advanced Cluster Management (ACM) with `OperatorPolicy` support
- Access to the Red Hat Operators catalog


## Configuration

The chart uses the `acm-operatorpolicy` dependency. The default values install the operator into `openshift-keda`:

```yaml
acm-operatorpolicy:
  subscription:
    channel: stable
    name: openshift-custom-metrics-autoscaler-operator
    namespace: openshift-keda
    source: redhat-operators
    sourceNamespace: openshift-marketplace
    startingCSV: custom-metrics-autoscaler.v2.19.0-3
  upgradeApproval: Automatic
  versions:
    - custom-metrics-autoscaler.v2.19.0-3
  operatorGroup:
    name: openshift-keda
    namespace: openshift-keda
    targetNamespaces:
      - openshift-keda
```

Values are validated using `values.schema.json`.

## Namespace Monitoring Label

The namespace monitoring label is applied by the Argo Application setup, not by this Helm chart. Configure the application with `managedNamespaceMetadata`:

```yaml
managedNamespaceMetadata:
  labels:
    openshift.io/cluster-monitoring: 'true'
```

When using the `argocd-app-of-apps` chart, place this block under the application entry. The application must also enable namespace creation or already manage the target namespace, for example:

```yaml
custom-metrics-autoscaler-operator:
  render:
    chart: gr8it-openshift/custom-metrics-autoscaler-operator
  destination:
      namespace: openshift-keda    
  managedNamespaceMetadata:
    labels:
      openshift.io/cluster-monitoring: 'true'
  syncOptions:
    - CreateNamespace=true
  enableAutoSync: true
  autoSyncPrune: true
```
