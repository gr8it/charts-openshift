# How to contribute

Original generic contributing rules located at <https://github.com/gr8it/privatecloud/.github/CONTRIBUTING.md>

## General

- Follow [twelve factor apps](https://12factor.net)
- Follow DRY (Don't Repeat Yourself) principle
- If several ways of doing the same thing are shown (GUI, YAML, CLI), all options should do the same thing
- Keep NOTES (usually using quotation `>`) relevant to code (YAML / CLI) above
  <details>
  <summary>Click for explanation</summary>

  - if a NOTE is positioned below YAML / CLI, it might be missed when executing
  - positioning the NOTE above the code allows the reader to make a conscious decision whether to execute the code
  </details>
- always try to pin version, e.g. image, software, package, helm chart
  - prefer image digest to image tag
    <details>
    <summary>Click for explanation</summary>

    - if using image tag, the underlying image can change, which is not the case when using image digest
    </details>

## Pull Requests

- Branch / Pull request name shall include the Jira ticket ID, e.g. SPEXAPC-3288, so Jira can map the PR to a ticket automatically
- Creator of the comment should resolve the conversation, as he opened it
- Creator of the PR should merge the PR, so all required parties gave their review
- Keep git history
  <details>
  <summary>Click for explanation</summary>

  - Squash commits (during PR) only if the git log is spammed with messages like "testing"
  </details>

- Approvals
  - Explicit approval is optional for changes to dev environment
  - Approval (= review) should be given for merges of whole (nontrivial) tasks to dev environment
  - Explicit approval is required for changes to non dev environments
- After required changes are applied, re-request review from the particular reviewer 
- Delete branch, after PR is merged

## Documentation

- Create documentation in the /docs folder, and link to it from the environment / cluster specific folders README.md
  <details>
  <summary>Click for explanation</summary>

  - Prefer filesystem symlink
  - Alternatively use markdown link
  </details>

- Inline diagrams in Markdown  should use Mermaid format
- Images should use SVG format
  <details>
  <summary>Click for explanation</summary>

  - For maximum quality
  - So everyone can edit
  - draw.io usage is recommended (thick client makes usage a breeze)
  </details>

## Security

- Plain HTTP is not allowed outside cluster
- Plain HTTP is allowed within cluster
- Termination of TLS on ingress controller is preferred
- Establish TLS trust with CA
  <details>
  <summary>Click for explanation</summary>

  - Do not use insecure = true option
  - ca-cert-bundle configmap and secret are available in namespaces managed by Kyverno if installed
  </details>

- All endpoints should be authenticated
  <details>
  <summary>Click for explanation</summary>

  - Monitoring endpoints usually don't include authentication and use plain HTTP
  </details>

- Secrets / passwords
  - Secrets must not be stored in the GIT repository!
  - Secrets must be generated where possible (and pushed to Vault)
  - Generated secrets must follow [password policy](https://aspecta.atlassian.net/wiki/spaces/SP/pages/100499482/Politika+hesiel+password+policy)
  - Static secrets should be downloaded from Vault

## Production best practices

Follow <https://learnk8s.io/production-best-practices>

- Health checks should be defined
- Graceful shutdown should be implemented
  <details>
  <summary>Click for explanation</summary>

  See <https://learnk8s.io/graceful-shutdown#graceful-shutdown-with-a-prestop-hook>
  </details>

- Application should be fault tolerant
  <details>
  <summary>Click for explanation</summary>

  - More than 1 replica in production
  - Use podAntiAffinity / TopologySpreadConstraint
  - Specify pod disruption budget
  </details>

- Request / limits should be set
  <details>
  <summary>Click for explanation</summary>

  - Verticalpodautoscaler should be deployed to establish resource usage base line
  </details>

- Mount secrets as volumes, not environment variables
- pullPolicy should be set to Always for private registries
  <details>
  <summary>Click for explanation</summary>

  - setting pullPolicy to Always is a security best practice, which ensures, that the pod using an image is entitled to do so. If using an authenticated registry, a pod in another namespace could have downloaded an image using its pullsecret. Another pod without a pullsecret could reuse the image, when scheduled on the same node.
  - in lower environments, when mutable tags such as latest are used, the image should be always re-downloaded to pull the latest and greatest version of the image

  > this policy should be enforced using a policy engine such as Kyverno, OPA, ..
  </details>

## Monitoring

- Integrate Prometheus monitoring (podMonitor / serviceMonitor)
- Create alerts (prometheusRules)
- Create Grafana dashboard(s)

## Logging

- Logs are sent to STDOUT to be aggregated by platform logging solution
- Each production application should have audit policy defined
  <details>
  <summary>Click for explanation</summary>

  - All critical operations should be logged (e.g. all CRUD operations on sensitive application data / resources - more info - link to wiki (does not exist yet))
  - All audit logs should use global fluentd audit output (cluster wide resource - clusterOutput)

  </details>

## Comments

- Keep only implementation specific comments
  <details>
  <summary>Click for explanation</summary>

  - Configuration comments should be part of helm chart / operator used
  </details>

## Lint

- Use linters (markdown, yaml, ..)
  <details>
  <summary>Click for examples</summary>

  - For markdown you can use DavidAnson.vscode-markdownlint extension
  - For yaml you can use redhat.vscode-yaml extension

  </details>

- Prefer indented sequences for yaml
  <details>
  <summary>Click for explanation</summary>

  ```yaml
  sequence:
    - one
    - two
  ```

  over

  ```yaml
  sequence:
  - one
  - two
  ```

  Decision made by [team poll](https://teams.microsoft.com/l/message/19:meeting_MmFjNjA4OTQtZGU1ZS00YmFlLWIxNmEtODJhYjczMGY1Nzcz@thread.v2/1721213549897?context=%7B%22contextType%22%3A%22chat%22%7D) 8:4

  </details>

## GitOps

Original gitops contributing rules located at <https://github.com/gr8it/privatecloud/blob/develop/docs/openshift/gitops.md>

### Component naming

Use simple component names with no prefix, e.g. remove-kubeadmin, crossplane, kyverno. Suffix when necessary:

> [!IMPORTANT]  
> While the usage of a single \<component\> comprising both installation and configuration is preferred, usually the followup configuration uses CRs created during operator / helm installation => must be split to different sync waves and hence "subcomponents" like kyverno-operator, kyverno-policies should be used

- \<component\>, e.g. remove-kubeadmin
- \<component>-operator / helm for installation of operators / helm charts, e.g. acm-operator, crossplane-helm
  - do not include followup configuration
- \<component\>-config / instance / policies / etc, e.g. cert-manager-config
  - if configuration contains CRs created during operator / helm chart installation use -config suffix
  - if more specific configuration is used like instance setup, policies creation, use that instead, e.g. acm-instance, kyverno-policies

### Helmfile DRYness

Global / meta environment values can be used:

- for simple use cases adapt helm chart:
  - values.yaml

    > [!IMPORTANT]  
    > explicitly declare  used global values, and local value in the values.yaml

    ```yaml
    global:
      apc:
        parameter: ~
  
    parameter: ~ # keep empty so, global can be used
    ```

  - templates/*.yaml

    ```yaml
    {{ .Values.parameter | default .Values.global.apc.parameter | default "bar" }}
    ```

- for more advanced templating use cases / 3rd party helm charts:
  - define values in \<component\>/values.common.yaml.gotmpl, or \<component\>/values.\<environment\>.yaml.gotmpl

    ```yaml
    parameter: {{ .Values.global.apc.parameter}}-suffix
    ```

### Local development

Use gitops/charts directory of conf repo for development, place final helm chart to <https://github.com/gr8it/charts-openshift>

> [!IMPORTANT]  
> Use for development only!

> [!WARNING]  
> No versioning is possible with local helm charts => use for local development only!

For example (for more check [Development of a new component](#development-of-a-new-component)) a `new-component` in versions file:

```yaml
new-component:
  render:
    chart: ../charts/<component>
    chartVersion: "1.0.0"
...
```

> [!NOTE]  
> the local path used for local development must be relative to the helmfile which is rendering the versions file, i.e. `/gitops/components/helmfile.releases.yaml.gotmpl`

#### Dependencies

To update dependencies to new versions, consult [Helmfile documentation](https://helmfile.readthedocs.io/en/latest/#deps) / [Helm documentation](https://helm.sh/docs/helm/helm_dependency_update/):

```bash
helmfile -e <env> deps [--build]
helmfile -e <env> deps [--update]
```

### Static manifests

#### Helm chart

1) To convert plain Kubernetes manifest to Helm charts, usage of [Helmify](https://github.com/arttor/helmify) is recommended

   ```bash
   helmify -f <directory-with-manifests> <chart-name>
   ```

   e.g.

   ```bash
   $ pwd
   /home/gr8it/conf-socpoist/gitops/charts
   $ helmify -f /home/gr8it/conf-socpoist/ocp-dev01/argo-events-config argo-events-config
   ```

1) Namespace should be specified in all manifests because of rendered manifest pattern usage - <https://github.com/helm/helm/issues/3553>

   - prefer usage of Release namespace
   - templates/*.yaml

   ```yaml
   metadata:
     namespace: {{ .Release.Namespace }}
   ```

1) Manifest name

   - prefer helm chart generated manifest names
     - usually the manifest names won't match the names generated by helm (release name + chart name)
     - if possible (with little work), change the manifest name to the helm chart generated one
       - if data migration / CR loss => use static naming

   ```yaml
   metadata:
     name: {{ include "apc-component.fullname" . }}
   ```

   ```yaml
   metadata:
     name: {{ include "apc-component.fullname" . }}-configuration
   ```

   - not preferred

   ```yaml
   metadata:
     name: component-configuration
   ```

1) Always parametrize version, and pin default in values.yaml

   - templates/*.yaml

   ```yaml
   image: {{ .Values.image }}
   ```

   - values.yaml

   ```yaml
   image: myimage:v1.2.3
   ```

1) Parametrize settings which differ between environments

   ```yaml
   apiVersion: velero.io/v1
   kind: Schedule
   spec:
     schedule: {{ .Values.schedule }}
     template:
       includedNamespaces:
       - moodle
       includedResources:
       - '*'
       ttl: 72h0m0s
   ```

   - values.yaml

   ```yaml
   schedule: ~
   ```

1) .. snips ..

   - when encountering snips

   ```yaml
   spec:
     ... snip ...
     foo: bar
     ... snip ...
   ```

   - the functionality should be probably centralized in a different helm chart, e.g. changes to the hostedcluster CR can't be distributed = open a discussion to resolve the issue

1) local development referencing existing chart repo

   - Chart.yaml

   ```yaml
   apiVersion: v2
   name: development-chart
   description: A Dev Helm chart
   type: application
   version: 1.0.0

   dependencies:
     - name: acm-configurationpolicy
       version: "1.0.0"
       repository: https://raw.githubusercontent.com/gr8it/charts-openshift/refs/heads/SPEXAPC-xxx/
   ```

> [!NOTE]  
> main branch can use a shorter notation `https://raw.githubusercontent.com/gr8it/charts-openshift/main/`

### Helm

#### Best practices

1) Follow helm best practices - <https://helm.sh/docs/chart_best_practices/>, e.g.

   - Each resource definition should be in its own template file!
   - prefer flat over nested values <https://helm.sh/docs/chart_best_practices/values/#flat-or-nested-values>, e.g. clusterName over cluster.name
   - use pre-releases while developing (e.g. 1.2.3-1) + pin version to use pre-release charts, e.g. ~1.2.3-0

2) Namespace should be specified in all manifests because of rendered manifest pattern usage - helm/helm#3553

   - prefer usage of Release namespace
   - templates/*.yaml

     ```yaml
     metadata:
       namespace: {{ .Release.Namespace }}
     ```

3) Always parametrize version, and pin default in values.yaml

   - templates/*.yaml

     ```yaml
     image: {{ .Values.image }}
     ```

   - values.yaml

     ```yaml
     image: myimage:v1.2.3
     ```

### Helm chart installation

- Helm charts should be installed as a dependency, i.e. an APC specific helm chart with a dependency to the to be installed helm chart
- for example usage see [crossplane-helm](https://github.com/gr8it/charts-openshift/tree/main/charts/crossplane-helm)
- Chart.yaml

```yaml
apiVersion: v2
name: crossplane-helm
description: A Helm chart to install Crossplane
type: application
version: 1.0.0
appVersion: "1.19.2"

dependencies:
  - name: crossplane
    version: 1.19.2
    repository: https://charts.crossplane.io/stable
```

- values.yaml

```yaml
crossplane:
  replicas: 2
  rbacManager:
    replicas: 2
    topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app: crossplane-rbac-manager
...
```

### Operator installation

- ACM operatorpolicy should be used to install operators, and approve only allowed versions
- should depend on helm chart [acm-operatorpolicy](https://github.com/gr8it/charts-openshift/tree/main/charts/acm-operatorpolicy)
- for example usage see [quay-operator](https://github.com/gr8it/charts-openshift/tree/main/charts/quay-operator), e.g.:
- Chart.yaml

```yaml
apiVersion: v2
name: quay-operator
description: A Helm chart to install Quay Operator using ACM operator policy
type: application
version: 1.0.0
appVersion: "v0.11.0"

dependencies:
  - name: acm-operatorpolicy
    version: "1.0.0"
    repository: https://raw.githubusercontent.com/gr8it/charts-openshift/refs/heads/main/
```

- values.yaml

```yaml
acm-operatorpolicy:
  subscription:
    channel: stable-3.13
    name: quay-operator
    source: redhat-operators
    sourceNamespace: openshift-marketplace
    startingCSV: quay-operator.v3.13.2

  upgradeApproval: Automatic # set to Automatic only when at least 1 version is defined, otherwise all updates are approved!
  versions:
    - quay-operator.v3.13.2
```

Although not natural, this installs Quay operator with manual approval, but approves specified versions only!

### Extending Helmfile releases

It is possible to add arbitrary [helmfile parameters](https://helmfile.readthedocs.io/en/latest/#configuration) to a helmfile release by specifying it / them in the helmfile dictionary:

```yaml
  acm-operator:
    render:
      chart: gr8it-openshift/acm-operator
      chartVersion: "1.0.0"
    destination:
      namespace: open-cluster-management
    helmfile:
      verify: true
```

#### Patching of 3rd party helm charts

Sometimes it is required to patch 3rd party helm charts, e.g. due to incompatibility with Openshift. This can be done by using helmfile features, see <https://github.com/roboll/helmfile/pull/673> (note - this link is referred to by the original documentation!?), which under the hood use kustomize to do the work.

To add strategicMergePatches / jsonPatches to a release they need to be specified in the helmfile dictionary, in versions.yaml.gotmpl add:

```yaml
  acm-operator:
    render:
      chart: gr8it-openshift/acm-operator
      chartVersion: "1.0.0"
    destination:
      namespace: open-cluster-management
    helmfile:
      strategicMergePatches:
      - apiVersion: batch/v1
        kind: Job
        metadata:
          name: advanced-cluster-management-v2-12-1-approver
          namespace: open-cluster-management
        spec:
          template:
            spec:
              containers:
              - name: installplan-approver
                env:
                - name: HTTP_PROXY
                  value: {{ .Values.global.apc.proxy }}
                - name: HTTPS_PROXY
                  value: {{ .Values.global.apc.proxy }}
                - name: NO_PROXY
                  value: {{ .Values.global.apc.noProxy }}
```

> [!NOTE]  
> apiVersion, kind, metadata.name, and metadata.namespace must all be specified for the strategicMergePatch to work! Otherwise an error similar to `Error: no resource matches strategic merge patch "Job.v1.batch/advanced-cluster-management-v2-12-1-approver.[noNs]": no matches for Id Job.v1.batch/advanced-cluster-management-v2-12-1-approver.[noNs]; failed to find unique target for patch Job.v1.batch/advanced-cluster-management-v2-12-1-approver.[noNs]]` might be thrown during helmfile rendering

or

```yaml
  acm-operator:
    render:
      chart: gr8it-openshift/acm-operator
      chartVersion: "1.0.0"
    destination:
      namespace: open-cluster-management
    helmfile:
      jsonPatches:
      - target:
          version: v1
          group: batch
          kind: Job
        patch:
        - op: add
          path: /spec/template/spec/containers/0/env/0
          value: 
            name: NO_PROXY
            value: {{ .Values.global.apc.noProxy }}
        - op: add
          path: /spec/template/spec/containers/0/env/0
          value: 
            name: HTTPS_PROXY
            value: {{ .Values.global.apc.proxy }}
        - op: add
          path: /spec/template/spec/containers/0/env/0
          value: 
            name: HTTP_PROXY
            value: {{ .Values.global.apc.proxy }}
```

> [!WARNING]  
> Prefer usage of strategicMergePatches, because it fails during helmfile rendering if target is not found. In contrast jsonPatches fail silently, i.e. in case helm chart changes you hardly notice the patch wasn't applied!

In the case of ACM operator example, jsonPatches were used contrary to the recommendation, because no target name needs to be specified, which is beneficial because the job name changes between operator versions and as such the strategicMergePatches would need to be updated accordingly on every release.

> [!NOTE]  
> When patching is used, the result of rendering is one file `patched_resources.yaml` containing all manifests

### Patching of existing resources (server side / server-side apply)

If existing resources needs to be extended / patched, e.g. API server certs (modifying APIserver.config.openshift CR named cluster). Add an annotation to the object being modified:

```yaml
apiVersion: config.openshift.io/v1
kind: APIServer
metadata:
  name: cluster
  annotations:
    argocd.argoproj.io/sync-options: ServerSideApply=true
...
```

or alternatively add sync option serversideapply in the versions.yaml:

```yaml
  acm-operator:
    render:
      chart: gr8it-openshift/apiserver-cert
      chartVersion: "1.0.0"
    destination:
      namespace: kube-system
    syncPolicy:
      syncOptions:
        - ServerSideApply=true
```

> [!NOTE]  
> The managed fields information is visible in ArgoCD, but must be explicitly requested when using kubectl using `kubectl get xxx -o yaml --show-managed-fields`!

### Deploying big resources

Using standard ArgoCD method of deployment (similar to kubectl apply -f ...), only resources up to 256kB can be deployed due to limitation of Kubernetes annotation size. This is caused by the fact that client side apply creates annotation with the resource content.

This is usually a problem with Custom Resource Definitions (CRDs), which can be megabytes in size.

The recommended way to workaround the problem is to use ArgoCDs replace strategy (similar to kubectl replace -f ...) on the problematic resources by supplying annotation:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-options: Replace=true
```

or as a last resort use server side apply, see [Patching of existing resources](#patching-of-existing-resources-server-side--server-side-apply).

### Environment / Cluster specific configuration

While it is best practice to specify configuration using values.yaml in the environment, we strive to minimize deployment configuration of components to environments.

As these components are APC specific, some "environment" configuration can be bundled within the component itself, e.g. RBAC. This is acceptable, because the components are strongly APC opinionated.

The agreed method is to have a generic configuration, which can be overridden by environment / cluster specific configuration, which allows us to:

- bundle most of the configuration in the component
- define default configuration
- override environment / cluster configuration only if different to default
- define whole configuration per environment / cluster
- yet still use the best practice approach of defining configuration in the environment

<details>
<summary>Click for an Example</summary>

Example [application-gitops](https://github.com/gr8it/charts-openshift/tree/main/charts/application-gitops)

```yaml
# values.yaml

# uses following global values => do not set here
global:
  apc:
    environment: ~
    cluster:
      name: ~

environment: ~ # environment name, e.g. dev, test, prod. If not set, .global.apc.environment is used
clusterName: ~ # cluster name, e.g. dev01, test01, ... If not set, .global.apc.cluster.name is used

# roles applied to all environments
# can be overridden by roleEnvOverrides and roleClusterOverrides
# to override default roles in values.yaml, we need to workaround helm's merge issues, e.g.:
# defaultRoles:
#  viewer:
#    policies: []
defaultRoles:
  admin:
    groupSuffix: PJA
    # policies are ArgoCD Cabin policies stripped of the first 2 parts, e.g. p, proj:xxx:admin, as they are generated in the template
    policies:
      - repositories, *, {{`{{ request.object.metadata.namespace }}`}}/{{ .Values.allowedGitDomain }}*, allow

  tester:
    groupSuffix: TES
    policies:
      - applications, get, {{`{{ request.object.metadata.namespace }}`}}/*, allow

# environment specific roles
# overrides defaultRoles
# can be overridden by roleClusterOverrides
# deep merging is NOT applied => all parameters (groupSuffix and policies) must be specified here as well!
# roleEnvOverrides:
#  prod:
#    tester:
#      groupSuffix: TES
#      policies:
#        - applications, get, {{`{{ request.object.metadata.namespace }}`}}/*, allow
roleEnvOverrides:
  # environmentName
  prod:
    tester: {}

# cluster specific roles
# overrides defaultRoles and roleEnvOverrides
# deep merging is NOT applied => all parameters (groupSuffix and policies) must be specified here as well!
# roleClusterOverrides:
#  prod01:
#    tester:
#      groupSuffix: TES
#      policies:
#        - applications, get, {{`{{ request.object.metadata.namespace }}`}}/*, allow
roleClusterOverrides: {}
```

Which would create admin and tester roles on all environments, except tester on prod.

The used _helper.tpl

```go
{{/*
Create the clusterName
*/}}
{{- define "application-gitops.clusterName" -}}
{{- .Values.clusterName | default .Values.global.apc.cluster.name | required "clusterName is required"  }}
{{- end }}

{{/*
Create the environment
*/}}
{{- define "application-gitops.environment" -}}
{{- .Values.environment | default .Values.global.apc.environment | required "environment is required"  }}
{{- end }}

{{/*
Create the roles
*/}}
{{- define "application-gitops.roles" -}}
{{ $result := .Values.defaultRoles | deepCopy }}
{{- if hasKey .Values.roleEnvOverrides (include "application-gitops.environment" .) }}
{{- range $role, $roleValues := get .Values.roleEnvOverrides (include "application-gitops.environment" .) }}
  {{- $_ := set $result $role $roleValues }}
{{- end }}
{{- end }}
{{- if hasKey .Values.roleClusterOverrides (include "application-gitops.clusterName" .) }}
{{- range $role, $roleValues := get .Values.roleClusterOverrides (include "application-gitops.clusterName" .) }}
  {{- $_ := set $result $role $roleValues }}
{{- end }}
{{- end }}
{{- $result | toJson }}
{{- end }}
```

and respective usage in template:

```yaml
...
            roles:
              {{- range $role, $roleValues := (include "application-gitops.roles" $ | fromJson ) }}
                ...
              {{- end }}
...
```

> [!NOTE]  
> toJson/fromJson can be replaced with toYaml/fromYaml

</details>

### Helm capabilities check

Some helm charts check for existence of an API on the target cluster, which is a bit problematic in the rendered manifest pattern, as no actual cluster is connected when rendering, e.g.

```yaml
{{- if .Capabilities.APIVersions.Has "apps.openshift.io/v1" }}
```

It is strongly recommended to work around this, e.g. helm chart upgrade..

However it is possible to manually specify APIVersions available on a cluster by specifying global APC parameters in helmfile, e.g.:

```yaml
global:
  apc:
    cluster:
      # always create a comment stating the component, which uses the particular apiVersion
      apiVersions:
        - apps.openshift.io/v1
```

### Escaping double curly brackets

Some services running in APC require usage of templates delimited with double curly brackets `{{ }}`, e.g. prometheus alert rules (do use {{ $labels.name }}), or kyverno policies. Which might be problematic, as several go templating passes might be going on, e.g. helmfile, configurationpolicy (ACM). The easiest and most readable way of doing this is to use raw string literals (delimited by backticks):

```go
{{ `{{ $labels.name }}` }}
```

or double escape in combination with interpreted string literals (delimited by doublequotes):

```go
{{ `{{ "{{ $labels.name }}" }}` }}
```

> [!WARNING]  
> Kyverno doesn't use go escaping - see [Kyverno](https://kyverno.io/docs/policy-types/cluster-policy/variables/#escaping-variables)

Usage of interpreted string literals only is also possible:

```go
{{ "{{ $labels.name }}" }}
{{ "{{ \"{{ $labels.name }}\" }}" }}
```

#### Kyverno

Kyverno doesn't use standard go escaping, it uses backslash "\" instead, i.e. when a prometheusrule (or similar) needs to be created by Kyverno policy, double escaping can be done:

```yaml
foo: {{ `\{{ $labels.namespace }}` }}
```

or when using doublequotes for strings:

```yaml
foo: "{{ `\\{{ $labels.namespace }}` }}"
```

### Namespace creation

Namespace creation will be handled by ArgoCD, which can be requested by setting syncOptions item CreateNamespace=true for a particular component in versions.yaml for a particular environment:

 ```yaml
  component-create-namespace:
    source:
      path: components/apps/component-create-namespace
    syncOptions:
      - CreateNamespace=true
```

If the namespace needs to contain a specific label / annotation (e.g. **apc.namespace.type=platform**), this can be realized using component managedNamespaceMetadata parameter in versions.yaml:

```yaml
  component-create-namespace-with-labels:
    source:
      path: components/apps/component-create-namespace-with-labels
    syncOptions:
      - CreateNamespace=true
    managedNamespaceMetadata:
      labels:
        apc.namespace.type: platform
```

### ObjectBucketClaim

- use static names for bucketnames, prefixed with apc-
- as with manifest naming, use standard helm chart naming if possible and enable override, which will be used for existing SP OBC:
- templates/obc.yaml

  ```yaml
  apiVersion: objectbucket.io/v1alpha1
  kind: ObjectBucketClaim
  metadata:
    name: {{ include "test.fullname" . }}
    namespace: {{ .Release.Namespace }}
  spec:
    storageClassName: {{ .Values.storageClassName }}
    bucketName: {{ .Values.bucketName | default (include "test.fullname" .) }}
  ```

- default values.yaml

```yaml
nameOverride: ""
fullnameOverride: ""

storageClassName: ocs-storagecluster-ceph-rgw
bucketName: ~
```

- values.yaml

```yaml
nameOverride: ""
fullnameOverride: "existing-obc"

bucketName: existing-123a5
```

- rendered manifest

```yaml
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: existing-obc
  namespace: namespace-with-obc
spec:
  storageClassName: ocs-storagecluster-ceph-rgw
  bucketName: existing-123a5
```

#### Secrets transformation

- use Kyverno policy to transform secrets to other formats, or combine created OBC configmap with a secret
- check generate-bucket-secret-allinfo cluster policy ()

### Secrets

Secrets are a bit problematic in Rendered manifest pattern, as they would be fully visible, during rendering and stored in a git repo.

Use External Secrets Operator to manage secrets instead:

- use ClusterSecretStore apc, which is created during ESO setup

> [!NOTE]  
> usage of apc store must be explicitly enabled, outside of namespaces with label apc.application.type=platform!

- [ExternalSecret CR](https://external-secrets.io/latest/api/externalsecret/)
- [PushSecret CR](https://external-secrets.io/latest/api/pushsecret/)
- [ESO password generator](https://external-secrets.io/latest/api/generator/password/)

#### Secret generator

Instructions for  secret generator to create [passwords](https://external-secrets.io/latest/api/generator/password/), [quay tokens](https://external-secrets.io/latest/api/generator/quay/), [UUID](https://external-secrets.io/latest/api/generator/uuid/) and others.

> [!NOTE]  
> use correct API version when manifesting

- use [ESO password generator](https://external-secrets.io/latest/api/generator/password/) together with [ESO externalsecret](https://external-secrets.io/latest/api/externalsecret/), [ESO pushsecret](https://external-secrets.io/latest/api/pushsecret/) or alternative cluster ESO resources
- to generate password in namespace, use [ESO externalsecret](https://external-secrets.io/latest/api/externalsecret/) without ```spec.secretStoreRef```
- in case manifest should generate a new secret during a fresh installation, but preserve any existing secret already present in the cluster or managed by a secret provider please, follow
  - [ESO pushsecret](https://external-secrets.io/latest/api/pushsecret/) use  ```spec.updatePolicy=IfNotExist```
  - [ESO externalsecret](https://external-secrets.io/latest/api/externalsecret/) use ```spec.refreshInterval="0"``` and  in newer ESO version ```spec.refreshPolicy=CreatedOnce``` [createdonce](https://external-secrets.io/latest/api/externalsecret/#createdonce)

- example for generating secret with user/password in namespace which preserves existing one

```yaml
---
# Source: keycloak/templates/secret-password-generator.yaml
apiVersion: generators.external-secrets.io/v1alpha1
kind: Password
metadata:
  name: keycloak-db-auth
  namespace: apc-keycloak
  labels:
    helm.sh/chart: keycloak-1.0.0
    app.kubernetes.io/name: keycloak
    app.kubernetes.io/instance: keycloak
    app.kubernetes.io/version: "v26.0"
    app.kubernetes.io/managed-by: Helm
spec:
  length: 26
  digits: 5
  symbols: 5
  symbolCharacters: "-_/!@^)"
  noUpper: false
  allowRepeat: false
---
# Source: keycloak/templates/secret-external-keycloak-db-auth.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: keycloak-db-auth
  namespace: apc-keycloak
  labels:
    helm.sh/chart: keycloak-1.0.0
    app.kubernetes.io/name: keycloak
    app.kubernetes.io/instance: keycloak
    app.kubernetes.io/version: "v26.0"
    app.kubernetes.io/managed-by: Helm
spec:
  refreshInterval: "0"
  #refreshPolicy it is not supported for external-secrets v 0.11
  #refreshPolicy: "CreatedOnce"
  target:
    name: keycloak-db-auth
    creationPolicy: Owner
    template:
      type: kubernetes.io/basic-auth
      metadata:
        labels:
          helm.sh/chart: keycloak-1.0.0
          app.kubernetes.io/name: keycloak
          app.kubernetes.io/instance: keycloak
          app.kubernetes.io/version: "v26.0"
          app.kubernetes.io/managed-by: Helm
      data:
        username: "keycloak"
        password: "{{ . }}" 
  dataFrom:
  - sourceRef:
      generatorRef:
        apiVersion: generators.external-secrets.io/v1alpha1
        kind: Password
        name: keycloak-db-auth

```

### Extra objects

> [!CAUTION]  
> While it is a common practice to include ExtraObjects / ExtraManifests option in a helm chart, it is preferred to not implement this feature for APC helm charts. When implemented, the complexity would shift to the configuration repository, while we want to keep the config repo as simple as possible = hide the complexity in the component itself = helm chart.

> [!NOTE]  
> Extra objects might be relevant, if the chart is to be used as a library helm chart

### Helm lookup

> [!CAUTION]  
> Do not use [helm lookup function](https://helm.sh/docs/chart_template_guide/function_list/#kubernetes-and-chart-functions), because it makes the deployment non-deterministic, which is the opposite what we strive for by using rendered manifest Gitops pattern. Use declarative approach instead, e.g. Kyverno policy / Crossplane might help!
