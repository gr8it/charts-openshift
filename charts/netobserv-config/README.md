# netobserv-config

Configures OpenShift Network Observability stack: NetworkPolicies, LokiStack, and FlowCollector.

## Prerequisites

- `netobserv-operators` chart deployed (Network Observability Operator v1.8.0)
- Loki Operator deployed (via `logging-operators` or equivalent)
- OCS/RHODF with RGW (for ObjectBucketClaim) and RBD (for LokiStack storage)
- The S3 credentials Secret (`<fullname>-rgw-allinfo`) must exist in the namespace before LokiStack reconciles. It is created automatically by OBC provisioning — combine the OBC-generated ConfigMap and Secret into the required format.

## Namespace provisioning

The namespace is managed by ArgoCD, not by this chart. Configure `managedNamespaceMetadata` and `CreateNamespace=true` in the ArgoCD application definition in the conf repository:

```yaml
netobserv-config:
  render:
    chart: gr8it-openshift/netobserv-config
    chartVersion: "1.0.0"
  destination:
    namespace: apc-netobserv
  managedNamespaceMetadata:
    labels:
      apc.namespace.type: platform
      openshift.io/cluster-monitoring: 'true'
  syncOptions:
    - CreateNamespace=true
```

## Values

| Key | Description | Default |
|-----|-------------|---------|
| `objectBucketClaim.storageClassName` | StorageClass for OBC | `ocs-storagecluster-ceph-rgw` |
| `objectBucketClaim.bucketName` | Override bucket name for existing buckets | `apc-<fullname>-rgw` |
| `lokistack.size` | LokiStack size | `1x.small` |
| `lokistack.existingSecret` | Override S3 credentials secret name | `<fullname>-rgw-allinfo` |
| `lokistack.storageClassName` | StorageClass for LokiStack | `ocs-storagecluster-ceph-rbd` |
| `flowCollector.agent.ebpf.sampling` | eBPF sampling rate | `50` |
