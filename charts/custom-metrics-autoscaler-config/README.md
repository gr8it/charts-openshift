# Custom Metrics Autoscaler Config

This chart delivers the `KedaController` custom resource, which triggers installation and configuration of [KEDA](https://keda.sh/) by the [Custom Metrics Autoscaler Operator](https://github.com/openshift/custom-metrics-autoscaler-operator). Install the operator (e.g. via ACM OperatorPolicy) before this chart.

## Templates

1. **KedaController** – Singleton resource named `keda`, created in the namespace where the operator is installed (typically `openshift-keda`).

## Key Values

```yaml
operator: {}         # KEDA Operator deployment config
metricsServer: {}    # KEDA Metrics Server deployment config
admissionWebhooks: {} # KEDA Admission Webhooks deployment config

httpAddon:
  enabled: true      # optional KEDA HTTP Add-on (operator/interceptor/scaler)
```

> [!NOTE]
> The core KEDA Operator, Metrics Server, and Admission Webhooks deployments do not expose a `replicas` field in the `KedaController` CRD - they are always deployed with a fixed replica count. Only the optional `httpAddon` operator/interceptor/scaler components support `replicas`, which are set to `2` in [values.yaml](values.yaml).

## Usage

- Install the `custom-metrics-autoscaler-operator` (KEDA Operator) chart first.
- Install `custom-metrics-autoscaler-config` in the same namespace as the operator (`keda`).
