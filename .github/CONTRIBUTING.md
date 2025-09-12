# Contributing rules / best practices

Repo contains helm chart, to be used within ArgoCD GitOps on top of Openshift platform, which means that **all charts** are published in the repo must:

- be Openshift compatible
- work with ArgoCD GitOps

## Component naming

Use simple component names with no prefix, e.g. remove-kubeadmin, crossplane, kyverno. Suffix when necessary:

> [!IMPORTANT]  
> While the usage of a single \<component\> comprising both installation and configuration is preferred, usually the followup configuration uses CRs created during operator / helm installation => must be split to different sync waves and hence "subcomponents" like kyverno-operator, kyverno-policies should be used

- \<component\>, e.g. remove-kubeadmin
- \<component\>-operator / helm for installation of operators / helm charts, e.g. acm-operator, crossplane-helm
  ~~- includes configuration not requiring CRDs to exist~~
  - do not incluce followup configuration
- \<component\>-config / instance / policies / etc, e.g. cert-manager-config
  - if configuration contains CRs created during operator / helm chart installation use -config suffix
  - if more specific configuration is used like instance setup, policies creation, use that instead, e.g. acm-instance, kyverno-policies

## Best practices

1) Follow helm best practices - <https://helm.sh/docs/chart_best_practices/>, e.g.

   - Each resource definition should be in its own template file!
   - prefer flat over nested values <https://helm.sh/docs/chart_best_practices/values/#flat-or-nested-values>, e.g. clusterName over cluster.name
   - use pre-releases while developing (e.g. 1.2.3-1) + pin version to use pre-release charts, e.g. ~1.2.3-0

1) Namespace should be specified in all manifests because of rendered manifest pattern usage - <https://github.com/helm/helm/issues/3553> 

   - prefer usage of Release namespace
   - templates/*.yaml

   ```yaml
   metadata:
     namespace: {{ .Release.Namespace }}
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

## Helm chart installation

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

## Operator installation

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
  versions:
    - quay-operator.v3.13.2
```

This installs Quay operator with **Manual approval** and approves specified version

## Patching of existing resources

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

## ObjectBucketClaim

- use static names for bucketnames, prefixed with apc- (they are much easier to work with)
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

### Secrets transformation

- use Kyverno policy to transform secrets to other formats, or combine created OBC configmap with a secret
- check generate-bucket-secret-allinfo cluster policy ()

## Secrets

Secrets are a bit problematic in Rendered manifest pattern, as they would be fully visible, during rendering and stored in a git repo.

Use External Secrets Operator to manage secrets instead:

- use ClusterSecretStore apc, which is created during ESO setup

> [!NOTE]  
> usage of apc store must be explicitly enabled, outside of namespaces with label apc.application.type=platform!

- [ExternalSecret CR](https://external-secrets.io/latest/api/externalsecret/)
- [PushSecret CR](https://external-secrets.io/latest/api/pushsecret/)
- ESO password generator <https://external-secrets.io/latest/api/generator/password/>, or <https://github.com/mittwald/kubernetes-secret-generator/blob/master/README.md>

## Extra objects

> [!CAUTION]  
> While it is a common practice to include ExtraObjects / ExtraManifests option in a helm chart, it is preferred to not implement this feature for APC helm charts. When implemented, the complexity would shift to the configuration repository, while we want to keep the config repo as simle as possible = hide the complexity in the component itself = helm chart.

> [!NOTE]  
> Extra objects might be relevant, if the chart is to be used as a library helm chart

## Helm lookup

> [!CAUTION]  
> Do not use [helm lookup function](https://helm.sh/docs/chart_template_guide/function_list/#kubernetes-and-chart-functions), because it makes the deployment non-deterministic, which is the opposite what we strive for by using rendered manifest Gitops pattern. Use declarative approach instead, e.g. Kyverno policy / Crossplane might help!
