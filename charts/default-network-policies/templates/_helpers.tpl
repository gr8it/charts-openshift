{{/*
Expand the name of the chart.
*/}}
{{- define "default-network-policies.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "default-network-policies.fullname" -}}
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
{{- define "default-network-policies.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "default-network-policies.labels" -}}
helm.sh/chart: {{ include "default-network-policies.chart" . }}
{{ include "default-network-policies.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "default-network-policies.selectorLabels" -}}
app.kubernetes.io/name: {{ include "default-network-policies.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "default-network-policies.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "default-network-policies.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Helper function to work around helm limitation while using the default function, where false and null / nil are handled the same.
This function returns value of 1st argument if exists (ano not null), or the fallback = default (3rd argument).
*/}}
{{- define "boolDefault" -}}
{{- $value := index . 0 -}}
{{- $global := index . 1 -}}
{{- $default := index . 2 -}}
{{- if kindIs "bool" $value -}}
  {{ $value }}
{{- else if kindIs "bool" $global -}}
  {{ $global }}
{{- else -}}
  {{ $default }}
{{- end -}}
{{- end -}}
