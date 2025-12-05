# ACM Operatorpolicy

This helm chart installs ACM operatorpolicy CR using external tools, i.e. directly on managed clusters only (no placement decisions!)

See <https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.13/html-single/governance/index#policy-deploy-ext-tools>

## Usage

Helm charts should be installed as a dependency, i.e. an APC specific helm chart with a dependency to this helm chart

```
apiVersion: v2
name: quay-operator
description: A Helm chart to install Quay Operator using ACM operator policy
type: application
version: 1.0.0
appVersion: "v0.11.0"

dependencies:
  - name: acm-operatorpolicy
    version: "1.3.0"
    repository: https://raw.githubusercontent.com/gr8it/charts-openshift/refs/heads/SPEXAPC-3919/
```

### Targeting namespaces

There are several ways how to target namespace the operator should be installed in:

1) operator default
2) static (non-default) namespace
3) release namespace of the chart installation (non-default)

These are set using combination of variables, mainly `forceReleaseNamespace` parameter. The forced namespace is taken from .Release.Name (as in `helm install --namespace <custom-namespace> ...`).

When forceReleaseNamespace is true:

- set operatorGroup.namespace and/or subscription.namespace to the value of .Release.Namespace
- only works when operatorGroup.namespace and/or subscription.namespace are null
- will break if there are other existing operators in the .Release.Namespace
- when operatorGroup is targeting 1 namespace, templating can be used for dynamic targeting, see values.example.releaseNamespace.yaml

When forceReleaseNamespace is false:

- use explicit values set in operatorGroup.namespace and/or subscription.namespace
- uses operator defaults when operatorGroup.namespace and/or subscription.namespace are null

#### Operator default

[values.example.yaml](values.example.yaml)

```yaml
subscription:
  channel: stable-v1
  name: openshift-cert-manager-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: cert-manager-operator.v1.15.1
  config:
    env:
    - name: HTTP_PROXY
      value: "proxy.example.com"
    - name: HTTPS_PROXY
      value: "proxy.example.com"
    - name: NO_PROXY
      value: "localhost,127.0.0.1,.svc,.cluster.local,.example.com"

upgradeApproval: Automatic
versions:
  - cert-manager-operator.v1.15.1
```

#### Static (non-default) namespace

[values.example.namespace.yaml](values.example.namespace.yaml)

```yaml
# namespace of the operatorGroup and subscription is taken from namespace values
operatorGroup:
  name: apc-cert-manager
  namespace: apc-cert-manager
  targetNamespaces:
  - apc-cert-manager

subscription:
  channel: stable-v1
  name: openshift-cert-manager-operator
  namespace: apc-cert-manager
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: cert-manager-operator.v1.15.1

upgradeApproval: Automatic
versions:
  - cert-manager-operator.v1.15.1
```
#### Release namespace (non-default)

[values.example.releaseNamespace.yaml](values.example.releaseNamespace.yaml)

```yaml
# namespace of the operatorGroup and subscription is taken from .Release.Namespace
forceReleaseNamespace: true

operatorGroup:
  # targets release namespace only
  targetNamespaces:
  - "{{ .Release.Namespace }}"

subscription:
  channel: stable-v1
  name: openshift-cert-manager-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: cert-manager-operator.v1.15.1

upgradeApproval: Automatic
versions:
  - cert-manager-operator.v1.15.1
```

