# Kyverno App Project

This chart delivers Kyverno ClusterPolicies that standardize application namespace defaults (quotas, limit ranges, proxy config, Vault access) and optional security helpers.

## Security: critical vulnerability enforcement

Enforcement of critical/important fixable CVEs is handled by RHACS (StackRox) admission control in Central using the built-in policy:
**Privileged Containers with Important and Critical Fixable CVEs**.

This chart does **not** manage RHACS policies. It provides an optional Kyverno policy to apply the RHACS break-glass annotation to selected workloads so that:
- the debug pod can run even if it is privileged and currently has critical CVEs,
- existing workloads can be exempted to avoid reschedule blockage until they are remediated.

Break-glass is enabled by default and can target resources via:
- explicit namespace list (`stackroxAdmissionBreakGlass.namespaces`),
- namespace label selector (`stackroxAdmissionBreakGlass.namespaceSelector`),
- workload label selector (`stackroxAdmissionBreakGlass.workloadSelector`).

The selectors are evaluated as **OR** (any match applies), so namespace-level targeting works
without requiring workload labels.

This chart also supports automatic namespace labeling through
`stackroxAdmissionBreakGlass.autoNamespaceLabeling` (enabled by default for `apc-debug`).
That removes the need to label namespaces manually in each cluster.

For first rollout safety, this chart also includes bootstrap coverage for already existing workloads via
`stackroxAdmissionBreakGlass.bootstrapExistingWorkloads` (enabled by default). It mutates existing workloads
in background mode so reschedules/upgrades are not blocked immediately, while new workloads can still be
enforced once you tighten selectors.

## Decision log (2026-02-03)

- CVE enforcement must use RHACS admission control because Kyverno has no native access to vulnerability scan data.
- Exceptions are required for privileged debug tooling and for legacy workloads that must not be blocked on reschedule.
- We implement exceptions via Kyverno mutation that adds `admission.stackrox.io/break-glass: "true"` for selected workloads/namespaces.

## Follow-up tasks

- Enable enforcement for the RHACS policy in Central (GUI) for deploy-time blocking.
- Configure `stackroxAdmissionBreakGlass.autoNamespaceLabeling.namespaces` and/or selectors in Git.
- Review and then tighten/disable `stackroxAdmissionBreakGlass.bootstrapExistingWorkloads` after remediation.
- Remove exemptions after remediation.
