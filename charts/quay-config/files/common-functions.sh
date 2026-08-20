#!/usr/bin/env bash

log_phase() {
  printf '\n[>>>] %s\n' "$*"
}

log_info() {
  printf '[inf] %s\n' "$*"
}

log_error() {
  printf '[err] %s\n' "$*"
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

has_json_key() {
  printf '%s' "$1" | python3 -c "import json,sys; sys.exit(0 if sys.argv[1] in json.load(sys.stdin) else 1)" "$2" 2>/dev/null
}

get_json_value() {
  printf '%s' "$1" | python3 -c "import json,sys; print((json.load(sys.stdin)).get(sys.argv[1]))" "$2"
}

urlencode() {
  printf '%s' "$*" | python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=''), end='')"
}
