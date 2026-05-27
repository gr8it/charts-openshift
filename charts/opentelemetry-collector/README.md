# opentelemetry-collector


## APC specific information


### ArgoCD / Red Hat OpenShift GitOps Sync Status and Health Checks

If you are using this Helm chart with ArgoCD / Red Hat OpenShift GitOps, make sure your ArgoCD Application (`Application.argoproj.io`) manifest includes the following `spec.ignoreDifferences` configuration:

``` yaml
spec:
  ignoreDifferences:
    - group: opentelemetry.io
      jqPathExpressions:
        - .spec.config.exporters
        - .spec.config.service.pipelines
        - .spec.config.connectors.routing.table
      kind: OpenTelemetryCollector
```

The `ignoreDifferences` block is required because the Kyverno Policy mutates the `OpenTelemetryCollector` custom resource after it is applied, injecting runtime fields into `.spec.config.exporters`, `.spec.config.service.pipelines`, and `.spec.config.connectors.routing.table`. Without this configuration, ArgoCD continuously detects these fields as drift and marks the Application as `OutOfSync`, even though the desired state in Git is unchanged. This in turn can trigger unwanted auto-sync loops that revert the kyverno's mutations, leading to a fight between ArgoCD and the Kyverno that destabilizes the collector pipeline. By instructing ArgoCD to ignore differences on these specific jq paths, the Application remains `Synced` and `Healthy` while still allowing the kyverno to manage dynamic configuration. This pattern is the recommended way to integrate operator-owned or kyverno-owned CRDs with GitOps tooling, where ownership of certain fields is intentionally split between Git and the controller.

