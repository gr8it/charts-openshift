# Prometheus Pushgateway Helm Chart for OpenShift

This Helm chart deploys Prometheus Pushgateway on OpenShift with integrated OAuth proxy authentication and comprehensive RBAC configuration.

## Overview

The `pushgateway` chart wraps the upstream `prometheus-pushgateway` Helm chart and adds OpenShift-specific features:

- **OAuth Proxy Sidecar**: Secures Pushgateway behind OpenShift's built-in OAuth provider
- **Route & TLS**: Exposes Pushgateway via OpenShift Route with reencrypt TLS termination
- **Veeam Integration**: Pre-configured ServiceAccount for external metric submission (e.g., Veeam backups)
- **Hub-only Deployment**: All OpenShift-specific resources conditionally render only on hub clusters using the `apc-global-overrides.clusterIsHub` helper
- **Full RBAC**: ClusterRoles, ClusterRoleBindings, Roles, and RoleBindings for proper authorization

## Prerequisites

1. OpenShift cluster with `isHub: true` in cluster configuration
2. `apc-global-overrides` Helm chart available (included as a dependency)
3. Pre-created Secret containing OAuth proxy cookie: `pushgateway-oauth-cookie-secret`
   - Create with: `scripts/create-pushgw-cookie-secret.sh` (included in conf-socpoist)

## Architecture

### Key Components

1. **Pushgateway Deployment** (via upstream chart)
   - Metrics collection endpoint
   - PersistentVolume for metrics storage
   - ServiceMonitor for integration with cluster monitoring

2. **OAuth Proxy Sidecar** (ose-oauth-proxy container)
   - Secures HTTP endpoint (:9091 → :9092 HTTPS)
   - Authenticates requests against OpenShift OAuth
   - Delegates authorization to Prometheus resources

3. **Route** (OpenShift network route)
   - Public external endpoint for Pushgateway
   - TLS termination: Reencrypt mode
   - Points to OAuth proxy Service

4. **Service for OAuth Proxy**
   - Port 9092 (HTTPS)
   - Automatic TLS certificate provisioning via annotation

5. **RBAC Resources**
   - **pushgw-sa** (main ServiceAccount)
     - Used by OAuth proxy
     - Bound to tokenreview and prometheus-access roles
   
   - **veeam-sa** (external metrics pusher)
     - For Veeam or other backup systems
     - Can push metrics via the OAuth-protected Route

## Installation

### 1. Update Chart Dependencies

```bash
cd charts-openshift/charts/pushgateway
helm dependency update
```

This generates `Chart.lock` and populates `charts/` directory.

### 2. Install the Chart

```bash
helm install prometheus-pushgateway ./charts/pushgateway \
  --namespace prometheus-pushgateway \
  --create-namespace \
  --set cluster.isHub=true
```

### 3. Create OAuth Cookie Secret

Before or after installation, create the cookie secret (if not already present):

```bash
# From conf-socpoist:
./ocp-hub01/observability/pushgateway/create-pushgw-cookie-secret.sh
```

Or manually:

```bash
head -c 32 /dev/urandom | base64 > /tmp/cookie-secret

kubectl create secret generic pushgateway-oauth-cookie-secret \
  --from-file=cookie-secret=/tmp/cookie-secret \
  -n prometheus-pushgateway
```

## Configuration

### Default Values

See `values.yaml` for all available options.

### Key Customization Points

#### Enable/Disable Veeam Integration

```yaml
veeam:
  enabled: true  # Set to false to skip Veeam SA creation
  serviceAccountName: veeam-sa
```

#### Pushgateway Image & Version

```yaml
prometheus-pushgateway:
  image:
    repository: quay.io/prometheus/pushgateway
    tag: v1.10.0      # Change to desired version
    pullPolicy: Always
```

#### OAuth Proxy Image

```yaml
prometheus-pushgateway:
  extraContainers:
    - name: oauth-proxy
      image: registry.redhat.io/openshift4/ose-oauth-proxy:v4.16.0
```

#### Persistence

```yaml
prometheus-pushgateway:
  persistentVolume:
    enabled: true
    size: 2Gi          # Increase for large deployments
```

#### Resource Limits

```yaml
prometheus-pushgateway:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi
```

(Note: Resource limits are controlled via the upstream chart's values.)

## Security

All resources follow Kubernetes security best practices:

- **Non-root containers**: `runAsNonRoot: true`
- **Read-only root filesystem**: `readOnlyRootFilesystem: true` for Pushgateway, mutable for oauth-proxy (required for cookie handling)
- **Capability dropping**: `drop: ["ALL"]` for minimal attack surface
- **Pod Security Context**: Configured with appropriate `fsGroup` and `runAsUser`

## Metrics & Monitoring

The chart creates a ServiceMonitor in the `openshift-monitoring` namespace (configurable):

```yaml
prometheus-pushgateway:
  serviceMonitor:
    enabled: true
    namespace: openshift-monitoring
    honorLabels: true
```

Prometheus will scrape metrics from the main Pushgateway pod (port 9091 via local endpoint).

## Accessing Pushgateway

### Public Route (HTTPS)

```bash
# Get the route URL
oc get route prometheus-pushgateway -n prometheus-pushgateway -o jsonpath='{.spec.host}'

# Example URL:
# https://prometheus-pushgateway-prometheus-pushgateway.apps.hub01.example.com

# Push metrics:
echo "metric_name 123" | curl -X POST \
  --cacert /path/to/ca.crt \
  --cert /path/to/client.crt \
  --key /path/to/client.key \
  https://prometheus-pushgateway-prometheus-pushgateway.apps.hub01.example.com/metrics/job/myjob
```

### From Veeam (Internal)

The `veeam-sa` ServiceAccount is pre-configured with permissions to push metrics:

```bash
# Veeam pod would use this SA and access via the Route with OAuth proxy
```

### Internal Endpoint (For Testing)

```bash
# Port-forward to test (bypasses OAuth proxy):
oc port-forward -n prometheus-pushgateway \
  svc/prometheus-pushgateway 9091:9091

curl http://localhost:9091/metrics
```

## Conditional Rendering (Hub-only)

All OpenShift-specific resources are wrapped with:

```gotemplate
{{- if eq (include "apc-global-overrides.clusterIsHub" .) "true" }}
  # Resources here only render on hub clusters
{{- end }}
```

This allows the same chart to be deployed to spoke clusters (where these resources are skipped) with no errors.

## Troubleshooting

### OAuth Proxy Not Starting

Check logs:

```bash
oc logs -n prometheus-pushgateway \
  deployment/prometheus-pushgateway \
  -c oauth-proxy -f
```

Common issues:
- Cookie secret not found: Verify `pushgateway-oauth-cookie-secret` exists
- TLS cert not provisioned: Check Service annotation and OpenShift cert controller

### Cannot Access Pushgateway

1. Verify Route exists and is ready:
   ```bash
   oc get route -n prometheus-pushgateway
   ```

2. Check OAuth proxy Service selector matches pods:
   ```bash
   oc get svc prometheus-pushgateway-oauth-proxy -n prometheus-pushgateway -o yaml
   oc get pods -n prometheus-pushgateway -L app.kubernetes.io/name
   ```

3. Test OAuth proxy directly:
   ```bash
   oc port-forward -n prometheus-pushgateway \
     svc/prometheus-pushgateway-oauth-proxy 9092:9092
   ```

### Metrics Not Scraped

1. Verify ServiceMonitor:
   ```bash
   oc get servicemonitor -n prometheus-pushgateway
   ```

2. Check Prometheus config reload in openshift-monitoring:
   ```bash
   oc logs -n openshift-monitoring deployment/prometheus-operator
   ```

## Chart Values Reference

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| veeam.enabled | bool | `true` | Enable Veeam ServiceAccount and RBAC |
| veeam.serviceAccountName | string | `veeam-sa` | Name of Veeam service account |
| prometheus-pushgateway.replicaCount | int | `1` | Number of Pushgateway replicas |
| prometheus-pushgateway.image.tag | string | `v1.10.0` | Pushgateway container image tag |
| prometheus-pushgateway.persistentVolume.enabled | bool | `true` | Enable persistent storage |
| prometheus-pushgateway.persistentVolume.size | string | `2Gi` | PVC size |
| prometheus-pushgateway.serviceAccount.name | string | `pushgw-sa` | ServiceAccount name (must match oauth-proxy args) |
| prometheus-pushgateway.serviceMonitor.enabled | bool | `true` | Enable ServiceMonitor |
| prometheus-pushgateway.serviceMonitor.namespace | string | `openshift-monitoring` | Namespace for ServiceMonitor |

## Upgrading

```bash
helm upgrade prometheus-pushgateway ./charts/pushgateway \
  --namespace prometheus-pushgateway
```

Check [CHANGELOG.md](CHANGELOG.md) for breaking changes between versions.

## References

- [Prometheus Pushgateway](https://github.com/prometheus/pushgateway)
- [prometheus-community/helm-charts - pushgateway](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway)
- [OpenShift OAuth Proxy](https://github.com/openshift/oauth-proxy)
- [apc-global-overrides](../apc-global-overrides/README.md)
