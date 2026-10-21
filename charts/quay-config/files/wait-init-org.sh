#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- variables ---------------------------------------------
intOrgJobName="$INITORGJOB"
waitTimeout="600"
waitRetries="10"

#-- main --------------------------------------------------
log_phase "Waiting for $intOrgJobName job to finish ..."
if ! oc get job "$intOrgJobName" >/dev/null 2>&1; then
  log_info "Job $intOrgJobName does not exist. Nothing to do."
  exit 0
fi

statusActive="$(oc get job "$intOrgJobName" -o jsonpath='{.status.active}')"
if [ "$statusActive" ] && [ "$statusActive" -gt 0 ]; then
  waitCounter=0
  until oc wait --for=condition=complete "job/$intOrgJobName" --timeout="$((waitTimeout/waitRetries))s" 2>/dev/null; do
    waitCounter=$((waitCounter+1))
    log_info "[${waitCounter}/${waitRetries}] Job ${intOrgJobName} still running. Waiting for $((waitTimeout/waitRetries)) seconds."
    if test $waitCounter -gt $waitRetries; then
      log_error "Giving up. Job $intOrgJobName did not complete in time."
      exit 1
    fi
  done
  log_info "Job $intOrgJobName completed. Ok to continue."
else
  log_info "Job $intOrgJobName exists but is not running. Nothing to do."
fi

exit 0
