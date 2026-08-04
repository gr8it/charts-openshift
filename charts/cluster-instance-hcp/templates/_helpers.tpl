{{- define "cluster-instance-hcp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cluster-instance-hcp.fullname" -}}
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

{{- define "cluster-instance-hcp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cluster-instance-hcp.labels" -}}
helm.sh/chart: {{ include "cluster-instance-hcp.chart" . }}
{{ include "cluster-instance-hcp.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "cluster-instance-hcp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cluster-instance-hcp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Returns the validated cluster name */}}
{{- define "cluster-instance-hcp.clusterName" -}}
{{- required "clusterName is required" .Values.clusterName }}
{{- end }}

{{/* Returns the cluster set; defaults to clusterName with trailing digits stripped (e.g. prod01 => prod) */}}
{{- define "cluster-instance-hcp.clusterSet" -}}
{{- .Values.clusterSet | default (regexReplaceAll "[0-9]+$" (include "cluster-instance-hcp.clusterName" .) "") }}
{{- end }}

{{/* Returns the infrastructure namespace (infrastructure-<clusterName> by convention) */}}
{{- define "cluster-instance-hcp.infrastructureNamespace" -}}
{{- if .Values.infrastructureNamespace }}
{{- .Values.infrastructureNamespace }}
{{- else }}
{{- printf "infrastructure-%s" (include "cluster-instance-hcp.clusterName" .) }}
{{- end }}
{{- end }}
