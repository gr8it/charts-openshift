{{- define "cluster-config-standalone.machineConfig" -}}
{{- $ := index . 0 -}}
{{- $name := index . 1 -}}
{{- $ntpServers := include "apc-global-overrides.ntpServers" $ | fromYamlArray -}}
{{- $chronyConf := "" -}}
{{- range $ntpServers -}}
  {{- $chronyConf = printf "%sserver %s iburst\n" $chronyConf . -}}
{{- end -}}
{{- if $ntpServers -}}
  {{- $chronyConf = printf "%sdriftfile /var/lib/chrony/drift\nmakestep 1.0 3\nrtcsync\nlogdir /var/log/chrony\n" $chronyConf -}}
{{- end -}}
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
            source: data:text/plain;charset=utf-8;base64,{{ $chronyConf | b64enc }}
          mode: 420
          overwrite: true
          path: /etc/chrony.conf
{{- end }}