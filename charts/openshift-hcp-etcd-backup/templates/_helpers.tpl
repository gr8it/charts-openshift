{{/*
Chart name
*/}}
{{- define "etcd-hcp-backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/*
Resolve cluster name with defaults*/}}
{{- define "etcd-hcp-backup.clusterName" -}}
{{- $ctx := dict "Values" (dict "cluster" (dict "name" .Values.clusterName) "global" .Values.global) -}}
{{- include "apc-global-overrides.require-clusterName" $ctx -}}
{{- end -}}


{{/*
Resolve cluster name with defaults

{{- define "etcd-hcp-backup.clusterName" -}}
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
*/}}


{{/*
Fullname = etcd-hcp-backup prefix + cluster name
*/}}
{{- define "etcd-hcp-backup.fullname" -}}
{{- $clusterName := include "etcd-hcp-backup.clusterName" . -}}
{{- printf "%s-%s" "etcd-hcp-backup" $clusterName | replace "+" "_" | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart name and version for labels
*/}}
{{- define "etcd-hcp-backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate hosted cluster namespace
*/}}
{{- define "etcd-hcp-backup.namespace" -}}
{{- $clusterName := include "etcd-hcp-backup.clusterName" . -}}
{{- $clusterNamespace := default (printf "%s-%s" $clusterName $clusterName) .Values.clusterNamespace -}}
{{- $clusterNamespace | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate ObjectBucketClaim name
*/}}
{{- define "etcd-hcp-backup.obcName" -}}
{{- $clusterName := include "etcd-hcp-backup.clusterName" . -}}
{{- if and (hasKey .Values "objectBucketClaim") (hasKey .Values.objectBucketClaim "name") (.Values.objectBucketClaim.name) -}}
  {{- .Values.objectBucketClaim.name | required "objectBucketClaim.name is invalid" -}}
{{- else -}}
  {{- printf "etcd-hcp-%s-backup" $clusterName | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "etcd-hcp-backup.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ include "etcd-hcp-backup.fullname" . }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
helm.sh/chart: {{ include "etcd-hcp-backup.chart" . }}
{{- end -}}
