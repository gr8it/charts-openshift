#!/bin/sh
# helm-unittest validates schemas before assertions; exercise invalid values here.
set -eu
chart=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
output=$(mktemp)
trap 'rm -f "$output"' EXIT
if helm template operators-guard "$chart" -f "$chart/values.example.yaml" --set-string brief.enabled=yes >"$output" 2>&1; then
    echo 'FAIL: schema accepted a string brief.enabled' >&2
    exit 1
fi
grep -Eq "brief/enabled.*want boolean|brief.enabled.*boolean" "$output"
if helm template operators-guard "$chart" -f "$chart/values.example.yaml" --set brief.extra=true >"$output" 2>&1; then
    echo 'FAIL: schema accepted an unknown brief property' >&2
    exit 1
fi
grep -Eq "additional properties.*extra|Additional property extra" "$output"
echo 'PASS: brief schema rejects invalid toggle and unknown keys (2 checks)'

values=$(mktemp)
trap 'rm -f "$output" "$values"' EXIT
reject_workflow() {
    printf '%s\n' "$1" >"$values"
    if helm template operators-guard "$chart" -f "$chart/values.example.yaml" -f "$values" >"$output" 2>&1; then
        echo "FAIL: schema accepted $2" >&2
        exit 1
    fi
    grep -Eq 'workflow|excludeClusters|brief' "$output"
}
reject_workflow 'policy: {workflow: []}' 'workflow list'
reject_workflow 'policy: {workflow: {extra: true}}' 'unknown workflow key'
reject_workflow 'policy: {workflow: {chartsRepo: {path: 1}}}' 'numeric charts path'
reject_workflow 'policy: {workflow: {chartsRepo: {remote: " "}}}' 'blank remote'
reject_workflow 'policy: {workflow: {confRepos: {}}}' 'non-list conf repos'
reject_workflow 'policy: {workflow: {confRepos: [{clusters: cluster-a}]}}' 'non-list clusters'
reject_workflow 'policy: {workflow: {confRepos: [{envs: {cluster-a: false}}]}}' 'non-string environment'
reject_workflow 'policy: {workflow: {ticketPrefix: ""}}' 'empty ticket'
reject_workflow 'policy: {workflow: {push: yes}}' 'invalid push permission'
reject_workflow 'policy: {brief: {excludeClusters: cluster-a}}' 'non-list exclusions'
reject_workflow 'policy: {brief: {excludeClusters: [""]}}' 'empty exclusion'
reject_workflow 'policy: {brief: {extra: true}}' 'unknown policy brief key'
echo 'PASS: workflow and exclusion schema rejects invalid types, empty strings and unknown keys (12 checks)'
