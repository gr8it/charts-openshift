{{/*
Expand the name of the chart.
*/}}
{{- define "cert-manager-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cert-manager-config.fullname" -}}
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
{{- define "cert-manager-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cert-manager-config.labels" -}}
helm.sh/chart: {{ include "cert-manager-config.chart" . }}
{{ include "cert-manager-config.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cert-manager-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cert-manager-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the cluster name
*/}}
{{- define "cert-manager-config.clusterName" -}}
{{- .Values.clusterName | default .Values.global.apc.cluster.name -}}
{{- end }}

{{/*
Create the mount path
*/}}
{{- define "cert-manager-config.vaultKubeAuthMountPath" -}}
{{ .Values.vaultKubeAuthMountPath | default (include "cert-manager-config.clusterName" .) }}
{{- end }}

{{/*
Create the mount path
*/}}
{{- define "cert-manager-config.caCertificates" -}}
{{- .Values.caCertificates | default .Values.global.apc.caCertificates -}}
{{- end }}

{{/*
Create the Vault name
From VaultURL = hostname, or override if specified
*/}}
{{- define "cert-manager-config.vaultName" -}}
{{- $vaultName := regexReplaceAll "https?://([^:/]+).*" (.Values.vaultUrl | default .Values.global.apc.services.vault.url) "${1}" | required "Vault URL/Name is required" }}
{{- .Values.vaultName | default $vaultName }}
{{- end }}

{{/*
Create the Vault URL
*/}}
{{- define "cert-manager-config.vaultUrl" -}}
{{- .Values.vaultUrl | default .Values.global.apc.services.vault.url | required "Vault URL is required" -}}
{{- end }}

{{/*
Create the Vault PKI role to use for signing certs
*/}}
{{- define "cert-manager-config.vaultPkiRole" -}}
{{- .Values.vaultPkiRole | default .Values.global.apc.cluster.appsDomain -}}
{{- end }}

{{/*
Create the vault provider config name
*/}}
{{- define "cert-manager-config.kubeVaultProviderConfigName" -}}
{{- .Values.kubeVaultProviderConfigName | default (include "cert-manager-config.vaultName" .) }}
{{- end }}

{{/*
Create the cert-manager cluster issuer name
*/}}
{{- define "cert-manager-config.clusterIssuerName" -}}
{{- $vaultName := regexReplaceAll "https?://([^:/]+).*" (.Values.vaultUrl | default .Values.global.apc.services.vault.url) "${1}" | required "Vault URL/Name is required" -}}
vault-{{ include "cert-manager-config.vaultName" . }}-issuer
{{- end }}

{{/*
Create the ingress cert CN
*/}}
{{- define "cert-manager-config.ingressCertCommonName" -}}
{{- .Values.ingressCertCommonName | default .Values.global.apc.cluster.appsDomain }}
{{- end }}

{{/*
Create the ingress cert SANs
*/}}
{{- define "cert-manager-config.ingressCertDnsNames" -}}
{{- (.Values.ingressCertDnsNames | default (list (print "*." .Values.global.apc.cluster.appsDomain))) | toJson }}
{{- end }}
