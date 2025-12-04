{{/*
Expand the name of the chart.
*/}}
{{- define "argo-events-project-setup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argo-events-project-setup.fullname" -}}
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
{{- define "argo-events-project-setup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "argo-events-project-setup.labels" -}}
helm.sh/chart: {{ include "argo-events-project-setup.chart" . }}
{{ include "argo-events-project-setup.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argo-events-project-setup.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argo-events-project-setup.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "argo-events-project-setup.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "argo-events-project-setup.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Transform reservedNamespaces: add '^' at start, '$' if no '-' at end, '.*' if '-' at end.
Usage: {{ include "argo-events-project-setup.reservedNsTransform" . }}
*/}}
{{- define "argo-events-project-setup.reservedNsTransform" -}}
{{- $patterns := list }}
{{- range $ns := .Values.reservedNamespaces }}
  {{- $suffix := (hasSuffix "-" $ns | ternary ".*" "$") }}
  {{- $patterns = append $patterns (printf "^%s%s" $ns $suffix) }}
{{- end }}
{{- toJson $patterns }}
{{- end }}