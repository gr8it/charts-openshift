{{/*
Expand the name of the chart.
*/}}
{{- define "vault-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vault-config.fullname" -}}
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
{{- define "vault-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vault-config.labels" -}}
helm.sh/chart: {{ include "vault-config.chart" . }}
{{ include "vault-config.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ default .Release.Service .Values.releaseServiceOverride }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vault-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vault-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vault-config.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vault-config.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "vault-config.defaultAllowedDomains" -}}
- {{ include "apc-global-overrides.clusterAppsDomain" . }}
- cluster.local
- svc
- service.{{ include "apc-global-overrides.clusterName" . }}.{{ include "apc-global-overrides.clusterRootDomain" . }}
{{- end }}
