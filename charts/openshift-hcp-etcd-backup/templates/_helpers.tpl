{{/* Application / Chart name */}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/* Fullname = chart name + cluster name */}}
{{- define "app.fullname" -}}
{{- $chartName := default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- $clusterName := .Values.clusterName | trunc 20 | trimSuffix "-" | required "clusterName is required" -}}
{{- printf "%s-%s" $chartName $clusterName | replace "+" "_" | trunc 50 | trimSuffix "-" }}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Generate hosted clsuter namespace - if not defined in values file */}}
{{- define "cluster.namespace" -}}
{{- $clusterName := .Values.clusterName | required "clusterName is required" -}}
{{- $clusterNamespace := default (printf "%s-%s" $clusterName $clusterName) (.Values.clusterNamespace) -}}
{{- printf "%s" $clusterNamespace | trimSuffix "-" | required "clusterNamespace cannot be empty" -}}
{{- end -}}

{{/* Genereate ObjectBucketClaim name */}}
{{- define "obc.name" -}}
{{- $clusterName := .Values.clusterName | required "clusterName is required" -}}
{{- if and (hasKey .Values "objectBucketClaim") (hasKey .Values.objectBucketClaim "name") (.Values.objectBucketClaim.name) -}}
{{- printf "%s" .Values.objectBucketClaim.name | required "objectBucketClaim.name is invalid" -}}
{{- else -}}
{{- printf "%s-%s-%s" "etcd-hcp" $clusterName "backup" | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Common labels */}}
{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ include "app.fullname" . }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
helm.sh/chart: {{ include "app.chart" . }}
{{- end -}}
