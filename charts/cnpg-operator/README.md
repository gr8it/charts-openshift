# CNPG Operator

## Barman plugin

- version 0.2.0 of the Barman plugin is not compatible with Openshift - <https://github.com/cloudnative-pg/charts/issues/673>

either kustomize the deployment (preferred) after rendering, e.g.

```yaml
  cnpg-operator:
    render:
      chart: gr8it-openshift/cnpg-operator
      chartVersion: "1.1.0"
    destination:
      namespace: openshift-operators
    enableAutoSync: true
    helmfile:
      strategicMergePatches:
      - apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: plugin-barman-cloud
          namespace: apc-cnpg-operator
        spec:
          template:
            spec:
              containers:
              - name: barman-cloud
                securityContext:
                  runAsGroup: ~
                  runAsUser: ~
```

or add scc to barman service account:

```bash
oc adm policy add-scc-to-user nonroot -z plugin-barman-cloud -n apc-cnpg-operator
```
