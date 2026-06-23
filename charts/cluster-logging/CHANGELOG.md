# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-23

_Initial release._

Migrates the Cluster Logging Operator from hand-applied static manifests
(`ocp-<cluster>/observability/logging/06-logging-operator.yaml`) to a GitOps-managed
helm release using ACM `OperatorPolicy`. Reproduces the existing install with manual
install-plan approval (`upgradeApproval: None`); `startingCSV` is omitted so the managed
Subscription renders identical to the live object on every cluster (live subs set none,
and the installed CSV differs per cluster). The chart default carries the conf-socpoist
`stable-6.1` baseline, with a single conf-sp-qa override to channel `stable-6.2`. Adopts
the existing `OperatorGroup` in `openshift-logging` (no second OperatorGroup is created).
