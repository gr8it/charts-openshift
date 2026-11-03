{{/*
Chart name
*/}}
{{- define "operator-readiness.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart name and version for labels
*/}}
{{- define "operator-readiness.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "operator-readiness.selectorLabels" -}}
app.kubernetes.io/name: {{ include "operator-readiness.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "operator-readiness.labels" -}}
{{ include "operator-readiness.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version | quote }}
helm.sh/chart: {{ include "operator-readiness.chart" . }}
{{- end -}}
