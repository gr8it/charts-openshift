{{/*
Expand the name of the chart.
*/}}
{{- define "gitops-bootstrap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gitops-bootstrap.fullname" -}}
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
{{- define "gitops-bootstrap.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gitops-bootstrap.labels" -}}
helm.sh/chart: {{ include "gitops-bootstrap.chart" . }}
{{ include "gitops-bootstrap.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gitops-bootstrap.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gitops-bootstrap.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gitops-bootstrap.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gitops-bootstrap.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "gitops-bootstrap.nodePoolHealthCheck" -}}
hs = { status = "Progressing", message = "Waiting for NodePool status" }

if obj.status == nil then
  return hs
end

for _, condition in ipairs(obj.status.conditions or {}) do
  if condition.type == "Degraded" and condition.status == "True" then
    hs.status = "Degraded"
    hs.message = condition.message or "NodePool is degraded"
    return hs
  end

  if (condition.type == "UpdatingConfig" or condition.type == "UpdatingVersion" or condition.type == "UpdatingPlatformMachineTemplate") and condition.status == "True" then
    hs.message = condition.message or "NodePool update is in progress"
    return hs
  end
end

for _, condition in ipairs(obj.status.conditions or {}) do
  if condition.type == "Ready" and condition.status == "True" and condition.observedGeneration == obj.metadata.generation then
    hs.status = "Healthy"
    hs.message = condition.message or "NodePool is ready"
    return hs
  end
end

hs.message = "Waiting for NodePool readiness to reflect its current generation"
return hs
{{- end }}
