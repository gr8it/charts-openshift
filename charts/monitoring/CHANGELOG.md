# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.7] - 2026-08-19

_([SPEXAPC-21080](https://aspecta.atlassian.net/browse/SPEXAPC-21080))_

### Changed

- Added `atlassian_aspecta` route for `KubeNodeNotReady`, `KubeNodeUnreachable`, `CephClusterNearFull`, `CephOSDNearFull` warnings

## [1.1.6] - 2026-04-23

_([SPEXAPC-7744](https://aspecta.atlassian.net/browse/SPEXAPC-7744))_

### Changed

- Add note to ceph.rules silence: fixed in OCP 4.17.6, remove after cluster upgrade

## [1.1.5] - 2026-04-23

_([SPEXAPC-7744](https://aspecta.atlassian.net/browse/SPEXAPC-7744))_

### Changed

- Add KB reference comment to ceph.rules PrometheusRuleFailures silence

## [1.1.4] - 2026-04-23

_([SPEXAPC-7744](https://aspecta.atlassian.net/browse/SPEXAPC-7744))_

### Changed

- Extend certificate expiration silence matcher with `result-client-cert-ocp4-cis-1-5` and `root-ca-ocp4-cis-1-5` to avoid false alerts on periodic cert rotation

## [1.1.3] - 2026-07-29

_([SPEXAPC-7744](https://aspecta.atlassian.net/browse/SPEXAPC-7744))_

### Fixed

- conditional `prometheusrule-ldap-monitoring.yaml` behind `vaultBastionMonitoring.bastionIP`, matching the other vault-bastion templates — was rendering unconditionally into the `apc-monitoring-bastion` namespace, which doesn't exist on clusters without bastion monitoring enabled

## [1.1.2] - 2026-07-29

_([SPEXAPC-7744](https://aspecta.atlassian.net/browse/SPEXAPC-7744))_

### Fixed

- `clusterMonitoring.prometheus.retention` default corrected from `7d` to `14d`, matching the actual standard on spoke clusters (dev01, test01) — mirrors the same fix already applied to `userWorkloadMonitoring.prometheus.retention`

## [1.1.1] - 2026-07-29

_([SPEXAPC-7744](https://aspecta.atlassian.net/browse/SPEXAPC-7744))_

### Fixed

- Restored `PrometheusRuleFailures`/`ceph.rules` silence route in Alertmanager config, dropped during the raw-manifest-to-chart migration

## [1.1.0] - 2026-05-05

_([SPEXAPC-7744](https://aspecta.atlassian.net/browse/SPEXAPC-7744))_

### Changed

- Merged `cluster-monitoring` and `user-workload-monitoring` charts into this chart
- Added `ClusterMonitoringConfig`, `UserWorkloadMonitoringConfig`, AlertManager secrets and ExternalSecrets, AlertingRule, PrometheusRule, and NetworkPolicy templates
- Added `openshift-adp-backups` subchart dependency for Velero backup schedules
- Updated `apc-global-overrides` dependency to 1.8.0
- Hub detection via `global.apc.cluster.isHub` (replaces manual `hub.enabled` flag)

## [1.0.9] - 2026-02-27

_([ASPELAB-87](https://aspecta.atlassian.net/browse/ASPELAB-87))_

### Changed

- Added standard `monitoring.labels` to `clusterrole-admission-controller.yaml` for consistent resource tracking

## [1.0.8] - 2026-02-25

_([SPEXAPC-12860](https://aspecta.atlassian.net/browse/SPEXAPC-12860))_

### Changed

- Bump dependency on `monitoring-prometheusrules` to 1.0.6
- Added missing labels to Prometheus rules

## [1.0.7] - 2026-02-13

_([SPEXAPC-8954](https://aspecta.atlassian.net/browse/SPEXAPC-8954))_

### Changed

- Bump dependency on `monitoring-prometheusrules` to 1.0.5

## [1.0.6] - 2026-02-02

_([SPEXAPC-8954](https://aspecta.atlassian.net/browse/SPEXAPC-8954))_

### Changed

- Bump dependency on `monitoring-prometheusrules` to 1.0.4

## [1.0.5] - 2025-11-14

### Changed

- added verbs into prometheusrules resource

## [1.0.4] - 2025-11-12

### Changed

- added skipBackgroundRequests

## [1.0.3] - 2025-11-07

_chart type and clusterole_

### Changed

- added chart type: application
- added clusterrole-admission-controller.yaml
- bump version of dependency chart monitoring-prometheusrules

## [1.0.2] - 2025-10-30

_([SPEXAPC-7193](https://aspecta.atlassian.net/jira/software/c/projects/SPEXAPC/boards/109?selectedIssue=SPEXAPC-7193))_

### Changed

- Bump dependency on `monitoring-prometheusrules` from 1.0.0 to 1.0.3
- Bump dependency on `apc-global-overrides` from 1.3.0 to 1.4.0
