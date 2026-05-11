{{/*
Expand the name of the chart.
*/}}
{{- define "vector-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vector-helm.fullname" -}}
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
{{- define "vector-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vector-helm.labels" -}}
helm.sh/chart: {{ include "vector-helm.chart" . }}
{{ include "vector-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vector-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vector-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Mirror the Vector subchart fullname logic so wrapper resources can follow it.
*/}}
{{- define "vector-helm.vectorFullname" -}}
{{- if .Values.vector.fullnameOverride }}
{{- .Values.vector.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "vector" .Values.vector.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Minimal selector labels that match the Vector workload pods.
*/}}
{{- define "vector-helm.vectorSelectorLabels" -}}
app.kubernetes.io/name: {{ default "vector" .Values.vector.nameOverride }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Labels for wrapper-owned Vector resources without colliding with chart labels.
*/}}
{{- define "vector-helm.vectorResourceLabels" -}}
helm.sh/chart: vector-0.38.1
app.kubernetes.io/name: vector
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: Agent
app.kubernetes.io/version: "0.43.1-distroless-libc"
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
The wrapper-owned Vector ConfigMap deliberately keeps the legacy `vector` name.
*/}}
{{- define "vector-helm.vectorConfigMapName" -}}
{{ include "vector-helm.vectorFullname" . }}
{{- end }}

{{/*
Static Vector container ports for the APC wrapper config.
*/}}
{{- define "vector-helm.vectorContainerPorts" -}}
- name: prom-exporter
  containerPort: 9090
  protocol: TCP
{{- end }}

{{/*
Static Vector service ports for the APC wrapper config.
*/}}
{{- define "vector-helm.vectorServicePorts" -}}
- name: udp-syslog
  protocol: UDP
  port: 9441
  targetPort: 9441
- name: tcp-syslog
  protocol: TCP
  port: 9442
  targetPort: 9442
- name: webhook
  protocol: TCP
  port: 9444
  targetPort: 9444
{{- end }}

{{/*
Mirror the Vector subchart service account name logic for APC-owned resources.
*/}}
{{- define "vector-helm.vectorServiceAccountName" -}}
{{- $serviceAccount := .Values.vector.serviceAccount | default dict -}}
{{- if hasKey $serviceAccount "create" -}}
  {{- if $serviceAccount.create -}}
    {{- default (include "vector-helm.vectorFullname" .) $serviceAccount.name -}}
  {{- else -}}
    {{- default "default" $serviceAccount.name -}}
  {{- end -}}
{{- else -}}
  {{- default (include "vector-helm.vectorFullname" .) $serviceAccount.name -}}
{{- end -}}
{{- end }}
