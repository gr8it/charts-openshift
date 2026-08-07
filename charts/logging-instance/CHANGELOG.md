# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-16

_([SPEXAPC-7742](https://aspecta.atlassian.net/browse/SPEXAPC-7742))_

_Initial release._

### Added

- LokiStack configuration with per-environment size, retention, and ingestion settings
- ObjectBucketClaim for Loki S3 storage (replaces manual shell script)
- UIPlugin for logging in OpenShift console
- ClusterLogForwarder with conditional hub forwarding for spoke clusters
- ServiceAccount and ClusterRoleBindings for log collector
- ExternalSecret for hub-spoke-logforward token from Vault
