{{/*
Names of the GeneratingPolicies creating vault Policies and AuthBackendGroups, one per vault role and kind.
Downstream resources carry the generating policy name in the generate.kyverno.io/policy-name label;
app-project-vault-groups is the name of the pre-1.20 ClusterPolicy, kept so its resources are still cleaned up.
*/}}
{{- define "kyverno-app-project.vaultGroupsPolicyNames" -}}
{{- $names := list "app-project-vault-groups" }}
{{- range $vr, $vrs := (include "kyverno-app-project.vaultRolesOverride" . | fromYaml) }}
{{- $names = append $names (printf "app-project-vault-groups-%s-policy" $vrs) }}
{{- $names = append $names (printf "app-project-vault-groups-%s-group" $vrs) }}
{{- end }}
{{- $names | toYaml }}
{{- end }}

{{/*
Common GeneratingPolicy spec part for vault groups: trigger, cluster name lookup and downstream naming.
Expects a dict with "root" (chart context) and "short" (vault role short name).
*/}}
{{- define "kyverno-app-project.vaultGroupsSpec" -}}
evaluation:
  generateExisting:
    enabled: true
  skipBackgroundRequests: {{ .root.Values.vaultGroupDefaults.skipBackgroundRequests }}
matchConstraints:
  resourceRules:
    - apiGroups: [""]
      apiVersions: ["v1"]
      operations: ["CREATE", "UPDATE"]
      resources: ["namespaces"]
  objectSelector:
    matchLabels:
      apc.namespace.type: application
variables:
  - name: clusterName
    expression: {{ include "kyverno-app-project.vaultGroupsClusterName" . | quote }}
  - name: clusterInitial
    expression: "variables.clusterName.substring(0, 1)"
  # role/group/policy name
  - name: name
    expression: >-
      "apc-" + variables.clusterInitial + "-" + object.metadata.name + "-{{ .short }}"
{{- end }}

{{/*
CEL expression: OCP cluster name, derived from the openshift-console route host; empty when not resolvable.
Rendered as a standalone expression, as GeneratingPolicy matchConditions cannot reference variables.
*/}}
{{- define "kyverno-app-project.vaultGroupsClusterName" -}}
cel.bind(parts, cel.bind(route, dyn(resource.Get("route.openshift.io/v1", "routes", "openshift-console", "console")), route == null ? "" : route.spec.host).split("."), size(parts) > 2 ? parts[2] : "")
{{- end }}

{{/*
CEL expression: vault role/group/policy name apc-<cluster initial>-<namespace>-<role short name>.
Expects a dict with "short" (vault role short name).
*/}}
{{- define "kyverno-app-project.vaultGroupsName" -}}
"apc-" + ({{ include "kyverno-app-project.vaultGroupsClusterName" . }}).substring(0, 1) + "-" + object.metadata.name + "-{{ .short }}"
{{- end }}

{{/*
GeneratingPolicy matchConditions for vault groups: cluster name resolved and downstream resource missing
(created only when missing, as re-applying them causes a reconciliation loop with crossplane).
Expects a dict with "short" (vault role short name), "apiVersion" and "resource" of the downstream resource.
*/}}
{{- define "kyverno-app-project.vaultGroupsMatchConditions" -}}
matchConditions:
  - name: cluster-name-resolved-and-{{ .resource | trimSuffix "s" }}-missing
    expression: >-
      {{ include "kyverno-app-project.vaultGroupsClusterName" . }} != "" &&
      dyn(resource.Get("{{ .apiVersion }}", "{{ .resource }}", "", {{ include "kyverno-app-project.vaultGroupsName" . }})) == null
{{- end }}
