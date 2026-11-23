# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.19; `ClusterPolicies` migrated to CEL policies (`policies.kyverno.io/v1`), names kept
- `<stack>-generate-tenant-clusterrole` → `GeneratingPolicy` (existing ClusterRoles/ClusterRoleBindings are adopted)
- `<stack>-tempo-sync-tenants` and `<stack>-tempo-cleanup-tenants` → `MutatingPolicy` mutating the existing TempoStack; tenant presence is checked on the TempoStack itself
- `<stack>-generate-tenant-clusterrole` keeps the generated resources when the policy is deleted (`orphanDownstreamOnPolicyDelete`), same as the pre-2.0.0 `ClusterPolicy`, so rolling back to the `ClusterPolicy` does not delete them

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.1.0] - 2026-07-10

### Changed
- Added tokenreviews (authentication.k8s.io) and subjectaccessreviews (authorization.k8s.io) permissions to the Kyverno background controller ClusterRole, required due to a breaking change in ([Tempo operator 0.16.0](https://github.com/grafana/tempo-operator/blob/main/CHANGELOG.md#0160))
- Added missing clusterrolebindings permissions to the Kyverno background controller ClusterRole

## [1.0.0] - 2026-05-12

_Initial release._
