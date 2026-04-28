# ACS Security Policies

This directory contains Red Hat Advanced Cluster Security (RHACS) policy definitions in JSON format for import into ACS Central.

## Policies Included

### containers-critical-fixable-cves.json

**Purpose:** Detects containers with fixable Critical CVEs.

**Important:** The exported policy is **disabled by default** and remains **inform-only** when enabled. It does **not** block deployments or `oc debug` flows.

**Policy Behavior:**
- **Mode:** Disabled by default; inform-only when enabled
- **Scope:** Containers with fixable vulnerabilities at severity >= Critical
- **Lifecycle Stage:** DEPLOY (checks deployments, not runtime)
- **Enforcement Actions:** None (empty) - violations appear in ACS dashboard only
- **Notifiers:** Not configured (must be set up per environment)

**Why Inform-Only Mode?**
- Compatible with GitOps/ArgoCD workflows (no deployment blocking or auto-scaling)
- Allows vulnerability detection without operational disruption
- Team can review violations and remediate through Git commits
- Prevents conflicts between ACS enforcement and ArgoCD reconciliation

## Namespace Exclusions

The policy excludes these namespaces from scanning:

- **Core Kubernetes/OpenShift:**
  - `kube-system`
  - `openshift` (exact match)
  - `openshift-*` (all openshift- prefixed namespaces)

- **Security & Management:**
  - `stackrox` (ACS Central/Scanner)
  - `open-cluster-management`
  - `hive`
  - `hypershift`

- **Cluster Infrastructure:**
  - `infrastructure-*` (regex pattern for all infrastructure namespaces)
  - `klusterlet-*` (regex pattern for managed cluster agents)

- **HCP Hosted Cluster Namespaces:**
  - `dev01`, `dev01-dev01`
  - `test01`, `test01-test01`
  - `prod01`, `prod01-prod01`

**Note:** Update the exclusions list via UI after import if your environment has additional core namespaces.

## How to Import the Policy

### Prerequisites
- RHACS Central instance is deployed and accessible
- You have admin access to ACS Central
- For CLI import: `roxctl` CLI tool installed

### Option 1: Import via ACS UI

1. Log in to ACS Central web console
2. Navigate to **Platform Configuration → Policy Management**
3. Click **Import policy** button
4. Upload `containers-critical-fixable-cves.json`
5. Review the policy details, especially that it imports as disabled
6. Click **Import**
7. Edit the policy and enable it after notifier setup and validation

## Jira Integration Status

The policy ships without notifiers configured (`"notifiers": []`) to ensure portability across environments.

Current verified state:
- Native RHACS Jira notifier works and successfully creates `Task` issues in project `SPEXAPC`, but this path was rejected architecturally.
- ACS -> Loki -> Alertmanager -> Jira was rejected for this use case because it overloads the logging path.
- RHACS Generic Webhook -> Jira Operations API was tested directly and failed because RHACS sends an `alert` object payload while Jira Operations expects top-level alert fields.
- Jira webhook-style translation on the Jira side is not available in the current Jira package.
- The remaining approved direction is a small translation layer in Vector: `RHACS -> Vector -> Jira Operations`.

## Recommended Architecture

Use the existing Vector deployment on `hub01` as the adapter:

1. RHACS Generic Webhook posts the native ACS JSON payload to the existing Vector `http_server` input on `https://vector.hub01.cloud.socpoist.sk:9444`.
2. Vector `remap` transforms the ACS event into a Jira Operations alert payload.
3. Vector HTTP sink posts the transformed JSON to `https://api.atlassian.com/jsm/ops/integration/v2/alerts`.

This fits the current cluster topology already present in `conf-socpoist`:
- `hub01` already runs a dedicated Vector deployment with a TLS-enabled webhook listener on port `9444`.
- `dev01`, `test01`, and `prod01` already use hub Vector as an HTTP target in their `ClusterLogForwarder` configuration.
- Hub Vector already handles ACS-shaped webhook events for Loki labeling, so this adds an outbound sink instead of introducing a new runtime.

## ACS Generic Webhook Setup

Create a RHACS **Generic Webhook** notifier, not the native Jira notifier.

Use these values:

| ACS Webhook field | Value |
|---|---|
| Endpoint | `https://vector.hub01.cloud.socpoist.sk:9444` |
| Extra field `gr8it` | `acs-audit-log` |
| Extra field `central_base_url` | `https://central-stackrox.apps.hub01.cloud.socpoist.sk` |

Notes:
- `gr8it=acs-audit-log` lets Vector distinguish these events from any other webhook traffic hitting the shared input.
- `central_base_url` is used to build a clickable RHACS violation URL in the Jira alert description.
- Attach this notifier only to the intended policy after the Vector sink is in place.

### Native Jira Values (Rejected Path)

Use these values in ACS for the native Jira notifier:

| ACS Jira field | Value |
|---|---|
| Integration name | `ACS-to-Jira-SPEXAPC-Security` |
| Jira URL | `https://aspecta.atlassian.net` |
| Username / Email | Jira user or service account with access to create issues in `SPEXAPC` |
| Password or API token | Jira API token for that user |
| Default project | `SPEXAPC` |
| Issue type | `Task` |
| Verify TLS | Enabled |
| Disable setting priority | Unchecked |
| CRITICAL_SEVERITY | `Highest` |
| HIGH_SEVERITY | `High` |
| MEDIUM_SEVERITY | `Medium` |
| LOW_SEVERITY | `Low` |

Observed behavior from the RHACS Jira test:
- RHACS creates a Jira work item directly in project `SPEXAPC`
- the test created a `Task`
- the created item is a normal Jira issue, not a Jira Operations alert

### Native Jira Setup Steps (Rejected Path)

1. **Create notifier integration in ACS:**
   - Navigate to **Platform Configuration → Integrations → Notifier Integrations**
   - Click **New Integration**
   - Select **Jira**
   - Fill the form with the exact values listed above
   - Test the integration
   - Save

   **Example: Jira Integration Setup**

   ![Jira Integration Form](jira-integration.png)

   Use the screenshot fields like this:
   - **Integration name**: `ACS-to-Jira-SPEXAPC-Security`
   - **Username**: Jira service account from Vault or Jira admin
   - **Password or API token**: Jira API token from Vault or Jira admin
   - **Issue type**: `Task`
   - **Jira URL**: `https://aspecta.atlassian.net`
   - **Default project**: `SPEXAPC`
   - **Annotation key for project**: leave empty
   - **Disable setting priority**: unchecked
   - **Priority Mapping: CRITICAL_SEVERITY**: `Highest`
   - **Priority Mapping: HIGH_SEVERITY**: `High`
   - **Priority Mapping: MEDIUM_SEVERITY**: `Medium`
   - **Priority Mapping: LOW_SEVERITY**: `Low`

2. **Attach notifier to this policy:**
   - Navigate to **Platform Configuration → Policy Management**
   - Find policy: "Containers with Critical Fixable CVEs"
   - Click **Actions → Edit policy**
   - Scroll to **Policy Behavior** section
   - Under **Configure notifications**, attach your notifier(s)
   - Enable the policy after the notifier is configured and tested
   - Save

### Native Jira Validation Checklist (Rejected Path)

1. In ACS, run **Test Integration** and confirm success.
2. Verify that the test creates or validates creation of a Jira issue in project `SPEXAPC`.
3. Remember that the RHACS Jira notifier creates Jira issues, not Jira Operations alerts.
4. Attach the notifier only to the intended policy.
5. Trigger a controlled test violation in a non-production namespace.
6. Confirm exactly one Jira issue is created in `SPEXAPC`.

### Jira Operations API Note

The following path is the target endpoint for the Vector bridge:
- Vector HTTP sink -> Jira Operations integration API (`https://api.atlassian.com/jsm/ops/integration/v2/alerts`)

Why the direct ACS -> Jira path fails:
- RHACS Generic Webhook sends a fixed payload containing an `alert` object plus optional custom fields.
- Jira Operations create-alert API expects top-level fields such as `message`, `alias`, `description`, `details`, `source`, and `priority`.
- Direct posting from RHACS to Jira Operations therefore fails validation.

What the Vector bridge does:
- maps ACS severities to Jira Ops priorities (`CRITICAL -> P1`, `HIGH -> P2`, `MEDIUM -> P3`, `LOW -> P4`)
- uses the ACS alert id as Jira `alias` for deduplication
- keeps RHACS metadata under Jira `details`
- builds a RHACS violation URL when `central_base_url` is supplied as an ACS extra field

## Vector Bridge Notes

The Vector implementation belongs in `conf-socpoist/ocp-hub01/observability/vector`, not in this chart.

Secret handling model:
- provide a Kubernetes secret named `jira-ops` in namespace `apc-logging`
- store the full header value under key `authorization`, for example `GenieKey <api-key>`
- let Vector read it from `/var/run/ocp-collector/secrets/jira-ops`

Keep the API key out of Git, Helm values, and this chart. Store it in Vault and materialize it into the cluster as a Kubernetes secret.

Do not store Jira credentials in Git, Helm values, or this chart. Keep them in Vault and inject them only at runtime.
