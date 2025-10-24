# OpenShift ADP Config

Helm chart that prepares OpenShift Application Data Protection (OADP) for application backups. It renders:

- a `DataProtectionApplication` (DPA) with two backup locations (backup and restore)
- optional `ObjectBucketClaim` resources for Ceph RGW backed storage
- a Kyverno policy that mirrors cloud credentials from `apc-backup` into `openshift-adp`
- optional ServiceMonitor resources for Velero metrics

## Requirements

- OADP operator installed in the cluster
- Kyverno operator when `kyverno.enabled` is `true`
- ObjectBucketClaim provisioning (Ceph RGW) if `objectBucketClaims.enabled` is `true`
- Source secrets containing `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` in `apc-backup`

## Values

### Namespaces & Credentials

| Value | Description | Default |
| --- | --- | --- |
| `sourceNamespace` | Namespace containing the original cloud credentials | `apc-backup` |
| `targetNamespace` | Namespace where OADP resources and transformed secrets are created | `openshift-adp` |
| `credentials.backup.sourceName` | Explicit source secret name (backup); auto-generated when `~` | `~` |
| `credentials.backup.targetName` | Target secret name override (backup) | `~` |
| `credentials.restore.sourceName` | Explicit source secret name (restore); auto-generated when `~` | `~` |
| `credentials.restore.targetName` | Target secret name override (restore) | `~` |

### DataProtectionApplication

| Value | Description | Default |
| --- | --- | --- |
| `dpa.name` | Name of the rendered DPA | `apc-dpa` |
| `dpa.backupLocations` | Array with backup location overrides | see `values.yaml` |
| `dpa.s3.region` | S3 region | `us-east-1` |
| `dpa.s3.url` | S3 endpoint URL | `https://rook-ceph-rgw-ocs-storagecluster-cephobjectstore.openshift-storage.svc:443` |
| `dpa.s3.forcePathStyle` | Enable path-style addressing | `"true"` |
| `dpa.s3.insecureSkipTLSVerify` | Skip TLS verification for S3 endpoint | `"true"` |
| `dpa.s3.caCert` | Base64 or PEM CA bundle (leave blank to skip) | `~` |
| `dpa.velero.defaultPlugins` | Velero plugins | `[openshift, aws, kubevirt, csi]` |
| `dpa.velero.defaultSnapshotMoveData` | Enable snapshot move data | `true` |
| `dpa.velero.defaultVolumesToFSBackup` | Enable filesystem backups by default | `false` |
| `dpa.velero.resourceTimeout` | Velero reconcile timeout | `60m` |
| `dpa.nodeAgent.enabled` | Enable NodeAgent | `true` |
| `dpa.nodeAgent.uploaderType` | Uploader implementation | `kopia` |
| `dpa.nodeAgent.resourceAllocations.requests` | CPU / memory requests | `500m` / `4Gi` |
| `dpa.nodeAgent.resourceAllocations.limits` | CPU / memory limits | `"2"` / `32Gi` |

### Kyverno

| Value | Description | Default |
| --- | --- | --- |
| `kyverno.enabled` | Render Kyverno secret-transform policy and related objects | `true` |

### ObjectBucketClaims

| Value | Description | Default |
| --- | --- | --- |
| `objectBucketClaims.enabled` | Render ObjectBucketClaims | `true` |
| `objectBucketClaims.backup.name` | OBC name override for backup bucket | `~` |
| `objectBucketClaims.backup.storageClassName` | StorageClass for backup OBC | `~` (defaults to `ocs-storagecluster-ceph-rgw`) |
| `objectBucketClaims.restore.name` | OBC name override for restore bucket | `~` |
| `objectBucketClaims.restore.storageClassName` | StorageClass for restore OBC | `~` |

### Monitoring

| Value | Description | Default |
| --- | --- | --- |
| `serviceMonitor.enabled` | Create ServiceMonitor for Velero | `true` |
| `serviceMonitor.namespace` | Namespace for ServiceMonitor | `openshift-adp` |
| `prometheusRule.enabled` | Create PrometheusRule alerts | `true` |
| `prometheusRule.namespace` | Namespace for PrometheusRule | `openshift-adp` |
| `prometheusRule.name` | PrometheusRule resource name | `oadp-monitoring-rules` |

## Secret Flow

When `kyverno.enabled` is `true`:

1. Source secret (`apc-backup/<default name>`) contains `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
2. Kyverno `ClusterPolicy` generates / syncs a target secret in `openshift-adp` containing the `cloud` data expected by Velero.
3. The DPA references the generated target secret for each backup location.

You can override secret names via the `credentials.*` block if your naming does not follow the defaults (defaults resolve to `oadp-<cluster>-app-backup` / `oadp-<cluster>-app-backup-cloud-credentials` for backup and `oadp-<cluster>-app-restore` / `oadp-<cluster>-app-restore-cloud-credentials` for restore).
By default Kyverno reads the credentials from `sourceNamespace` (`apc-backup`) and writes the transformed secret to `targetNamespace` (`openshift-adp`).

> [!NOTE]
> Velero restore objects are ephemeral and should be created manually. Red Hat’s guidance states: “The `velero restore create` command creates restore resources in the cluster. You must delete the resources created as part of the restore after you review them.” — [OKD documentation](https://docs.okd.io/latest/backup_and_restore/application_backup_and_restore/backing_up_and_restoring/restoring-applications.html)

## Object Storage

Two backup locations are rendered by default:

- **Default backup** (`default: true`): shared bucket used by application backups, defaults to `oadp-<cluster>-app-backup`.
- **Restore helper** (`default: false`): helper bucket for restore workflows, defaults to `oadp-<cluster>-app-restore`.

Override buckets, prefixes, or mark locations as default by editing `dpa.backupLocations` or supplying environment-specific values.

## Notes

- TLS verification is disabled by default (`insecureSkipTLSVerify: "true"`). Provide a CA bundle and set it to `"false"` in your environment overrides when the endpoint has a trusted certificate.
- All helper defaults (names, buckets) rely on `apc-global-overrides`; ensure the dependency is present in `Chart.yaml`.
