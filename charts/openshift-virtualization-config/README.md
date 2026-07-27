# openshift-virtualization-config

This chart renders the `HyperConverged` configuration for OpenShift Virtualization and the CNV entries in `Network/cluster.spec.additionalNetworks`.

`values.example.yaml` mirrors the existing `conf-socpoist/ocp-dev01/ocp-virt` deployment shape so rendered examples stay close to the real GitOps usage. Other clusters should override only their environment-specific network details in the conf repo.
