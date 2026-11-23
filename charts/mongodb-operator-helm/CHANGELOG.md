# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2026-11-10

_([SPEXAPC-30540](https://aspecta.atlassian.net/browse/SPEXAPC-30540))_


### Fixed

- Duplicate instance report metrics (`PrometheusDuplicateTimestamps`) by bumping kube-state-metrics to `v2.20.0`; `v2.13.0` added a new custom resource store on every CRD discovery change ([kube-state-metrics#2502](https://github.com/kubernetes/kube-state-metrics/pull/2502))


## [1.2.0] - 2026-08-27

_([SPEXAPC-3367](https://aspecta.atlassian.net/browse/SPEXAPC-3367))_


### Added

- Optional MongoDB instance report: a kube-state-metrics deployment (ServiceAccount, ClusterRole/ClusterRoleBinding, ConfigMap, Deployment, Service, ServiceMonitor) reporting inventory and status.phase for MongoDBCommunity custom resources, toggled via `instanceReport.enabled`

## [1.1.1] - 2025-10-29

_([SPEXAPC-12156](https://aspecta.atlassian.net/browse/SPEXAPC-12156))_


### Fixed

- Selector label for monitoring service to point to operator pod  
