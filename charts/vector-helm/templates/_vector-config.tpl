{{- define "vector-helm.vectorConfig" -}}
api:
  enabled: true
  address: 0.0.0.0:8686
  playground: false
secret:
  kubernetes_secret:
    type: directory
    path: /var/run/ocp-collector/secrets/vector-token
  kubernetes_jiraops:
    type: directory
    path: /var/run/ocp-collector/secrets/jira-ops
  kubernetes_siemtoken:
    type: directory
    path: /var/run/ocp-collector/secrets/siem-token
sources:
  internal_metrics:
    type: internal_metrics
  udp_syslog:
    type: syslog
    address: 0.0.0.0:{{ include "vector-helm.port.udpSyslog" . }}
    mode: udp
  tcp_syslog:
    type: syslog
    address: 0.0.0.0:{{ include "vector-helm.port.tcpSyslog" . }}
    mode: tcp
  webhook:
    type: http_server
    address: 0.0.0.0:{{ include "vector-helm.port.webhook" . }}
    encoding: json
    tls:
      enabled: true
      key_file: /var/run/ocp-collector/secrets/vector-service/tls.key
      crt_file: /var/run/ocp-collector/secrets/vector-service/tls.crt
transforms:
  udp_syslog_labels:
    type: remap
    inputs:
      - udp_syslog
    source: |
      .additionalLabel={}
      .additionalLabel.kubernetes_container_name="{{ include "vector-helm.vectorFullname" . }}"
      .additionalLabel.kubernetes_namespace_name="{{ .Release.Namespace }}"
      .additionalLabel.kubernetes_pod_name="{{ include "vector-helm.vectorFullname" . }}"
  tcp_syslog_labels:
    type: remap
    inputs:
      - tcp_syslog
    source: |
      .additionalLabel={}
      .additionalLabel.kubernetes_container_name="{{ include "vector-helm.vectorFullname" . }}"
      .additionalLabel.kubernetes_namespace_name="{{ .Release.Namespace }}"
      .additionalLabel.kubernetes_pod_name="{{ include "vector-helm.vectorFullname" . }}"
  webhook_labels:
    type: remap
    inputs:
      - webhook
    source: |
      .additionalLabel={}
      .additionalLabel.kubernetes_container_name="{{ include "vector-helm.vectorFullname" . }}"
      .additionalLabel.kubernetes_namespace_name="{{ .Release.Namespace }}"
      .additionalLabel.kubernetes_pod_name="{{ include "vector-helm.vectorFullname" . }}"
  ldap_auth:
    type: remap
    inputs:
      - udp_syslog_labels
    source: |
      str = to_string(.message) ?? "default"

      if .appname == "slapd" {
        if contains(str, "ACCEPT") {
          .start_ldap_auth = "true"
          .has_relevant_data = "true"
          . |= parse_regex!(str, r'(?P<connid>conn=(\d+))')
        } else if contains(str, "conn=") && contains(str, "op=1 SRCH ") && contains(str, "uid=") {
          .has_relevant_data = "true"
          . |= parse_regex!(str, r'(?P<connid>conn=(\d+))')
        } else if contains(str, "conn=") && contains(str, "op=2 RESULT tag=") {
          .has_relevant_data = "true"
          . |= parse_regex!(str, r'(?P<connid>conn=(\d+))')
        } else if contains(str, "conn=") && contains(str, "op=0 BIND") && contains(str, "mech=SIMPLE bind_ssf=0 ssf=128") {
          .has_relevant_data = "true"
          . |= parse_regex!(str, r'(?P<connid>conn=(\d+))')
        }
      }
  reduce_ldap_auth:
    type: reduce
    inputs:
      - ldap_auth
    group_by:
      - has_relevant_data
      - connid
      - appname
    ends_when: contains(string!(.message), "closed")
    merge_strategies:
      message: concat
  filter_ldap_reduce:
    type: filter
    inputs:
      - reduce_ldap_auth
    condition: .has_relevant_data == "true"
  remap_ldap_auth:
    type: remap
    inputs:
      - filter_ldap_reduce
    source: "del(.has_relevant_data)\ndel(.connid)\ndel(.start_ldap_auth)\n\nstr = to_string(.message) ?? \"default\"\nuser = r'(?P<user>uid=([^\\)\\n]+))'\nsource = r'(?P<source>\\b(\\d{1,3}\\.){3}\\d{1,3}:\\d{1,5}\\b)'\ncluster = r'(?P<env>cn=[^,]+)'\n\nif !(contains(str, \"uid=\")) {\n  del(.)\n} else {\n\n  if !(contains(str, \"op=2 RESULT tag=97\")) || !(contains(str, \"op=2 RESULT tag=97 err=49\")) {\n    .message = parse_regex!(str, user)\n    .message |= parse_regex!(str, cluster)\n    .message |= parse_regex!(str, source)\n    .message |= {\"auth\": \"unsuccessful\"}\n    .message |= {\"reason\": \"user does not exist\"}\n  }\n  \n  if contains(str, \"ACCEPT\") && contains(str, \"uid=\") && contains(str, \"op=2 RESULT tag=97\") {\n    .message = parse_regex!(str, user)\n    .message |= parse_regex!(str, cluster)\n    .message |= parse_regex!(str, source)\n    .message |= {\"auth\": \"successful\"}\n  } \n  \n  if contains(str, \"ACCEPT\") && contains(str, \"uid=\") && contains(str, \"op=2 RESULT tag=97 err=49\") {\n    .message = parse_regex!(str, user)\n    .message |= parse_regex!(str, cluster)\n    .message |= parse_regex!(str, source)\n    .message |= {\"auth\": \"unsuccessful\"}\n    .message |= {\"reason\": \"wrong password\"}\n  }\n\n}\nif is_empty(.) {\n  abort\n}        \n"
  webhook_parse:
    type: remap
    inputs:
      - webhook_labels
    source: |
      if exists(.gr8it) && exists(.alert) {
        if .gr8it == "acs-audit-log" {
          .additionalLabel.acs_alert_clusterName = .alert.clusterName
          .additionalLabel.acs_alert_policy_name = .alert.policy.SORTName
          .additionalLabel.acs_alert_id = .alert.id
          .additionalLabel.acs_alert_policy_description = .alert.policy.description
          .additionalLabel.acs_alert_policy_severity = .alert.policy.severity
          if exists(.alert.namespace) {
            .additionalLabel.acs_alert_namespace = .alert.namespace
          }
        }
      }
  acs_to_jira_ops:
    type: remap
    inputs:
      - webhook_labels
    drop_on_abort: true
    drop_on_error: true
    source: |
      if !exists(.alert) {
        abort
      }

      if exists(.gr8it) && .gr8it != "acs-audit-log" {
        abort
      }

      alert_id = to_string(.alert.id) ?? "unknown-alert"
      cluster = to_string(.alert.clusterName) ?? "unknown-cluster"
      namespace = to_string(.alert.namespace) ?? "unknown-namespace"
      deployment = to_string(.alert.deployment.name) ?? "unknown-deployment"
      lifecycle_stage = to_string(.alert.lifecycleStage) ?? ""
      if lifecycle_stage == "" {
        lifecycle_stage = to_string(.alert.policy.SORTLifecycleStage) ?? ""
      }
      if lifecycle_stage == "" {
        lifecycle_stage = to_string(.alert.policy.lifecycleStages[0]) ?? ""
      }
      if lifecycle_stage == "" {
        lifecycle_stage = "DEPLOY"
      }
      policy_name = to_string(.alert.policy.name) ?? to_string(.alert.policy.SORTName) ?? "RHACS policy violation"
      policy_description = to_string(.alert.policy.description) ?? "RHACS policy violation detected."
      policy_rationale = to_string(.alert.policy.rationale) ?? ""
      policy_remediation = to_string(.alert.policy.remediation) ?? ""
      severity = upcase(to_string(.alert.policy.severity) ?? "LOW_SEVERITY")
      central_base_url = to_string(.central_base_url) ?? ""
      image_full_name = to_string(.alert.deployment.containers[0].image.name.fullName) ?? ""
      if image_full_name == "" {
        image_registry = to_string(.alert.deployment.containers[0].image.name.registry) ?? ""
        image_remote = to_string(.alert.deployment.containers[0].image.name.remote) ?? ""
        image_tag = to_string(.alert.deployment.containers[0].image.name.tag) ?? ""
        if image_registry != "" && image_remote != "" && image_tag != "" {
          image_full_name = image_registry + "/" + image_remote + ":" + image_tag
        }
      }
      image_id = to_string(.alert.deployment.containers[0].image.id) ?? ""
      deployment_type = to_string(.alert.deployment.type) ?? to_string(.alert.deployment.deploymentType) ?? ""

      priority = "P5"
      severity_label = "low"
      if severity == "CRITICAL_SEVERITY" {
        priority = "P1"
        severity_label = "critical"
      } else if severity == "HIGH_SEVERITY" {
        priority = "P2"
        severity_label = "high"
      } else if severity == "MEDIUM_SEVERITY" {
        priority = "P3"
        severity_label = "medium"
      } else if severity == "LOW_SEVERITY" {
        priority = "P4"
        severity_label = "low"
      }

      central_url = ""
      if central_base_url != "" {
        central_url = central_base_url + "/main/violations/" + alert_id
      }

      description = "Policy: " + policy_name + "\n"
      description = description + "Cluster: " + cluster + "\n"
      description = description + "Namespace: " + namespace + "\n"
      description = description + "Deployment: " + deployment + "\n"
      if deployment_type != "" {
        description = description + "Deployment type: " + deployment_type + "\n"
      }
      if image_full_name != "" {
        description = description + "Image: " + image_full_name + "\n"
      } else if image_id != "" {
        description = description + "Image: " + image_id + "\n"
      }
      description = description + "Lifecycle stage: " + lifecycle_stage + "\n"
      description = description + "Severity: " + severity_label + "\n"
      description = description + "Summary: " + policy_description
      if policy_rationale != "" {
        description = description + "\nRationale: " + policy_rationale
      }
      if policy_remediation != "" {
        description = description + "\nRemediation: " + policy_remediation
      }
      if central_url != "" {
        description = description + "\n\nCentral: " + central_url
      }

      payload = {
        "message": "[RHACS]: [{{ required "vectorRhacs.customerTag must be set in the environment/customer values" .Values.vectorRhacs.customerTag }}/" + cluster + "/" + severity_label + "] - " + policy_name,
        "alias": "rhacs-" + alert_id,
        "description": description,
        "entity": cluster + "/" + namespace + "/" + deployment,
        "source": "rhacs-vector-bridge",
        "priority": priority,
        "tags": [
          "rhacs",
          "security",
          "{{ required "vectorRhacs.customerTag must be set in the environment/customer values" .Values.vectorRhacs.customerTag }}",
          cluster,
          namespace,
          deployment,
          severity_label
        ],
        "details": {
          "cluster": cluster,
          "namespace": namespace,
          "deployment": deployment,
          "deployment_type": deployment_type,
          "image": image_full_name,
          "image_id": image_id,
          "lifecycle_stage": lifecycle_stage,
          "policy_name": policy_name,
          "policy_rationale": policy_rationale,
          "policy_remediation": policy_remediation,
          "severity": severity_label,
          "alert_id": alert_id,
          "central_url": central_url
        }
      }

      . = { "message": encode_json(payload) }
  tcp_syslog_parse:
    type: remap
    inputs:
      - tcp_syslog_labels
    source: "if exists(.hostname) {\n  .additionalLabel.hostname = to_string(.hostname) ?? \"undefined\"\n}\nif exists(.appname) {\n  .additionalLabel.appname = to_string(.appname) ?? \"undefined\"\n}\nif exists(.message) {\n  .additionalLabel.message = to_string(.message) ?? \"undefined\"\n}\nif exists(.msgid) {\n  .additionalLabel.msgid = to_string(.msgid) ?? \"undefined\"\n}else{\n  .additionalLabel.msgid = \"undefined\"\n}        \nif exists(.severity) {\n  .additionalLabel.severity = to_string(.severity) ?? \"undefined\"\n}\nif exists(.source_ip) {\n  .additionalLabel.source_ip = to_string(.source_ip) ?? \"undefined\"\n}\n\n\n.additionalLabel.hostname = string!(.additionalLabel.hostname)\n.additionalLabel.appname = string!(.additionalLabel.appname)\nif match(.additionalLabel.hostname, r'(?i)pdu.*') {\n  .additionalLabel.hw_type = \"pdu\"\n} else if match(.additionalLabel.hostname, r'(?i)ups.*') {\n  .additionalLabel.hw_type = \"ups\"\n} else if match(.additionalLabel.appname, r'(?i)xca') {\n  .additionalLabel.hw_type = \"xca\"\n}else{\n  .additionalLabel.hw_type = \"other\"\n}\n"
sinks:
  prom_exporter:
    type: prometheus_exporter
    inputs: [internal_metrics]
    address: 0.0.0.0:{{ include "vector-helm.port.promExporter" . }}
  default_loki_audit:
    type: loki
    inputs: ["udp_syslog_labels", "tcp_syslog_parse", "remap_ldap_auth"]
    endpoint: https://logging-loki-gateway-http.openshift-logging.svc:8080/api/logs/v1/audit
    tenant_id: audit
    out_of_order_action: accept
    healthcheck:
      enabled: false
    encoding:
      codec: json
      except_fields: ["_internal"]
    buffer:
      type: memory
      when_full: block
    request:
      retry_attempts: 10
    tls:
      ca_file: /var/run/ocp-collector/secrets/vector-token/service-ca.crt
      verify_certificate: true
    auth:
      strategy: bearer
      token: SECRET[kubernetes_secret.token]
    labels:
      log_type: audit
      "*": |-
        {{ print "{{ additionalLabel }}" }}
  acs_loki_audit:
    type: loki
    inputs: ["webhook_parse"]
    endpoint: https://logging-loki-gateway-http.openshift-logging.svc:8080/api/logs/v1/audit
    tenant_id: audit
    out_of_order_action: accept
    healthcheck:
      enabled: false
    encoding:
      codec: json
      except_fields: ["_internal"]
    buffer:
      type: memory
      when_full: block
    request:
      retry_attempts: 10
    tls:
      ca_file: /var/run/ocp-collector/secrets/vector-token/service-ca.crt
      verify_certificate: true
    auth:
      strategy: bearer
      token: SECRET[kubernetes_secret.token]
    labels:
      log_type: audit
      "*": |-
        {{ print "{{ additionalLabel }}" }}
  jira_ops_alerts:
    type: http
    inputs: ["acs_to_jira_ops"]
    uri: {{ required "vectorJira.endpoint must be set in the environment/customer values" .Values.vectorJira.endpoint | quote }}
    method: post
    request:
      concurrency: none
      headers:
        Accept: application/json
        Authorization: SECRET[kubernetes_jiraops.authorization]
        Content-Type: application/json
      retry_attempts: 10
      timeout_secs: 30
    encoding:
      codec: raw_message
    framing:
      method: bytes
    batch:
      max_events: 1
      timeout_secs: 1
    buffer:
      type: memory
      when_full: block
    healthcheck:
      enabled: false
  {{ .Values.vectorSiem.sinkName }}:
    type: splunk_hec_logs
    inputs: ["remap_ldap_auth"]
    endpoint: {{ required "vectorSiem.endpoint must be set in the environment/customer values" .Values.vectorSiem.endpoint | quote }}
    encoding:
      codec: json
      except_fields: ["_internal"]
    tls:
      verify_certificate: {{ .Values.vectorSiem.tls.verifyCertificate }}
      verify_hostname: {{ .Values.vectorSiem.tls.verifyHostname }}
    default_token: SECRET[kubernetes_siemtoken.token]
    acknowledgements:
      enabled: true
      indexer_acknowledgements_enabled: true
    healthcheck:
      enabled: false
    timestamp_key: timestamp
    endpoint_target: event
{{- end }}
