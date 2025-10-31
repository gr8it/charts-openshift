# OpenShift ADP Backups

Helm chart that renders Velero `Schedule` resources for application backups. Use environment overrides to declare the schedules required for each cluster.

## Values

| Value | Description | Default |
| --- | --- | --- |
| `namespace` | Namespace where schedules are created | `openshift-adp` |
| `schedules` | List of Velero schedule definitions | `[]` |

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
