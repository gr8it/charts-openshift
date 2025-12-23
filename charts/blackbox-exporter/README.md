# APC Blackbox exporter Helm chart

A Helm chart to setup Blackbox exporter in APC

## Overview

This Helm chart deploys Blackbox exporter in following configuration:
- blackbox exporter with 
  - modules:
    - icmp
    - tcp_probe
    - http_2xx
      http_openshift_api
    - http_openshift_console
  - serviceMonitor:
    - defaults:
      - openshift-console
      - openshift-api
      - hw-xca
      - gitlab-webui
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

- `prometheus-blackbox-exporter.serviceMonitor.targets`: list target to monitoring from cluster where Blacbox exporter is deployed

Examples:
  - cluster test01:
    ```yaml
    serviceMonitor:
      enabled: true
      targets:
        - name: openshift-console
          url: https://console-openshift-console.apps.test01.cloud.socpoist.sk/health
          labels:
            vendor: aspecta
            team: platform
            module: http_openshift_console
            component: "openshift-console"
          interval: 30s
          scrapeTimeout: 30s
          module: http_openshift_console
        - name: openshift-api
          url: https://api.test01.cloud.socpoist.sk:6443/readyz
          labels:
            vendor: aspecta
            team: platform
            module: http_openshift_api
            component: "openshift-api"
          interval: 10s
          scrapeTimeout: 10s
          module: http_openshift_api
    ```
  - cluster hub01:
    ```yaml
    serviceMonitor:
      enabled: true
      targets:
        - name: openshift-console
          url: https://console-openshift-console.apps.hub01.cloud.socpoist.sk/health
          labels:
            vendor: aspecta
            team: platform
            module: http_openshift_console
            component: "openshift-console"
          interval: 30s
          scrapeTimeout: 30s
          module: http_openshift_console
        - name: openshift-api
          url: https://api.hub01.cloud.socpoist.sk:6443/readyz
          labels:
            vendor: aspecta
            team: platform
            module: http_openshift_api
            component: "openshift-api"
          interval: 10s
          scrapeTimeout: 10s
          module: http_openshift_api
        - name: hw-xca
          url: https://sr-ba-xapc1xca-p11.hw.apc.socpoist.sk
          labels:
            vendor: aspecta
            team: platform
            module: http_2xx
            component: "xca"
          interval: 10s
          scrapeTimeout: 10s
          module: http_2xx
        - name: gitlab-webui
          url: https://git.apps.hub01.cloud.socpoist.sk
          labels:
            vendor: aspecta
            team: platform
            module: http_2xx
            component: "gitlab-webui"
          interval: 10s
          scrapeTimeout: 10s
          module: http_2xx
    ```


