# Monitoring-reminder

Helm chart creates a `PrometheusRule` containing static date-based reminder alerts. Use it to fire a warning (and optionally a critical) alert before a known expiry date — for example a client secret, a certificate, or an API key stored outside the cluster.

## Installation

When monitoring an **external dependency** (anything outside the cluster — external certificates, API keys, etc.) the chart should be installed in the `apc-observability` namespace so that the Prometheus instance that scrapes cluster-wide rules picks it up:

```bash
helm upgrade --install gitlab-token-reminder gr8it-openshift/monitoring-reminder \
  --namespace apc-observability \
  -f values.yaml
```

If you are co-locating the reminder with the component it monitors (e.g. an in-cluster secret), install it in that component's namespace instead.

## Configuration

### Top-level values

| Value | Default | Description |
|---|---|---|
| `releaseServiceOverride` | _unset_ | Overrides `app.kubernetes.io/managed-by` label (e.g. `ArgoCD`). |
| `defaultLabels` | `vendor: aspecta`<br>`team: platform` | Labels applied to every alert rule. Per-reminder `labels` take precedence. |
| `reminders` | `[]` | List of reminder rules (see below). |

### Per-reminder fields

| Field | Required | Description |
|---|---|---|
| `alert` | yes | Prometheus alert name (used for routing/deduplication), e.g. `OIDCVaultSecretExpirySoon`. |
| `summary` | yes | Short annotation shown in alert notifications. |
| `description` | yes | Detailed annotation explaining context and impact. |
| `datetime` | yes | Expiry date in `dd.mm.yyyy` or `dd.mm.yyyy HH:MM` format. Time defaults to `00:00` when omitted. **Always interpreted as UTC.** |
| `daysBeforeExpiry` | no | How many days before the expiry date to fire the warning alert. Default: `30`. |
| `runbookUrl` | no | URL to the remediation runbook. |
| `critical` | no | If `true`, adds a second alert (`<alert>Critical`) with `severity: critical` that fires when fewer than 1 day remains. Default: `false`. |
| `labels` | no | Extra labels or overrides for this specific alert (merged over `defaultLabels`). |

## Usage examples

### Minimal — single warning alert

```yaml
reminders:
  - alert: OIDCVaultSecretExpirySoon
    summary: Azure Entra ID secret for vault.lab.gr8it.cloud OIDC expires soon
    description: >
      Azure Entra ID client secret used for OIDC authentication in vault.lab.gr8it.cloud
      expires soon. After expiry, login to Vault via OIDC will stop working.
    datetime: "01.04.2027" # UTC!
```
