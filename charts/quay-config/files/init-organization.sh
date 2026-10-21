#!/usr/bin/env bash
set -e -u -o pipefail

#-- import common functions -------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common-functions.sh"

#-- functions ---------------------------------------------
get_registry_auth() {
  printf '%s' "$1" | python3 -c "import json,sys; print(json.load(sys.stdin).get('auths', {}).get(sys.argv[1], {}).get('auth', ''))" "$2"
}

proxycache_data() {
  printf '{"upstream_registry":"%s","expiration_s":%i}' "$1" "$tagExpirationSeconds"
}

proxycache_data_auth() {
  printf '{"upstream_registry":"%s","upstream_registry_username":"%s","upstream_registry_password":"%s","expiration_s":%i}' "$1" "$2" "$3" "$tagExpirationSeconds"
}

#-- variables ---------------------------------------------
bootstrapToken="$(cat /var/opt/token/bootstrap)"
managedRegistriesCm="$MANAGEDORGCM"
tagExpirationSeconds=604800
quayService="$QUAYSERVICE"
registryCredentials="$REGISTRYCREDENTIALS"
proxyRegistry="$REGISTRY"

#-- main (org init) ---------------------------------------
log_phase "Creating organization $proxyRegistry ..."
createOrgResponse=$(curl --silent --show-error --connect-timeout 10 \
  --request POST --write-out "\n%{http_code}" \
  --header "Authorization: Bearer $bootstrapToken" \
  --header "Content-Type: application/json" \
  --data '{"name": "'"$proxyRegistry"'"}' \
  "${quayService}/api/v1/organization/")
createOrgCode=$(echo "$createOrgResponse" | tail -n1)
createOrgMsg=$(echo "$createOrgResponse" | sed '$d')

case "$createOrgCode" in
  201)
    log_info "Organization $proxyRegistry created successfully."
    oc patch configmap "$managedRegistriesCm" --type merge \
      --patch '{"data":{"'"$proxyRegistry"'":"managed"}}'
    ;;
  400)
    log_info "Organization $proxyRegistry already exists. Nothing to do."
    ;;
  *)
    log_error "Something went wrong during organization creation (http_code: $createOrgCode)."
    echo "$createOrgMsg"
    exit 1
    ;;
esac

#-- main (proxy cache) ------------------------------------
log_phase "Creating/Updating proxy cache configuration for $proxyRegistry ..."
repoAuth=$(get_registry_auth "${registryCredentials:-{\}}" "$proxyRegistry" | base64 -d)
if [ -z "$repoAuth" ]; then
  proxycacheData=$(proxycache_data "$proxyRegistry")
else
  repoUser="${repoAuth%%:*}"
  repoPasswd="${repoAuth#*:}"
  proxycacheData=$(proxycache_data_auth "$proxyRegistry" "$repoUser" "$repoPasswd")
fi

proxycacheExists=$(curl --silent --show-error --connect-timeout 10 \
  --request GET --write-out "\n%{http_code}" \
  --header "Authorization: Bearer $bootstrapToken" \
  "${quayService}/api/v1/organization/$(urlencode $proxyRegistry)/proxycache")
proxycacheExistsCode=$(echo "$proxycacheExists" | tail -n1)
proxycacheExistsMsg=$(echo "$proxycacheExists" | sed '$d')
if  [ "$proxycacheExistsCode" -eq 200 ] &&
    has_json_key "${proxycacheExistsMsg:-}" "upstream_registry" &&
    [ "$(get_json_value "$proxycacheExistsMsg" "upstream_registry")" ]; then
  proxycacheDelete=$(curl --silent --show-error --connect-timeout 10 \
    --request DELETE --write-out "\n%{http_code}" \
    --header "Authorization: Bearer $bootstrapToken" \
    "${quayService}/api/v1/organization/$(urlencode $proxyRegistry)/proxycache")
  proxycacheDeleteCode=$(echo "$proxycacheDelete" | tail -n1)
  proxycacheDeleteMsg=$(echo "$proxycacheDelete" | sed '$d')
  if [ "$proxycacheDeleteCode" -ne 201 ]; then
    log_error "Something went wrong with proxy cache removal (http_code: $proxycacheDeleteCode)."
    echo "$proxycacheDeleteMsg"
    exit 1
  fi
fi

log_info "Validating proxy cache configuration."
proxycacheValidate=$(curl --silent --show-error --connect-timeout 10 \
  --request POST --write-out "\n%{http_code}" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $bootstrapToken" \
  --data "$proxycacheData" \
  "${quayService}/api/v1/organization/$(urlencode $proxyRegistry)/validateproxycache")
proxycacheValidateCode=$(echo "$proxycacheValidate" | tail -n1)
proxycacheValidateMsg=$(echo "$proxycacheValidate" | sed '$d')
if [ "$proxycacheValidateCode" -ne 202 ]; then
  log_error "Something went wrong when validating proxycache configuration (http_code: $proxycacheValidateCode)."
  echo "$proxycacheValidateMsg"
  exit 1
fi

log_info "Applying proxy cache configuration."
proxycacheCreate=$(curl --silent --show-error --connect-timeout 10 \
  --request POST --write-out "\n%{http_code}" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $bootstrapToken" \
  --data "$proxycacheData" \
  "${quayService}/api/v1/organization/$(urlencode $proxyRegistry)/proxycache")
proxycacheCreateCode=$(echo "$proxycacheCreate" | tail -n1)
proxycacheCreateMsg=$(echo "$proxycacheCreate" | sed '$d')
if [ "$proxycacheCreateCode" -ne 201 ]; then
  log_error "Something went wrong when applying proxy cache configuration (http_code: $proxycacheCreateCode)."
  echo "$proxycacheCreateMsg"
  exit 1
fi
log_info "Proxy cache configuration for $proxyRegistry has been applied."

exit 0
