# OpenShift ADP Backups

Helm chart that renders Velero `Schedule` resources for application backups. Use environment overrides to declare the schedules required for each cluster.

## Values

| Value | Description | Default |
| --- | --- | --- |
| `namespace` | Namespace where schedules are created | `openshift-adp` |
| `schedules` | List of Velero schedule definitions | `[]` |
| `hostedClusters` | Hosted control plane spokes to protect on this hub | `[]` |

## Hosted Control Plane Backups

On a hub cluster, declare each spoke by name and the chart renders the two
Schedules that protect it:

```yaml
hostedClusters:
  - name: spokea2
    schedule: "0 22 * * *"           # control plane backup
    infraEnvSchedule: "15 22 * * *"  # InfraEnv backup
    paused: false                    # optional, default false
    ttl: 336h0m0s                    # optional, default 336h0m0s (14 days)
```

Both cron expressions are required and have no defaults — like every other
schedule in this chart, the times belong to the cluster and are set in the conf
repo. Application backups run in an evening window (prometheus at 20:00, other
workloads through to 23:50), so hosted cluster backups fit naturally after it.

Velero queues concurrent backups, so give each spoke its own slot and leave a gap
between its two schedules instead of starting them together.

A spoke occupies four namespaces on the hub, all derived from its name — so only
the name is configurable:

| Namespace | Contents | Schedule |
| --- | --- | --- |
| `<name>` | HostedCluster, NodePool, ManagedCluster addons | `hcp-<name>` |
| `<name>-<name>` | HostedControlPlane and its workloads | `hcp-<name>` |
| `klusterlet-<name>` | ACM klusterlet (hosted mode) | `hcp-<name>` |
| `infrastructure-<name>` | InfraEnv, agents, nmstateconfigs | `infraenv-<name>` |

The cluster-scoped `ManagedCluster` is included as well; a namespace-only backup
would miss it. The InfraEnv gets its own Schedule because it lives in a separate
namespace and must be restorable independently of the control plane.

`ManagedCluster` is cluster-scoped, so Velero's resource-type inclusion is not
spoke-filtered: every spoke's `hcp-<name>` backup contains every hub's
`ManagedCluster` objects, not just its own. This is a small, fixed-size set (one
per spoke) and Velero's default restore skips resources that already exist, so
restoring one spoke does not overwrite another's.

The resource filters are fixed by the chart and intentionally not configurable —
each one fixes a restore failure reproduced on a live cluster:

- everything is captured (`'*'`) rather than a curated resource list; a curated
  list silently dropped roughly half the objects needed to rebuild the spoke
- `pods` and `replicasets.apps` are excluded: a restored bare Pod carries a dead
  network sandbox and blocks its ReplicaSet from creating a healthy one
- `snapshotMoveData: false` — etcd data is protected by the hosted-etcd snapshot
  CronJob, not by Velero

The chart also renders a Kyverno `ClusterPolicy` labelling the ACM registration
credentials (`<cluster>-import`, `bootstrap-hub-kubeconfig`,
`hub-kubeconfig-secret`) with `velero.io/exclude-from-backup: "true"`, so they
are never captured. They are bound to the `ManagedCluster` identity and must be
regenerated on restore, not restored — restoring the old secret leaves the
klusterlet failing `Unauthorized` and the managed cluster never re-registers.
This runs regardless of `hostedClusters`, since Kyverno matches by label/name,
not by spoke. Requires the Kyverno operator on the hub.

## Restore Notice

> [!NOTE]
> Velero restore objects are ephemeral and should be created manually. As the OKD documentation states: “The `velero restore create` command creates restore resources in the cluster. You must delete the resources created as part of the restore after you review them.” — [OKD docs](https://docs.okd.io/latest/backup_and_restore/application_backup_and_restore/backing_up_and_restoring/restoring-applications.html)

## Schedule Guidelines

- Always target the intended namespace/project in `spec.template.includedNamespaces` and list the resources you want to include (or exclude) so backups remain focused.
- Specify a TTL around 1–3 days (`spec.template.ttl`) and provide the cron expression (`spec.schedule`) to control retention and cadence.
- Do **not** set `spec.template.backupStorageLocation`; schedules use the default location defined by the DataProtectionApplication.

Example (from rendered schedule):

```yaml
schedules:
  - name: 01-test01-prometheus
    spec:
      schedule: "0 20 * * *"
      template:
        includedNamespaces:
          - openshift-user-workload-monitoring
          - openshift-monitoring
        includedResources:
          - configmaps
          - persistentvolumes
          - persistentvolumeclaims
        ttl: 24h
```

## TODO

- Move platform component backup schedules (Quay, Prometheus, XCA) into their respective charts once those components are deployed via GitOps.
```
