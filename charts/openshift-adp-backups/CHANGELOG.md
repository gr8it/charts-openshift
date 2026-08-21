# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-07-28

### Added

- `hostedClusters` renders the two Velero Schedules that protect a hosted control plane spoke, deriving all four of its namespaces and the cluster-scoped ManagedCluster from the spoke name
- ClusterPolicy excluding klusterlet hub-kubeconfig credentials from Velero backups (moved in from the former `kyverno-backup-exclusions` chart)
- pre-seeded `<name>-import` Secret per `hostedClusters` entry, excluding it from Velero backups without Kyverno
