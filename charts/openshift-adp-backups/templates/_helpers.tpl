{{/*
Common Helm helper definitions for the openshift-adp-backups chart.
*/}}

{{- define "openshift-adp-backups.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "openshift-adp-backups.fullname" -}}
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

{{- define "openshift-adp-backups.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "openshift-adp-backups.labels" -}}
helm.sh/chart: {{ include "openshift-adp-backups.chart" . }}
{{ include "openshift-adp-backups.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "openshift-adp-backups.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openshift-adp-backups.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
