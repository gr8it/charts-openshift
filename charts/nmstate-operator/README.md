# NMstate operator

## Usage

Installing nmstate operator using GUI results in a label `operators.coreos.com/kubernetes-nmstate-operator.openshift-nmstate:""` being set on the created subscription, which can't be realized using ACM operatorpolicy. As such the label must be added using helmfiles' jsonPatches upon usage:

```yaml
  nmstate-operator:
    render:
      chart: gr8it-openshift/nmstate-operator
      chartVersion: "1.0.0"
    destination:
      namespace: openshift-nmstate
    syncOptions:
      - CreateNamespace=true
    helmfile:
      jsonPatches:
      - target:
          version: v1beta1
          group: policy.open-cluster-management.io
          kind: OperatorPolicy
        patch:
        - op: add
          path: /metadata/labels/0/operators.coreos.com/kubernetes-nmstate-operator.openshift-nmstate
          value: ""
    enableAutoSync: true
```
