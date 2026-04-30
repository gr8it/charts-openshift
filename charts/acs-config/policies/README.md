# ACS Policies

This directory contains RHACS policy definitions and the minimum documentation needed for the ACS to Jira Operations implementation used in `conf-socpoist`.

## Policy in this folder

`containers-critical-fixable-cves.json`

Purpose:
- Detect containers with fixable Critical CVEs
- Intended test policy for the ACS to Jira Operations flow
- Inform-only policy; it does not block deployments

Notes:
- The exported policy ships without notifiers so it can be imported into different environments
- In ACS, attach the notifier after import

## Integration used in `conf-socpoist`

Environment:
- `conf-socpoist`
- cluster: `hub01`

ACS integration used for this implementation:
- RHACS notifier type: `Generic Webhook`
- integration name: `acs-vector-jira`

Flow:
1. RHACS sends the native ACS alert payload to Vector
2. Vector remaps the ACS payload into Jira Operations alert JSON
3. Vector sends the transformed payload to Atlassian Jira Operations

This is the supported path for this implementation. Native ACS Jira notifier is not used for this flow.

Runtime note for `hub01`:
- ACS policy alerts are intended to go through the explicit Vector webhook path to Jira Operations.
- The older Loki alerting rule manifest at `conf-socpoist/ocp-hub01/observability/logging/10-acs-policy-alerts.yaml` is kept in the repo for reference/history and is not part of the active ACS alert delivery path on `hub01`.
- On `hub01`, ACS should not rely on Loki `AlertingRule` resources for Jira or Alertmanager delivery when the RHACS policy already uses the Vector webhook notifier.

## `conf-socpoist` Vector references

Vector values file:
- [vector-hub-values.yaml](/Users/filipcsupka/aspecta/conf-socpoist/ocp-hub01/observability/vector/vector-hub-values.yaml:1)

Relevant sections in that file:
- ACS webhook label parsing: [vector-hub-values.yaml](/Users/filipcsupka/aspecta/conf-socpoist/ocp-hub01/observability/vector/vector-hub-values.yaml:177)
- Jira remap `acs_to_jira_ops`: [vector-hub-values.yaml](/Users/filipcsupka/aspecta/conf-socpoist/ocp-hub01/observability/vector/vector-hub-values.yaml:195)
- Jira HTTP sink `jira_ops_alerts`: [vector-hub-values.yaml](/Users/filipcsupka/aspecta/conf-socpoist/ocp-hub01/observability/vector/vector-hub-values.yaml:455)
- Jira secret backend `kubernetes_jiraops`: [vector-hub-values.yaml](/Users/filipcsupka/aspecta/conf-socpoist/ocp-hub01/observability/vector/vector-hub-values.yaml:32)
- Jira secret volume and mount: [vector-hub-values.yaml](/Users/filipcsupka/aspecta/conf-socpoist/ocp-hub01/observability/vector/vector-hub-values.yaml:678)

## What the remap does

The `acs_to_jira_ops` VRL transform converts the ACS payload into the Jira Operations schema and keeps the ACS context that matters operationally.

Important mappings:
- `policy name`
- `cluster`
- `namespace`
- `deployment`
- `deployment type`
- `image`
- `lifecycle stage`
- `severity`
- `summary`
- `rationale`
- `remediation`
- `central` violation URL

Current lifecycle stage behavior:
- use `.alert.lifecycleStage` if present
- fallback to `.alert.policy.SORTLifecycleStage`
- fallback to `.alert.policy.lifecycleStages[0]`
- fallback to `DEPLOY`

Current image behavior:
- use `.alert.deployment.containers[0].image.name.fullName` if present
- otherwise rebuild from `registry`, `remote`, and `tag`

## ACS notifier values required

Create a RHACS `Generic Webhook` integration with:

- endpoint: `https://vector.hub01.cloud.socpoist.sk:9444`
- extra field `gr8it`: `acs-audit-log`
- extra field `central_base_url`: `https://central-stackrox.apps.hub01.cloud.socpoist.sk`

Why these fields matter:
- `gr8it=acs-audit-log` is used by Vector to accept only the intended ACS webhook traffic
- `central_base_url` is used to construct the clickable RHACS violation URL in the Jira alert

## Jira auth handling

Vector reads Jira Operations auth from a Kubernetes secret:

- secret name: `jira-ops`
- namespace: `apc-logging`
- key: `authorization`
- value format: `GenieKey <api-key>`

This is consumed through:
- `SECRET[kubernetes_jiraops.authorization]`

Do not store the Jira API key in Git or Helm values.
