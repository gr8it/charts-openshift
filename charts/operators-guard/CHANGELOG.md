# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.2] - 2026-11-10

- Add NetworkPolicy `<release>-allow-proxy` with egress to `global.apc.proxyCIDRs`;

## [0.7.1] - 2026-11-09

- Initial version in charts-openshift (from [apc-operators-guard](https://github.com/gr8it/apc-operators-guard) chart 0.7.1, operators-guard engine 0.7.4)
- Egress proxy from `global.apc.proxy` / `global.apc.noProxy` (apc-global-overrides) instead of the `proxy` object
- `image` is set without a tag; the tag is the chart appVersion
