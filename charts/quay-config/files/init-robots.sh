#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- functions ---------------------------------------------
json_get_uuid_by_title() {
    printf '%s' "$1" | python3 -c "
import json,sys
data = json.load(sys.stdin)
title = sys.argv[1]
for t in data.get('tokens',[]):
  if t.get('title') == title:
    print(t.get('uuid'))
    break
" "$2" 2>/dev/null
}

json_equal() {
  python3 -c "import sys,json; sys.exit(0 if json.loads(sys.argv[1]) == json.loads(sys.argv[2]) else 1)" "$1" "$2"
}

merge_pull_secret() {
  printf '%s' "$1" | python3 -c "
import json,sys,base64
data = json.load(sys.stdin)
registry, username, password = sys.argv[1], sys.argv[2], sys.argv[3]
auth = base64.b64encode(f'{username}:{password}'.encode()).decode()
data['auths'][registry] = {'auth': auth}
json.dump(data, sys.stdout)
" "$2" "$3" "$4"
}

#-- variables ---------------------------------------------
bootstrapToken="$(cat /var/opt/token/bootstrap)"
clusterName="$CLUSTERNAME"
authBackendName="$AUTHBACKENDNAME"
vaultPath="$CLUSTERVAULTPATH"
quayService="$QUAYSERVICE"
quayRoute="$QUAYROUTE"
robotAccountsSecret="$ROBOTACCOUNTSECRET"
vaultAddress="$VAULTADDRESS"
vaultRole="$NAMESPACE"
vaultUpdateSecrets="$UPDATEVAULTSECRETS"

#-- main (robot init) -------------------------------------
log_phase "Setup robot account for \"$clusterName\" ..."
getAppTokensResponse=$(curl --silent --show-error --connect-timeout 10 \
  --request GET --write-out "\n%{http_code}" \
  --header "Authorization: Bearer $bootstrapToken" \
  "${quayService}/api/v1/user/apptoken")
getAppTokensCode=$(echo "$getAppTokensResponse" | tail -n1)
getAppTokensMsg=$(echo "$getAppTokensResponse" | sed '$d')
if [ "$getAppTokensCode" -ne 200 ]; then
  log_error "Error when checking if AppToken already exists (http_code: $getAppTokensCode)."
  echo: "$getAppTokensMsg"
  exit 1
fi

appTokenUuid=$(json_get_uuid_by_title "$getAppTokensMsg" "$clusterName")
if [ ! "${appTokenUuid}" ]; then
  log_info "Creating AppToken \"$clusterName\"."
  createAppTokenResponse=$(curl --silent --show-error --connect-timeout 10 \
    --request POST --write-out "\n%{http_code}" \
    --header "Authorization: Bearer $bootstrapToken" \
    --header "Content-Type: application/json" \
    --data  '{"title": "'"$clusterName"'"}' \
    "${quayService}/api/v1/user/apptoken")
  createAppTokenCode=$(echo "$createAppTokenResponse" | tail -n1)
  createAppTokenMsg=$(echo "$createAppTokenResponse" | sed '$d')
  if [ "$createAppTokenCode" -ne 200 ]; then
    log_error "Error when creating AppToken (http_code: $createAppTokenCode)."
    echo: "$createAppTokenMsg"
    exit 1
  fi
  appToken="$(get_json_value "$(get_json_value "$createAppTokenMsg" "token")" "token_code")"
else
  log_info "Getting AppToken for \"$clusterName\"."
  getAppTokenResponse=$(curl --silent --show-error --connect-timeout 10 \
    --request GET --write-out "\n%{http_code}" \
    --header "Authorization: Bearer $bootstrapToken" \
    "${quayService}/api/v1/user/apptoken/${appTokenUuid}")
  getAppTokenCode=$(echo "$getAppTokenResponse" | tail -n1)
  getAppTokenMsg=$(echo "$getAppTokenResponse" | sed '$d')
  if [ "$getAppTokenCode" -ne 200 ]; then
    log_error "Error when getting AppToken (http_code: $getAppTokenCode)."
    echo: "$getAppTokenMsg"
    exit 1
  fi
  appToken="$(get_json_value "$(get_json_value "$getAppTokenMsg" "token")" "token_code")"
fi

log_phase "Update robot accounts Secret ..."
if ! errorMsg=$(oc patch secret "$robotAccountsSecret" --type merge --patch '{"stringData":{"'"$clusterName"'":"$app:'"$appToken"'"}}' 2>&1 ); then
  log_error "Failed to update secret/$robotAccountsSecret"
  echo "$errorMsg"
  exit 1
fi
log_info "Updated secret/$robotAccountsSecret"

log_phase "Updating pull-secret in vault ..."

if ! (echo 'yes true 1'|grep -wqi "$vaultUpdateSecrets"); then
  log_info "Updating of pull-secret is disabled. Nothing to do."
  exit 0
fi

export VAULT_SKIP_VERIFY=true
export VAULT_ADDR="$vaultAddress"

if VAULT_TOKEN="$(vault/vault write -field=token "auth/${authBackendName}/login" role="$vaultRole" jwt="$(cat /run/secrets/kubernetes.io/serviceaccount/token)" 2>&1)"; then
  export VAULT_TOKEN
else
  log_error "Failed to authenticate with vault:"
  echo "$VAULT_TOKEN"
  exit 1
fi

currentPullSecret=$(vault/vault kv get -field=pull-secret "$vaultPath")
if ! errorMsg=$(validate_pull_secret "$currentPullSecret" 2>&1); then
  log_error "Original pull-secret at vault:${vaultPath} is malformed."
  echo "$errorMsg"
  exit 1
fi

mergedPullSecret=$(merge_pull_secret "$currentPullSecret" "$quayRoute" '$app' "$appToken")
if ! errorMsg=$(validate_pull_secret "$mergedPullSecret" 2>&1); then
  log_error "Merged pull-secret is malformed. Vault push aborted."
  echo "$errorMsg"
  exit 1
fi

if json_equal "$currentPullSecret" "$mergedPullSecret"; then
  log_info "Pull-secret is already up to date. Nothing to do."
else
  echo "$mergedPullSecret" | vault/vault kv patch "$vaultPath" pull-secret=-
  log_info "Updated pull-secret in \"$vaultPath\"."
fi

exit 0
