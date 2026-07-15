# Logging Instance

This Helm chart configures OpenShift logging infrastructure (LokiStack, ClusterLogForwarder, UIPlugin) on a cluster.

## Description

This chart deploys the `LokiStack`, `ClusterLogForwarder` and `UIPlugin` custom resources that make up the logging stack on a cluster, along with the supporting `ObjectBucketClaim`, `ServiceAccount`/`ClusterRoleBinding`s and (on spoke clusters) the `ExternalSecret` needed to forward audit logs to the hub. It requires the Loki Operator and OpenShift Logging Operator to be already installed (use the `loki-operator` and `cluster-logging-operator` charts for that).

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
- `hub.alertingRules.hwEvents.enabled`: hub-only Loki `AlertingRule` for HW/infrastructure event alerts (UPS/PDU/XCA), evaluated against the `audit` tenant

ACS policy violation alerting via Loki `AlertingRule` is intentionally not included — ACS alert delivery is expected to go through the RHACS Generic Webhook -> Vector -> Jira Operations path instead. See the conf repo's `ocp-hub01/observability/logging/10-acs-policy-alerts.yaml` for the historical (unused) manifest.

The `spoke-logforward` `ServiceAccount`/`ClusterRoleBinding` (whose token spokes authenticate `auditToHub` requests with) is created automatically on the hub — it is not a separate toggle, it follows the same hub/spoke cluster detection as `externalSecret` above.

### `hub-spoke-logforward` secret content

The `TOKEN` synced by `externalSecret` (Vault key `<platform>/<environmentShort>/openshift-logging/hub-spoke-logforward`) is a long-lived bound token for the `spoke-logforward` `ServiceAccount`, created on the hub (namespace `openshift-logging`, bound to the `cluster-logging-write-audit-logs` `ClusterRole`). It authorizes the bearer to push audit logs into the hub's Loki gateway.

The token is currently minted and stored in Vault manually, on the hub, via:

```bash
TOKEN=`oc create token spoke-logforward -n openshift-logging --duration=$((720*24))h`
```

(see the conf repo's `ocp-hub01/observability/logging/09-ocp-log-fw-audit-spoke2hub.sh`). Automating this rotation is tracked separately as a follow-up.

## Usage

```yaml
objectBucketClaim:
  name: logging-loki-rgw

auditToHub:
  enabled: true
  url: "https://loki-gateway-openshift-logging.apps.hub01.example.com/api/logs/v1/audit/loki/api/v1/push"

externalSecret:
  refreshInterval: "15m"
```
