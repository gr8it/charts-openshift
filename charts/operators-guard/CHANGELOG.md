# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.6] - 2026-11-10

- Schema accepts `interval` only in the format the engine parses (`h`, `m`, `s` in this order, e.g. `1h30m`)
- README: Route as the main access, logging, title and RBAC notes

## [0.7.5] - 2026-11-10

- appVersion 0.8.0: failed API call attempts are logged as `WARNING` with URL, attempt and duration and each collect logs its steps at `INFO`

## [0.7.4] - 2026-11-10

- Use lowercase `reencrypt` as stored by the Route API, so Argo CD does not report the Route as OutOfSync

## [0.7.3] - 2026-11-10

- Add Route `operators-guard` to the UI through an oauth-proxy sidecar that lets only cluster-admins through

## [0.7.2] - 2026-11-10

- Add NetworkPolicy `<release>-allow-proxy` with egress to `global.apc.proxyCIDRs`

## [0.7.1] - 2026-11-09

- Initial version in charts-openshift (from [apc-operators-guard](https://github.com/gr8it/apc-operators-guard) chart 0.7.1, operators-guard engine 0.7.4)
- Egress proxy from `global.apc.proxy` / `global.apc.noProxy` (apc-global-overrides) instead of the `proxy` object
- `image` is set without a tag; the tag is the chart appVersion
