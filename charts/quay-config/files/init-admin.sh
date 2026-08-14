#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- functions ---------------------------------------------
admin_credentials() {
  printf '{ "username": "%s", "password": "%s", "mail": "%s@localhost", "access_token": true }' "$1" "$2" "$1"
}

#-- variables ---------------------------------------------
waitRetries=20
waitCounter=0
sleepCycleSeconds=90
adminPassword="$(openssl rand -base64 32 | tr -d /=+ | cut -c1-20)"
adminUser="$ADMINUSER"
namespace="$NAMESPACE"
secretName="$SECRETNAME"
pushSecretLabels="$PUSHSECRETLABELS"
quayService="$QUAYSERVICE"

#-- main --------------------------------------------------
log_info "Checking if Quay service is up and running ..."
until [ $(get_http_code "${quayService}/health/instance") -eq 200 ]; do
  waitCounter=$((waitCounter+1))
  if test $waitCounter -gt $waitRetries; then
    log_error "Giving up. Quay did not respond in time"
    exit 1
  fi
  log_info "[${waitCounter}/${waitRetries}] Quay Application is not ready yet. Sleeping for $sleepCycleSeconds seconds."
  sleep $sleepCycleSeconds
done

log_info "Setting up local admin user ..."
adminInitCredentials=$(admin_credentials "$adminUser" "$adminPassword")
adminInitResponse=$(curl --silent --show-error --connect-timeout 10 \
  --request POST --write-out "\n%{http_code}" \
  --header "Content-Type: application/json" \
  --data "$adminInitCredentials" \
  "${quayService}/api/v1/user/initialize")
adminInitCode=$(echo "$adminInitResponse" | tail -n1)
adminInitMsg=$(echo "$adminInitResponse" | sed '$d')
case "$adminInitCode" in
  200)
    log_info "Admin user created successfully"
    ;;
  400)
    log_info "Admin user is already initialized. Nothing to do."
    exit 0
    ;;
  *)
    log_error "Something went wrong during admin user creation:"
    echo "$adminInitMsg"
    exit 1
    ;;
esac

log_info "Storing admin credentials in a secret ..."
adminAccessToken=$(echo "$adminInitMsg" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
oc apply -f - <<EOT
apiVersion: v1
kind: Secret
metadata:
  name: "$secretName"
  namespace: "$namespace"
  labels:
    ${pushSecretLabels}
type: Opaque
stringData:
  username: "$adminUser"
  password: "$adminPassword"
  access_token: "$adminAccessToken"
EOT
log_info "Admin credentials stored in secret/${secretName}"

exit 0
