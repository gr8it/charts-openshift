# Changelog

All notable changes to this component will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.11.0] - 2026-11-11

- **Breaking:** remove the Route, oauth-proxy sidecar and OAuth cookie Secret; reports are reachable only through a pod port-forward.
  Argo CD prunes the old Route, ExternalSecret and Password generator only when pruning is enabled.
- **Breaking:** remove the `proxy` value; the chart reads `global.apc.proxy`, `global.apc.noProxy` and `global.apc.proxyCIDRs`.
- **Breaking:** split `image` into `image.repository` and `image.tag`; the tag defaults to the chart `appVersion`.
- Pin engine 0.13.3 (`appVersion`) with catalog channel options in the report and work order.
- Keep chart pins on the subscribed channel until a user chooses a switch.
- Use cluster proxy settings and scrape metrics every minute.

## [0.10.0] - 2026-11-11

- Pin engine 0.11.0 with self-contained operator work orders and ask-first destinations.
- Validate optional policy.workflow and policy.brief.excludeClusters; preserve report and snapshot formats.
- Quote report evidence, retain excluded-cluster CSVs, reject unsafe workflow references and tolerate empty chart values.

## [0.9.0] - 2026-11-11

- appVersion 0.10.0: `brief` writes operator pins and an LLM work order from report evidence, with optional chart mapping
- Block pin proposals when catalog comparison is uncertain; isolate brief failures from collection and remove stale output
- Optional `brief.enabled` writes the work order to the existing collector cache without new RBAC
- Add the local chart-editing playbook; unknown or incomplete evidence stays in Do-not-touch

## [0.8.1] - 2026-11-10

- Use `exported_namespace` (the operator namespace after the scrape, `honorLabels: false`) in the stale InstallPlan alert joins
  and in the keys and the namespace column of the non-MATCH prediction table; same-named Subscriptions in two namespaces no longer merge
- Show only MISMATCH and STALE-PLAN plans in the non-MATCH prediction table
- `OperatorReadinessCollectStale` and the "Data age" panel use three collect intervals, at least 3 h (was a fixed 3 h)
- Schema accepts `interval` only in the format the engine parses (`h`, `m`, `s` in this order)

## [0.8.0] - 2026-11-10

- appVersion 0.9.0: `--metrics-listen` serves only `/metrics`, `/healthz` and `/readyz`
- **Breaking:** the reports listen on `127.0.0.1:8080` only, the Service, ServiceMonitor and probes use the metrics listener on port 9090;
  pods that could reach the Service could read the fleet reports without authentication. Use `port-forward deploy/operators-guard 8080:8080`

## [0.7.2] - 2026-11-10

- appVersion 0.8.0: log every failed API call attempt as `WARNING` (method, URL, attempt, duration; `404` and `409` the engine handles only at `DEBUG`)
  and each collect step at `INFO` (start, inventory, lifecycle, catalog, prediction, evaluation, snapshot, next run) with counts and durations
- `LOG_LEVEL` environment variable (`DEBUG`, `INFO`, `WARNING`, `ERROR`; default `INFO`); `DEBUG` also logs every successful API call

## [0.7.1] - 2026-11-09

- Change the default image to `ghcr.io/gr8it/operators-guard:0.7.4`; the image content is unchanged.

## [0.7.0] - 2026-11-09

- **Breaking:** rename the chart from `operator-readiness` to `operators-guard`; default resource names and selector labels change. Set `nameOverride: operator-readiness` to keep them on existing installs.

## [0.6.4] - 2026-11-06

- appVersion 0.7.4: keep running OCP minors in catalog queries and classify uncertain OLM evidence as `UNKNOWN`.
- Alert on stale plans without readable timestamps; scope dashboard totals and split expiring from expired exceptions.

## [0.6.3] - 2026-11-06

- appVersion 0.7.3: compare channel-switch plans with the loaded current-channel graph; an absent graph yields `UNKNOWN`.
- Add dashboard panels for prediction checks, stale plans, exception expiry and source health.

## [0.6.2] - 2026-11-06

- appVersion 0.7.2: classify valid older pending InstallPlans as `STALE-PLAN`, with plan age, a separate gate and an alert after 14 days.
- Reserve prediction mismatches for CSVs outside the loaded channel graph.

## [0.6.1] - 2026-11-06

- appVersion 0.7.1: build the catalog index filter from the OCP versions observed in the [QA run on 2026-11-06](https://github.com/gr8it/apc-operators-guard/blob/operators-guard-chart-0.11.0/docs/06-example-hub-run.md#qa-hub-read-2026-11-06); the OCP 5.0 entry had made the prior filter empty and the catalog request failed with HTTP 400.

## [0.6.0] - 2026-11-06

- Compare the predicted OLM path with Subscription and InstallPlan evidence; alert on mismatches.
- Add package owners to operator reports, metrics, alerts and dashboard filters.
- Keep a bounded local report history, push timestamped snapshots and alert on expiring exceptions.

## [0.5.0] - 2026-11-03

- appVersion 0.6.0: HTML page of the summary on `/` (count tiles, filters, optional merge of clusters); `readiness-engine summary --format html`

## [0.4.1] - 2026-11-03

- Dashboard: `package` and `status` filters

## [0.4.0] - 2026-11-03

- appVersion 0.5.0: served catalog head per cluster (`CATALOG-LAG`), source `packagemanifests`
- RBAC: a Role and RoleBinding in `openshift-marketplace` with `get` on `packagemanifests` (hub); managed clusters are read through ManagedClusterViews
- Dashboard: the "different versions" panel lists the version per cluster

## [0.3.0] - 2026-11-03

- appVersion 0.4.0: `readiness-engine propose` and `check` commands, `proposal` in the drift report; the chart itself is unchanged

## [0.2.0] - 2026-11-03

- appVersion 0.3.0: operator drift (versions and days behind the channel head, `policy.minVersions`, vendor support end, OperatorPolicy pin staleness, version differences between clusters)
- Add `policy.minVersions` and `policy.drift` to values, schema and example
- Add alerts `OperatorSupportEnded`, `OperatorBelowMinVersion`, `OperatorPinStale`, `OperatorVersionBehind` and two dashboard panels
- RBAC: add `list` on `operatorpolicies` (hub) to read version pins
- Default image `ghcr.io/gr8it/readiness-engine:0.3.0` (was a `quay.io` path that is not published); add `imagePullSecrets`
- RBAC: add `list` on Subscriptions, CSVs and Deployments; without it Search returns no operators of the hub itself
- Add optional `nodeSelector` and `proxy` (HTTPS_PROXY, HTTP_PROXY, NO_PROXY)
- `snapshot.repository` and `snapshot.pushSecret` are optional: without a repository no snapshot is pushed
- Correct the memory comment (Pyxis replaced catalog index extraction)

## [0.1.10] - 2026-11-03

- Remove policy keys the engine does not read from `values.example.yaml` (`stages`, `evidence`, `gate`, `unsupportedWindow.maxDays`)
- Fix the policy section reference in `values.yaml`

## [0.1.9] - 2026-10-30

- appVersion 0.2.0; document metric `readiness_engine_info`

## [0.1.8] - 2026-10-30

- Document `policy.helmOperators` (upstream Helm operators) in values

## [0.1.7] - 2026-10-30

- Remove `registryAuthSecret`: catalog data comes from Pyxis, no registry.redhat.io pull
- Least privilege: ClusterRole limited to what readiness-engine calls; remove unused Role for `supported-versions` in `hypershift` and unused read access to OLM, HyperShift and ClusterOperator objects

## [0.1.6] - 2026-10-30

- Document egress to `catalog.redhat.com` (Pyxis) and new data sources `catalog`, `apirequestcount`

## [0.1.5] - 2026-10-30

- Remove alert `OperatorUpgradePending`: on a live hub 59 of 67 Subscriptions were `UpgradePending`, the normal state with OperatorPolicy `upgradeApproval: None`

## [0.1.4] - 2026-10-30

- Alert `OperatorUpgradePending` on `operator_subscription_upgrade_pending` (InstallPlan waiting for approval for 24 h)

## [0.1.3] - 2026-10-30

- readinessProbe on `/readyz`: the pod is ready only after the first successful collect
- Alert `OperatorReadinessNoData` when no successful collect exists (pod never ready)

## [0.1.2] - 2026-10-30

- Align with readiness-engine MVP: `lockstep` in example policy, `cluster_upgrade_readiness` and collect duration metrics documented

## [0.1.1] - 2026-10-30

- Fix default `grafanaDashboard.instanceName` to `apc-grafana` (label of grafana-apc-instance)
- Do not override the system trust store with the service CA (`SEARCH_API_CA_FILE` instead of `SSL_CERT_FILE`)
- Document Search API NetworkPolicy prerequisite

## [0.1.0] - 2026-10-30

- Initial release (example, readiness-engine image does not exist yet)
