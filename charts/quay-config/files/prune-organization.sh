#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- functions ---------------------------------------------
get_json_keys_by_value() {
  printf '%s' "${1:-{\}}" | python3 -c "import json,sys; [print(k) for k,v in json.load(sys.stdin).items() if v==sys.argv[1]]" "$2"
}

#-- variables ---------------------------------------------
bootstrapToken="$(cat /var/opt/token/bootstrap)"
quayService="$QUAYSERVICE"
managedRegistriesCm="$MANAGEDORGCM"
requestedRegistriesList="$REGISTRYLIST"
errorFlag=0

#-- main --------------------------------------------------
if ! (oc get configmap "$managedRegistriesCm" -o go-template='{{range $k, $v := .data}}{{$v}}{{"\n"}}{{end}}' 2>/dev/null | grep -qw managed); then
  log_info "No managed organizations stored in ConfigMap $managedRegistriesCm. Skipping cleanup."
  exit 0
fi

managedRegistriesJson=$(oc get configmap "$managedRegistriesCm" -ojsonpath='{.data}')
managedRegistries=$(get_json_keys_by_value "$managedRegistriesJson" "managed" | sort -u)
requestedRegistries=$(echo $requestedRegistriesList | sed 's/,/\n/g' | sort -u)
readarray -t deltaRegistries <<< "$(comm -23 <(sed '/^[[:space:]]*$/d' <<<  "$managedRegistries") <(sed '/^[[:space:]]*$/d' <<<  "$requestedRegistries"))"

for proxyRegistry in "${deltaRegistries[@]}"; do
  if [ -z "${proxyRegistry//}" ]; then
    continue
  fi

  log_phase "Removing managed organization ${proxyRegistry} ..."
  deleteOrgResponse=$(curl --silent --show-error --connect-timeout 10 \
    --request DELETE --write-out "\n%{http_code}" \
    --header "Authorization: Bearer $bootstrapToken" \
    "${quayService}/api/v1/superuser/organizations/$(urlencode $proxyRegistry)")
  deleteOrgCode=$(echo "$deleteOrgResponse" | tail -n1)
  deleteOrgMsg=$(echo "$deleteOrgResponse" | sed '$d')

  case "$deleteOrgCode" in
    204)
      log_info "Organization $proxyRegistry removed."
      ;;
    400)
      log_info "Organization $proxyRegistry does not exist."
      ;;
    *)
      log_error "Something went wrong during organization removal (http_code: $deleteOrgCode)."
      echo "$deleteOrgMsg"
      errorFlag=1
      continue
      ;;
  esac

  oc patch configmap "$managedRegistriesCm" --type merge \
    --patch '{"data":{"'"$proxyRegistry"'":"removed"}}'
  log_info "Updated $proxyRegistry status in ConfigMap/${managedRegistriesCm}."
done

exit "$errorFlag"
