# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-27

_([SPEXAPC-4727](https://aspecta.atlassian.net/browse/SPEXAPC-4727))_

### Added

- NNCP bond/VLAN/bridge values under `nncp.` key with `nncp.enabled` flag (default: `true`)
- Default values reflect ocp-dev01 cluster configuration
- Full `_helpers.tpl` with chart/labels/selectorLabels helpers
- `values.example.yaml` for snapshot testing (ocp-dev01 config)
- `values.lint.yaml` for chart linting (minimal config, `nncp.enabled: false`)
- Snapshot test uses `values.example.yaml`
