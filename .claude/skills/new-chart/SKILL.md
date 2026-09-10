---
name: new-chart
description: Scaffold a brand-new Helm chart in charts-openshift for a new use case, following repo conventions (values files, schema, tests, naming). Use when asked to "create a new chart", "add a chart for X", "package X as a chart", or similar — not for converting an existing static manifest (use migrate-chart for that).
---

# New chart

Scaffold a new chart under `charts/<name>/` that is correct on the first PR — matching every convention in `.github/copilot-instructions.md` (symlinked as `CLAUDE.md`), not just the ones visible in nearby example charts. Several existing charts in this repo predate the current conventions and are missing required files (e.g. `values.schema.json`) — don't copy that gap forward.

## 1. Clarify before scaffolding

Don't guess on these — ask the user if not already stated:

- **Component name.** Check it against the naming convention (`<component>`, `<component>-operator`/`-helm`, `<component>-config`/`-instance`/`-policies`) — pick the suffix based on what the chart actually does, not habit.
- **What Kubernetes/OpenShift resources it creates.** Enough to know the template list up front.
- **What genuinely differs between DEV01/TEST01/PROD01** for this component (image tag, replica count, resource sizes, feature toggle). Everything else should come from `apc-global-overrides` or be hardcoded — see values.yaml Conventions in the root instructions. If the user asks for a config knob that isn't a real per-environment difference, push back before adding it.
- Whether it needs to install an operator (→ ACM `operatorpolicy` pattern) vs. configure one already installed (→ `-config`/`-instance` chart depending on a CR).

## 2. Scaffold

```
charts/<name>/
  Chart.yaml
  values.yaml
  values.example.yaml
  values.lint.yaml        # only if helm lint needs globals absent from values.yaml
  values.schema.json
  templates/
    _helpers.tpl           # only if needed
    <resource>.yaml         # one resource per file
  tests/
    snapshot_test.yaml
```

- `Chart.yaml`: `apiVersion: v2`, `type: application`, `version: 1.0.0`. Add the `apc-global-overrides` dependency if the chart uses any of its helpers — check `charts/apc-global-overrides/Chart.yaml` for the current version to pin, don't assume.
- `values.yaml`: only the minimal per-environment values identified in step 1. Document every global value the chart relies on as a comment block (`## uses following global values => do not set here`), never set it.
- `values.example.yaml`: realistic, non-secret values — just the overrides needed to render, plus whatever globals `values.lint.yaml`/test rendering requires.
- `values.schema.json`: schema for everything in `values.yaml` — this is a hard requirement, not optional, even though you'll find it missing on most existing charts.
- Every template file: `namespace: {{ .Release.Namespace }}`, flat value references (`clusterName` not `cluster.name`).
- `tests/snapshot_test.yaml`: base snapshot against `values.example.yaml`, plus explicit cases for any conditional (feature toggle on/off, optional resource created/not created).
- If the component involves alerting, follow PrometheusRule Conventions (severity/vendor/team labels) in the root instructions.

## 3. Verify — don't declare done without this

```bash
CHARTFOLDER=<name> make lint
CHARTFOLDER=<name> make unittest
```

Both must pass. If `make lint` fails only because of missing cluster globals, that's what `values.lint.yaml` is for — add the minimum needed, nothing more.

Re-read the Definition of Done checklist in the root instructions before considering the chart finished.

## 4. Handing off

Per the repo's agent boundaries: you may commit to a feature branch (name includes the Jira ticket ID) and open a PR. Never run `make publish`, never merge, never force-push. Stop at "PR opened" and let a human take it from there.
