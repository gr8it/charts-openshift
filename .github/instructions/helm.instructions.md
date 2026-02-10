---
applyTo: "charts/**"
---

# Copilot — Helm Chart Review Instructions

You are reviewing **Helm charts**. Focus on chart structure, templating quality, Kubernetes & OpenShift compatibility, runtime security, reliability, and upgrade safety.  
Always provide: (a) root cause, (b) concrete fix, (c) suggested diff.
When you find an issue, cite the relevant Helm or Kubernetes best practice and provide a concrete fix.

## What to check (ordered)

### 1) **Chart structure & metadata**
  - Ensure required files exist and are well‑formed: `Chart.yaml`, `values.yaml`, `templates/**`. 
  - Optional but recommended: `README.md`, `values.schema.json`, `templates/NOTES.txt`.
  - Enforce naming conventions: lowercase, hyphenated chart names; SemVer for `version`; set `appVersion`.
  - Check Chart.yaml metadata: description, keywords, maintainers (optional), `kubeVersion` if applicable.
  - Validate chart structure per Helm best practices.
  - Suggest fixes if missing.
  - _Refs_: 
    - [Helm chart structure & required files](https://helm.sh/docs/topics/charts/)
    - [naming & SemVer conventions](https://v2.helm.sh/docs/chart_best_practices/)

### 2) **Lint & schema validation readiness**
  - Recommend **`helm lint --strict`** and CI enforcement.
  - Call out missing schema defaults, missing enums, inconsistent types, or unvalidated complex objects.
  - If `values.schema.json` is missing, propose one covering:
    - `image.repository`, `image.tag`, `resources`, `ingress`, `service`, `securityContext`, etc.
  - Check if schema enforces required fields for production readiness.
  - _Refs_: 
    - [Helm lint](https://helm.sh/docs/helm/helm_lint/)
    - [JSON Schema validation examples](https://oneuptime.com/blog/post/2026-01-17-helm-schema-validation-values/view)

### 3) **Templates quality**
  - Verify templates avoid hard‑coded values; use `.Values` with sensible defaults.
  - Ensure `_helpers.tpl` exists and includes:
    - Standard Kubernetes labels  
    - Consistent resource naming helpers  
  - Require recommended Kubernetes label set:  
    `app.kubernetes.io/name`, `instance`, `version`, `managed-by`, `part-of`, `helm.sh/chart`.
  - For OpenShift: note that some annotations (e.g., route annotations) may differ—warn if non‑portable between K8s/OpenShift.
  - _Refs_:
    - [Helm templates best practices](https://helm.sh/docs/chart_best_practices/)
    - [OpenShift Helm guidelines (redhat.com)](https://docs.openshift.com/container-platform/latest/openshift_images/using-helm-charts.html)


### 4) **Kubernetes API compatibility & deprecations**
- Flag deprecated API versions in rendered manifests:
  - HPA → `autoscaling/v2`
  - PSP (removed) usage  
  - Deprecated Ingress versions  
  - Deprecated Storage, RBAC, CRD APIs
- Check compatibility with declared `kubeVersion`.
- Recommend avoiding alpha APIs in production unless strictly required.
- _Refs_:
  - [Kubernetes API deprecation guide](https://kubernetes.io/docs/reference/using-api/deprecation-guide/)
  - [Kubernetes dep policy](https://kubernetes.io/docs/reference/using-api/deprecation-policy/)


### 5) **Security (Pod Security, kube‑score checks, OpenShift UIDs)**
Check for violations of Kubernetes Security, OpenShift SCCs, and kube‑score rules:

- Mandatory security recommendations:
  - `runAsNonRoot: true`
  - Non‑zero `runAsUser`
  - `allowPrivilegeEscalation: false`
  - `readOnlyRootFilesystem: true`
  - Drop capabilities by default:  
    `capabilities: { drop: ["ALL"] }`
  - Avoid `privileged: true`, host namespaces, host networking/ports.
- OpenShift UID‑specific requirements:
  - Do **not** assume a fixed UID; OpenShift assigns random high UIDs.  
  - Avoid hard‑coded UIDs unless necessary; instead set:  
    ```yaml
    runAsNonRoot: true
    runAsUser: null
    ```
- _Refs_:
  - [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
  - [Kubernetes securityContext guidance](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
  - [OpenShift securityContext constraints](https://docs.openshift.com/container-platform/latest/authentication/managing-security-context-constraints.html)


### 6) **Resources, probes, and policies**
  - Require `resources.requests`/`limits`, `livenessProbe`/`readinessProbe` (and `startupProbe` where relevant).
  - Verify Service selectors align with pod labels; warn on mismatches.
  - _Refs_: 
    - [Helm best practices](https://helm.sh/docs/chart_best_practices/)
    - [Label/selector usage](https://www.baeldung.com/ops/helm-charts-best-practices)

### 7) **Dependencies & subcharts**
  - Use `dependencies` in `Chart.yaml` (or `charts/`) with pinned versions; document configurable values that flow into subcharts.  
  - _Refs_:
    - [Helm chart dependencies](https://helm.sh/docs/chart_best_practices/)

### 8) **Upgrades & immutability hazards**
  - Call out changes to immutable fields (e.g., StatefulSet volumeClaimTemplates) and recommend migration notes or hooks when needed.  

### 9) **Documentation & NOTES**
  - Ensure `README.md` includes: install/upgrade/uninstall commands, common overrides, and examples for `values.yaml`. 
  - Add `templates/NOTES.txt` for quick post‑install tips.  


## How to respond
When a user asks for a “Helm chart review” or opens a PR touching `charts/**`, do the following:

- **Summarize** overall health in 2–3 bullets.
- **Checklist with status** (✅/⚠️/❌) for items 1–9 above.
- **Inline suggestions**: propose specific diffs for problematic templates/values.
- **Pre‑merge validation**: show exact commands:
  ```bash
  helm lint --strict charts/<name>
  helm template charts/<name> --kube-version 1.29.0
  ```
