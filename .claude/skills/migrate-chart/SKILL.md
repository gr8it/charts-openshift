---
name: migrate-chart
description: Convert an existing static OpenShift manifest set (deployed outside GitOps, living in the conf repo's ocp-<environment>/<component>/ folders) into a Helm chart in charts-openshift, so it can be adopted into ArgoCD GitOps. Use when asked to "migrate X to a chart", "gitops-ify X", "bring X under helm", or similar — not for a brand-new use case (use new-chart for that).
---

# Migrate chart

Turn a pre-existing, manually-applied set of manifests into a chart that renders to the **same objects**, parametrized only where genuinely necessary. The goal is a chart ArgoCD can adopt without an unexpected diff on first sync — not a redesign of the component.

## 1. Locate the source manifests

The conf repo is a separate git repository, usually checked out as a sibling directory (e.g. `conf-<customer>`). If you don't already have its path from context, ask rather than guessing.

Static, pre-GitOps manifests for a component live at:

```
<conf-repo>/ocp-<environment>/<component>/*.yaml
```

for each of `dev01`, `test01`, `prod01` (and sometimes `hub01`, if the component has hub-cluster objects — see the watch-out below). Read all environment copies before writing anything.

Ignore/flag non-manifest files in that folder (`.sh` scripts, `.ini` config, README) — these aren't candidates for templating and need a human decision on how to handle them; don't try to force them into the chart.

**Watch out:** filenames are sometimes prefixed with a cluster name (e.g. `03-hub01-hostedcluster-idp.yaml`, `04-dev01-secret-ad-bind.yaml`) inside a single environment's folder. This means some objects belong to the **hub cluster** (installed once, not per-workload-environment) while others repeat per DEV01/TEST01/PROD01. Don't assume every file in `ocp-dev01/<component>/` is a DEV01-cluster object — check the target cluster per file before deciding what's "per-environment".

## 2. Diff across environments, classify every difference

For each field that differs between the DEV01/TEST01/PROD01 (and hub01, if applicable) copies of a manifest:

1. **Check if `apc-global-overrides` already covers it** (cluster name, environment short name, apps domain, shared stores, etc. — see the helper list in `charts/apc-global-overrides/README.md`). If yes, use the helper — do not turn it into a chart value.
2. **If it's a genuine per-environment business value** (image tag, replica count, resource sizing, a feature toggle) — promote it to `values.yaml`, minimal-values style, same as new-chart.
3. **If it's neither** — don't guess. Ask the user whether it's a real configuration need or an accident of how the static manifests were hand-written (e.g. leftover copy-paste drift).

Anything that's **identical** across all environment copies should be hardcoded straight into the template — it is not a configuration point.

## 3. Scaffold the chart

Same structure and requirements as `new-chart` (Chart.yaml, values.yaml, values.example.yaml, values.lint.yaml if needed, values.schema.json, one resource per template file, `namespace: {{ .Release.Namespace }}` everywhere, tests/snapshot_test.yaml). Naming follows the same component-naming convention — the chart name doesn't have to match the conf-repo folder name if the naming convention implies a different suffix (e.g. it's actually a `-config` chart, not a bare component).

## 4. Verify equivalence, not just "it renders"

The bar for a migration is that `helm template` output matches the original static manifest for a given environment, modulo intentional, explained changes (e.g. adding `namespace: {{ .Release.Namespace }}` where it was implicit before). Concretely:

```bash
helm template <name> charts/<name> -f charts/<name>/values.example.yaml
```

Diff this against the actual static manifest for at least one environment (prefer dev01) and call out every difference to the user with a reason — don't silently accept drift, and don't silently "improve" the object (add fields, change defaults) beyond what step 2 concluded was necessary.

Also run the standard gate: `CHARTFOLDER=<name> make lint` and `CHARTFOLDER=<name> make unittest` must pass.

## 5. What this skill does NOT do

- It never edits, commits, or pushes to the conf repo. Registering the new chart for actual GitOps deployment (adding it to `gitops/environments/<env>/versions.yaml.gotmpl` and creating `gitops/components/<component>/values.<env>.yaml.gotmpl`) happens in that repo's own session — end by listing exactly what needs to be added there, as a checklist for the user, not as an auto-applied change.
- It never deletes or edits the original static manifests in `ocp-<environment>/<component>/`. Decommissioning those is a separate, human-led step taken only after the chart is deployed and reconciled by ArgoCD.
- Same PR boundaries as new-chart: commit + open a PR in charts-openshift, never `make publish`, never merge, never force-push.
