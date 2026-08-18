# openshift-virtualization-config

This chart renders the `HyperConverged` configuration for OpenShift Virtualization and the CNV entries in `Network/cluster.spec.additionalNetworks`.

`values.example.yaml` mirrors the existing production deployment shape so rendered examples stay close to real GitOps usage without naming customer-specific repos, clusters, or paths. Other clusters should override only their environment-specific network details in the conf repo.
