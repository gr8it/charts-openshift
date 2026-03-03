# ACS Instance

This Helm chart creates Red Hat Advanced Cluster Security (RHACS) SecuredCluster instance on managed clusters.

## Description

This chart deploys the SecuredCluster custom resource that configures the RHACS sensor and scanner components on a managed cluster. It requires the RHACS operator to be already installed (use the `acs-operator` chart for that).

## Prerequisites

- RHACS operator must be installed (use `acs-operator` chart)
- Central instance must be running and accessible
- Cluster must be registered with Central

## Configuration

The chart is configured through `values.yaml`. Key parameters include:

- `securedCluster.clusterName`: Unique cluster identifier (override per environment)
- `securedCluster.centralEndpoint`: URL of the Central instance
- Resource limits and scaling configuration for sensors and scanners
- `central.enabled`: Enable to deploy the Central instance (hub cluster only)
- `prometheusRule.enabled`: Enable to install the RHACS alerting ruleset

## Usage

```yaml
central:
  enabled: true

prometheusRule:
  enabled: true
```

## Policy import and break-glass

This chart includes the policy JSON for **Privileged Containers with Important and Critical Fixable CVEs** at
`policies/privileged-containers-important-critical-fixable-cves.json`. The policy is intended to be enforced at
deploy time (it includes `FAIL_KUBE_REQUEST` in `enforcementActions`). The policy is not active in Central until
it is imported.

### Manual policy import

Because RHACS policies are managed in Central (not as Kubernetes CRDs) and short-lived tokens are used in this
environment, policy import is a manual step.

Import options:

- Central UI: import the JSON policy and enable enforcement for DEPLOY.
- `roxctl` from a trusted admin workstation:

```bash
roxctl -e https://central-stackrox.apps.<cluster>.<domain>:443 \
  --token <central_api_token> policy import --overwrite \
  --file policies/privileged-containers-important-critical-fixable-cves.json
```

To allow exceptions (e.g., privileged debug pods or legacy workloads that must not be blocked on reschedule),
use the Kyverno break-glass policy from the `kyverno-app-project` chart. Enable it in GitOps and target
namespaces or workloads (example in that chart's values). This adds `admission.stackrox.io/break-glass: "true"`
so RHACS admission control bypasses enforcement for those workloads.

## Additional OpenShift setup

Implement these supporting steps alongside the chart deployment:

- [docs/roles.md](docs/roles.md): create the ACS Auditor permission set/role and assign it to the required identity provider groups.
- [docs/backup.md](docs/backup.md): configure ACS backup to S3 (and downstream Veeam backup) using the provided ACS backup functionality.
