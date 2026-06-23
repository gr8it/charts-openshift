# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-23

_Initial release._

Migrates the Loki Operator from hand-applied static manifests
(`observability/logging/02-loki-operator.yaml`) to a GitOps-managed helm release using
ACM `OperatorPolicy`. Reproduces the existing `stable-6.1` install with manual
install-plan approval (`startingCSV` pinned to the currently-installed
`loki-operator.v6.1.4`); adopts the existing `OperatorGroup` in
`openshift-operators-redhat` (no second OperatorGroup is created).
