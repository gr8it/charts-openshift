# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-08-11

### Changed

- MetalLB upgrade `metallb-operator.v4.17.0-202502250404` → `metallb-operator.v4.19.0-202607200644` (channel `stable` catalog head; MetalLB tracks OCP, clusters are OCP 4.19 so 4.19 is the reachable head and 4.20 waits for the OCP 4.20 bump).
- Keep the currently-installed `v4.17.0-202502250404` in the OperatorPolicy allowed `versions` so the policy stays compliant during the upgrade.

## [1.0.0] - 2026-02-25

_Initial release._
