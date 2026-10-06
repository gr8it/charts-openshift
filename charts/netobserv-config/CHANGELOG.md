# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-10-06

### Added

- RBAC for Network Observability Operator 1.12.2+ in a custom namespace: ClusterRoleBindings for `flowlogs-pipeline` and `netobserv-plugin`, RoleBindings for the LokiStack secret
- `flowCollector.agent.ebpf.features` to enable eBPF agent features (e.g. `DNSTracking`, `FlowRTT`, `TLSTracking`)

## [1.0.0] - 2026-04-20

_Initial release._
