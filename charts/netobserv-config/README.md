# netobserv-config

Configures OpenShift Network Observability stack: Namespace, NetworkPolicies, LokiStack, and FlowCollector.

## Prerequisites

- `netobserv-operators` chart deployed (Network Observability Operator v1.8.0)
- Loki Operator deployed (via `logging-operators` or equivalent)
- OCS/RHODF with RGW (for ObjectBucketClaim) and RBD (for LokiStack storage)
- The S3 credentials Secret (`<fullname>-rgw-allinfo`) must exist in the namespace before LokiStack reconciles. It is created automatically by OBC provisioning — combine the OBC-generated ConfigMap and Secret into the required format.

## Component deployment order

1. `netobserv-operators` — installs the operator
2. `netobserv-config` — deploys Namespace, NetworkPolicies, OBC, LokiStack, FlowCollector

## Values

| Key | Description | Default |
|-----|-------------|---------|
| `objectBucketClaim.storageClassName` | StorageClass for OBC | `ocs-storagecluster-ceph-rgw` |
| `objectBucketClaim.bucketName` | Override bucket name for existing buckets | `apc-<fullname>-rgw` |
| `lokistack.size` | LokiStack size | `1x.small` |
| `lokistack.existingSecret` | Override S3 credentials secret name | `<fullname>-rgw-allinfo` |
| `lokistack.storageClassName` | StorageClass for LokiStack | `ocs-storagecluster-ceph-rbd` |
| `flowCollector.agent.ebpf.sampling` | eBPF sampling rate | `50` |
