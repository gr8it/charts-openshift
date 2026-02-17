# Kyverno App Project

This chart delivers Kyverno ClusterPolicies that standardize application namespace defaults (quotas, limit ranges, proxy config, Vault access) and optional security helpers.

## Security: critical vulnerability enforcement

Enforcement of critical/important fixable CVEs is handled by RHACS (StackRox) admission control in Central using the built-in policy:
**Privileged Containers with Important and Critical Fixable CVEs**.

This chart does **not** manage RHACS policies. It provides an optional Kyverno policy to apply the RHACS break-glass annotation to selected workloads so that:
- the debug pod can run even if it is privileged and currently has critical CVEs,
- existing workloads can be exempted to avoid reschedule blockage until they are remediated.

Break-glass is enabled by default and targets namespaces or workloads labeled with
`apc.stackrox.io/break-glass: "true"`. You can disable or override the selectors with
`stackroxAdmissionBreakGlass` values.

## Decision log (2026-02-03)

- CVE enforcement must use RHACS admission control because Kyverno has no native access to vulnerability scan data.
- Exceptions are required for privileged debug tooling and for legacy workloads that must not be blocked on reschedule.
- We implement exceptions via Kyverno mutation that adds `admission.stackrox.io/break-glass: "true"` for selected workloads/namespaces.

## Follow-up tasks

- Enable enforcement for the RHACS policy in Central (GUI) for deploy-time blocking.
- Label or namespace-label workloads that need temporary exemptions.
- Remove exemptions after remediation.
