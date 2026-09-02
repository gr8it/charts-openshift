# SPEXAPC-8225 — Alert audit and Phase 2

## Purpose

Phase 1 addressed the ArgoCD alert group. Phase 2 starts the remaining APC alert audit from the current `charts-openshift` `main` branch. The audit is intentionally incremental: each chart is reviewed independently, and only a demonstrated presentation or diagnostic problem is changed.

## Inventory from `charts-openshift/main`

Alert-producing definitions are present in 35 chart source areas. They cover:

- reusable Kubernetes workload rules (`monitoring-prometheusrules`);
- cluster and user-workload monitoring wrappers (`monitoring`, `user-workload-monitoring-policy`);
- blackbox/target monitoring;
- storage, backup, hardware, Vault, LDAP, and operator health;
- Kafka, MirrorMaker, Kafka Bridge, MongoDB, Keycloak, ACS, Kyverno, OpenTelemetry, Tempo, and Veeam.

The audit distinguishes diagnostic labels from scrape metadata. Labels naming the failing object are retained; labels identifying only the Prometheus scrape target are candidates for omission from the notification description.

## Phase 2 first implementation

The first selected chart is `monitoring-prometheusrules`, a reusable library consumed by both `monitoring` and `user-workload-monitoring-policy`.

Its 25 generic Kubernetes rules already define runbook URLs in `values.yaml`, but the three shared rendering helpers output only `description` and `summary`. Consequently, the runbook links are lost from the generated PrometheusRule annotations and cannot be shown by downstream notification templates.

The Phase 2 change preserves the configured `runbook_url` annotation in all three helper paths:

- application namespace rules;
- platform namespace rules;
- cluster-monitoring rules.

The change does not remove object-identifying labels such as `namespace`, `pod`, `container`, `deployment`, `job_name`, or `persistentvolumeclaim`. Those labels are part of the diagnosis for the relevant rule and will be reviewed individually in later alert-group changes.

## Versioning and compatibility

`monitoring-prometheusrules` is versioned from `1.0.7` to `1.1.0`. The minor bump records the additive optional `runbook_url` annotation output and requires consuming charts to update their dependency version before adoption.

This first implementation changes only the reusable library chart. Updating and re-rendering its consumers is the next step after the library change is reviewed.

## Verification

- Helm lint must pass.
- The generated output must contain `runbook_url` when configured.
- The generated output must omit `runbook_url` when it is not configured.
- Existing rule expressions, severity, routing labels, and object-identifying labels must remain unchanged.
- The chart package and index must be regenerated.

## Not included in this phase

- ArgoCD alerts; covered by Phase 1.
- A global label blacklist.
- Changes to every remaining alert chart in one release.
- Direct cluster changes or deployment.
