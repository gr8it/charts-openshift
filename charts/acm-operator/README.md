# ACM Operator

Dependency helm chart operators-installer has no proxy support => add environment variables using jsonPatch feature of helmfile, e.g.:

```yaml
  acm-operator:
    render:
      chart: gr8it-openshift/acm-operator
      chartVersion: "1.0.0"
    destination:
      namespace: open-cluster-management
    syncOptions:
      - CreateNamespace=true
    enableAutoSync: true
    helmfile:
      jsonPatches:
      - target:
          version: v1
          group: batch
          kind: Job
        patch:
        - op: add
          path: /spec/template/spec/containers/0/env/0
          value: 
            name: NO_PROXY
            value: {{ .Values.global.apc.noProxy }}
        - op: add
          path: /spec/template/spec/containers/0/env/0
          value: 
            name: HTTPS_PROXY
            value: {{ .Values.global.apc.proxy }}
        - op: add
          path: /spec/template/spec/containers/0/env/0
          value: 
            name: HTTP_PROXY
            value: {{ .Values.global.apc.proxy }}
```
