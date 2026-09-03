# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-03

_([SPEXAPC-8225](https://aspecta.atlassian.net/browse/SPEXAPC-8225))_

### Changed

- Curated Kubernetes workload alert descriptions to show only affected objects, status, and measured values.

## [1.0.7] - 2026-07-30

_([SPEXAPC-20772](https://aspecta.atlassian.net/browse/SPEXAPC-20772))_

### Added

- added alert for evicted pod

## [1.0.6] - 2026-02-25

_([SPEXAPC-12860](https://aspecta.atlassian.net/browse/SPEXAPC-12860))_

### Changed

- added missing labels into prometheus rules

## [1.0.5] - 2026-02-12

_([SPEXAPC-8954](https://aspecta.atlassian.net/browse/SPEXAPC-8954))_

### Changed

- reformat description in KubeJobNotCompleted alert

## [1.0.4] - 2026-02-03

_([SPEXAPC-8954](https://aspecta.atlassian.net/browse/SPEXAPC-8954))_

### Changed

- reformat alerts description for correct label rendering
- added alerts HighMemoryUtilization and HighCPUUtilization

## [1.0.3] - 2025-11-07

_Rules logic update_

### Changed

- proper namespace handling of expr in prometheusrules


## [1.0.2] - 2025-10-30

_([SPEXAPC-7193](https://aspecta.atlassian.net/jira/software/c/projects/SPEXAPC/boards/109?selectedIssue=SPEXAPC-7193))_

### Added

- Provide PrometheusRule manifests as a reusable library chart that other Helm charts can import.
