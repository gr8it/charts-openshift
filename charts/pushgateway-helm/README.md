# Prometheus Pushgateway Helm Chart for OpenShift

This Helm chart deploys Prometheus Pushgateway on OpenShift with integrated OAuth proxy authentication and comprehensive RBAC configuration.

## Overview

The `pushgateway-helm` chart wraps the upstream `prometheus-pushgateway` Helm chart and adds OpenShift-specific features:

- **OAuth Proxy Sidecar**: Secures Pushgateway behind OpenShift's built-in OAuth provider
- **Route & TLS**: Exposes Pushgateway via OpenShift Route with reencrypt TLS termination
- **Full RBAC**: ClusterRoles, ClusterRoleBindings, Roles, and RoleBindings for proper authorization
- **Automatic OAuth cookie secret**: Generated via ESO `Password` generator on first install; no manual secret creation required.

## Prerequisites

1. OpenShift cluster
2. External Secrets Operator (ESO) installed in the cluster

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

6. **OAuth Cookie Secret** (auto-generated)
   - ESO `Password` generator creates a random secret on install
   - Stored as `pushgateway-oauth-cookie-secret`

## Installation

### 1. Update Chart Dependencies

```bash
cd charts-openshift/charts/pushgateway-helm
helm dependency update
```

### 2. Install the Chart

```bash
helm install prometheus-pushgateway ./charts/pushgateway-helm \
  --namespace prometheus-pushgateway \
  --create-namespace
```

The OAuth cookie secret is created automatically by ESO on first install.

## Configuration

### Default Values

See `values.yaml` for all available options.

### Key Customization Points

#### Pushgateway Image & Version

```yaml
prometheus-pushgateway:
  replicaCount: 2
  image:
    repository: quay.io/prometheus/pushgateway
    tag: v1.10.0
    pullPolicy: IfNotPresent
```

The chart default is `2` replicas. Existing hub environments can override that in conf when they need to preserve the current single-replica rollout.

#### Pushgateway Admin API

The admin API is enabled by default because it is **required by the Veeam exporter** (metrics deletion/reset). It also preserves behavior from the migrated static manifests:

```yaml
prometheus-pushgateway:
  extraArgs:
    - --web.enable-admin-api
```

#### OAuth Proxy Image

```yaml
prometheus-pushgateway:
  extraContainers:
    - name: oauth-proxy
      image: registry.redhat.io/openshift4/ose-oauth-proxy:v4.12.0
```

#### Service Account Name

The SA name is shared between the wrapper chart and the oauth-proxy `--openshift-service-account` argument. If you override `prometheus-pushgateway.serviceAccount.name`, you must also update the `--openshift-service-account` arg in `prometheus-pushgateway.extraContainers[oauth-proxy].args` to match.

#### Persistence

```yaml
prometheus-pushgateway:
  persistentVolume:
    enabled: true
    size: 2Gi
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

## Security

- **Least-privilege RBAC**: ClusterRole grants only `get` on `prometheuses` — the minimum required by the OAuth delegate check
- **OAuth proxy**: all Pushgateway endpoints protected; external access requires a valid OpenShift token bound to the push-metrics ClusterRole

## Metrics & Monitoring

The chart creates a ServiceMonitor in the `openshift-monitoring` namespace (configurable):

```yaml
prometheus-pushgateway:
  serviceMonitor:
    enabled: true
    namespace: openshift-monitoring
    honorLabels: true
```

## Accessing Pushgateway

### Public Route (HTTPS)

```bash
oc get route prometheus-pushgateway -n prometheus-pushgateway -o jsonpath='{.spec.host}'
```

### Internal Endpoint (For Testing)

```bash
oc port-forward -n prometheus-pushgateway \
  svc/prometheus-pushgateway 9091:9091

curl http://localhost:9091/metrics
```

## Troubleshooting

### OAuth Proxy Not Starting

```bash
oc logs -n prometheus-pushgateway \
  deployment/prometheus-pushgateway \
  -c oauth-proxy -f
```

Common issues:

- Cookie secret not found: Check ESO `ExternalSecret` status (`oc get externalsecret -n prometheus-pushgateway`)
- TLS cert not provisioned: Check Service annotation and OpenShift cert controller

### Cannot Access Pushgateway

```bash
oc get route -n prometheus-pushgateway
oc get svc -n prometheus-pushgateway
```

### Metrics Not Scraped

```bash
oc get servicemonitor -n prometheus-pushgateway
oc logs -n openshift-monitoring deployment/prometheus-operator
```

## Chart Values Reference

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| resourceNames.route | string | `prometheus-pushgateway` | Name of the OpenShift Route |
| resourceNames.oauthProxyService | string | `pushgateway-oauth-proxy` | Name of the OAuth proxy Service |
| resourceNames.pushMetricsClusterRole | string | `service-sa-push-metrics` | ClusterRole for pushing metrics |

## Upgrading

```bash
helm upgrade prometheus-pushgateway ./charts/pushgateway-helm \
  --namespace prometheus-pushgateway
```

Check [CHANGELOG.md](CHANGELOG.md) for breaking changes between versions.

## References

- [Prometheus Pushgateway](https://github.com/prometheus/pushgateway)
- [prometheus-community/helm-charts - pushgateway](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway)
- [OpenShift OAuth Proxy](https://github.com/openshift/oauth-proxy)
- [apc-global-overrides](../apc-global-overrides/README.md)
