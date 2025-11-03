{{/* Chart name */}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/* Resolve cluster name using global overrides helper */}}
{{- define "openshift-etcd.clusterName" -}}
{{- $ctx := dict "Values" (dict "cluster" (dict "name" .Values.clusterName) "global" .Values.global) -}}
{{- include "apc-global-overrides.require-clusterName" $ctx -}}
{{- end -}}

{{/* Fullname = chart name + cluster name */}}
{{- define "app.fullname" -}}
{{- $chartName := .Chart.Name | trunc 40 | trimSuffix "-" -}}
{{- $clusterName := (include "openshift-etcd.clusterName" .) | trunc 20 | trimSuffix "-" -}}
{{- printf "%s-%s" $chartName $clusterName | trunc 50 | trimSuffix "-" }}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Genereate ObjectBucketClaim name */}}
{{- define "obc.name" -}}
{{- $clusterName := include "openshift-etcd.clusterName" . -}}
{{- if and (hasKey .Values "objectBucketClaim") (hasKey .Values.objectBucketClaim "name") (.Values.objectBucketClaim.name) -}}
{{- printf "%s" .Values.objectBucketClaim.name | required "objectBucketClaim.name is invalid" -}}
{{- else -}}
{{- printf "%s-%s-%s" "etcd" $clusterName "backup" | trunc 63 | trimSuffix "-" -}}
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
