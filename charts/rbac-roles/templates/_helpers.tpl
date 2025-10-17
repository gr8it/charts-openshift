{{/*
Expand the name of the chart.
*/}}
{{- define "rbac-roles.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rbac-roles.fullname" -}}
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
{{- define "rbac-roles.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rbac-roles.labels" -}}
helm.sh/chart: {{ include "rbac-roles.chart" . }}
{{ include "rbac-roles.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ default .Release.Service .Values.releaseServiceOverride }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rbac-roles.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rbac-roles.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rbac-roles.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rbac-roles.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the roles
*/}}
{{- define "rbac-roles.roles" -}}
{{ $result := .Values.defaultRoles | deepCopy }}
{{- if hasKey .Values.rolesOverride (include "apc-global-overrides.environment" .) }}
{{- range $role, $roleValues := get .Values.rolesOverride (include "apc-global-overrides.environment" .) }}
  {{- $_ := set $result $role $roleValues }}
{{- end }}
{{- end }}
{{- $result | toYaml }}
{{- end }}

{{/*
Transform defaultRoles to aggregatedRoles mapping.
Usage: {{ include "remaping.aggregatedRoles" . }}
*/}}
{{- define "remaping.aggregatedRoles" -}}
{{- $result := dict -}}
{{- $roles := (include "rbac-roles.roles"  . | fromYaml) }}
{{- range $role, $spec := $roles }}
    {{- range $agg := $spec }}
      {{- if not (hasKey $result $agg) }}
        {{- $_ := set $result $agg (list $role) }}
      {{- else }}
        {{- $_ := set $result $agg (append (get $result $agg) $role) }}
      {{- end }}
    {{- end }}
{{- end }}
{{- $result | toYaml }}
{{- end }}