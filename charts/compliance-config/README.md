# Compliance Config

This chart delivers ScanSetting, ScanSettingBinding, and optional TailoredProfile resources for the OpenShift Compliance Operator. Use it together with the `compliance-operator` chart, which installs the operator via ACM OperatorPolicy.

The namespace `openshift-compliance` is managed by ArgoCD through `managedNamespaceMetadata` in the gitops configuration.

## Templates

1. **ScanSetting** – Configures storage, tolerations, and scheduling of CIS scans.
2. **ScanSettingBinding** – Binds the ScanSetting to the built-in `ocp4-cis-node` profile.
3. **TailoredProfiles** (hub only) – Rendered only on hub clusters (when `apc-global-overrides.clusterIsHub=true`) by loading individual profile files from the `tailoredprofiles/` directory.

## TailoredProfiles Structure

TailoredProfiles are stored as individual YAML files in the `tailoredprofiles/` directory:
- `apc-ocp4-cis.yaml` – Custom CIS profile for APC hub cluster
- `apc-dev01-hypershift.yaml` – Profile for dev01 HyperShift spoke clusters
- `apc-test01-hypershift.yaml` – Profile for test01 HyperShift spoke clusters
- `apc-prod01-hypershift.yaml` – Profile for prod01 HyperShift spoke clusters

The template uses `.Files.Glob "tailoredprofiles/*.yaml"` to iterate over these files and render TailoredProfile resources with proper metadata.

## Key Values

```yaml
scanSetting:
  name: cis-scan-settings
  schedule: "0 1 * * *"

scanSettingBinding:
  name: cis-compliance
  profiles:
    - name: ocp4-cis-node  # Base CIS profile for node scanning
```

## Usage

- Install `compliance-operator` chart first to ensure the operator exists.
- Install `compliance-config` in the same namespace.
  - On hub clusters, TailoredProfiles automatically render via `clusterIsHub` detection from `apc-global-overrides`.
  - On spoke clusters, only ScanSetting and ScanSettingBinding render (no TailoredProfiles).
- Namespace is created by ArgoCD with labels: `openshift.io/cluster-monitoring=true` and `pod-security.kubernetes.io/enforce=privileged`.
