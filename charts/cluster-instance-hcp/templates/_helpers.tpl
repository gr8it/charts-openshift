{{- define "cluster-instance-hcp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cluster-instance-hcp.fullname" -}}
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

{{- define "cluster-instance-hcp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cluster-instance-hcp.labels" -}}
helm.sh/chart: {{ include "cluster-instance-hcp.chart" . }}
{{ include "cluster-instance-hcp.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "cluster-instance-hcp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cluster-instance-hcp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Returns the validated cluster name */}}
{{- define "cluster-instance-hcp.clusterName" -}}
{{- required "clusterName is required" .Values.clusterName }}
{{- end }}

{{/* Returns the cluster set; defaults to clusterName with trailing digits stripped (e.g. prod01 => prod) */}}
{{- define "cluster-instance-hcp.clusterSet" -}}
{{- .Values.clusterSet | default (regexReplaceAll "[0-9]+$" (include "cluster-instance-hcp.clusterName" .) "") }}
{{- end }}

{{/* Returns the infrastructure namespace (infrastructure-<clusterName> by convention) */}}
{{- define "cluster-instance-hcp.infrastructureNamespace" -}}
{{- if .Values.infrastructureNamespace }}
{{- .Values.infrastructureNamespace }}
{{- else }}
{{- printf "infrastructure-%s" (include "cluster-instance-hcp.clusterName" .) }}
{{- end }}
{{- end }}

{{/*
Returns an OAuth identity provider in the OpenShift API format.
*/}}
{{- define "cluster-instance-hcp.identityProvider" -}}
{{- $provider := . -}}
{{- if eq $provider.type "LDAP" -}}
{{- $ldap := $provider.ldap -}}
{{- $attributes := $ldap.attributes | default dict -}}
{{- $ldapConfig := dict
  "attributes" (dict
    "id" ($attributes.id | default (list "dn"))
    "email" ($attributes.email | default (list "mail"))
    "name" ($attributes.name | default (list "cn"))
    "preferredUsername" ($attributes.preferredUsername | default (list "uid")))
  "bindDN" $ldap.bindDN
  "insecure" ($ldap.insecure | default false)
  "url" $ldap.url
  "ca" (dict "name" "oauth-idp-ca-bundle")
-}}
{{- with $ldap.bindPassword -}}
{{- $_ := set $ldapConfig "bindPassword" . -}}
{{- end -}}
{{- dict "name" $provider.name "type" $provider.type "mappingMethod" $provider.mappingMethod "ldap" $ldapConfig | toYaml -}}
{{- else if eq $provider.type "OpenID" -}}
{{- $openID := deepCopy ($provider.openID | default dict) -}}
{{- $_ := set $openID "ca" (dict "name" "oauth-idp-ca-bundle") -}}
{{- $_ := set $provider "openID" $openID -}}
{{- toYaml $provider -}}
{{- else -}}
{{- toYaml $provider -}}
{{- end -}}
{{- end -}}
