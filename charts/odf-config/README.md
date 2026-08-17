# odf-config

This chart renders the ODF entries in `Network/cluster.spec.additionalNetworks`.

`Network/cluster.spec.additionalNetworks` is co-owned: this chart only ever sets its own entries via server-side apply (merge-keyed by `name`), so other owners (e.g. `openshift-virtualization-config`'s CNV entries) are left intact. Set `additionalNetworks` per cluster in the conf repo; see [values.example.yaml](values.example.yaml).
