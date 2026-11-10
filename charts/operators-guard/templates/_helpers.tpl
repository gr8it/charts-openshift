{{/*
Chart name
*/}}
{{- define "operators-guard.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 40 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart name and version for labels
*/}}
{{- define "operators-guard.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "operators-guard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "operators-guard.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "operators-guard.labels" -}}
{{ include "operators-guard.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version | quote }}
helm.sh/chart: {{ include "operators-guard.chart" . }}
{{- end -}}

{{/*
Collector interval in seconds (the schema allows h, m, s in this order, e.g. 1h30m)
*/}}
{{- define "operators-guard.intervalSeconds" -}}
{{- $h := regexFind "[0-9]+h" .Values.interval | trimSuffix "h" | default "0" | int -}}
{{- $m := regexFind "[0-9]+m" .Values.interval | trimSuffix "m" | default "0" | int -}}
{{- $s := regexFind "[0-9]+s" .Values.interval | trimSuffix "s" | default "0" | int -}}
{{- add (mul $h 3600) (mul $m 60) $s -}}
{{- end -}}

{{/*
Data is stale after three intervals, at least 3 h: a cycle is the collect duration plus the interval
*/}}
{{- define "operators-guard.staleSeconds" -}}
{{- max 10800 (mul 3 (include "operators-guard.intervalSeconds" . | int)) -}}
{{- end -}}
