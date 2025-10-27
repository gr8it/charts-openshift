# ACS Operator

This Helm chart installs the Red Hat Advanced Cluster Security (RHACS) operator and configures a secured cluster using ACM OperatorPolicy.

## Components

This chart creates:

1. **RHACS Operator** - Installed via ACM OperatorPolicy dependency
   - ACM automatically creates: operator namespace, OperatorGroup, and Subscription
2. **Stackrox Namespace** - Namespace where ACS components run
3. **SecuredCluster CR** - Configures the ACS secured cluster instance

## How It Works

The chart uses `acm-operatorpolicy` as a dependency. When ACM processes the OperatorPolicy:

```yaml
subscription:
  namespace: rhacs-operator  # ACM creates this namespace automatically
  name: rhacs-operator
  channel: stable
```

ACM automatically creates:
- Namespace: `rhacs-operator`
- OperatorGroup in that namespace
- Subscription for the operator

The chart's templates then create the `stackrox` namespace and `SecuredCluster` custom resource.

## Configuration

### Key Values

```yaml
acm-operatorpolicy:
  subscription:
    channel: stable
    startingCSV: rhacs-operator.v4.6.1
  upgradeApproval: Manual

securedCluster:
  clusterName: dev01  # Override per environment
  centralEndpoint: 'https://central-stackrox.apps.hub01.cloud.socpoist.sk:443'
```

### Per-Environment Override

```yaml
securedCluster:
  clusterName: prod01  # Change for each environment
  centralEndpoint: 'https://central-stackrox.apps.hub01.cloud.socpoist.sk:443'
```

## Prerequisites

- OpenShift 4.x cluster
- Access to Red Hat Operators catalog
- ACM (Advanced Cluster Management) for OperatorPolicy support

