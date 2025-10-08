# CNPG Operator

## Barman plugin

- version 0.2.0 of the Barman plugin is not compatible with Openshift - <https://github.com/cloudnative-pg/charts/issues/673>

kustomize the deployment (preferred) after rendering, e.g.:

```yaml
  cnpg-operator:
    render:
      chart: gr8it-openshift/cnpg-operator
      chartVersion: "1.3.0"
    destination:
      namespace: apc-cnpg-operator
    managedNamespaceMetadata:
      labels:
        apc.namespace.type: platform
    syncOptions:
      - CreateNamespace=true
    helmfile:
      # remove after https://github.com/cloudnative-pg/charts/issues/673 is fixed
      strategicMergePatches:
      - apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: cnpg-operator-plugin-barman-cloud
          namespace: apc-cnpg-operator
        spec:
          template:
            spec:
              containers:
              - name: barman-cloud
                securityContext:
                  runAsGroup: ~
                  runAsUser: ~
    enableAutoSync: true
```
