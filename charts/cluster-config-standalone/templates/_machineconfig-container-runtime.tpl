{{- define "cluster-config-standalone.machineConfigContainerRuntime" -}}
{{- $ := index . 0 -}}
{{- $pool := index . 1 -}}
{{- with $.Values.defaultContainerRuntime }}
{{- if not (has . (list "crun" "runc")) }}
{{- fail (printf "defaultContainerRuntime must be crun or runc, got %q" .) }}
{{- end }}
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  name: 99-crun-default-runtime-{{ $pool }}
  labels:
    machineconfiguration.openshift.io/role: {{ $pool }}
spec:
  config:
    ignition:
      version: 3.4.0
    storage:
      files:
        - contents:
            source: data:text/plain;charset=utf-8;base64,{{ printf "[crio.runtime]\ndefault_runtime = %q\n" . | b64enc }}
          mode: 420
          overwrite: true
          path: /etc/crio/crio.conf.d/99-crun-runtime.conf
{{- end }}
{{- end }}