{{/*
Expand the name of the chart.
*/}}
{{- define "crossplane-vault-provider-bootstrap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "crossplane-vault-provider-bootstrap.fullname" -}}
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
{{- define "crossplane-vault-provider-bootstrap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "crossplane-vault-provider-bootstrap.labels" -}}
helm.sh/chart: {{ include "crossplane-vault-provider-bootstrap.chart" . }}
{{ include "crossplane-vault-provider-bootstrap.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "crossplane-vault-provider-bootstrap.selectorLabels" -}}
app.kubernetes.io/name: {{ include "crossplane-vault-provider-bootstrap.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "crossplane-vault-provider-bootstrap.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "crossplane-vault-provider-bootstrap.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "crossplane-vault-provider-bootstrap.caCertificates" -}}
{{- if .Values.customCACertificates }}
{{- .Values.customCACertificates }}
{{- else }}
{{- range $i, $item := (.Values.global.apc.caCertificates | values) }}
{{- $item }}
{{- end }}
{{- end }}
{{- end }}
