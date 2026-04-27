{{/*
Expand the name of the chart.
*/}}
{{- define "ocp-virt.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
