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

## Usage

```yaml
securedCluster:
  clusterName: prod01
  centralEndpoint: 'https://central-stackrox.apps.hub01.cloud.socpoist.sk:443'
```