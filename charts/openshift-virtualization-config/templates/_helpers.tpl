{{/*
Expand the name of the chart.
*/}}
{{- define "openshift-virtualization-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openshift-virtualization-config.fullname" -}}
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
{{- define "openshift-virtualization-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openshift-virtualization-config.labels" -}}
helm.sh/chart: {{ include "openshift-virtualization-config.chart" . }}
{{ include "openshift-virtualization-config.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openshift-virtualization-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openshift-virtualization-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openshift-virtualization-config.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openshift-virtualization-config.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define VMLM interface name
*/}}
{{- define "openshift-virtualization-config.vmlmInterfaceName" -}}
{{ .Values.vmlmInterface.baseIface | required "VMLM interface base interface must be defined" }}.{{ .Values.vmlmInterface.vlanId | required "VMLM interface VLAN ID must be defined" }}
{{- end }}
