#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- variables ---------------------------------------------
waitCounter=0
waitRetries=20
tokenExists=0
sleepCycleSeconds=30
bootstrapTokenSecret="$BOOTSTRAPTOKENSECRET"
quayService="$QUAYSERVICE"

#-- main --------------------------------------------------
log_phase "Checking if bootstrap token secret exists ..."
until [ "$tokenExists" -eq 1 ]; do
  waitCounter=$((waitCounter+1))
  if [ $waitCounter -gt $waitRetries ]; then
    log_error "Giving up. Bootstrap token secret was not provisioned in time."
    exit 1
  fi
  bootstrapTokenJson=$( oc get secret $bootstrapTokenSecret -o go-template='{{ index .data "token.json" | base64decode}}' 2>/dev/null || true )

  if has_json_key "${bootstrapTokenJson:-}" "access_token"; then
    bootstrapToken="$(get_json_value "${bootstrapTokenJson:-}" "access_token")"
  fi

  if  [ "${bootstrapToken:-}" != "" ] &&
      [ "${bootstrapToken:-}" != "None" ]; then
    tokenExists=1
    continue
  fi

  log_info "[${waitCounter}/${waitRetries}] Bootstrap token is not ready yet. Sleeping for $sleepCycleSeconds seconds."
  sleep "$sleepCycleSeconds"
done
log_info "Bootstrap token secret exists."

log_phase "Checking if bootstrap token is valid ..."
checkTokenResponse=$(get_http_code_auth "$bootstrapToken" "${quayService}/api/v1/user/")
checkTokenCode=$(echo "$checkTokenResponse" | tail -n1)
checkTokenMsg=$(echo "$checkTokenResponse" | sed '$d')

if [ "$checkTokenCode" -eq 401 ]; then
  tokenRotated=0
  log_info "Bootstrap token is expired and will be rotated."
  quayAppPod=$( oc get pods -l quay-component=quay-app --field-selector status.phase=Running -o jsonpath='{.items[0].metadata.name}' )
  renewReply=$(oc exec $quayAppPod -- curl -sS -X POST -H "Authorization: Bearer $bootstrapToken" "http://127.0.0.1:8080/api/v1/bootstrap/renew")
  if [ "$renewReply" != '{"status": "rotated"}' ]; then
    log_error "There was a problem with renewing the bootstrap token:"
    echo "$renewReply"
    #exit 1
  fi
  while [ "${newBootstrapToken:-$bootstrapToken}" = "$bootstrapToken"  ]; do
    if [ $tokenRotated -ge $((waitRetries/2)) ]; then
      log_error "Giving up. New bootstrap token was not provisioned in time."
      #exit 1
      break
    fi
    bootstrapTokenJson=$( oc get secret $bootstrapTokenSecret -o go-template='{{ index .data "token.json" | base64decode}}' 2>/dev/null || true )
    newBootstrapToken="$(get_json_value "${bootstrapTokenJson:-}" "access_token")"
    tokenRotated=$((tokenRotated+1))
    log_info "[${tokenRotated}/$((waitRetries/2))] Waiting for new token secret to be provisioned."
    sleep 5
  done
  bootstrapToken="$newBootstrapToken"
  log_info "Bootstrap token has been rotated."
fi

if [ "${tokenRotated:-0}" -gt 0 ]; then
  log_phase "Checking if new (rotated) bootstrap token is valid ..."
  checkTokenResponse=$(get_http_code_auth "$bootstrapToken" "${quayService}/api/v1/user/")
  checkTokenCode=$(echo "$checkTokenResponse" | tail -n1)
  checkTokenMsg=$(echo "$checkTokenResponse" | sed '$d')
fi

if [ "$checkTokenCode" -ne 200 ]; then
  log_error "Bootstrap bearer token is invalid. Unable to proceed (http_code: $checkTokenCode)."
  echo "$checkTokenMsg"
  exit 1
fi

echo "$bootstrapToken" > /var/opt/token/bootstrap

log_info "Bootstrap token is valid."

exit 0
