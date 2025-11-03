# Hosted Control Plane ETCD Backup

This Helm Chart will deploy a Hosted Control Plane ETCD backup job.  
The Job will create a compressed etcd snapshot, and uploads it to an S3 endpoint.

## Chart Variables

> [!NOTE]  
> Each variable without a default value is mandatory  

|Variable                         | Type | Default                         |  Notes |
|:---                             |:---  |:---                             |:---    |
| clusterName                     | str  |                                 | Name of the Hosted Cluster. Defaults to `global.apc.cluster.name` when not set. |
| clusterNamespace                | str  | `{clusterName}-{clusterName}`   | Overrides the default Hosted Cluster namespace | 
| backupNamespace                 | str  | `apc-backup`                    | Namespace for deploying the backup job. ObjectBucketClaim must be configured in this namespace beforehand. Alternatively, this Helm Chart can create one by setting the `objectBucketClaim.create` variable. |
| backupSchedule                  | str  | `"0 * * * *"`                   | Cron notation for ETCD backup schedule |
| retentionDays                   | int  | `30`                            | Specifies the number of days to retain old backups during the cleanup phase  |
| etcdStatefulSetName             | str  | `etcd`                          | An optional parameter that overrides the default etcd StatefulSet name in  the Hosted Cluster namespace |
| compressSnapshot                | bool | `false`                         | Controls whether to use gzip to compress the snapshot before uploading to S3 |
| objectBucketClaim.create        | bool | `false`                         | Determines whether to create an ObjectBucketClaim in the `{backupNamespace}` for storing etcd backups. If set to `false`, an existing ObjectBucketClaim must be referenced with `{objectBucketClaim.name}` |
| objectBucketClaim.name          | str  | `etcd-hcp-{clusterName}-backup` | This parameter is mandatory when using a pre-existing ObjectBucketClaim. Overrides the default ObjectBucketClaim name if `{objectBucketClaim.create}` is `true` |
| objectBucketClaim.storageClass  | str  | `ocs-storagecluster-ceph-rgw`   | An optional parameter that defines a storageClass for the ObjectBucketClaim. Only used when `{objectBucketClaim.create}` is `true` |
| selfSignedCertificate.name      | str  | `openshift-service-ca.crt`      | ConfigMap with private CA in pem format. Set this to reference private CA for accessing s3 storage endpoint via local svc url |
| selfSignedCertificate.key       | str  | `service-ca.crt`                | Key name in the ConfigMap that references the private CA file |
| image.awscli                    | str  | `amazon/aws-cli:2.24.27`                       | Container image with `aws` cli tool |
| image.ocpcli                    | str  | `registry.redhat.io/openshift4/ose-cli:v4.15`  | Container image with `kubectl` and `oc` cli tool |
| image.etcd                      | str  | `registry.redhat.io/openshift4/ose-etcd:v4.12` | Container image with `etcdctl` and `etcdutl` cli tool |

## Example Deployment

### Option #1: ObjectBucketClaim for etcd backup already exists

```yaml
# my-values.yaml
clusterName: ocpdemo-spoke2
backupNamespace: apc-backup
backupSchedule: "20 */3 * * *"
retentionDays: 10
objectBucketClaim:
  name: etcd-hcp-ocpdemo-spoke2
selfSignedCertificate:
  configMap: openshift-service-ca.crt
  name: service-ca.crt
```

```sh
$ helm -n apc-backup install -f my-values.yaml etcd-hcp-ocpdemo-spoke2-backup .
NAME: etcd-hcp-ocpdemo-spoke2-backup
LAST DEPLOYED: Fri Mar 28 10:08:09 2025
NAMESPACE: apc-backup
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

### Option #2: ObjectBucketClaim for etcd backup does not exist

```yaml
# my-values.yaml
clusterName: ocpdemo-spoke1
backupNamespace: apc-backup
backupSchedule: "30 */3 * * *"
retentionDays: 10
objectBucketClaim:
  create: true
  storageClass: openshift-storage.noobaa.io
selfSignedCertificate:
  configMap: openshift-service-ca.crt
  name: service-ca.crt
```

```sh
$ helm -n apc-backup install -f my-values.yaml etcd-hcp-ocpdemo-spoke1-backup .
NAME: etcd-hcp-ocpdemo-spoke1-backup
LAST DEPLOYED: Fri Mar 28 08:48:48 2025
NAMESPACE: apc-backup
STATUS: deployed
REVISION: 1
TEST SUITE: None
```
