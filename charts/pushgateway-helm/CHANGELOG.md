# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-28

### Added

- Initial release of pushgateway-helm chart
- Wraps prometheus-pushgateway upstream Helm chart (v2.16.0, app version v1.10.0)
- OpenShift OAuth proxy sidecar integration with TLS termination via Route
- ServiceAccount with OpenShift OAuth redirect annotation
- RBAC for OAuth proxy token reviews and Prometheus access
- Veeam ServiceAccount and ClusterRoleBinding for external metric submission
- Hub-only conditional rendering using `apc-global-overrides.clusterIsHub`
- PersistentVolume for metrics storage
- ServiceMonitor for integration with cluster monitoring
