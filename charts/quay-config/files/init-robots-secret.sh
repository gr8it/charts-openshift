#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- variables ---------------------------------------------
quayName="$QUAYNAME"
robotAccountsSecret="$ROBOTACCOUNTSECRET"
namespace="$NAMESPACE"
secretLabels="$LABELS"

#-- main (init cm) ----------------------------------------
log_phase "Creating $robotAccountsSecret Secret ..."
if oc get secret "$robotAccountsSecret" >/dev/null 2>&1; then
  log_info "Secret $robotAccountsSecret already exists. Nothing to do."
  exit 0
fi

quayUuid=$(oc get QuayRegistry "$quayName" -o jsonpath='{.metadata.uid}')
oc apply -f - <<EOT > /dev/null
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: "$robotAccountsSecret"
  namespace: "$namespace"
  labels:
    ${secretLabels}
  ownerReferences:
    - apiVersion: quay.redhat.com/v1
      kind: QuayRegistry
      name: "$quayName"
      uid: "$quayUuid"
data: {}
EOT
log_info "Secret $robotAccountsSecret created."

exit 0
