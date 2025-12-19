# OpenShift ETCD Backup

This Helm Chart will deploy an OpenShift ETCD backup CronJob.  
The Job will create etcd snapshot, and uploads it to an S3 endpoint.

## Chart Variables

> [!NOTE]  
> Each variable without a default value is mandatory  

|Variable                         | Type | Default                         |  Notes |
|:---                             |:---  |:---                             |:---    |
| clusterName                     | str  |                                 | Name of the OpenShift Cluster. Defaults to `global.apc.cluster.name` when not set. |
| defaultNamespace                | str  | `apc-backup`                    | Namespace for deploying the backup job. ObjectBucketClaim must be configured in this namespace beforehand. Alternatively, this Helm Chart can create one by setting the `objectBucketClaim.create` variable. |
| etcdBackupSchedule              | str  | `"0 * * * *"`                   | Cron notation for ETCD backup schedule |
| retentionDays                   | int  | `10`                            | Specifies the number of days to retain old backups during the cleanup phase |
| compressSnapshot                | bool | `false`                         | Controls whether to use gzip to compress the snapshot before uploading to S3 |
| objectBucketClaim.name          | str  | `etcd-{clusterName}-backup`     | This parameter is mandatory when using a pre-existing ObjectBucketClaim. Overrides the default ObjectBucketClaim name if `{objectBucketClaim.create}` is `true` |
| objectBucketClaim.storageClass  | str  | `ocs-storagecluster-ceph-rgw`   | An optional parameter that defines a storageClass for the ObjectBucketClaim. Only used when `{objectBucketClaim.create}` is `true` |
| image.awscli                    | str  | `amazon/aws-cli:2.24.27`        | Container image with `aws` cli tool |
| image.busybox                   | str  | `busybox:1.37-glibc`            | Simple container image with `bash` |

## Example Deployment

### Option #1: ObjectBucketClaim for etcd backup already exists

```yaml
# my-values.yaml
clusterName: ocpdemo
defaultNamespace: apc-backup
retentionDays: 7
etcdBackupSchedule: "0 */2 * * *"
compressSnapshot: false
objectBucketClaim:
  create: false
  name: etcd-hub01-backup
image:
  awscli: amazon/aws-cli:2.24.27
  busybox: busybox:1.37-glibc

```

```sh
# add repo
$ helm repo add gr8it https://raw.githubusercontent.com/gr8it/charts/main/
# install
$ helm -n apc-backup install -f my-values.yaml etcd-ocpdemo-backup gr8it/openshift-etcd-backup
NAME: etcd-ocpdemo-backup
LAST DEPLOYED: Fri Mar 30 12:07:19 2025
NAMESPACE: apc-backup
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

### Option #2: ObjectBucketClaim for etcd backup does not exist

```yaml
# my-values.yaml
clusterName: ocpdemo
defaultNamespace: apc-backup
retentionDays: 7
etcdBackupSchedule: "0 */2 * * *"
compressSnapshot: false
objectBucketClaim:
  create: true
  storageClass: "openshift-storage.noobaa.io"
image:
  awscli: amazon/aws-cli:2.24.27
  busybox: busybox:1.37-glibc
```

```sh
# add repo
$ helm repo add gr8it https://raw.githubusercontent.com/gr8it/charts/main/
# install
$ helm -n apc-backup install -f my-values.yaml etcd-ocpdemo-backup gr8it/openshift-etcd-backup
NAME: etcd-ocpdemo-backup
LAST DEPLOYED: Fri Mar 30 09:48:28 2025
NAMESPACE: apc-backup
STATUS: deployed
REVISION: 1
TEST SUITE: None
```
