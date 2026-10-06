# netobserv-config

Configures OpenShift Network Observability stack: NetworkPolicies, LokiStack, and FlowCollector.

## Prerequisites

- `netobserv-operators` chart deployed (Network Observability Operator v1.12.2 or newer)
- Loki Operator deployed (via `logging-operators` or equivalent)
- OCS/RHODF with RGW (for ObjectBucketClaim) and RBD (for LokiStack storage)
- The S3 credentials Secret (`<fullname>-rgw-allinfo`) must exist in the namespace before LokiStack reconciles. It is created automatically by OBC provisioning — combine the OBC-generated ConfigMap and Secret into the required format.

## Namespace provisioning

The namespace is managed by ArgoCD, not by this chart. Configure `managedNamespaceMetadata` and `CreateNamespace=true` in the ArgoCD application definition in the conf repository:

```yaml
netobserv-config:
  render:
    chart: gr8it-openshift/netobserv-config
    chartVersion: "1.3.0"
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
| `flowCollector.agent.ebpf.features` | eBPF agent features: `DNSTracking`, `FlowRTT`, `TLSTracking`, `IPSec`, `PacketTranslation`, plus `PacketDrop`, `NetworkEvents`, `UDNMapping` which also need `privileged` | `[]` |
| `flowCollector.agent.ebpf.privileged` | Run the eBPF agent privileged, required by `PacketDrop`, `NetworkEvents` and `UDNMapping` | `false` |
| `flowCollector.processor.healthRules` | Network Health rules passed to `spec.processor.metrics.healthRules`: `template`, `mode` (`Alert` or `Recording`), `variants`. A template set here replaces its operator defaults, so restate the variants and thresholds you want | `[]` |
| `prometheusRule.enabled` | Create the labelled alerts and turn off the operator `NetObservNoFlows` and `NetObservLokiError`. The packet drop alerts need `PacketDrop` and the `PacketDropsByKernel` and `PacketDropsByDevice` health rules in `Recording` mode | `true` |
