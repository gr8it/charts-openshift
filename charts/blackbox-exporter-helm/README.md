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
      http_openshift_api
    - http_openshift_console
  - serviceMonitor:
    - defaults:
      - openshift-console
      - openshift-api
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

### Key Parameters

- `prometheus-blackbox-exporter.serviceMonitor.targets`: list OCP console and API to monitor from cluster where Blackbox exporter is deployed

Examples:
  - cluster:
    ```yaml
    serviceMonitor:
      enabled: true
      targets:
        - name: openshift-console
          url: https://console-openshift-console.apps.cluster.example.com/health
          labels:
            vendor: aspecta
            team: platform
            module: http_openshift_console
            component: "openshift-console"
          interval: 30s
          scrapeTimeout: 30s
          module: http_openshift_console
        - name: openshift-api
          url: https://api.cluster.example.com:6443/readyz
          labels:
            vendor: aspecta
            team: platform
            module: http_openshift_api
            component: "openshift-api"
          interval: 10s
          scrapeTimeout: 10s
          module: http_openshift_api
    ```


