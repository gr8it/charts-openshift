{{/*
Common Helm helper definitions for the kyverno-backup-exclusions chart.
*/}}

{{- define "kyverno-backup-exclusions.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kyverno-backup-exclusions.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kyverno-backup-exclusions.labels" -}}
helm.sh/chart: {{ include "kyverno-backup-exclusions.chart" . }}
{{ include "kyverno-backup-exclusions.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "kyverno-backup-exclusions.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kyverno-backup-exclusions.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
