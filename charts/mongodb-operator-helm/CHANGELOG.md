# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-08-27

_([SPEXAPC-3367](https://aspecta.atlassian.net/browse/SPEXAPC-3367))_


### Added

- Optional MongoDB instance report: a kube-state-metrics deployment (ServiceAccount, ClusterRole/ClusterRoleBinding, ConfigMap, Deployment, Service, ServiceMonitor) reporting inventory and status.phase for MongoDBCommunity custom resources, toggled via `instanceReport.enabled`

## [1.1.1] - 2025-10-29

_([SPEXAPC-12156](https://aspecta.atlassian.net/browse/SPEXAPC-12156))_


### Fixed

- Selector label for monitoring service to point to operator pod  
