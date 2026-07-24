# Logging Instance

This Helm chart configures OpenShift logging infrastructure (LokiStack, ClusterLogForwarder, UIPlugin) on a cluster.

## Description

This chart deploys the `LokiStack`, `ClusterLogForwarder` and `UIPlugin` custom resources that make up the logging stack on a cluster, along with the supporting `ObjectBucketClaim`, `ServiceAccount`/`ClusterRoleBinding`s, (on spoke clusters) the `ExternalSecret` needed to forward audit logs to the hub, and (optionally) a `monitoring-reminder` `PrometheusRule` warning before that secret's token expires. It requires the Loki Operator and OpenShift Logging Operator to be already installed (use the `loki-operator` and `cluster-logging-operator` charts for that).

## Prerequisites

- Loki Operator and OpenShift Logging Operator must be installed
- ODF/NooBaa (or another `ObjectBucketClaim`-compatible storage provisioner) must be available for the LokiStack object storage bucket

## Configuration

The chart is configured through `values.yaml`. Key parameters include:

- `objectBucketClaim.name` / `objectBucketClaim.bucketName`: override the generated `ObjectBucketClaim`/bucket name (needed when adopting an existing, already-provisioned bucket instead of the default release-name-based one)
- `lokistack.name`: override the `LokiStack` (and matching `ClusterLogForwarder` output / `UIPlugin` reference) name - needed when adopting an existing `LokiStack` instead of the default release-name-based one
- `lokistack.*`: LokiStack sizing, storage, replication, ingestion/query limits and retention
- `uiplugin.timeout`: request timeout for the Logging UIPlugin (defaults to `120s`, a workaround for [this issue](https://access.redhat.com/solutions/6998442))
- `collector.resources`: resource requests/limits for the log collector
- `auditToHub.enabled` / `auditToHub.url`: forward audit logs to the hub's Loki gateway (spoke clusters). Enables both the `hub-loki-audit` output and the `audit-to-hub` pipeline in the `ClusterLogForwarder`; requires the `hub-spoke-logforward` token secret (see `externalSecret` below)
- `pgaudit.enabled` / `pgaudit.url`: forward CloudNativePG audit logs to an external vector webhook endpoint
- `externalSecret.refreshInterval`: the `hub-spoke-logforward` `ExternalSecret` used to authenticate `auditToHub` forwarding against the hub. Created automatically on spoke clusters only (not on the hub) - there is no toggle to override this
- `monitoring-reminder.reminders`: [monitoring-reminder](https://github.com/gr8it/charts-openshift/tree/main/charts/monitoring-reminder) dependency used to alert before the `hub-spoke-logforward` token expires. The token is created manually (see below), so the chart has no way to know its expiry - left empty (`{}`) by default, no `PrometheusRule` is created. **When deploying to a spoke cluster, this must be set in the conf repo** with the actual expiry `datetime` of the token. See `values.lint.yaml` or `values.example.yaml` for the expected fields

This chart intentionally does not include Loki `AlertingRule` resources (ACS policy violation alerts, HW/infrastructure event alerts):
- ACS alert delivery is expected to go through the RHACS Generic Webhook -> Vector -> Jira Operations path instead of Loki/Alertmanager.
- HW/infrastructure event alerting doesn't belong in a logging-config chart; tracked as a follow-up to move it into a dedicated HW-monitoring chart.

The `spoke-logforward` `ServiceAccount`/`ClusterRoleBinding` (whose token spokes authenticate `auditToHub` requests with) is created automatically on the hub — it is not a separate toggle, it follows the same hub/spoke cluster detection as `externalSecret` above.

### `hub-spoke-logforward` secret content

The `TOKEN` synced by `externalSecret` (Vault key `<platform>/<environmentShort>/openshift-logging/hub-spoke-logforward`) is a long-lived bound token for the `spoke-logforward` `ServiceAccount`, created on the hub (namespace `openshift-logging`, bound to the `cluster-logging-write-audit-logs` `ClusterRole`). It authorizes the bearer to push audit logs into the hub's Loki gateway.

The token is currently created and stored in Vault manually, on the hub, via:

```bash
TOKEN=`oc create token spoke-logforward -n openshift-logging --duration=$((720*24))h`
```

Automating this rotation is tracked separately as a follow-up.

## Usage

```yaml
objectBucketClaim:
  name: logging-loki-rgw

auditToHub:
  enabled: true
  url: "https://loki-gateway-openshift-logging.apps.hub01.example.com/api/logs/v1/audit/loki/api/v1/push"

externalSecret:
  refreshInterval: "15m"

monitoring-reminder:
  reminders:
    HubSpokeLogforwardTokenExpirySoon:
      summary: "hub-spoke-logforward Vault token is expiring soon"
      description: "..."
      datetime: "01.04.2027"
```
