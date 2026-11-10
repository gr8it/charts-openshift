# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.8.0] - 2026-11-10

- appVersion 0.9.0: the reports listen on `127.0.0.1:8080` only, so pods on the network cannot read them without oauth-proxy
- **Breaking:** the Service port `metrics`, the ServiceMonitor and the probes use the metrics listener on port 9090 (`/metrics`, `/healthz`, `/readyz`);
  oauth-proxy upstream is `http://127.0.0.1:8080`; port-forward to `deploy/operators-guard` instead of the Service
- Readiness and liveness probes for oauth-proxy on `/oauth/healthz`
- `OperatorReadinessCollectStale` and the "Data age" panel use three collect intervals, at least 3 h (was a fixed 3 h)
- The non-MATCH prediction table shows the operator namespace (`exported_namespace`) in the namespace column

## [0.7.8] - 2026-11-10

- Fix the oauth-proxy cookie secret: write the generated `.password`, not the whole generator data map
- Use `exported_namespace` (the operator namespace after the scrape) in the prediction alert joins and the non-MATCH table keys
- Show only MISMATCH and STALE-PLAN plans in the non-MATCH prediction table

## [0.7.7] - 2026-11-10

- Lowered requests `256Mi` / `50m` and limits `512Mi` / `500m`

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
