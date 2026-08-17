{{/*
Expand the name of the chart.
*/}}
{{- define "multi-cluster-observability.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "multi-cluster-observability.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "multi-cluster-observability.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "multi-cluster-observability.labels" -}}
helm.sh/chart: {{ include "multi-cluster-observability.chart" . }}
{{ include "multi-cluster-observability.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: multi-cluster-observability
{{- end }}

{{/*
Selector labels
*/}}
{{- define "multi-cluster-observability.selectorLabels" -}}
app.kubernetes.io/name: {{ include "multi-cluster-observability.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
