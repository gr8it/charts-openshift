{{/* Application / Chart name */}}
{{- define " openshift-hcp-etcd-backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/* Resolve cluster name using global overrides helper */}}
{{- define "openshift-hcp-etcd-backup.clusterName" -}}
{{- $ctx := dict "Values" (dict "cluster" (dict "name" .Values.clusterName) "global" .Values.global) -}}
{{- include "apc-global-overrides.require-clusterName" $ctx -}}
{{- end -}}

{{/* Fullname = chart name + cluster name */}}
{{- define "openshift-hcp-etcd-backup.fullname" -}}
{{- $chartName := default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- $clusterName := (include "openshift-hcp-etcd-backup.clusterName" .) | trunc 20 | trimSuffix "-" -}}
{{- printf "%s-%s" $chartName $clusterName | replace "+" "_" | trunc 50 | trimSuffix "-" }}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "openshift-hcp-etcd-backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Generate hosted clsuter namespace - if not defined in values file */}}
{{- define "openshift-hcp-etcd-backup.namespace" -}}
{{- $clusterName := include "openshift-hcp-etcd-backup.clusterName" . -}}
{{- $clusterNamespace := default (printf "%s-%s" $clusterName $clusterName) (.Values.clusterNamespace) -}}
{{- printf "%s" $clusterNamespace | trimSuffix "-" | required "clusterNamespace cannot be empty" -}}
{{- end -}}

{{/* Genereate ObjectBucketClaim name */}}
{{- define "openshift-hcp-etcd-backup.name" -}}
{{- $clusterName := include "openshift-hcp-etcd-backup.clusterName" . -}}
{{- if and (hasKey .Values "objectBucketClaim") (hasKey .Values.objectBucketClaim "name") (.Values.objectBucketClaim.name) -}}
{{- printf "%s" .Values.objectBucketClaim.name | required "objectBucketClaim.name is invalid" -}}
{{- else -}}
{{- printf "%s-%s-%s" "etcd-hcp" $clusterName "backup" | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Common labels */}}
{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "openshift-hcp-etcd-backup.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ include "openshift-hcp-etcd-backup.fullname" . }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
helm.sh/chart: {{ include "openshift-hcp-etcd-backup.chart" . }}
{{- end -}}
