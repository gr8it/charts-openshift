# ACS Security Policies

This directory contains Red Hat Advanced Cluster Security (RHACS) policy definitions in JSON format for import into ACS Central.

## Policies Included

### containers-important-critical-fixable-cves.json

**Purpose:** Detects non-privileged containers with fixable Important or Critical CVEs.

**Important:** This is an **inform-only** policy. It does **not** block deployments or `oc debug` flows.

**Policy Behavior:**
- **Mode:** Inform-only (detection without blocking deployments)
- **Scope:** Non-privileged containers with fixable vulnerabilities at severity >= Important
- **Lifecycle Stage:** DEPLOY (checks deployments, not runtime)
- **Enforcement Actions:** None (empty) - violations appear in ACS dashboard only
- **Notifiers:** Not configured (must be set up per environment)

**Why Non-Privileged Only?**
- Privileged containers are covered by a separate policy
- Prevents blocking `oc debug` and emergency troubleshooting pods
- Focuses on regular application workloads where fixes are actionable

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
4. Upload `containers-important-critical-fixable-cves.json`
5. Review the policy details
6. Click **Import**
7. The policy is now active in inform mode

## Configuring Notifiers (Optional)

The policy ships without notifiers configured (`"notifiers": []`) to ensure portability across environments.

### Why Configure Notifiers?

Without notifiers, violations only appear in the ACS dashboard. With notifiers, you get:
- Automatic Jira tickets for security team triage
- Slack/Teams messages for immediate team awareness
- Email alerts for compliance reporting
- PagerDuty incidents for critical violations

### Quick Setup Steps

1. **Create notifier integration in ACS:**
   - Navigate to **Platform Configuration → Integrations → Notifier Integrations**
   - Click **New Integration**
   - Select type: Jira, Slack, MS Teams, Email, PagerDuty, or Generic Webhook
   - Configure connection details and credentials
   - Test the integration
   - Save

   **Example: Jira Integration Setup**
   
   ![Jira Integration Form](jira-integration.png)
   
   *Fill in all required fields:*
   - **Integration Name**: Descriptive name for this notifier (e.g., "ACS to Jira - Security Violations")
   - **Jira Instance URL**: Your Jira Cloud/Server URL
   - **Username/Email**: Jira account with permission to create issues
   - **API Token/Password**: Authentication credentials for the Jira account
   - **Default Project**: Project key where tickets will be created (e.g., SEC, VULN)
   - **Issue Type**: Type of issue to create (Task, Bug, Story, etc.)
   - **Priority Mapping** (optional): Map ACS severity levels to Jira priorities

2. **Attach notifier to this policy:**
   - Navigate to **Platform Configuration → Policy Management**
   - Find policy: "Privileged Containers with Important and Critical Fixable CVEs"
   - Click **Actions → Edit policy**
   - Scroll to **Policy Behavior** section
   - Under **Configure notifications**, attach your notifier(s)
   - Save
