# APC Global Overrides

APC Gitops uses global values to share parameters in the environment. These can be either used directly (.Values.global.apc...) or overriden by values local to a specific chart. While it is straightforward to override strings, it is harder to do so for lists, dictionaries, and booleans.

This chart aims to help with the logic of overriding the global values with the local ones, as the logic is shared between several charts.

The chart creates helper functions for all global values, where:

- a local override strips the .global.apc from global value, e.g. .Values.global.apc.cluster.name => local override is .Values.cluster.name
- the namespace for all helper function is apc-global-overrides
- the name of the helper function is camelCase of the value, e.g. .Values.cluster.name => apc-global-overrides.clusterName
- for most of the values a require helper function is available, which requires the particular value to be set, e.g. apc-global-overrides.require-clusterName
- for dictionary values a merge helper function is available, e.g. .Values.caCertificates => apc-global-overrides.merge-caCertificates. This function merges local and global dictionaries giving preference to the local value. This is different to the "normal" helper function, which uses local dictionary if defined, otherwise fallsback to the global dictionary.

## Usage

Define this chart as a dependency:

```yaml
dependencies:
  - name: global-apc-overrides
    version: "1.0.0"
    repository: https://raw.githubusercontent.com/gr8it/charts-openshift/refs/heads/main/

```

Reference particular helper function in chart template:

```go
{{ include "global-apc-overrides.clusterName" .}}
```

This will use **local override** (.Values.cluster.name), and if not defined **fallback to global** (.Values.global.apc.cluster.name).

> [!NOTE]  
> For string helper functions alternative helper functions are defined to require the value to be specified, i.e. if neither cluster.name, nor global.apc.cluster.name are specified helm rendering fails

Local overrides can be specified in values.yaml as:

```yaml
cluster:
  name: klaster1
```

> [!NOTE]  
> While it is usually required to specify the subchart name in values.yaml to forward values to a subchart, e.g.
>
> ```yaml
> global-apc-overrides:
>   cluster:
>     name: klaster1
> ```
>
> **This is not the case here**, because we're not using template rendering, but helper functions, where context is sent directly - via 2nd parameter, e.g. dot in the `{{ include "global-apc-overrides.clusterName" . }}`

See [values.yaml](values.yaml), and [APC Global Overrides Unit Tests chart](../../library-charts-unittests/apc-global-overrides-unit-tests/templates/apc-global-overrides.yaml) for usage.

## Helper function list

|Name|Local override|Global|Output type|Note|
|---|---|---|---|---|
|apc-global-overrides.customer|customer|global.apc.customer|string||
|apc-global-overrides.require-customer|customer|global.apc.customer|string||
|apc-global-overrides.repoURL|repoURL|global.apc.repoURL|string||
|apc-global-overrides.require-repoURL|repoURL|global.apc.repoURL|string||
|apc-global-overrides.repoShort|repoShort|global.apc.repoShort|string|extracts organization and project name from repoURL and concatenates them using '-', e.g. gr8it-charts-openshift|
|apc-global-overrides.repoTargetRevision|repoTargetRevision|global.apc.repoTargetRevision|string||
|apc-global-overrides.require-repoTargetRevision|repoTargetRevision|global.apc.repoTargetRevision|string||
|apc-global-overrides.environment|environment|global.apc.environment|string||
|apc-global-overrides.require-environment|environment|global.apc.environment|string||
|apc-global-overrides.environmentShort|environmentShort|global.apc.environmentShort|string||
|apc-global-overrides.require-environmentShort|environmentShort|global.apc.environmentShort|string||
|apc-global-overrides.clusterName|cluster.name|global.apc.cluster.name|string||
|apc-global-overrides.require-clusterName|cluster.name|global.apc.cluster.name|string||
|apc-global-overrides.clusterAcmName|cluster.acmName|global.apc.cluster.acmName|string||
|apc-global-overrides.require-clusterAcmName|cluster.acmName|global.apc.cluster.acmName|string||
|apc-global-overrides.clusterType|cluster.type|global.apc.cluster.type|string||
|apc-global-overrides.require-clusterType|cluster.type|global.apc.cluster.type|string||
|apc-global-overrides.clusterBaseDomain|cluster.baseDomain|global.apc.cluster.baseDomain|string||
|apc-global-overrides.require-clusterBaseDomain|cluster.baseDomain|global.apc.cluster.baseDomain|string||
|apc-global-overrides.clusterAppsDomain|cluster.appsDomain|global.apc.cluster.appsDomain|string||
|apc-global-overrides.require-clusterAppsDomain|cluster.appsDomain|global.apc.cluster.appsDomain|string||
|apc-global-overrides.clusterApiURL|cluster.apiURL|global.apc.cluster.apiURL|string||
|apc-global-overrides.require-clusterApiURL|cluster.apiURL|global.apc.cluster.apiURL|string||
|apc-global-overrides.clusterKubeVersion|cluster.kubeVersion|global.apc.cluster.kubeVersion|string||
|apc-global-overrides.require-clusterKubeVersion|cluster.kubeVersion|global.apc.cluster.kubeVersion|string||
|apc-global-overrides.clusterApiVersions|cluster.apiVersions|global.apc.cluster.apiVersions|list|List of supported Kubernetes API versions used during helm template rendering|
|apc-global-overrides.clusterServices|cluster.services|global.apc.cluster.services|dictionary||
|apc-global-overrides.merge-clusterServices|cluster.services|global.apc.cluster.services|dictionary||
|apc-global-overrides.clusterIsHub|cluster.isHub|global.apc.cluster.isHub|boolean||
|apc-global-overrides.clusterRunsApps|cluster.runsApps|global.apc.cluster.runsApps|boolean||
|apc-global-overrides.proxy|proxy|global.apc.proxy|string||
|apc-global-overrides.require-proxy|proxy|global.apc.proxy|string||
|apc-global-overrides.noProxy|noProxy|global.apc.noProxy|string||
|apc-global-overrides.require-noProxy|noProxy|global.apc.noProxy|string||
|apc-global-overrides.proxyIPs|proxyIPs|global.apc.proxyIPs|list||
|apc-global-overrides.require-proxyIPs|proxyIPs|global.apc.proxyIPs|list||
|apc-global-overrides.services|services|global.apc.services|dictionary||
|apc-global-overrides.merge-services|services|global.apc.services|dictionary||
|apc-global-overrides.caCertificates|caCertificates|global.apc.caCertificates|dictionary||
|apc-global-overrides.merge-caCertificates|caCertificates|global.apc.caCertificates|dictionary||
|apc-global-overrides.caCertificatesBundle|caCertificates|global.apc.caCertificates|string|flattened caCertificates to be used as a bundle|

## Unit tests

As this chart is a library chart, unit tests can't be implemented here => unit tests are implemented in [APC Global Overrides Unit Tests chart](../../library-charts-unittests/apc-global-overrides-unit-tests/README.md)
