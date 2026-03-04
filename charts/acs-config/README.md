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

## Security Policies

This chart includes ACS security policies in `policies/` directory.

**Included policy:** Detects non-privileged containers with fixable Important/Critical CVEs (inform-only mode).

**How to use:**
1. Import policy via Central UI: **Platform Configuration → Policy Management → Import policy**
2. Upload `policies/containers-important-critical-fixable-cves.json`
3. Configure Jira integration in **Platform Configuration → Integrations → Notifier Integrations** to receive alerts

**📖 Full documentation:** See [policies/README.md](policies/README.md) for detailed setup instructions, namespace exclusions, notifier configuration, and troubleshooting.

## Additional OpenShift setup

Implement these supporting steps alongside the chart deployment:

- [docs/roles.md](docs/roles.md): create the ACS Auditor permission set/role and assign it to the required identity provider groups.
- [docs/backup.md](docs/backup.md): configure ACS backup to S3 (and downstream Veeam backup) using the provided ACS backup functionality.
