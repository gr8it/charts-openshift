# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
