{{/*
Expand the name of the chart.
*/}}
{{- define "ingress-configuration.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ingress-configuration.fullname" -}}
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
{{- define "ingress-configuration.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ingress-configuration.labels" -}}
helm.sh/chart: {{ include "ingress-configuration.chart" . }}
{{ include "ingress-configuration.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ default .Release.Service .Values.releaseServiceOverride }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ingress-configuration.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ingress-configuration.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ingress-configuration.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ingress-configuration.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create logging overrides
Usage: {{ include "ingress-configuration.loggingRequestMaxlengthEffective" . | fromYaml }}
*/}}
{{- define "ingress-configuration.loggingRequestMaxlengthEffective" -}}
{{- $env := default .Values.global.apc.environment .Values.environment }}
{{- if hasKey .Values.loggingRequestMaxlengthOverride $env }}
{{- toYaml (get .Values.loggingRequestMaxlengthOverride $env) }}
{{- else }}
{{- toYaml .Values.defaultLoggingRequestMaxlength }}
{{- end }}
{{- end }}

{{/*
Create replicas overrides
Usage: {{ include "ingress-configuration.replicasEffective" . }}
*/}}
{{- define "ingress-configuration.replicasEffective" -}}
{{- $env := default .Values.global.apc.environment .Values.environment }}
{{- if hasKey .Values.replicasOverride $env }}
{{- get .Values.replicasOverride $env }}
{{- else }}
{{- .Values.defaultReplicas }}
{{- end }}
{{- end }}

{{/*
Create the cert-manager cluster issuer name
*/}}
{{- define "cert-manager-config.defaultClusterIssuer" -}}
{{- $vaultName := include "cert-manager-config.vaultName" . -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).certManager).defaultClusterIssuer | default (printf "vault-%s-issuer" $vaultName) }}
{{- end }}

{{/*
Create the Vault name
From VaultURL = hostname, or override if specified
*/}}
{{- define "cert-manager-config.vaultName" -}}
{{- $vaultName := regexReplaceAll "https?://([^:/]+).*" (include "cert-manager-config.vaultUrl" .) "${1}" | required "Vault URL/Name is required" }}
{{- .Values.vaultName | default $vaultName }}
{{- end }}

{{/*
Create the Vault URL
*/}}
{{- define "cert-manager-config.vaultUrl" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).url | required "Vault URL is required" }}
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