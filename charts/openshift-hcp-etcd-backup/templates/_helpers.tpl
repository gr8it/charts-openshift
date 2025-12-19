{{/*  Chart name */}}
{{- define "etcd-hcp-backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/* Fullname = chart name + cluster name */}}
{{- define "etcd-hcp-backup.fullname" -}}
{{- $chartName := default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- $clusterName := .Values.clusterName | trunc 20 | trimSuffix "-" | required "clusterName is required" -}}
{{- printf "%s-%s" $chartName $clusterName | replace "+" "_" | trunc 50 | trimSuffix "-" }}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "etcd-hcp-backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Generate hosted clsuter namespace - if not defined in values file */}}
{{- define "etcd-hcp-backup.namespace" -}}
{{- $clusterName := .Values.clusterName | required "clusterName is required" -}}
{{- $clusterNamespace := default (printf "%s-%s" $clusterName $clusterName) (.Values.clusterNamespace) -}}
{{- printf "%s" $clusterNamespace | trimSuffix "-" | required "clusterNamespace cannot be empty" -}}
{{- end -}}

{{/* Genereate ObjectBucketClaim name */}}
{{- define "etcd-hcp-backup.obcName" -}}
{{- $clusterName := .Values.clusterName | required "clusterName is required" -}}
{{- if and (hasKey .Values "objectBucketClaim") (hasKey .Values.objectBucketClaim "name") (.Values.objectBucketClaim.name) -}}
{{- printf "%s" .Values.objectBucketClaim.name | required "objectBucketClaim.name is invalid" -}}
{{- else -}}
{{- printf "%s-%s-%s" "etcd-hcp" $clusterName "backup" | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Common labels */}}
{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "etcd-hcp-backup.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ include "etcd-hcp-backup.fullname" . }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
helm.sh/chart: {{ include "etcd-hcp-backup.chart" . }}
{{- end -}}
