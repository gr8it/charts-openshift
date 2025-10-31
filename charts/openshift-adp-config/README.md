# OpenShift ADP Config

Helm chart that prepares OpenShift Application Data Protection (OADP) for application backups. It renders:

- a Kyverno policy that generates the `DataProtectionApplication` (DPA) with two backup locations (backup and restore)
- namespaced RBAC granting Kyverno permission to manage the DPA
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
| `dpa.s3.forcePathStyle` | Enable path-style addressing (accepts boolean or string; rendered as string) | `true` |
| `dpa.s3.insecureSkipTLSVerify` | Skip TLS verification for S3 endpoint (accepts boolean or string; rendered as string) | `false` |
| `dpa.s3.caCert` | Base64 or PEM CA bundle (leave blank to use the cluster service CA) | `~` |
| `dpa.velero.defaultPlugins` | Velero plugins | `[openshift, aws, kubevirt, csi]` |
| `dpa.velero.defaultSnapshotMoveData` | Enable snapshot move data | `true` |
| `dpa.velero.defaultVolumesToFSBackup` | Enable filesystem backups by default | `false` |
| `dpa.velero.resourceTimeout` | Velero reconcile timeout | `60m` |
| `dpa.nodeAgent.enabled` | Enable NodeAgent | `true` |
| `dpa.nodeAgent.uploaderType` | Uploader implementation | `kopia` |
| `dpa.nodeAgent.resourceAllocations.requests` | CPU / memory requests | `500m` / `4Gi` |
| `dpa.nodeAgent.resourceAllocations.limits` | CPU / memory limits | `"2"` / `32Gi` |

> The S3 booleans are coerced to strings in the rendered manifest to match Velero's configuration map; you may supply either `true`/`false` or the quoted string equivalents in your values.

### Kyverno

| Value | Description | Default |
| --- | --- | --- |
| `kyverno.enabled` | Render Kyverno secret-transform policy and related objects | `true` |
| `kyverno.generateExisting` | Create generated resources immediately if the source already exists | `true` |
| `kyverno.synchronize` | Continuously reconcile generated resources to match the source | `true` |
| `kyverno.orphanDownstreamOnPolicyDelete` | Leave generated resources in place if the policy is removed | `true` |
| `kyverno.dpaPolicy.enabled` | Generate the DPA through Kyverno using the namespace-local service CA | `true` |
| `kyverno.dpaPolicy.serviceAccountNamespace` | Namespace containing Kyverno service accounts | `apc-kyverno` |
| `kyverno.dpaPolicy.serviceAccounts` | Service accounts granted access to manage the DPA | `[kyverno-background-controller, kyverno-admission-controller]` |
| `kyverno.dpaPolicy.rbac.create` | Toggle creation of the helper Role/RoleBinding | `true` |

> [!NOTE]
> The Kyverno DPA policy consumes this configuration. If Kyverno is disabled you must manage the DPA manifest outside of this chart.

### ObjectBucketClaims

| Value | Description | Default |
| --- | --- | --- |
| `objectBucketClaims.enabled` | Render ObjectBucketClaims | `true` |
| `objectBucketClaims.backup.name` | ObjectBucketClaim resource name used by the DPA (`<cluster>` from `apc-global-overrides.clusterName`) | `~` (renders to `oadp-<cluster>-app-backup`) |
| `objectBucketClaims.backup.storageClassName` | StorageClass for backup OBC | `~` (renders to `ocs-storagecluster-ceph-rgw`) |
| `objectBucketClaims.backup.generateBucketName` | Generated bucket prefix for Ceph RGW; defaults to the resolved OBC name when `~` | `~` |
| `objectBucketClaims.restore.name` | ObjectBucketClaim resource name used by the DPA (`<cluster>` from `apc-global-overrides.clusterName`) | `~` (renders to `oadp-<cluster>-app-restore`) |
| `objectBucketClaims.restore.storageClassName` | StorageClass for restore OBC | `~` (renders to `ocs-storagecluster-ceph-rgw`) |
| `objectBucketClaims.restore.generateBucketName` | Generated bucket prefix for Ceph RGW; defaults to the resolved OBC name when `~` | `~` |

The chart always renders two ObjectBucketClaims (backup + restore). When `dpa.backupLocations`
is empty, the templates inject default names/buckets derived from the cluster name. Supplying a
matching entry in `dpa.backupLocations` or `objectBucketClaims.*` overrides just the fields you
explicitly set while retaining the rest of the defaults.
Put the backup override first (`dpa.backupLocations[0]`) and the restore override second (`dpa.backupLocations[1]`); any missing entries fall back to the chart defaults.

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

- TLS verification is enabled by default (`insecureSkipTLSVerify: "false"`). Only flip it to `"true"` when connecting to an endpoint with an untrusted certificate or during troubleshooting, and ideally pair that with a CA bundle (`dpa.s3.caCert`).
- When `dpa.s3.caCert` is blank the Kyverno policy injects the service-ca bundle (base64-encoded). Supplying your own bundle overrides that value.
- All helper defaults (names, buckets) rely on `apc-global-overrides`; ensure the dependency is present in `Chart.yaml`.

## TODO

- Merge the nearly identical backup/restore ObjectBucketClaim templates into one template.
