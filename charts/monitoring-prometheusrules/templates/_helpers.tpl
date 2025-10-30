{{/*
Expand the name of the chart.
*/}}
{{- define "prometheusrules.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheusrules.fullname" -}}
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
{{- define "prometheusrules.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prometheusrules.labels" -}}
helm.sh/chart: {{ include "prometheusrules.chart" . }}
{{ include "prometheusrules.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheusrules.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheusrules.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheusrules.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prometheusrules.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the rules list usable for prometheusrule.spec.groups.rules for Application namespaces
*/}}
{{- define "monitoring-prometheusrules.rulesApp" -}}
{{- $rules := index .Values "monitoring-prometheusrules" "rules" | default .Values.rules }}
{{- range $rules }}
- alert: {{ .alert }}
  expr: {{ .expr | quote }}
  for: {{ .for }}
  labels:
    vendor: socpoist
    team: developers
    severity: {{ .labels.severity }}
    namespace: "{{`{{request.object.metadata.name}}`}}"
  annotations:
    description: {{ .annotations.description | quote }}
    summary: {{ .annotations.summary | quote }}
{{- end }}
{{- end }}

{{/*
Create the rules list usable for prometheusrule.spec.groups.rules for Platform (non-application) namespaces
*/}}
{{- define "monitoring-prometheusrules.rulesPlatform" -}}
{{- $rules := index .Values "monitoring-prometheusrules" "rules" | default .Values.rules }}
{{- range $rules }}
- alert: {{ .alert }}
  expr: {{ .expr | quote }}
  for: {{ .for }}
  labels:
    vendor: aspecta
    team: platform
    severity: {{ .labels.severity }}
    namespace: "{{`{{request.object.metadata.name}}`}}"
  annotations:
    description: {{ .annotations.description | quote }}
    summary: {{ .annotations.summary | quote }}
{{- end }}
{{- end }}

{{/*
Create the rules list usable for prometheusrule.spec.groups.rules for Cluster Monitoring namespaces
*/}}
{{- define "monitoring-prometheusrules.rulesClusterMonitoring" -}}
{{- $rules := index .Values "monitoring-prometheusrules" "rules" | default .Values.rules }}
{{- range $rules }}
- alert: {{ .alert }}
  expr: {{ .expr | quote }}
  for: {{ .for }}
  labels:
    vendor: aspecta
    team: platform
    severity: {{ .labels.severity }}
    namespace: "{{`{{request.object.metadata.name}}`}}"
  annotations:
    description: {{ .annotations.description | quote }}
    summary: {{ .annotations.summary | quote }}
{{- end }}
{{- end }}


