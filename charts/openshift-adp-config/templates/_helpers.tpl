{{/*
Common Helm helper definitions for the openshift-adp-config chart.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "openshift-adp-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "openshift-adp-config.fullname" -}}
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
Return the chart label.
*/}}
{{- define "openshift-adp-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to resources.
*/}}
{{- define "openshift-adp-config.labels" -}}
helm.sh/chart: {{ include "openshift-adp-config.chart" . }}
{{ include "openshift-adp-config.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "openshift-adp-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openshift-adp-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
