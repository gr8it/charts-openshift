{{/* Chart name */}}
{{- define "openshift-etcd-backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/*
Resolve cluster name with defaults*/}}
{{- define "openshift-etcd-backup.clusterName" -}}
{{- $ctx := dict "Values" (dict "cluster" (dict "name" .Values.clusterName) "global" .Values.global) -}}
{{- include "apc-global-overrides.require-clusterName" $ctx -}}
{{- end -}}

{{/* Fullname = chart name + cluster name */}}
{{- define "openshift-etcd-backup.fullname" -}}
{{- $chartName := .Chart.Name | trunc 40 | trimSuffix "-" -}}
{{- $clusterName := (include "openshift-etcd-backup.clusterName" .) | trunc 20 | trimSuffix "-" -}}
{{- printf "%s-%s" $chartName $clusterName | trunc 50 | trimSuffix "-" }}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "openshift-etcd-backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Generate ObjectBucketClaim name */}}
{{- define "openshift-etcd-backup.obcName" -}}
{{- $clusterName := include "openshift-etcd-backup.clusterName" . -}}
{{- if and (hasKey .Values "objectBucketClaim") (hasKey .Values.objectBucketClaim "name") (.Values.objectBucketClaim.name) -}}
{{- printf "%s" .Values.objectBucketClaim.name | required "objectBucketClaim.name is invalid" -}}
{{- else -}}
{{- printf "%s-%s-%s" "etcd" $clusterName "backup" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Common labels */}}
{{- define "openshift-etcd-backup.labels" -}}
app.kubernetes.io/name: {{ include "openshift-etcd-backup.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ include "openshift-etcd-backup.fullname" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version | quote }}
helm.sh/chart: {{ include "openshift-etcd-backup.chart" . }}
{{- end -}}
