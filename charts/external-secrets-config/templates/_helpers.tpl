``{{/*
Expand the name of the chart.
*/}}
{{- define "external-secrets-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "external-secrets-config.fullname" -}}
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
{{- define "external-secrets-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "external-secrets-config.labels" -}}
helm.sh/chart: {{ include "external-secrets-config.chart" . }}
{{ include "external-secrets-config.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "external-secrets-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "external-secrets-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "external-secrets-config.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "external-secrets-config.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the Vault URL
*/}}
{{- define "external-secrets-config.vaultUrl" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).url | required "Vault URL is required" }}
{{- end }}

{{/*
Create the Vault name
From VaultURL = hostname, or override if specified
*/}}
{{- define "cert-manager-config.vaultName" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).name | default (regexReplaceAll "https?://([^:/]+).*" (include "external-secrets-config.vaultUrl" .) "${1}") }}
{{- end }}

{{/*
Create the mount path
*/}}
{{- define "external-secrets-config.vaultKubeAuthMountPath" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).kubeAuthMountPath | required "Vault kubeAuthMountPath is required" }}
{{- end }}

{{/*
Create the vault provider config name
*/}}
{{- define "external-secrets-config.vaultKubeVaultProviderConfigName" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).kubeVaultProviderConfigName | required "Vault kubeVaultProviderConfigName is required" }}
{{- end }}

{{/*
Create the eso default cluster secret store
*/}}
{{- define "external-secrets-config.ESODefaultClusterSecretStore" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).externalSecretsOperator).defaultClusterSecretStore | required "Vault ESODefaultClusterSecretStore is required" }}
{{- end }}

{{/*
Create the policy name
*/}}
{{- define "external-secrets-config.policyName" -}}
{{ .Values.vaultKVmountPlatform }}-{{ include "apc-global-overrides.require-environmentShort" . }}-{{ .Values.vaultKubeAuthRole }}
{{- end }}
