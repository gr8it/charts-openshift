# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-08-10

Move the default channel to `stable-6.2` and let the OperatorPolicy upgrade to the
current catalog head `loki-operator.v6.2.12`. The approved `versions` list spans
`v6.2.9..v6.2.12` (covering the head across clusters whose catalogs may lag) plus the
previously installed `loki-operator.v6.1.4`, so clusters on either the old 6.1.4 or
the new 6.2.x stay compliant during the CSV swap.

## [1.1.1] - 2026-07-07

Fix Loki Operator metrics policy ServiceMonitor matching after namespace migration.

## [1.1.0] - 2026-07-07

Fix Loki Operator metrics ServiceMonitor TLS server name and metrics-reader RBAC after namespace migration.

## [1.0.0] - 2026-06-23

_Initial release._
