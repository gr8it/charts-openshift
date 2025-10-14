{{/*
Expand the name of the chart.
*/}}
{{- define "apc-global-overrides.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "apc-global-overrides.fullname" -}}
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
{{- define "apc-global-overrides.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "apc-global-overrides.labels" -}}
helm.sh/chart: {{ include "apc-global-overrides.chart" . }}
{{ include "apc-global-overrides.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "apc-global-overrides.selectorLabels" -}}
app.kubernetes.io/name: {{ include "apc-global-overrides.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "apc-global-overrides.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "apc-global-overrides.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Helper function to work around helm limitation while using the default function, where false and null / nil are handled the same.
This function:
- returns value (1st argument) if the value is a boolean or string "true" or "false"
- if not, it returns global value (2nd argument) if it is a boolean or string "true" or "false"
- otherwise it returns the fallback value = default (3rd argument)

Usage example:
if eq "true" (include "apc-global-overrides.boolDefaults" (list ((.Values.cluster).runsApps) .Values.global.apc.cluster.runsApps true)) }}
*/}}

{{- define "apc-global-overrides.boolDefaults" -}}
{{- $value := index . 0 -}}
{{- $global := index . 1 -}}
{{- $default := index . 2 -}}
{{- if or (kindIs "bool" $value) (and (kindIs "string" $value) (or (eq $value "true") (eq $value "false"))) -}}
  {{- $value -}}
{{- else if or (kindIs "bool" $global) (and (kindIs "string" $global) (or (eq $global "true") (eq $global "false"))) -}}
  {{ $global }}
{{- else -}}
  {{/* tu by zrejme mala prist kontrola na to, ci je default zadefinovany ak ano, tak pouzit? Pripadne ak je required, tak fail ?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/}}
  {{- $default -}}
{{- end -}}
{{- end -}}

{{/*
Create the customer
*/}}
{{- define "apc-global-overrides.customer" -}}
{{- .Values.customer | default (((.Values.global).apc).customer) | default "" }}
{{- end }}

{{/*
Create the customer and require it
*/}}
{{- define "apc-global-overrides.require-customer" -}}
{{- include "apc-global-overrides.customer" . | required "apc customer is required" }}
{{- end }}

{{/*
Create the repoURL
*/}}
{{- define "apc-global-overrides.repoURL" -}}
{{- .Values.repoURL | default (((.Values.global).apc).repoURL) | default "" }}
{{- end }}

{{/*
Create the repoURL and require it
*/}}
{{- define "apc-global-overrides.require-repoURL" -}}
{{- include "apc-global-overrides.repoURL" . | required "apc repoURL is required" }}
{{- end }}

{{/*
Create the repoShort = extract organization and project name from the repoURL
*/}}
{{- define "apc-global-overrides.repoShort" -}}
{{- mustRegexReplaceAll "^https://github.com/([^/]+)/([^/]+?)(\\.git|/)?$" (include "apc-global-overrides.repoURL" .) "${1}-${2}" }}
{{- end }}

{{/*
Create the repoTargetRevision
*/}}
{{- define "apc-global-overrides.repoTargetRevision" -}}
{{- .Values.repoTargetRevision | default (((.Values.global).apc).repoTargetRevision) | default "HEAD" }}
{{- end }}

{{/*
Create the repoTargetRevision and require it
*/}}
{{- define "apc-global-overrides.require-repoTargetRevision" -}}
{{- include "apc-global-overrides.repoTargetRevision" . | required "apc repoTargetRevision is required" }}
{{- end }}

{{/*
Create the environment
*/}}
{{- define "apc-global-overrides.environment" -}}
{{- .Values.environment | default (((.Values.global).apc).environment) | default "" }}
{{- end }}

{{/*
Create the environment and require it
*/}}
{{- define "apc-global-overrides.require-environment" -}}
{{- include "apc-global-overrides.environment" . | required "apc environment is required" }}
{{- end }}

{{/*
Create the environmentShort
*/}}
{{- define "apc-global-overrides.environmentShort" -}}
{{- .Values.environmentShort | default (((.Values.global).apc).environmentShort) | default "" }}
{{- end }}

{{/*
Create the environmentShort and require it
*/}}
{{- define "apc-global-overrides.require-environmentShort" -}}
{{- include "apc-global-overrides.environmentShort" . | required "apc environmentShort is required" }}
{{- end }}

{{/*
Create the clusterName
*/}}
{{- define "apc-global-overrides.clusterName" -}}
{{- (.Values.cluster).name | default ((((.Values.global).apc).cluster).name) | default "" }}
{{- end }}

{{/*
Create the clusterName and require it
*/}}
{{- define "apc-global-overrides.require-clusterName" -}}
{{- include "apc-global-overrides.clusterName" . | required "apc cluster.name is required" }}
{{- end }}

{{/*
Create the clusterAcmName
*/}}
{{- define "apc-global-overrides.clusterAcmName" -}}
{{- (.Values.cluster).acmName | default ((((.Values.global).apc).cluster).acmName) | default "" }}
{{- end }}

{{/*
Create the clusterAcmName and require it
*/}}
{{- define "apc-global-overrides.require-clusterAcmName" -}}
{{- include "apc-global-overrides.clusterAcmName" . | required "apc cluster.acmName is required" }}
{{- end }}

{{/*
Create the clusterType
*/}}
{{- define "apc-global-overrides.clusterType" -}}
{{- (.Values.cluster).type | default ((((.Values.global).apc).cluster).type) | default "" }}
{{- end }}

{{/*
Create the clusterType and require it
*/}}
{{- define "apc-global-overrides.require-clusterType" -}}
{{- include "apc-global-overrides.clusterType" . | required "apc cluster.type is required" }}
{{- end }}

{{/*
Create the clusterBaseDomain
*/}}
{{- define "apc-global-overrides.clusterBaseDomain" -}}
{{- (.Values.cluster).baseDomain | default ((((.Values.global).apc).cluster).baseDomain) | default "" }}
{{- end }}

{{/*
Create the clusterBaseDomain and require it
*/}}
{{- define "apc-global-overrides.require-clusterBaseDomain" -}}
{{- include "apc-global-overrides.clusterBaseDomain" . | required "apc cluster.baseDomain is required" }}
{{- end }}

{{/*
Create the clusterAppsDomain
*/}}
{{- define "apc-global-overrides.clusterAppsDomain" -}}
{{- (.Values.cluster).appsDomain | default ((((.Values.global).apc).cluster).appsDomain) | default "" }}
{{- end }}

{{/*
Create the clusterAppsDomain and require it
*/}}
{{- define "apc-global-overrides.require-clusterAppsDomain" -}}
{{- include "apc-global-overrides.clusterAppsDomain" . | required "apc cluster.appsDomain is required" }}
{{- end }}

{{/*
Create the clusterApiURL
*/}}
{{- define "apc-global-overrides.clusterApiURL" -}}
{{- (.Values.cluster).apiURL | default ((((.Values.global).apc).cluster).apiURL) | default "" }}
{{- end }}

{{/*
Create the clusterApiURL and require it
*/}}
{{- define "apc-global-overrides.require-clusterApiURL" -}}
{{- include "apc-global-overrides.clusterApiURL" . | required "apc cluster.apiURL is required" }}
{{- end }}

{{/*
Create the clusterKubeVersion
*/}}
{{- define "apc-global-overrides.clusterKubeVersion" -}}
{{- (.Values.cluster).kubeVersion | default ((((.Values.global).apc).cluster).kubeVersion) | default "" }}
{{- end }}

{{/*
Create the clusterKubeVersion and require it
*/}}
{{- define "apc-global-overrides.require-clusterKubeVersion" -}}
{{- include "apc-global-overrides.clusterKubeVersion" . | required "apc cluster.kubeVersion is required" }}
{{- end }}

{{/*
Create the clusterApiVersions (list)
*/}}
{{- define "apc-global-overrides.clusterApiVersions" -}}
{{- (.Values.cluster).apiVersions | default ((((.Values.global).apc).cluster).apiVersions | default list) | toYaml }}
{{- end -}}

{{/*
Create the clusterServices (dictionary)
*/}}
{{- define "apc-global-overrides.clusterServices" -}}
{{- (.Values.cluster).services | default ((((.Values.global).apc).cluster).services | default dict) | toYaml }}
{{- end -}}

{{/*
Create the clusterServices merged (local + global) (dictionary) - local has precedence
*/}}
{{- define "apc-global-overrides.merge-clusterServices" -}}
{{ deepCopy ((.Values.cluster).services | default dict) | mergeOverwrite ((((.Values.global).apc).cluster).services | default dict) | toYaml }}
{{- end -}}

{{/*
Create the clusterIsHub
*/}}
{{- define "apc-global-overrides.clusterIsHub" -}}
{{- include "apc-global-overrides.boolDefaults" (list ((.Values.cluster).isHub) ((((.Values.global).apc).cluster).isHub) false) }}
{{- end }}

{{/*
Create the clusterRunsApps
*/}}
{{- define "apc-global-overrides.clusterRunsApps" -}}
{{- include "apc-global-overrides.boolDefaults" (list ((.Values.cluster).runsApps) ((((.Values.global).apc).cluster).runsApps) false) }}
{{- end }}

{{/*
Create the proxy
*/}}
{{- define "apc-global-overrides.proxy" -}}
{{- .Values.proxy | default (((.Values.global).apc).proxy) | default "" }}
{{- end }}

{{/*
Create the proxy and require it
*/}}
{{- define "apc-global-overrides.require-proxy" -}}
{{- include "apc-global-overrides.proxy" . | required "apc proxy is required" }}
{{- end }}

{{/*
Create the noProxy
*/}}
{{- define "apc-global-overrides.noProxy" -}}
{{- .Values.noProxy | default (((.Values.global).apc).noProxy) | default "" }}
{{- end }}

{{/*
Create the noProxy and require it
*/}}
{{- define "apc-global-overrides.require-noProxy" -}}
{{- include "apc-global-overrides.noProxy" . | required "apc noProxy is required" }}
{{- end }}

{{/*
Create the proxyCIDRs (list)
*/}}
{{- define "apc-global-overrides.proxyCIDRs" -}}
{{- .Values.proxyCIDRs | default ((.Values.global).apc).proxyCIDRs | default list | toYaml }}
{{- end }}

{{/*
Create the proxyCIDRs and require it
*/}}
{{- define "apc-global-overrides.require-proxyCIDRs" -}}
{{- (include "apc-global-overrides.proxyCIDRs" .) | fromYamlArray | default ("") | required "apc proxyCIDRs is required" | toYaml }}
{{- end }}

{{/*
Create the services (dictionary)
*/}}
{{- define "apc-global-overrides.services" -}}
{{- .Values.services | default ((.Values.global).apc).services | default dict | toYaml }}
{{- end -}}

{{/*
Create the services merged (local + global) (dictionary) - local has precedence
*/}}
{{- define "apc-global-overrides.merge-services" -}}
{{ deepCopy (.Values.services | default dict) | mergeOverwrite (((.Values.global).apc).services | default dict) | toYaml }}
{{- end -}}

{{/*
Create the caCertificates (dictionary)
*/}}
{{- define "apc-global-overrides.caCertificates" -}}
{{- .Values.caCertificates | default (((.Values.global).apc).caCertificates | default dict) | toYaml }}
{{- end -}}

{{/*
Create the caCertificates merged (local + global) (dictionary) - local has precedence
*/}}
{{- define "apc-global-overrides.merge-caCertificates" -}}
{{ deepCopy (.Values.caCertificates | default dict) | mergeOverwrite (((.Values.global).apc).caCertificates | default dict) | toYaml }}
{{- end -}}

{{/*
Create the caCertificatesBundle containing all certificates (single string)
NOTE: this is a workaround to the https://github.com/helm/helm/issues/31324 issue
*/}}
{{- define "apc-global-overrides.caCertificatesBundle" -}}
{{ range $key, $value := (include "apc-global-overrides.caCertificates" .) | fromYaml }}
{{- $value }}
{{- end }}
{{- end }}

{{/* Extraction of particular service parameters
*/}}

{{/*
Create the cert-manager cluster issuer name
*/}}
{{- define "apc-global-overrides.certManagerDefaultClusterIssuer" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).certManager).defaultClusterIssuer | default "" }}
{{- end }}

{{- define "apc-global-overrides.require-certManagerDefaultClusterIssuer" -}}
{{- include "apc-global-overrides.certManagerDefaultClusterIssuer" . | required "certManagerdefaultClusterIssuer is required" }}
{{- end }}

{{/*
Create the vault provider config name
*/}}
{{- define "apc-global-overrides.crossplaneKubeVaultProviderConfigName" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).crossplane).kubeVaultProviderConfigName | default "" }}
{{- end }}

{{- define "apc-global-overrides.require-crossplaneKubeVaultProviderConfigName" -}}
{{- include "apc-global-overrides.crossplaneKubeVaultProviderConfigName" . | required "Crossplane kubeVaultProviderConfigName is required" }}
{{- end }}

{{/*
Create the eso default cluster secret store
*/}}
{{- define "apc-global-overrides.ESODefaultClusterSecretStore" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).externalSecretsOperator).defaultClusterSecretStore | default "" }}
{{- end }}

{{- define "apc-global-overrides.require-ESODefaultClusterSecretStore" -}}
{{- include "apc-global-overrides.ESODefaultClusterSecretStore" . | required "Vault ESODefaultClusterSecretStore is required" }}
{{- end }}

{{/*
Create the Vault kube auth mount path
*/}}
{{- define "apc-global-overrides.vaultKubeAuthMountPath" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).kubeAuthMountPath | default "" }}
{{- end }}

{{- define "apc-global-overrides.require-vaultKubeAuthMountPath" -}}
{{- include "apc-global-overrides.vaultKubeAuthMountPath" . | required "Vault kubeAuthMountPath is required" }}
{{- end }}

{{/*
Create the Vault name
From VaultURL = hostname, or override if specified
*/}}
{{- define "apc-global-overrides.vaultName" -}}
{{/* https://github.com/helm/helm/issues/13487 */}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).name | default "" }}
{{- end }}

{{- define "apc-global-overrides.require-vaultName" -}}
{{- include "apc-global-overrides.vaultName" . | required "Vault name is required" }}
{{- end }}

{{/*
Create the Vault URL
*/}}
{{- define "apc-global-overrides.vaultUrl" -}}
{{- (((include "apc-global-overrides.services" .) | fromYaml).vault).url | default "" }}
{{- end }}

{{- define "apc-global-overrides.require-vaultUrl" -}}
{{- include "apc-global-overrides.vaultUrl" . | required "Vault URL is required" }}
{{- end }}
