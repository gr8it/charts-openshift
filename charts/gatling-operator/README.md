# APC Gatling Operator

Gatling Operator is a Kubernetes Operator for running automated distributed Gatling load testing.

Following helm chart is able to install community version of [Gatling operator](https://github.com/st-tech/gatling-operator/tree/main)

Helm chart is built from [Gatling operator quickstart](https://github.com/st-tech/gatling-operator/blob/main/docs/quickstart-guide.md)


## Additional components

Additional to [Gatling operator quickstart](https://github.com/st-tech/gatling-operator/blob/main/docs/quickstart-guide.md) following resources are deployed:
- clusterrole-project-admin.yaml - aggregates full permissions for gatling resources to project admin, developer, tester, operator cluster roles 
- clusterrole-project-view.yaml - aggregates view permissions for gatling resources to project view cluster role

## Metrics Exposure

The chart exposes controller metrics directly from the manager container on port `8443`.

OpenShift prerequisite for user workload monitoring:

```bash
oc label namespace apc-gatling-operator openshift.io/user-monitoring=true --overwrite
```

Changes from community version:
- No `kube-rbac-proxy` sidecar is deployed
- No Ingress resource is deployed by this chart.
- ServiceMonitor scrapes the Service endpoint on port `metrics` over `http`.

## Install

Install from the published Helm repository:

```bash
helm repo add gr8it-openshift https://raw.githubusercontent.com/gr8it/charts-openshift/main/
helm repo update
helm install apc-gatling-operator gr8it-openshift/gatling-operator \
	--namespace apc-gatling-operator \
	--create-namespace
```

Install from a local checkout (useful for development/testing):

```bash
helm install apc-gatling-operator ./charts/gatling-operator \
	--namespace apc-gatling-operator \
	--create-namespace
```

## Upgrade

```bash
helm upgrade apc-gatling-operator gr8it-openshift/gatling-operator \
	--namespace apc-gatling-operator
```

## CRD Changes

When the Gatling CRD schema changes and an in-place upgrade is not possible, remove and recreate the CRD.

Warning: deleting the CRD removes all Gatling custom resources.

1. Back up Gatling custom resources:

```bash
kubectl get gatlings.gatling-operator.tech.zozo.com -A -o yaml > gatlings-backup.yaml
```

2. Delete the CRD:

```bash
kubectl delete crd gatlings.gatling-operator.tech.zozo.com
```

3. Reinstall or upgrade chart to recreate CRD:

```bash
helm upgrade --install apc-gatling-operator gr8it-openshift/gatling-operator \
	--namespace apc-gatling-operator \
	--create-namespace
```

## Uninstall

```bash
helm uninstall apc-gatling-operator --namespace apc-gatling-operator
```

## Common Overrides

Commonly overridden values are image tag, service account name, service port, and service monitoring behavior.

Example override file:

```yaml
image:
  repository: registry.example.com/platform/gatling-operator
  tag: "0.9.12"

serviceAccount:
  create: true
  name: gatling-controller

service:
  port: 8443

serviceMonitor:
  enabled: true
  scheme: http
  port: metrics
  path: /metrics
```

Apply it during install or upgrade:

```bash
helm upgrade --install apc-gatling-operator gr8it-openshift/gatling-operator \
	--namespace apc-gatling-operator \
	--create-namespace \
	-f my-values.yaml
```

## Render Before Applying

Render manifests for a specific release and namespace before applying changes:

```bash
helm template apc-gatling-operator ./charts/gatling-operator \
	--namespace apc-gatling-operator \
	-f ./charts/gatling-operator/values.example.yaml
```

