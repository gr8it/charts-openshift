{{/*
Expand the name of the chart.
*/}}
{{- define "gatling-operator.name" -}}
gatling-controller
{{- end }}

{{/*
Create the resource name.
*/}}
{{- define "gatling-operator.fullname" -}}
gatling-controller
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gatling-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gatling-operator.labels" -}}
helm.sh/chart: {{ include "gatling-operator.chart" . }}
{{ include "gatling-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gatling-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gatling-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
control-plane: controller-manager
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gatling-operator.serviceAccountName" -}}
{{- include "gatling-operator.fullname" . }}
{{- end }}
