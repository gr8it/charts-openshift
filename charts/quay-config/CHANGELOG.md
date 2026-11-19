# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.20; the Argo CD sync trigger migrated from `ClusterPolicy` to CEL `MutatingPolicy` (`policies.kyverno.io/v1`) mutating the existing Application; it ignores the re-evaluation Kyverno runs on policy create/update, so deploying the policy does not trigger a sync

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.0.0] - 2026-08-23

_Initial release._
