#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- variables ---------------------------------------------
intOrgJobName="$INITORGJOB"
waitTimeout="600s"

#-- main --------------------------------------------------
log_phase "Waiting for $intOrgJobName job to finish (timeout: $waitTimeout) ..."
if ! oc get job "$intOrgJobName" >/dev/null 2>&1; then
  log_info "Job $intOrgJobName does not exist. Nothing to do."
  exit 0
fi

statusActive="$(oc get job "$intOrgJobName" -o jsonpath='{.status.active}')"

if [ "$statusActive" ] && [ "$statusActive" -gt 0 ]; then
  oc wait --for=condition=complete "job/$intOrgJobName" --timeout="$waitTimeout"
  log_info "Job $intOrgJobName completed. Ok to continue."
else
  log_info "Job $intOrgJobName exists but is not running. Nothing to do."
fi

exit 0
