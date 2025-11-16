# Compliance Config

This chart delivers the namespace, ScanSetting, ScanSettingBinding, and optional TailoredProfile resources for the OpenShift Compliance Operator. Use it together with the `compliance-operator` chart, which installs the operator via ACM OperatorPolicy.

## Templates

1. **Namespace** – `openshift-compliance` with monitoring/security labels.
2. **ScanSetting** – Configures storage, tolerations, and scheduling of CIS scans.
3. **ScanSettingBinding** – Binds the ScanSetting to built-in and/or tailored profiles.
4. **TailoredProfiles** (optional) – Rendered when `tailoredProfiles.enabled` is `true` to apply APC-specific tailored content.

## Key Values

```yaml
namespace:
  name: openshift-compliance

scanSetting:
  name: cis-scan-settings

scanSettingBinding:
  name: cis-compliance
  profiles:
  - name: ocp4-cis-node

# Enable on the hub cluster only
# tailoredProfiles:
#   enabled: true
```

## Usage

- Install `compliance-operator` chart to ensure the operator subscription exists.
- Install `compliance-config` (same release namespace) per cluster.
  - For hub01, set `tailoredProfiles.enabled=true` so all APC TailoredProfiles render and are added to the binding.
  - For spoke clusters, override only the `scanSetting`/`scanSettingBinding` values that differ.
