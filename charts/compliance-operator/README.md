# Compliance Operator

This Helm chart installs the OpenShift Compliance Operator and configures CIS compliance scanning using ACM OperatorPolicy.

## Components

This chart creates:

1. **Compliance Operator** - Installed via ACM OperatorPolicy dependency
   - ACM automatically creates: operator namespace, OperatorGroup, and Subscription
2. **Namespace** - `openshift-compliance` with monitoring and security labels
3. **ScanSetting** - Configuration for compliance scans
4. **ScanSettingBinding** - Binds scan settings to compliance profiles

## How It Works

The chart uses `acm-operatorpolicy` as a dependency. ACM automatically creates the operator installation resources (namespace, OperatorGroup, Subscription).

The chart's templates create the compliance scanning configuration (ScanSetting and ScanSettingBinding).

## Configuration

### Key Values

```yaml
acm-operatorpolicy:
  subscription:
    channel: stable
    namespace: openshift-compliance
    config:
      nodeSelector:
        node-role.kubernetes.io/worker: ""
      env:
      - name: PLATFORM
        value: "HyperShift"

scanSetting:
  name: cis-scan-settings
  schedule: "0 1 * * *"  # Daily at 1 AM
  roles:
  - worker

scanSettingBinding:
  name: cis-compliance
  profiles:
  - name: ocp4-cis-node
```

### Customization

Modify scan schedule, profiles, or storage settings in `values.yaml`.

## Prerequisites

- OpenShift 4.x cluster
- Access to Red Hat Operators catalog
- ACM (Advanced Cluster Management) for OperatorPolicy support
