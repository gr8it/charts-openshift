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
- Registry CA stored in secret in vault in predefined path
- ClusterSecretStore created on cluster level and accessible from namespace where solution is deployed

## Configuration

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespaceOverride` | Override the namespace | `""` (uses release namespace) |
| `cronJob.name` | Name of the cronJob | `defaults to chart name` |
| `cronJob.schedule` | Schedule of the job, override by components values in specific environment | `0 9 * * 6` |
| `pod.restartPolicy` | Pod restart policy | `Never` |
| `initContainer.image.repository` | Init container image | `registry.redhat.io/openshift4/ose-cli` |
| `initContainer.image.tag` | Init container image tag | `v4.15` |
| `container.image.repository` | Main container image | `quay.io/containers/skopeo` |
| `container.image.tag` | Main container image tag | `latest` |
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.name` | Service account name | `getimagessa` |
| `rbac.create` | Create RBAC resources | `true` |
| `configMap.vars.registries` | Space-separated list of registries to cache | `"docker.io quay.io ghcr.io registry.connect.redhat.com registry.redhat.io"` |
| `configMap.vars.apcRegistry` | APC registry URL | `"apc-registry-quay-quay.apps.hub01.cloud.socpoist.sk"` |
| `externalSecrets.enabled` | Enable ExternalSecrets | `true` |
| `externalSecrets.secretStoreRef.name` | Secret store name | `vault-hub-secret-store` |
| `externalSecrets.regca.vault.key` | Path in vault. For specific environments it have to be updated in component values file | `"/d/quay-config/registry-ca-bundle"` |
| `externalSecrets.regrobot.vaultPath` | Path in vault where robot accounts are stored (templated later on) | `"/d/quay-config/registries/{{ .registry }}/robot-account"` |

### External Secrets

The chart uses External Secrets to manage sensitive data from Vault:

- to obtain registry certificate from vaul, used for skopeo to connect to proxy cache
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
   - Uses registry certificate from ExternalSecret for registry connection
   - Uses credentials from ExternalSecrets for registry authentication

3. **RBAC**:
   - ServiceAccount with ClusterRole to read pods across all namespaces
   - ClusterRoleBinding to bind the role to the service account

4. **Security**:
   - Non-root execution
