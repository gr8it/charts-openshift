{{/*
Expand the name of the chart.
*/}}
{{- define "pushgateway-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pushgateway-helm.fullname" -}}
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
{{- define "pushgateway-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pushgateway-helm.labels" -}}
helm.sh/chart: {{ include "pushgateway-helm.chart" . }}
{{ include "pushgateway-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pushgateway-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pushgateway-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name for the pushgateway OAuth proxy.
Must match prometheus-pushgateway.serviceAccount.name.
*/}}
{{- define "pushgateway-helm.serviceAccountName" -}}
{{- index .Values "prometheus-pushgateway" "serviceAccount" "name" | default "pushgw-sa" }}
{{- end }}

{{/*
Veeam service account name.
*/}}
{{- define "pushgateway-helm.veeamServiceAccountName" -}}
{{- .Values.veeam.serviceAccountName | default "veeam-sa" }}
{{- end }}

{{/*
Route name — used in both the Route resource and SA OAuth redirect annotation.
*/}}
{{- define "pushgateway-helm.routeName" -}}
{{- include "pushgateway-helm.fullname" . }}
{{- end }}

{{/*
OAuth proxy Service name.
*/}}
{{- define "pushgateway-helm.oauthProxyServiceName" -}}
{{- printf "%s-oauth-proxy" (include "pushgateway-helm.fullname" .) }}
{{- end }}
