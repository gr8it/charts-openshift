# OpenShift ADP Operator

This Helm chart installs the Red Hat OpenShift ADP (Application Data Protection) operator using ACM OperatorPolicy, which provides backup and restore capabilities for OpenShift applications and persistent volumes using Velero.

The chart uses the `acm-operatorpolicy` dependency to create ACM OperatorPolicy resources for managed cluster operator installation.

## Features

- Installs the Red Hat OpenShift ADP operator via ACM OperatorPolicy
- Policy-driven operator management on managed clusters
- Supports version pinning and upgrade control
- Configurable compliance and remediation actions

## Usage

This chart is designed for ACM-managed environments where operators are installed on managed clusters via OperatorPolicy resources.

### Basic Installation

```yaml
openshift-adp-operator:
  render:
    chart: gr8it-openshift/openshift-adp-operator
    chartVersion: "1.0.0"
  destination:
    namespace: open-cluster-management-policies
  syncOptions:
    - CreateNamespace=true
  enableAutoSync: true
```

**Note**: The OperatorPolicy resource is created in the `open-cluster-management-policies` namespace on the ACM hub, and ACM will install the actual operator in the target namespace (`openshift-adp`) on the managed cluster.


## Configuration Values

The chart supports the following configuration options through the `acm-operatorpolicy` values:

### Subscription Configuration
- `subscription.channel`: The operator channel (default: `stable-1.4`)
- `subscription.name`: The operator name (default: `redhat-oadp-operator`)
- `subscription.source`: The operator source catalog (default: `redhat-operators`)
- `subscription.sourceNamespace`: The source namespace (default: `openshift-marketplace`)
- `subscription.startingCSV`: The ClusterServiceVersion (default: `oadp-operator.v1.4.2`)
- `subscription.namespace`: The installation namespace (default: `openshift-adp`)

### Operator Group Configuration
- `operatorGroup.name`: The operator group name (default: `openshift-adp`)
- `operatorGroup.namespace`: The operator group namespace (default: `openshift-adp`)
- `operatorGroup.targetNamespaces`: Target namespaces for the operator (default: `[]`)

### Policy Configuration
- `upgradeApproval`: Upgrade approval mode (default: `None`)
- `versions`: Allowed operator versions (default: `["oadp-operator.v1.4.2"]`)

## Post-Installation

After the operator is installed, you can create DataProtectionApplication (DPA) resources to configure backup storage and other settings for Velero.

## Prerequisites

- Red Hat Advanced Cluster Management (ACM) installed and configured
- Managed cluster registered with ACM hub
- Access to create resources in `open-cluster-management-policies` namespace

## Dependencies

- acm-operatorpolicy: ^1.1.0
