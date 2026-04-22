resourceQuota:
  eds:
    default-resource-quota:
      "requests.cpu": "6"
      "requests.memory": "40Gi"
      "limits.cpu": "12"
      "limits.memory": "60Gi"
      "services.loadbalancers": "3"

  sktst:
    default-resource-quota:
      "requests.cpu": "3"
      "requests.memory": "25Gi"
      "limits.cpu": "6"
      "limits.memory": "35Gi"
      "services.loadbalancers": "1"
      "pods": "10"
      "persistentvolumeclaims": "30"
    cnpg-custom-resource-quota:
      "count/backups.postgresql.cnpg.io": "25"

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
