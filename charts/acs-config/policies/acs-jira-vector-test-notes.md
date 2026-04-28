# ACS -> Vector -> Jira Ops Notes

## Goal

Use `RHACS Generic Webhook -> Vector -> Jira Ops` instead of:

- Loki/Alertmanager for Jira alerting
- native ACS Jira integration

Reason:

- Loki/Alertmanager path was rejected
- ACS native Jira payload/auth approach was not acceptable
- Jira webhook is behind Atlassian paywall

## Current Status

Tested on `huba` first, not on production `hub01`.

Result:

- end-to-end delivery to Jira Ops works
- alert formatting now looks acceptable for further ACS testing
- this is proven with synthetic ACS-shaped webhook payloads

## Important Finding

The main delivery bug was not ACS data.

It was Vector HTTP sink formatting:

- Atlassian accepts a single JSON object
- Atlassian rejects a one-element JSON array with `422`

So the working Huba Vector config sends a single object body to Jira Ops.

## Missing Pieces That Solved It

These were the important configuration pieces that made `huba` work.

### 1. Jira Ops secret

Vector reads Jira auth from a mounted Kubernetes secret.

Expected secret content:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: jira-ops
  namespace: apc-logging
type: Opaque
stringData:
  authorization: "GenieKey <jira-ops-api-key>"
```

Important:

- Atlassian expects full `Authorization` header value in `GenieKey <key>` format
- not Bearer token

### 2. Jira secret mount in Vector

Vector must have a secret provider pointing at:

- `/var/run/ocp-collector/secrets/jira-ops`

And the sink uses:

- `SECRET[kubernetes_jiraops.authorization]`

### 3. Outbound proxy on huba

Direct egress from `huba` to Atlassian timed out.

What fixed that:

```yaml
env:
- name: HTTPS_PROXY
  value: http://10.11.0.10:3128
- name: HTTP_PROXY
  value: http://10.11.0.10:3128
- name: NO_PROXY
  value: .cluster.local,.gr8it.cloud,.huba.qa.sp.gr8it.cloud,.spokea1.qa.sp.gr8it.cloud,.svc,10.0.0.0/8,10.11.60.0/23,10.128.0.0/14,127.0.0.0/8,127.0.0.1,172.16.0.0/12,172.30.0.0/16,192.168.0.0/16,api-int.huba.qa.sp.gr8it.cloud,localhost
```

Comparison with `hub01`:

- `hub01` Vector did not have proxy env in its daemonset
- `huba` needed it because this Jira path is external Atlassian traffic

### 4. HTTP sink body format

This was the main transport fix.

The failing version used normal JSON encoding with batching, which resulted in Jira receiving a JSON array.

That caused:

- `422 Unprocessable Entity`

Working change:

- emit one JSON string from VRL using `encode_json(payload)`
- sink uses:
  - `encoding.codec: raw_message`
  - `framing.method: bytes`

That makes Jira receive one plain JSON object.

### 5. Remap output content

First we used a minimal payload only to prove transport.

Then we changed the remap to produce a richer operational alert:

- message/title includes cluster + severity + policy name
- description includes:
  - policy
  - cluster
  - namespace
  - deployment
  - lifecycle stage
  - severity
  - policy description
  - Central link
- details include:
  - cluster
  - namespace
  - deployment
  - lifecycle stage
  - policy name
  - severity
  - alert id
  - Central URL

### 6. ACS custom fields

The notifier should add custom fields:

- `gr8it=acs-audit-log`
- `central_base_url=https://central-stackrox.apps.huba.qa.sp.gr8it.cloud`

Why:

- `gr8it` lets Vector identify/filter ACS audit-style webhook traffic
- `central_base_url` is used to build the RHACS violation link in Jira

### 7. Network policy awareness

Direct local laptop POST to `10.11.60.100:9444` was not reliable for testing because Vector ingress is restricted.

Working path:

- send from `stackrox` namespace
- that namespace is allowed by Vector network policy on `9444`

## Proven RHACS Payload Shape

RHACS Generic Webhook sends:

```json
{
  "alert": {
    "id": "...",
    "policy": {
      "name": "...",
      "description": "...",
      "severity": "..."
    }
  },
  "gr8it": "acs-audit-log",
  "central_base_url": "..."
}
```

Fields already aligned with live `hub01` Vector parsing:

- `alert.id`
- `alert.clusterName`
- `alert.namespace`
- `alert.policy.name`
- `alert.policy.SORTName`
- `alert.policy.description`
- `alert.policy.severity`

Likely valid but still worth confirming with a real ACS alert:

- `alert.deployment.name`
- `alert.lifecycleStage`

## Current Working Jira Alert Format

Current test formatting on `huba` is intended to produce:

- title:
  - `[RHACS]: [socpoistsk/<cluster>/<severity>] - <policy name>`
- description:
  - policy
  - cluster
  - namespace
  - deployment
  - lifecycle stage
  - severity
  - policy description
  - Central violation link

## Huba Test Repo / Paths

Vector test implementation is in:

- `conf-sp-qa/ocp-huba/observability/vector/vector-hub-values.yaml`
- `conf-sp-qa/ocp-huba/observability/vector/jira-ops-secret.yaml`

Live test used:

- Jira Ops token in `jira-ops` secret
- Huba outbound proxy for Atlassian access

## Hub01 Comparison

`hub01` is still the reference for expected ACS field usage, but not for Jira delivery because:

- `hub01` Vector does not currently exercise the Jira sink path
- `huba` needed proxy env for Atlassian egress

Common verified baseline between `hub01` and `huba`:

- same webhook source pattern on Vector
- same ACS parsing assumptions for `.alert.*`

## What Is Still Not Done

1. Persist the final live-tested Huba Vector remap back into repo if not already synced.
2. Configure/attach a real ACS Generic Webhook notifier.
3. Trigger a real ACS policy alert.
4. Confirm the real webhook payload contains the optional fields as expected.
5. If real ACS alert differs, adjust only formatting details, not transport.
6. After Huba is clean, replicate to production `hub01`.

## Recommended Next Step Tomorrow

Use a real ACS policy on test first.

Best candidate:

- `Containers with Critical Fixable CVEs`

Then verify in Jira:

- title quality
- description readability
- Central link
- namespace/deployment correctness
- no unexpected deduplication

## Reproduction Commands

These are the commands used during testing on `huba`.

### 1. Check live Vector pods

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n apc-logging get pods -l app.kubernetes.io/name=vector -o wide
```

### 2. Check live Vector config

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n apc-logging get configmap vector -o jsonpath='{.data.vector\.yaml}'
```

### 3. Direct Jira Ops test from cluster through proxy

This proves:

- Atlassian token is valid
- Huba needs proxy for outbound Jira access

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n stackrox run jira-payload-test \
  --image=curlimages/curl:8.10.1 --restart=Never --rm -i --command -- sh -lc '
cat >/tmp/object.json <<\"EOF\"
{
  "message": "RHACS CRITICAL violation in test01/demo-app",
  "alias": "rhacs-test-rhacs-alert-001",
  "description": "Synthetic test alert routed through Vector to Jira Ops.",
  "entity": "test01/demo-app",
  "source": "rhacs-vector-bridge",
  "priority": "P1",
  "tags": ["rhacs", "security", "test01", "demo-app", "CRITICAL"],
  "details": {
    "cluster": "test01",
    "namespace": "demo-app",
    "policy_name": "Containers with Critical Fixable CVEs"
  }
}
EOF
curl -sS -D - -o /tmp/object.out \
  -x http://10.11.0.10:3128 \
  -H "Authorization: GenieKey <jira-ops-api-key>" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  --data @/tmp/object.json \
  https://api.atlassian.com/jsm/ops/integration/v2/alerts
printf "\nBODY\n"
cat /tmp/object.out'
```

Expected result:

- `HTTP/2 202`

### 4. Prove Atlassian rejects JSON array body

This was the key bug.

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n stackrox run jira-array-test \
  --image=curlimages/curl:8.10.1 --restart=Never --rm -i --command -- sh -lc '
cat >/tmp/array.json <<\"EOF\"
[
  {
    "message": "RHACS CRITICAL violation in test01/demo-app",
    "alias": "rhacs-test-rhacs-alert-001",
    "description": "Synthetic test alert routed through Vector to Jira Ops.",
    "entity": "test01/demo-app",
    "source": "rhacs-vector-bridge",
    "priority": "P1",
    "tags": ["rhacs", "security", "test01", "demo-app", "CRITICAL"],
    "details": {
      "cluster": "test01",
      "namespace": "demo-app",
      "policy_name": "Containers with Critical Fixable CVEs"
    }
  }
]
EOF
curl -sS -D - -o /tmp/array.out \
  -x http://10.11.0.10:3128 \
  -H "Authorization: GenieKey <jira-ops-api-key>" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  --data @/tmp/array.json \
  https://api.atlassian.com/jsm/ops/integration/v2/alerts
printf "\nBODY\n"
cat /tmp/array.out'
```

Expected result:

- `HTTP/2 422`

### 5. Send ACS-shaped webhook into Vector service

This tests the real bridge:

- ACS-style payload
- Vector webhook ingest
- VRL remap
- Jira sink delivery

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n stackrox run vector-webhook-test \
  --image=curlimages/curl:8.10.1 --restart=Never --rm -i --command -- sh -lc '
cat >/tmp/payload.json <<\"EOF\"
{
  "gr8it": "acs-audit-log",
  "central_base_url": "https://central-stackrox.apps.huba.qa.sp.gr8it.cloud",
  "alert": {
    "id": "8adab1df-0ebd-4506-b4a1-5f99cdbc6e8f-huba-test",
    "clusterName": "huba",
    "namespace": "apc-sonarqube",
    "lifecycleStage": "DEPLOY",
    "deployment": {
      "name": "sonarqube"
    },
    "policy": {
      "name": "Containers with Critical Fixable CVEs",
      "SORTName": "Containers with Critical Fixable CVEs",
      "description": "Alert on containers with important or critical fixable vulnerabilities",
      "severity": "CRITICAL_SEVERITY"
    }
  }
}
EOF
curl -sS -k -D - -o /tmp/resp.out \
  -H "Content-Type: application/json" \
  --data @/tmp/payload.json \
  https://vector.apc-logging.svc:9444
printf "\nBODY\n"
cat /tmp/resp.out'
```

Expected result:

- `HTTP/1.1 200 OK`

### 6. Send ACS-shaped webhook to one exact Vector pod

Use this when you want clean verification on a single pod.

Get pod IP:

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n apc-logging get pods -l app.kubernetes.io/name=vector -o wide
```

Then send to one pod IP, example:

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n stackrox run vector-webhook-pretty \
  --image=curlimages/curl:8.10.1 --restart=Never --rm -i --command -- sh -lc '
cat >/tmp/payload.json <<\"EOF\"
{
  "gr8it": "acs-audit-log",
  "central_base_url": "https://central-stackrox.apps.huba.qa.sp.gr8it.cloud",
  "alert": {
    "id": "8adab1df-0ebd-4506-b4a1-5f99cdbc6e8f-huba-unique",
    "clusterName": "huba",
    "namespace": "apc-sonarqube",
    "lifecycleStage": "DEPLOY",
    "deployment": {
      "name": "sonarqube"
    },
    "policy": {
      "name": "Containers with Critical Fixable CVEs",
      "SORTName": "Containers with Critical Fixable CVEs",
      "description": "Alert on containers with important or critical fixable vulnerabilities",
      "severity": "CRITICAL_SEVERITY"
    }
  }
}
EOF
curl -sS -k -D - -o /tmp/resp.out \
  -H "Content-Type: application/json" \
  --data @/tmp/payload.json \
  https://<vector-pod-ip>:9444
printf "\nBODY\n"
cat /tmp/resp.out'
```

### 7. Check Vector logs after sending

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n apc-logging logs -l app.kubernetes.io/name=vector --since=2m --tail=300
```

Or for one exact pod:

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n apc-logging logs <vector-pod-name> --since=2m
```

What to look for:

- good: no `jira_ops_alerts` error
- bad: `422 Unprocessable Entity`
- unrelated current noise: `acs_loki_audit` still returns `500`

### 8. Check Vector metrics on one exact pod

Port-forward one pod:

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context huba -n apc-logging port-forward pod/<vector-pod-name> 19092:9090
```

Then read metrics locally:

```bash
curl -s http://127.0.0.1:19092/metrics | grep 'jira_ops_alerts'
```

Best verification signals:

- `vector_component_received_events_total{component_id="jira_ops_alerts"...}`
- `vector_component_sent_events_total{component_id="jira_ops_alerts"...}`
- `vector_http_client_requests_sent_total{component_id="jira_ops_alerts"...}`
- `vector_http_client_responses_total{component_id="jira_ops_alerts",status="202"}`

### 9. Compare with hub01 live Vector baseline

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context hub01 -n apc-logging get configmap vector -o jsonpath='{.data.vector\.yaml}'
```

```bash
oc --kubeconfig=/Users/filipcsupka/.kube/asp --context hub01 -n apc-logging get ds vector -o jsonpath='{.spec.template.spec.containers[0].env}'
```

Why compare:

- `hub01` is the baseline for ACS field usage
- `huba` is the safe test target for Jira formatting
