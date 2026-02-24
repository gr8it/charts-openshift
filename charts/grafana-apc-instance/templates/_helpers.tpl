{{/*
Expand the name of the chart.
*/}}
{{- define "grafana-instance.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "grafana-instance.fullname" -}}
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
{{- define "grafana-instance.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "grafana-instance.labels" -}}
helm.sh/chart: {{ include "grafana-instance.chart" . }}
{{ include "grafana-instance.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Values.releaseServiceOverride | default ((.Values.global|default dict).apc|default dict).releaseServiceOverride | default .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "grafana-instance.selectorLabels" -}}
app.kubernetes.io/name: {{ include "grafana-instance.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Monitoring labels
*/}}
{{- define "grafana-instance.monitoringLabels" -}}
vendor: aspecta
team: platform
{{- end }}

{{/*
Render grafana host url
*/}}
{{- define "grafana-instance.grafanaHost" -}}
{{- $grafanaHost := .Values.grafanaHostOverride | default (printf "%s-%s" "grafana" .Release.Namespace) }}
{{- $grafanaDomain := .Values.grafanaDomainOverride | default (include "apc-global-overrides.require-clusterAppsDomain" .) }}
{{- (printf "%s.%s" $grafanaHost $grafanaDomain) | lower }}
{{- end -}}
