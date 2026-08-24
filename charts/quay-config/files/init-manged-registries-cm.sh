#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- variables ---------------------------------------------
quayName="$QUAYNAME"
managedRegistriesCm="$MANAGEDORGCM"
namespace="$NAMESPACE"
cmLabels="$CMLABELS"

#-- main (init cm) ----------------------------------------
log_phase "Creating $managedRegistriesCm ConfigMap ..."
if oc get configmap "$managedRegistriesCm" >/dev/null 2>&1; then
  log_info "ConfigMap $managedRegistriesCm already exists. Nothing to do."
  exit 0
fi

quayUuid=$(oc get QuayRegistry "$quayName" -o jsonpath='{.metadata.uid}')
oc apply -f - <<EOT > /dev/null
apiVersion: v1
kind: ConfigMap
metadata:
  name: "$managedRegistriesCm"
  namespace: "$namespace"
  labels:
    ${cmLabels}
  ownerReferences:
    - apiVersion: quay.redhat.com/v1
      kind: QuayRegistry
      name: "$quayName"
      uid: "$quayUuid"
data: {}
EOT
log_info "ConfigMap $managedRegistriesCm created."

exit 0
