# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-06-04

- Move RHACS customer tag, Jira Ops endpoint, and SIEM sink name out of the chart template and into environment values.

## [1.0.2] - 2026-06-04

- Preserve `Merge` creation policy for the SIEM token ExternalSecret during adoption.

## [1.0.1] - 2026-06-04

- Add Vector service VIP IP SANs to the generated cert-manager Certificate.
- Restore hub01 baseline values for the lint and snapshot fixture.

## [1.0.0] - 2026-05-04

- increasing version of vector from 0.38 to 0.50.0

_([SPEXAPC-7749]https://aspecta.atlassian.net/browse/SPEXAPC-7749)_
_Initial release. Migrated from conf-socpoist ocp-hub01/observability/vector._
