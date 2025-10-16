# OpenShift ADP Configuration

This Helm chart configures OpenShift ADP (Application Data Protection) with DataProtectionApplication resources and credential transformation driven by Kyverno.

## Overview

The chart transforms AWS credentials from source secrets in the `apc-backup` namespace to the format required by OADP in the `openshift-adp` namespace, and creates a complete DataProtectionApplication configuration for backup and restore operations.

## Features

- **Credential Transformation**: Uses a Kyverno `ClusterPolicy` to transform AWS credentials from `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` format to OADP's `cloud` format
- **DataProtectionApplication**: Creates a complete DPA configuration with backup locations, Velero settings, and NodeAgent configuration
- **Monitoring**: Optional ServiceMonitor for Prometheus monitoring
- **Storage**: ObjectBucketClaim resources for Ceph RGW storage
- **Environment Flexibility**: Configurable for different environments and applications

## Prerequisites

- OpenShift ADP Operator installed and running
- External Secrets Operator configured with appropriate SecretStore
- Ceph RGW storage available (for ObjectBucketClaims)
- Source secrets available in `apc-backup` namespace

## Installation

### Basic Installation

```yaml
openshift-adp-config:
  render:
    chart: gr8it-openshift/openshift-adp-config
    chartVersion: "1.0.0"
  destination:
    namespace: openshift-adp
  syncOptions:
    - CreateNamespace=true
  enableAutoSync: true
  values:
    environment: test01
    app: myapp
```

### Custom Environment

```yaml
openshift-adp-config:
  render:
    chart: gr8it-openshift/openshift-adp-config
    chartVersion: "1.0.0"
  destination:
    namespace: openshift-adp
  values:
    environment: prod
    app: critical-app
    dpa:
      backupLocations:
        - name: oadp-prod-critical-app-backup
          bucket: oadp-prod-critical-app-backup-abc123
          prefix: backup/prod-critical-app
          default: true
```

## Configuration

### Environment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `environment` | Environment name (test01, prod, etc.) | `test01` |
| `app` | Application name | `app` |
| `sourceNamespace` | Source namespace for secrets | `apc-backup` |
| `targetNamespace` | Target namespace for OADP resources | `openshift-adp` |

### Credential Transformation

The chart automatically transforms credentials from:

**Source format** (in `apc-backup` namespace):
```yaml
data:
  AWS_ACCESS_KEY_ID: <base64-encoded-key>
  AWS_SECRET_ACCESS_KEY: <base64-encoded-secret>
```

**Target format** (in `openshift-adp` namespace):
```yaml
data:
  cloud: <base64-encoded-aws-credentials-file>
```

### DataProtectionApplication Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `dpa.name` | DPA resource name | `apc-dpa` |
| `dpa.backupLocations` | Array of backup locations | See values.yaml |
| `dpa.s3.region` | AWS S3 region | `us-east-1` |
| `dpa.s3.url` | S3 endpoint URL | Ceph RGW URL |
| `dpa.velero.defaultPlugins` | Velero plugins to enable | `[openshift, aws, kubevirt, csi]` |
| `dpa.nodeAgent.enabled` | Enable NodeAgent (restic) | `true` |
| `dpa.nodeAgent.uploaderType` | Uploader type | `kopia` |

### Kyverno Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kyverno.enabled` | Enable Kyverno policy for credential transformation | `true` |
| `kyverno.injectCa` | Inject internal OpenShift CA into DPA backup locations ending with `.svc:443` | `true` |

### Optional Components

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceMonitor.enabled` | Create ServiceMonitor for monitoring | `true` |
| `objectBucketClaims.enabled` | Create ObjectBucketClaim resources | `true` |

## Secret Naming Convention

The chart uses template-based naming with environment and app variables:

- **Source secrets**: `oadp-${environment}-${app}-backup`, `oadp-${environment}-${app}-restore`
- **Target secrets**: `oadp-${environment}-${app}-backup-cloud-credentials`, `oadp-${environment}-${app}-restore-cloud-credentials`

Example for `environment: test01` and `app: myapp`:
- Source: `oadp-test01-myapp-backup`
- Target: `oadp-test01-myapp-backup-cloud-credentials`

## Backup Locations

The chart creates two backup locations by default:

1. **Primary backup location** (`default: true`): For regular backups
2. **Restore location** (`default: false`): For restore operations

Each location has its own:
- S3 bucket
- AWS credentials (transformed by Kyverno)
- Object prefix for organization

## Resource Allocation

Default NodeAgent resource allocation:
- **Requests**: 500m CPU, 4Gi memory
- **Limits**: 2 CPU, 32Gi memory

These can be adjusted based on your backup workload requirements.

## Dependencies

- apc-global-overrides: ^1.2.0 (provides standardized APC helper functions and labels)

## Troubleshooting

### Kyverno Policy Issues

If credentials are not being transformed:
1. Ensure Kyverno is installed and the CRDs are available
2. Verify source secrets exist in the `apc-backup` namespace
3. Check Kyverno logs for rule evaluation errors
3. Check Kyverno policy reports: `oc get clusterpolicyreport`

### DPA Configuration Issues

If DataProtectionApplication is not ready:
1. Check OADP operator logs
2. Verify cloud credentials are properly formatted
3. Test S3 connectivity from the cluster

### Backup/Restore Issues

1. Check Velero logs: `oc logs -n openshift-adp deployment/velero`
2. Verify backup locations are accessible
3. Check NodeAgent pods: `oc get pods -n openshift-adp -l app=node-agent`
