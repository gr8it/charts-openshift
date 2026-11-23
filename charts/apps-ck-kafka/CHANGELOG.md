# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-19

### Changed

- **Breaking:** requires Kyverno >= 1.19; `<namespace>-kuser-sync` migrated from `ClusterPolicy` to CEL `GeneratingPolicy` (`policies.kyverno.io/v1`), name kept so existing user Secrets are adopted; Secrets in namespaces removed from `appNs` are now deleted
- `<namespace>-kuser-sync` keeps the generated resources when the policy is deleted (`orphanDownstreamOnPolicyDelete`), same as the pre-2.0.0 `ClusterPolicy`, so rolling back to the `ClusterPolicy` does not delete them

_([SPEXAPC-32527](https://aspecta.atlassian.net/browse/SPEXAPC-32527))_

## [1.4.0] - 2026-07-14

### Added

- possibility to copy the kafka user secret to application namespace

### Fixed

- path in vault for kafka user secret in case kafka mirror is not enabled

## [1.3.0] - 2026-06-15

### Added

- kafka mirror support

## [1.2.4] - 2026-04-14

### Fixed

- fixing prometheusRule KafkaKRaftQuorumUnhealthy
- setting up correct jvm options for kafka controllers

## [1.2.3] - 2026-03-31

### Fixed

- disallow communication to port 9093 from the whole cluster and allow port 9093 only from specified namespaces
- allow communication to port 9092 from release namespace only

## [1.2.2] - 2026-03-18

### Added

- added optional KafkaTopic.spec.topicName

## [1.2.1] - 2026-01-28

### Changed

- change helm templating internal variable name

## [1.2.0] - 2026-01-22

### Added

- added Kafka UI auth using openshift oauth proxy with SAR for Kafka CR read privilege

### Changed

- creates KafkaTopics and KafkaUsers implicitly

## [1.1.0] - 2026-01-09

### Added

- added standard alert labels

## [1.0.0] - 2025-12-17

_Initial release._
