# ACM Policy Helm Chart

This helm chart installs ACM policy using ACM policy framework, i.e. on hub cluster with placement decisions = deployed to selected managed clusters

See <https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.13/html-single/governance/index#hub-policy-framework>

## Restrictions

### Placement

- can be created or not
  - if placement is not created, a placement name must be specified to be used by placement binding
- placement using:
  - cluster name
  - cluster sets
  - label selectors
- no additional parameters available

### Placement Binding

- created only if placement created

### Managed Cluster Set Binding

- created only if placement created and creation requested
