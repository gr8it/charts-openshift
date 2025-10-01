{{/*
Expand the name of the chart.
*/}}
{{- define "kyverno-app-project.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kyverno-app-project.fullname" -}}
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
{{- define "kyverno-app-project.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kyverno-app-project.labels" -}}
helm.sh/chart: {{ include "kyverno-app-project.chart" . }}
{{ include "kyverno-app-project.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ default .Release.Service .Values.releaseServiceOverride }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kyverno-app-project.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kyverno-app-project.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kyverno-app-project.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kyverno-app-project.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "kyverno-app-project.vaultRolesOverride" -}}
{{- $roles := dict -}}
{{- $roles := get .Values.vaultRolesOverride (include "apc-global-overrides.environment" . ) | default .Values.defaultVaultRoles }}
{{- $roles | toYaml }}
{{- end }}

{{- define "kyverno-app-project.vaultCapabilitiesOverride" -}}
{{- $capabilities := dict -}}
{{- $capabilities := get .Values.vaultCapabilitiesOverride (include "apc-global-overrides.environment" . ) | default .Values.defaultVaultCapabilities }}
{{- $capabilities | toYaml }}
{{- end }}

{{/*
Create the vault provider config name
*/}}
{{- define "kyverno-app-project.vaultKubeVaultProviderConfigName" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).kubeVaultProviderConfigName | required "Vault kubeVaultProviderConfigName is required" }}
{{- end }}

{{/*
Create the mount path
*/}}
{{- define "kyverno-app-project.vaultKubeAuthMountPath" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).kubeAuthMountPath | required "Vault kubeAuthMountPath is required" }}
{{- end }}
