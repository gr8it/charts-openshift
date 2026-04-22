# application-namespace-config

This helm chart can adjust specific configuration in application namespace. At the moment the resource quotas and default limits are managed. The quotas are craeted by Kyverno policies defined in [kyverno-app-project](../kyverno-app-project/). The quotas are set but synchronization is disabled, if the quotas have to be adjusted for specific application needs, it can be done via this helm chart.  

To patch the resources via the ArgoCD the [Server-Side Apply operation](https://argo-cd.readthedocs.io/en/latest/user-guide/sync-options/#server-side-apply) is used, which brings the possibility to patch an existing resources on the cluster that are not fully managed by Argo CD. This approach as well reflects the changes done manually and ArgoCD is correctly showing the drifts.  

## Configuration  

Via this helm chart it is possible to update following k8s objects:

- ResourceQuota
- LimitRange

Configuration is fully done via the component values file. For `resourceQuota` it is possible to update only specific values. For `limitRange` **all values have to be provided** in the configuration. ```values.yaml``` file in the helmchart show possible and default values for the resource quotas.  

Configuration schema:

```yaml
resourceQuota:
  <namespace_where_the_qutoa_is_applied>:
    <name_of_the_quota>:
      <quota>: <value>

limitRange:
  <namespace_where_the_qutoa_is_applied>:
    <limitRange_name>:
      defaultLimits:
        <resource>: <limit>
      defaultRequests:
        <resource>: <request>
```

Configuration example:

```yaml
resourceQuota:
  eds:
    default-resource-quota:
      "requests.cpu": "6"
      "requests.memory": "40Gi"
      "limits.cpu": "12"
      "limits.memory": "60Gi"
      "services.loadbalancers": "3"
```

limitRange configuration example:

```yaml
limitRange:
  sktst:
    default-limit-range:
      defaultLimits:
        "cpu": "200m"
        "ephemeral-storage": "1Gi"
        "memory": "200Mi"
      defaultRequests:
        "cpu": "50m"
        "memory": "50Mi"
```
