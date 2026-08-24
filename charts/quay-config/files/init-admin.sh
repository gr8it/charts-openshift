#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- functions ---------------------------------------------
admin_credentials() {
  printf '{ "username": "%s", "password": "%s", "mail": "%s@localhost", "access_token": false }' "$1" "$2" "$1"
}

#-- variables ---------------------------------------------
adminPassword="$(openssl rand -base64 32 | tr -d /=+ | cut -c1-20)"
adminUser="$QUAYADMINUSER"
namespace="$NAMESPACE"
quayName="$QUAYNAME"
secretName="$QUAYADMINSECRET"
pushSecretLabels="$PUSHSECRETLABELS"
quayService="$QUAYSERVICE"

#-- main --------------------------------------------------
log_phase "Setting up local admin user ..."
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
    log_error "Something went wrong during admin user creation."
    echo "$adminInitMsg"
    exit 1
    ;;
esac

log_phase "Storing admin credentials in a secret ..."
quayUuid=$(oc get QuayRegistry "$quayName" -o jsonpath='{.metadata.uid}')
oc apply -f - <<EOT > /dev/null
apiVersion: v1
kind: Secret
metadata:
  name: "$secretName"
  namespace: "$namespace"
  labels:
    ${pushSecretLabels}
  ownerReferences:
    - apiVersion: quay.redhat.com/v1
      kind: QuayRegistry
      name: "$quayName"
      uid: "$quayUuid"
type: Opaque
stringData:
  username: "$adminUser"
  password: "$adminPassword"
EOT
log_info "Admin credentials stored in secret/${secretName}"

exit 0
