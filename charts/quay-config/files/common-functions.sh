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
  printf '%s' "$1" | python3 -c "
import json,sys;
value=json.load(sys.stdin).get(sys.argv[1])
if isinstance(value, (dict, list)):
  print(json.dumps(value))
elif value is not None:
  print(value)
" "$2"
}

urlencode() {
  printf '%s' "$*" | python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=''), end='')"
}

validate_pull_secret() {
  printf '%s' "$*" | python3 -c "
import json,sys,base64
try:
    data = json.load(sys.stdin)
    if 'auths' not in data: raise ValueError('Missing auths key')
    for reg, body in data['auths'].items():
        if 'auth' not in body: raise ValueError(f'Missing auth token for {reg}')
        base64.b64decode(body['auth']).decode('utf-8').split(':', 1)
    sys.exit(0)
except Exception as e:
    print(f'Invalid config: {e}', file=sys.stderr)
    sys.exit(1)
"
}
