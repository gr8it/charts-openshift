{{/*
Expand the name of the chart.
*/}}
{{- define "crossplane-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "crossplane-helm.fullname" -}}
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
{{- define "crossplane-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "crossplane-helm.labels" -}}
helm.sh/chart: {{ include "crossplane-helm.chart" . }}
{{ include "crossplane-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "crossplane-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "crossplane-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "crossplane-helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "crossplane-helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "crossplane-helm.repoUrl" -}}
{{- .Values.repo.url | default .Values.global.apc.repoURL }}
{{- end }}

{{- define "crossplane-helm.targetRevision" -}}
{{- .Values.repo.targetRevision | default .Values.global.apc.repoTargetRevision | default "main" }}
{{- end }}

{{- define "crossplane-helm.repoShort" -}}
{{- mustRegexReplaceAll "^https://github.com/([^/]+)/([^/.]+)(.git|/)?$" (include "crossplane-helm.repoUrl" .) "${1}-${2}" }}
{{- end }}
