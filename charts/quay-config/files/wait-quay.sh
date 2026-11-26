#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- variables ---------------------------------------------
waitCounter=0
waitRetries=20
sleepCycleSeconds=90
quayService="$QUAYSERVICE"

#-- main --------------------------------------------------
log_phase "Checking if Quay service is up and running ..."
until [ "$(get_http_code "${quayService}/health/instance")" -eq 200 ]; do
  waitCounter=$((waitCounter+1))
  if test $waitCounter -gt $waitRetries; then
    log_error "Giving up. Quay did not respond in time"
    exit 1
  fi
  log_info "[${waitCounter}/${waitRetries}] Quay Application is not ready yet. Sleeping for $sleepCycleSeconds seconds."
  sleep $sleepCycleSeconds
done
log_info "Quay service is up and running."

exit 0
