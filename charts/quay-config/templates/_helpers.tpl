{{/*
Expand the name of the chart.
*/}}
{{- define "quay-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "quay-config.fullname" -}}
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
{{- define "quay-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quay-config.labels" -}}
helm.sh/chart: {{ include "quay-config.chart" . }}
{{ include "quay-config.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "quay-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quay-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "quay-config.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "quay-config.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validate that all values under clusterPullSecretPath are unique.
*/}}
{{- define "quay-config.validateClusterPullSecretPath" -}}
{{- $seen := dict }}
{{- range $key, $val := .Values.vault.clusterPullSecretPath }}
{{- if hasKey $seen $val }}
  {{- fail (printf "clusterPullSecretPath: duplicate value %q used by both %q and %q — values must be distinct" $val (get $seen $val) $key) }}
  {{- end }}
  {{- $_ := set $seen $val $key }}
{{- end }}
{{- end }}


{{/*
Insert path segment into vault path
*/}}
{{- define "quay-config.insertPathSegment" -}}
{{- $parts := splitList "/" .path }}
{{- if ge (len $parts) 3 }}
{{- printf "%s/%s/%s" (first $parts) .insert (join "/" (rest $parts)) }}
{{- else }}
{{- fail  (printf "Vault path %q seems to be invalid. Path must consist of 3 or more segments (mount/env/secret)") .path }}
{{- end }}
{{- end -}}

{{/*
Global object name definitions
*/}}
{{- define "quay-config.objname.sa" -}}
{{ printf "%s-postinstall" (include "quay-config.name" .) }}
{{- end }}

{{- define "quay-config.objname.quayadmin" -}}
{{ printf "%s-%s" (include "quay-config.name" .) .Values.quayConfig.localAdminUser }}
{{- end }}

{{- define "quay-config.objname.bootstraptoken" -}}
{{ printf "%s-bootstrap-token" (include "quay-config.name" .) }}
{{- end }}

{{- define "quay-config.objname.robotaccounts" -}}
{{ printf "%s-robot-accounts" (include "quay-config.name" .) }}
{{- end }}

{{- define "quay-config.objname.managedorgs" -}}
{{ printf "%s-managed-orgs" (include "quay-config.name" .) }}
{{- end }}

{{- define "quay-config.objname.postinst-env" -}}
{{ printf "%s-postinstall-env" (include "quay-config.name" .) }}
{{- end }}

{{- define "quay-config.objname.postinst-scripts" -}}
{{ printf "%s-postinstall-scripts" (include "quay-config.name" .) }}
{{- end }}

{{- define "quay-config.objname.initorg-job" -}}
{{ printf "%s-init-organizations"  (include "quay-config.name" .) }}
{{- end }}

{{- define "quay-config.objname.registry-credentials" -}}
{{ printf "%s-registry-credentials" (include "quay-config.name" .) }}
{{- end }}

{{- define "quay-config.objname.vault-policy" -}}
{{ printf "%s-%s" (include "quay-config.name" . ) .Release.Namespace }}
{{- end }}
