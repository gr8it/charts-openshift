# HW Monitoring

Helm chart for Loki `AlertingRule` alerts on HW/infrastructure events (UPS/PDU/XCA), evaluated against the `audit` tenant of the hub's LokiStack.

## Prerequisites

- Loki Operator and a `LokiStack` with an `audit` tenant must already be installed (see the `loki-operator` chart)
- Install this chart into the same namespace as the `LokiStack` (`openshift-logging`)

## Hub vs non-hub clusters

The `AlertingRule` is only rendered when `apc-global-overrides.clusterIsHub` resolves to `true` (`global.apc.cluster.isHub`, or a local `cluster.isHub` override) — HW/infrastructure events (UPS/PDU/XCA) are only ingested into the `audit` tenant on the hub. There is no dedicated enable/disable value for this chart; installing it on a spoke cluster renders no resources unless `cluster.isHub` is locally overridden to `true`.

## Alert rules

Three alerts, one per severity, fire when HW events (`hw_type` one of `ups`, `pdu`, `xca`) are seen in the `audit` tenant within the last 15 minutes:

- `HW-Events-Notification-Critical`
- `HW-Events-Notification-Warning`
- `HW-Events-Notification-Info`

The `customerName` alert label is taken from `apc-global-overrides.require-customer`.
