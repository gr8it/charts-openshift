# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.9.1] - 2026-03-02

### Changed

- excluding argocd alerts on apc_namespace_type="application"

## [2.9.0] - 2026-02-10

### Added

- add egress netpol for kubeapi if egress proxy netpol is created
- add ingress netpol for openshift ingress

## [2.8.2] - 2026-02-11

### Changed

- Increase memory limits for ArgoCD component controller to improve performance

## [2.8.1] - 2026-01-19

### Changed

- Enabled v1.Endpoint and v1.EndpointSlice in ArgoCD

## [1.0.0] - 2025-06-16

_Initial release._
