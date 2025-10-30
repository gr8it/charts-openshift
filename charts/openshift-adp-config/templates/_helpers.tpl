{{/*
Common Helm helper definitions for the openshift-adp-config chart.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "openshift-adp-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "openshift-adp-config.fullname" -}}
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
Return the chart label.
*/}}
{{- define "openshift-adp-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to resources.
*/}}
{{- define "openshift-adp-config.labels" -}}
helm.sh/chart: {{ include "openshift-adp-config.chart" . }}
{{ include "openshift-adp-config.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "openshift-adp-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openshift-adp-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Render the shared DataProtectionApplication spec. Allows an optional caCert override.
*/}}
{{- define "openshift-adp-config.dpaSpec" -}}
{{- $ctx := index . "root" -}}
{{- $valueCa := tpl (default "" $ctx.Values.dpa.s3.caCert) $ctx -}}
{{- $passedCa := default "" (index . "caCert") -}}
{{- $ca := default $passedCa $valueCa -}}
{{- $cluster := tpl (include "apc-global-overrides.clusterName" $ctx) $ctx -}}
{{- $locationDefaults := list
  (dict "name" (printf "oadp-%s-app-backup" $cluster) "bucket" (printf "oadp-%s-app-backup" $cluster) "prefix" (printf "backup/%s-app" $cluster) "default" true)
  (dict "name" (printf "oadp-%s-app-restore" $cluster) "bucket" (printf "oadp-%s-app-restore" $cluster) "prefix" (printf "backup/%s-app" $cluster) "default" false)
}}
{{- $providedLocations := $ctx.Values.dpa.backupLocations | default (list) -}}
{{- $backupTargetDefault := printf "oadp-%s-app-backup-cloud-credentials" $cluster -}}
{{- $restoreTargetDefault := printf "oadp-%s-app-restore-cloud-credentials" $cluster -}}
backupLocations:
{{- range $index, $defaults := $locationDefaults }}
  {{- $override := dict }}
  {{- if lt $index (len $providedLocations) }}
    {{- $override = index $providedLocations $index }}
  {{- end }}
  {{- $combined := merge (dict) $defaults $override }}
  {{- $locationName := tpl (default "" (index $combined "name")) $ctx }}
  {{- if eq $locationName "" }}
    {{- $locationName = index $defaults "name" }}
  {{- end }}
  {{- $isDefault := index $combined "default" }}
  {{- if eq (printf "%v" $isDefault) "" }}
    {{- $isDefault = index $defaults "default" }}
  {{- end }}
  {{- $bucket := tpl (default "" (index $combined "bucket")) $ctx }}
  {{- if eq $bucket "" }}
    {{- $bucket = index $defaults "bucket" }}
  {{- end }}
  {{- if $isDefault }}
    {{- $explicitBucket := tpl (default "" $ctx.Values.objectBucketClaims.backup.bucketName) $ctx }}
    {{- if ne $explicitBucket "" }}
      {{- $bucket = $explicitBucket }}
    {{- end }}
  {{- else }}
    {{- $explicitBucket := tpl (default "" $ctx.Values.objectBucketClaims.restore.bucketName) $ctx }}
    {{- if ne $explicitBucket "" }}
      {{- $bucket = $explicitBucket }}
    {{- end }}
  {{- end }}
  {{- $prefix := tpl (default "" (index $combined "prefix")) $ctx }}
  {{- if eq $prefix "" }}
    {{- $prefix = index $defaults "prefix" }}
  {{- end }}
  {{- $targetName := "" }}
  {{- if $isDefault }}
    {{- $targetName = tpl (default $backupTargetDefault (default "" $ctx.Values.credentials.backup.targetName)) $ctx }}
  {{- else }}
    {{- $targetName = tpl (default $restoreTargetDefault (default "" $ctx.Values.credentials.restore.targetName)) $ctx }}
  {{- end }}
  - name: {{ $locationName }}
    velero:
      accessMode: ReadWrite
      config:
        insecureSkipTLSVerify: {{ toString $ctx.Values.dpa.s3.insecureSkipTLSVerify | quote }}
        profile: default
        region: {{ $ctx.Values.dpa.s3.region }}
        s3ForcePathStyle: {{ toString $ctx.Values.dpa.s3.forcePathStyle | quote }}
        s3Url: {{ $ctx.Values.dpa.s3.url }}
      credential:
        key: cloud
        name: {{ $targetName }}
      default: {{ $isDefault }}
      objectStorage:
        bucket: {{ $bucket }}
        caCert: {{ $ca }}
        prefix: {{ $prefix }}
      provider: aws
{{- end }}
configuration:
  nodeAgent:
    enable: {{ $ctx.Values.dpa.nodeAgent.enabled }}
    podConfig:
      resourceAllocations:
        limits:
          cpu: {{ $ctx.Values.dpa.nodeAgent.resourceAllocations.limits.cpu | quote }}
          memory: {{ $ctx.Values.dpa.nodeAgent.resourceAllocations.limits.memory }}
        requests:
          cpu: {{ $ctx.Values.dpa.nodeAgent.resourceAllocations.requests.cpu | quote }}
          memory: {{ $ctx.Values.dpa.nodeAgent.resourceAllocations.requests.memory }}
    uploaderType: {{ $ctx.Values.dpa.nodeAgent.uploaderType }}
  velero:
    defaultPlugins:
{{- range $ctx.Values.dpa.velero.defaultPlugins }}
    - {{ . }}
{{- end }}
    defaultSnapshotMoveData: {{ $ctx.Values.dpa.velero.defaultSnapshotMoveData }}
    defaultVolumesToFSBackup: {{ $ctx.Values.dpa.velero.defaultVolumesToFSBackup }}
    resourceTimeout: {{ $ctx.Values.dpa.velero.resourceTimeout }}
{{- end }}
