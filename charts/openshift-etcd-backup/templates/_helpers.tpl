{{/* Chart name */}}
{{- define "etcd-backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/* Resolve cluster name with defaults */}}
{{- define "etcd-backup.clusterName" -}}
{{- if .Values.clusterName -}}
  {{- .Values.clusterName | trunc 20 | trimSuffix "-" -}}
{{- else if and
      (hasKey .Values "apc-global-overrides")
      (hasKey (index .Values "apc-global-overrides") "cluster")
      (hasKey (index (index .Values "apc-global-overrides") "cluster") "name")
      (index (index (index .Values "apc-global-overrides") "cluster") "name")
-}}
  {{- index (index (index .Values "apc-global-overrides") "cluster") "name" | trunc 20 | trimSuffix "-" -}}
{{- else -}}
  {{- .Release.Name | trunc 20 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Fullname = chart name + cluster name */}}
{{- define "etcd-backup.fullname" -}}
{{- $chartName := .Chart.Name | trunc 40 | trimSuffix "-" -}}
{{- $clusterName := (include "etcd-backup.clusterName" .) | trunc 20 | trimSuffix "-" -}}
{{- printf "%s-%s" $chartName $clusterName | trunc 50 | trimSuffix "-" }}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "etcd-backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Generate ObjectBucketClaim name */}}
{{- define "etcd-backup.obcName" -}}
{{- $clusterName := include "etcd-backup.name" . -}}
{{- if and (hasKey .Values "objectBucketClaim") (hasKey .Values.objectBucketClaim "name") (.Values.objectBucketClaim.name) -}}
{{- printf "%s" .Values.objectBucketClaim.name | required "objectBucketClaim.name is invalid" -}}
{{- else -}}
{{- printf "%s-%s-%s" "etcd" $clusterName "backup" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Common labels */}}
{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "etcd-backup.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ include "etcd-backup.fullname" . }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
helm.sh/chart: {{ include "etcd-backup.chart" . }}
{{- end -}}
