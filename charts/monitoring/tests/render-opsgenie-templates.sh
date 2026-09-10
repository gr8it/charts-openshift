#!/usr/bin/env bash
# Renders the monitoring chart's Alertmanager opsgenie_configs description/tags Go
# templates through amtool (the real Alertmanager templating engine) against fixture
# alert payloads in fixtures/, and asserts on the actual notification text.
#
# helm-unittest only proves the Helm template emits the expected Go template *source*
# (see alertmanager_opsgenie_test.yaml) - it never executes that Go template, so a bug
# in the template logic itself (e.g. a `with` guard not covering its trailing comma)
# passes helm-unittest while still producing a broken Opsgenie notification. This
# script closes that gap by rendering the real notification text.
#
# Requires: amtool (go install github.com/prometheus/alertmanager/cmd/amtool@latest),
# yq (mikefarah, v4), python3.
set -euo pipefail

CHART_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURES_DIR="$CHART_DIR/tests/fixtures"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

for bin in amtool yq python3; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: $bin not found on PATH" >&2
    exit 1
  fi
done

helm template monitoring "$CHART_DIR" -f "$CHART_DIR/values.example.yaml" \
  --show-only templates/secret-alertmanager.yaml > "$WORK_DIR/rendered.yaml"

python3 - "$WORK_DIR/rendered.yaml" "$WORK_DIR" <<'PYEOF'
import sys, yaml
rendered_path, work_dir = sys.argv[1], sys.argv[2]
doc = yaml.safe_load(open(rendered_path))
am = yaml.safe_load(doc["stringData"]["alertmanager.yaml"])
recv = next(r for r in am["receivers"] if r["name"] == "atlassian_aspecta")
og = recv["opsgenie_configs"][0]
open(f"{work_dir}/description.tmpl", "w").write(og["description"])
open(f"{work_dir}/tags.tmpl", "w").write(og["tags"])
PYEOF

fail=0
assert_contains() {
  local label="$1" haystack="$2" needle="$3"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "FAIL: $label - expected to contain: $needle"
    echo "  --- actual ---"
    echo "$haystack" | sed 's/^/  /'
    fail=1
  fi
}
assert_not_contains() {
  local label="$1" haystack="$2" needle="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "FAIL: $label - expected NOT to contain: $needle"
    echo "  --- actual ---"
    echo "$haystack" | sed 's/^/  /'
    fail=1
  fi
}

render() {
  amtool template render --template.glob='' --no-version-check \
    --template.text="$(cat "$1")" --template.data="$2"
}

# tags is sent to Opsgenie as a single string; newlines in it are meaningless, so
# normalize them away before checking for blank/empty entries.
render_tags_flat() {
  render "$1" "$2" | tr -d '\n'
}

echo "== alert-pvc.json =="
desc=$(render "$WORK_DIR/description.tmpl" "$FIXTURES_DIR/alert-pvc.json")
tags=$(render_tags_flat "$WORK_DIR/tags.tmpl" "$FIXTURES_DIR/alert-pvc.json")
assert_contains "pvc description" "$desc" "namespace = logging-loki"
assert_contains "pvc description" "$desc" "Runbook: https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumefillingup"
assert_contains "pvc description" "$desc" "Source: https://console-openshift-console"
assert_contains "pvc tags" "$tags" "namespace=logging-loki"
assert_not_contains "pvc tags" "$tags" ",,"

echo "== alert-argocd.json =="
desc=$(render "$WORK_DIR/description.tmpl" "$FIXTURES_DIR/alert-argocd.json")
tags=$(render_tags_flat "$WORK_DIR/tags.tmpl" "$FIXTURES_DIR/alert-argocd.json")
assert_contains "argocd description" "$desc" "health status Degraded"
assert_contains "argocd description" "$desc" "Source: https://console-openshift-console"
assert_contains "argocd tags" "$tags" "sync_status=Synced"
assert_contains "argocd tags" "$tags" "health_status=Degraded"
assert_not_contains "argocd tags" "$tags" ",,"

echo "== alert-vendor-no-runbook.json (no runbook_url annotation) =="
desc=$(render "$WORK_DIR/description.tmpl" "$FIXTURES_DIR/alert-vendor-no-runbook.json")
tags=$(render_tags_flat "$WORK_DIR/tags.tmpl" "$FIXTURES_DIR/alert-vendor-no-runbook.json")
assert_contains "vendor description" "$desc" "Something happened."
assert_contains "vendor description" "$desc" "Source: https://console-openshift-console"
assert_not_contains "vendor description" "$desc" "Runbook:"
assert_not_contains "vendor tags" "$tags" ",,"

if [[ "$fail" -eq 1 ]]; then
  echo "FAILED"
  exit 1
fi
echo "OK - all opsgenie template renders matched expectations"
