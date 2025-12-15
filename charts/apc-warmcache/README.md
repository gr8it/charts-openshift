# APC WarmCache Helm Chart

A Helm chart for warming registry cache by syncing images using Skopeo.

## Overview

This Helm chart deploys a cronjob that:

1. Retrieves all container images used across the cluster using an init container
2. Provides a warmcache script that copies these images through a registry cache to warm it, images are "stored" in /dev/null to prevent space usage in the running node
3. Uses ExternalSecrets to securely manage registry credentials from Vault

## Prerequisites

- External Secrets Operator
- Robot accounts for cached registries are created in vault, in path used by the helm chart
- ClusterSecretStore created on cluster level and accessible from namespace where solution is deployed

## Configuration

### Key Parameters

- `registries`: list of cached registries
- `apcRegistry`: FQDN of apc image registry which is configured as cached registry
- `cronJob.schedule`: job run schedule in crontab format
- `externalSecrets.regrobot.vaultPath`: path in vault where robot accounts are stored
- `retry`: number of retries for the image downloading

### External Secrets

The chart uses External Secrets to manage sensitive data from Vault:

- to obtain robot account credentials for configured registries

## How It Works

1. **Init Container (getimages)**: 
   - Uses OpenShift CLI to query all pods across the cluster
   - Extracts all container and init container images
   - Saves the unique list to `/imglist/images`

2. **Main Container (warmcache)**:
   - Runs with Skopeo installed
   - Mounts the image list from the init container
   - Provides a script to copy images through the APC registry cache
   - Uses credentials from ExternalSecrets for registry authentication

3. **RBAC**:
   - ServiceAccount with ClusterRole to read pods across all namespaces
   - ClusterRoleBinding to bind the role to the service account

4. **Security**:
   - Non-root execution
