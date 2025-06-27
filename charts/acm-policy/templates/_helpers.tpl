{{/*
Expand the name of the chart.
*/}}
{{- define "acm-policy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "acm-policy.fullname" -}}
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
{{- define "acm-policy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "acm-policy.labels" -}}
helm.sh/chart: {{ include "acm-policy.chart" . }}
{{ include "acm-policy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "acm-policy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acm-policy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "acm-policy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "acm-policy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "acm-policy.clusterSets" -}}
{{- $clusterSets := list }}
{{- if and (not .Values.placement.clusterName) (not .Values.placement.clusterSets) (not .Values.placement.labelSelectors) }}
{{- $clusterSets = list "global" }}
{{- else if .Values.placement.clusterSets -}}
{{- $clusterSets = .Values.placement.clusterSets }}
{{- end }}
{{- $clusterSets | toYaml }}
{{- end }}
