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

{{/* Returns the infrastructure namespace (infrastructure-<clusterName> by convention) */}}
{{- define "cluster-instance-hcp.infrastructureNamespace" -}}
{{- if .Values.infrastructureNamespace }}
{{- .Values.infrastructureNamespace }}
{{- else }}
{{- printf "infrastructure-%s" (include "cluster-instance-hcp.clusterName" .) }}
{{- end }}
{{- end }}

{{- define "cluster-instance-hcp.etcdBackup.fullname" -}}
{{- printf "etcd-hcp-backup-%s" (include "cluster-instance-hcp.clusterName" .) | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "cluster-instance-hcp.etcdBackup.namespace" -}}
{{- $clusterName := include "cluster-instance-hcp.clusterName" . -}}
{{- printf "%s-%s" $clusterName $clusterName | trimSuffix "-" -}}
{{- end }}

{{- define "cluster-instance-hcp.etcdBackup.objectBucketClaimName" -}}
{{- if .Values.etcd.backup.objectBucketClaim.name -}}
{{- .Values.etcd.backup.objectBucketClaim.name | required "etcd.backup.objectBucketClaim.name is invalid" -}}
{{- else -}}
{{- printf "etcd-hcp-%s-backup" (include "cluster-instance-hcp.clusterName" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{- define "cluster-instance-hcp.etcdBackup.etcdStatefulSetName" -}}
{{- .Values.etcd.backup.etcdStatefulSetName | default "etcd" -}}
{{- end }}

{{- define "cluster-instance-hcp.etcdBackup.labels" -}}
app.kubernetes.io/name: etcd-hcp-backup
app.kubernetes.io/instance: {{ include "cluster-instance-hcp.etcdBackup.fullname" . }}
app.kubernetes.io/component: etcd-backup
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
helm.sh/chart: {{ include "cluster-instance-hcp.chart" . }}
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
