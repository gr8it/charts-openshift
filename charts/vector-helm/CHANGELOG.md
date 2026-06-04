# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-04

- Initial release of the genericized Vector chart.
- Preserve `Merge` creation policy for the SIEM token ExternalSecret during adoption.
- Add Vector service VIP IP SANs to the generated cert-manager Certificate.
- Move RHACS customer tag, Jira Ops endpoint, and SIEM sink name out of the chart template and into environment values.

_([SPEXAPC-7749]https://aspecta.atlassian.net/browse/SPEXAPC-7749)_
_Initial release. Migrated from conf-socpoist ocp-hub01/observability/vector._
