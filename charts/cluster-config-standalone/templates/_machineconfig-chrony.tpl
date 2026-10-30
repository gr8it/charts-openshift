{{- define "cluster-config-standalone.machineConfig" -}}
{{- $ := index . 0 -}}
{{- $name := index . 1 -}}
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  name: 99-{{ $name }}-chrony
  labels:
    machineconfiguration.openshift.io/role: {{ $name }}
spec:
  config:
    ignition:
      version: 3.4.0
    storage:
      files:
        - contents:
            compression: ""
            source: data:text/plain;charset=utf-8;base64,{{ include "apc-global-overrides.chronyConfig" $ | b64enc }}
          mode: 420
          overwrite: true
          path: /etc/chrony.conf
{{- end }}