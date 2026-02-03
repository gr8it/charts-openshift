# Upgrading Guide

While upgrading follow guide at <https://docs.crossplane.io/latest/guides/upgrade-crossplane/>, which mainly recommends upgrading one minor version at a time, while following release notes of the particular releases.

## Health check

To check whether Crossplane upgrade is not causing any issues, please check:

- that all Crossplane component are running (using the new version)

- that all Crossplane provider usage is working, e.g vault provider, keycloak provider, ..
  - vault provider = cert-manager, eso
  - keycloak provider = bpm / api XRDs

### Provider config usage

Fortunately Crossplane provides a way to check how it is used = providerconfigusage CR. A vibe coded script than helps to list all usages:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Requires: kubectl, jq
# Purpose: From all ProviderConfigUsage objects, collect unique resourceRef kinds (and apiVersions)
# and then kubectl get all of those resources cluster-wide.

# Gather unique apiVersion+Kind pairs from resourceRef/resourceRefs
mapfile -t refs < <(
  kubectl get providerconfigusage -A -o json \
    | jq -r '
        .items[]
        | [(.resourceRef? // empty), (.resourceRefs[]? // empty)][]
        | select(.apiVersion and .kind)
        | "\(.apiVersion) \(.kind)"' \
    | sort -u
)

if ((${#refs[@]} == 0)); then
  echo "No resourceRefs found on any ProviderConfigUsage." >&2
  exit 0
fi

for line in "${refs[@]}"; do
  apiversion=${line%% *}
  kind=${line#* }

  # Split apiVersion into group/version
  if [[ "$apiversion" == */* ]]; then
    group=${apiversion%/*}
    version=${apiversion#*/}
  else
    group=""        # core
    version="$apiversion"
  fi

  # Resolve plural resource name for this Kind within the API group (if possible)
  resource=$(kubectl api-resources --no-headers -o wide ${group:+--api-group="$group"} 2>/dev/null \
               | awk -v k="$kind" 'toupper($0) ~ "\\<" toupper(k) "\\>" {print $1; exit}')

  # Prefer fully-qualified resource (resource.group) when we know the group; fallback to Kind
  if [[ -n "${resource:-}" ]]; then
    fqres=$resource
    if [[ -n "$group" ]]; then
      fqres="$resource.$group"
    fi
    echo "=== kubectl get $fqres -A ===" >&2
    kubectl get "$fqres" -A || true
  else
    echo "=== kubectl get $kind -A (fallback to Kind) ===" >&2
    kubectl get "$kind" -A || true
  fi
  echo >&2
done
```

### Cert manager, ESO

These use Kubernetes auth to Vault for authentication, and some policies for RBAC setup. All should be covered in [Provider config usage](#provider-config-usage), but we can still check the status of their stores / issuers:

```bash
kubectl get clustersecretstore; kubectl get secretstore -A; kubectl get clusterissuer
```
