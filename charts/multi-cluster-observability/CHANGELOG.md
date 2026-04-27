# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-25

### Added

- Initial chart for ACM MultiClusterObservability migration from static manifests
- Templated resources for MultiClusterObservability, ObjectBucketClaim, Kyverno policy, NetworkPolicy, and metrics allowlists
- Dashboard files stored as raw JSON; template wraps them into ConfigMaps with consistent labels and annotations
- Hub-only resources guarded by `apc-global-overrides.clusterIsHub` helper
