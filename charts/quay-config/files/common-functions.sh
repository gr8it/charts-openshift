#!/usr/bin/env bash

log_info() {
  printf '[INFO] %s\n' "$*"
}

log_error() {
  printf '[ERR] %s\n' "$*"
}

get_http_code() {
  curl --insecure --connect-timeout 3 \
    --silent --output /dev/null \
    --write-out '%{http_code}'  \
    "$1"
}

get_http_code_auth () {
  curl --insecure --connect-timeout 5 \
    --silent --output /dev/null \
    --write-out '%{http_code}' \
    --header "Authorization: Bearer $1" \
    "$2"
}
