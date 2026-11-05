# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-11-05

- Set the Local Storage OperatorGroup to target only `openshift-local-storage`.

## [1.0.2] - 2026-11-02

- Local Storage Operator `v4.19.0-202607311600` → `v4.19.0-202610241354` (channel `stable` catalog head). Previous 4.19 build stays in the OperatorPolicy allowed `versions`.

## [1.0.1] - 2026-08-14

- Keep the currently-installed `v4.17.0-202502250404` in the OperatorPolicy allowed `versions` so the policy stays compliant during the upgrade.
- Prefix `appVersion` with `v` to match operator wrapper chart metadata conventions.

## [1.0.0] - 2026-08-13

_Initial release._
