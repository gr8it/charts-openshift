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
Create the mount path
*/}}
{{- define "cert-manager-config.vaultKubeAuthMountPath" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).kubeAuthMountPath | required "Vault kubeAuthMountPath is required" }}
{{- end }}

{{/*
Create the Vault URL
*/}}
{{- define "cert-manager-config.vaultUrl" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).url | required "Vault URL is required" }}
{{- end }}

{{/*
Create the Vault PKI role to use for signing certs
*/}}
{{- define "cert-manager-config.vaultPkiRole" -}}
{{- .Values.vaultPkiRole | default (include "apc-global-overrides.require-clusterAppsDomain" .) }}
{{- end }}

{{/*
Create the vault provider config name
*/}}
{{- define "cert-manager-config.vaultKubeVaultProviderConfigName" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).kubeVaultProviderConfigName | required "Vault kubeVaultProviderConfigName is required" }}
{{- end }}

{{/*
Create the cert-manager cluster issuer name
*/}}
{{- define "cert-manager-config.certManagerdefaultClusterIssuer" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).certManager).defaultClusterIssuer | required "certManagerdefaultClusterIssuer is required" }}
{{- end }}

{{/*
Create the ingress cert CN
*/}}
{{- define "cert-manager-config.ingressCertCommonName" -}}
{{- .Values.ingressCertCommonName | default (include "apc-global-overrides.require-clusterAppsDomain" .) }}
{{- end }}

{{/*
Create the ingress cert SANs
*/}}
{{- define "cert-manager-config.ingressCertDnsNames" -}}
{{- (.Values.ingressCertDnsNames | default (list (print "*." (include "apc-global-overrides.require-clusterAppsDomain" .)))) | toJson }}
{{- end }}
