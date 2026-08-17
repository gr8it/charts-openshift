# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-08-10

### Changed

- ODF `stable-4.18` / `v4.18.25` → `stable-4.19` / `v4.19.20`.

## [1.1.0] - 2026-08-06

### Changed

- ODF upgrade `odf-operator.v4.17.5-rhodf` → `odf-operator.v4.18.25-rhodf` (catalog head; `v4.18.24` is not reachable from `stable-4.17` via `skipRange`, OLM resolves to head).
- Keep the currently-installed `v4.17.5-rhodf` in the OperatorPolicy allowed `versions` so the policy stays compliant during the upgrade.

## [1.0.0] - 2026-06-24

_Initial release._
