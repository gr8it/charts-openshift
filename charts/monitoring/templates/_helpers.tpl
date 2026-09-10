{{/*
Expand the name of the chart.
*/}}
{{- define "monitoring.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "monitoring.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "monitoring.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "monitoring.labels" -}}
helm.sh/chart: {{ include "monitoring.chart" . }}
{{ include "monitoring.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "monitoring.selectorLabels" -}}
app.kubernetes.io/name: {{ include "monitoring.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "monitoring.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "monitoring.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Alertmanager opsgenie_configs "description" template: renders each grouped alert's
description/summary with a Source link back to the firing Prometheus query, separated
by a rule between alerts. Falls back to Alertmanager's built-in default when the
PrometheusRule has no curated description.
*/}}
{{- define "monitoring.opsgenieDescription" -}}
{{ "{{" }} range $i, $a := .Alerts {{ "}}" }}
{{ "{{" }} if $i {{ "}}" }}
---
{{ "{{" }} end {{ "}}" }}
{{ "{{" }} if $a.Annotations.description {{ "}}" }}{{ "{{" }} $a.Annotations.description {{ "}}" }}{{ "{{" }} else if $a.Annotations.summary {{ "}}" }}{{ "{{" }} $a.Annotations.summary {{ "}}" }}{{ "{{" }} else {{ "}}" }}{{ "{{" }} $a.Annotations.message {{ "}}" }}{{ "{{" }} end {{ "}}" }}
{{ "{{" }} with $a.GeneratorURL {{ "}}" }}Source: {{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }}
{{ "{{" }} end {{ "}}" }}
{{- end }}

{{/*
Alertmanager opsgenie_configs "tags" template: the common label set shown to every
alert, plus the object-identifying labels (alertname/name/namespace/project/repo and
the ArgoCD-specific sync/health/autosync labels) when present on the firing alert.
Missing labels are silently omitted (`with`), safe for every alert type.
*/}}
{{- define "monitoring.opsgenieTags" -}}
{{ "{{" }} with .CommonLabels.alertname {{ "}}" }}alertname={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.clusterName {{ "}}" }}clusterName={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.customerName {{ "}}" }}customerName={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.environment {{ "}}" }}environment={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.location {{ "}}" }}location={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.namespace {{ "}}" }}namespace={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.hostname {{ "}}" }}hostname={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.name {{ "}}" }}name={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.project {{ "}}" }}project={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.repo {{ "}}" }}repo={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.sync_status {{ "}}" }}sync_status={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.health_status {{ "}}" }}health_status={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.autosync_enabled {{ "}}" }}autosync_enabled={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.severity {{ "}}" }}severity={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.team {{ "}}" }}team={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.vendor {{ "}}" }}vendor={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }},
{{ "{{" }} with .CommonLabels.app {{ "}}" }}app={{ "{{" }} . {{ "}}" }}{{ "{{" }} end {{ "}}" }}
{{- end }}
