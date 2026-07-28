# Kyverno Backup Exclusions

Renders a Kyverno `ClusterPolicy` that labels regenerable ACM registration
credentials with `velero.io/exclude-from-backup: "true"`, so OADP/Velero leaves
them out of backups.

Deploy on **hub** clusters that host spoke (hosted control plane) clusters,
alongside the `openshift-adp-backups` chart.

## Why

These secrets are bound to a `ManagedCluster` identity:

| Secret | Namespace |
| --- | --- |
| `<cluster>-import` | the ManagedCluster namespace |
| `bootstrap-hub-kubeconfig` | `klusterlet-<cluster>` |
| `hub-kubeconfig-secret` | `klusterlet-<cluster>` |

When a `ManagedCluster` is deleted its registration identity is revoked. Restoring
the old secret from a backup puts back a credential the hub no longer accepts: the
klusterlet registration-agent fails with `Unauthorized`, never issues a CSR, and
the cluster stays `Available=Unknown`.

This does not recover on its own — it was reproduced on a live spoke and stayed
stuck for 38 minutes with zero CSRs, then registered within minutes once the
secrets were deleted and ACM regenerated them.

Excluding them from the backup means a restore leaves ACM to mint fresh
credentials, and the managed cluster re-registers automatically with no manual
detach or re-import.

## Values

The chart is convention-only and has nothing to configure. The policy matches any
cluster: import secrets by the label ACM sets on them, and klusterlet credentials
by name inside namespaces labelled `createdByKlusterlet`.

## Verify

```bash
oc get clusterpolicy velero-exclude-acm-registration-secrets
```

```bash
oc -n <managedcluster-namespace> get secret <cluster>-import -o jsonpath='{.metadata.labels}'
```

Expect `velero.io/exclude-from-backup: "true"` on the secret.
