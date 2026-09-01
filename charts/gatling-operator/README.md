# APC Gatling Operator

Gatling Operator is a Kubernetes Operator for running automated distributed Gatling load testing.

Following helm chart is able to install community version of [Gatling operator](https://github.com/st-tech/gatling-operator/tree/main)

Helm chart is built from [Gatling operator quickstart](https://github.com/st-tech/gatling-operator/blob/main/docs/quickstart-guide.md)


## Additional components

Additional to [Gatling operator quickstart](https://github.com/st-tech/gatling-operator/blob/main/docs/quickstart-guide.md) following resources are deployed:
- clusterrole-project-admin.yaml - aggregates full permissions for gatling resources to project admin, developer, tester, operator cluster roles 
- clusterrole-project-view.yaml - aggregates view permissions for gatling resources to project view cluster role

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

Commonly overridden values are image tag, ingress host/TLS, service account name, and service monitoring behavior.

Example override file:

```yaml
image:
	repository: registry.example.com/platform/gatling-operator
	tag: "0.9.12"

serviceAccount:
	create: true
	name: gatling-controller

ingress:
	enabled: true
	className: nginx
	hosts:
		- host: gatling.example.com
			paths:
				- path: /
					pathType: Prefix
	tls:
		- secretName: gatling-tls
			hosts:
				- gatling.example.com

serviceMonitor:
	enabled: true
	scheme: https
	port: https
	openshift:
		serviceCA:
			enabled: true
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

