# APC Blackbox exporter Helm chart

A Helm chart to setup Blackbox exporter in APC

## Overview

This Helm chart deploys Blackbox exporter in following configuration:
- blackbox exporter with
  - modules:
    - icmp
    - tcp_probe
    - tcp_probe_tls
    - http_2xx
    - http_openshift_api
    - http_openshift_console
  - serviceMonitor:
    - selfMonitor (metrics of the exporter itself)
- probes (`monitoring.coreos.com/v1` Probe):
  - `openshift-api` - OpenShift API `/readyz` of the cluster where Blackbox exporter is deployed
  - `openshift-console` - OpenShift console `/health` of the cluster where Blackbox exporter is deployed
  - `hw-xca` - Lenovo XClarity Administrator, only when `hwXcaUrl` is set
- prometheus rules for APC platform team
- cluster roles:
   - blackbox-exporter-probe-edit
   - blackbox-exporter-probe-view
- network policy
   - egress to proxy

## Prerequisites

- [prometheus-blackbox-exporter](https://prometheus-community.github.io/helm-charts/)
- [apc-global-overrides](https://github.com/gr8it/charts-openshift/tree/main/charts/apc-global-overrides)
- deployed configmap for proxy using [kyverno](https://github.com/gr8it/charts-openshift/blob/main/charts/kyverno-app-project/templates/clusterpolicy-app-project-internetproxy-cm.yaml)


## Configuration

### Probes

The `openshift-api` and `openshift-console` probes are always deployed. Their targets are built from the cluster global values via `apc-global-overrides` helpers, so no configuration is needed:

- `openshift-api`: `<global.apc.cluster.apiURL>/readyz`, module `http_openshift_api`
- `openshift-console`: `https://console-openshift-console.<global.apc.cluster.appsDomain>/health`, module `http_openshift_console`

> [!NOTE]
> `prometheus-blackbox-exporter.serviceMonitor.targets` is intentionally empty. Platform targets are monitored with Probes, not ServiceMonitors.

### Key Parameters

- `hwXcaUrl`: URL of the Lenovo XClarity Administrator to probe. Empty by default; when set, Probe `hw-xca` (module `http_2xx`) is rendered. Set it only for the cluster that should probe XCA (usually the hub), e.g.:

  ```yaml
  hwXcaUrl: https://xca.example.com
  ```

- `proxy`, `noProxy`, `proxyCIDRs`: local overrides of `global.apc.proxy`, `global.apc.noProxy` and `global.apc.proxyCIDRs`; when unset, the global values are used
