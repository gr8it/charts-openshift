{{/*
Expand the name of the chart.
*/}}
{{- define "apps-ck-kafka-mm2.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "apps-ck-kafka-mm2.fullname" -}}
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
{{- define "apps-ck-kafka-mm2.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "apps-ck-kafka-mm2.labels" -}}
helm.sh/chart: {{ include "apps-ck-kafka-mm2.chart" . }}
{{ include "apps-ck-kafka-mm2.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ default .Release.Service .Values.releaseServiceOverride }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "apps-ck-kafka-mm2.selectorLabels" -}}
app.kubernetes.io/name: {{ include "apps-ck-kafka-mm2.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "apps-ck-kafka-mm2.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "apps-ck-kafka-mm2.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return cluster data by type.

Usage:
  {{- $source := include "apps-ck-kafka-mm2.clusterByType" (dict
        "clusters" .Values.clusters
        "type" "source"
      ) | fromYaml }}

  {{- $target := include "apps-ck-kafka-mm2.clusterByType" (dict
        "clusters" .Values.clusters
        "type" "target"
      ) | fromYaml }}
*/}}
{{- define "apps-ck-kafka-mm2.clusterByType" }}
{{- $result := dict }}
{{- $found := false }}

{{- range $name, $cluster := .clusters }}
  {{- if eq $cluster.type $.type }}
    {{- if $found }}
      {{- fail (printf "Multiple clusters found with type '%s'; expected exactly one" $.type) }}
    {{- end }}
    {{- $_ := set $result "name" $name }}
    {{- $_ := set $result "config" $cluster }}
    {{- $found = true }}
  {{- end }}
{{- end }}

{{- if empty $result }}
  {{- fail (printf "No cluster found with type '%s'" .type) }}
{{- end }}

{{- toYaml $result }}
{{- end }}
