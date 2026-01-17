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
  - name: apc-global-overrides
    version: "1.0.0"
    repository: https://raw.githubusercontent.com/gr8it/charts-openshift/refs/heads/main/

```

Reference particular helper function in chart template:

```go
{{ include "apc-global-overrides.clusterName" .}}
```

This will use **local override** (.Values.cluster.name), and if not defined **fallback to global** (.Values.global.apc.cluster.name).

### Local overrides in chart values

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
> apc-global-overrides:
>   cluster:
>     name: klaster1
> ```
>
> **This is not the case here**, because we're not using template rendering, but helper functions, where context is sent directly - via 2nd parameter, e.g. dot in the `{{ include "apc-global-overrides.clusterName" . }}`

See [values.yaml](values.yaml)

### Usage implementation examples

See [APC Global Overrides Unit Tests chart](../../library-charts-unittests/apc-global-overrides-unit-tests/templates/apc-global-overrides.yaml).

## Helper function kinds

### String

Local override string is used when defined, otherwise global string is used.

Helper functions prefixed with `require-` execute previous logic, but expect at least one of the values to be defined, otherwise rendering fails.

### Booleans

Local override boolean is used when defined, otherwise global boolean is used.

Standard default function would use global value, if local override value is set and set to false.

To workaround this issue a boolDefaults helper function is available, which corrects the behaviour as expected.
Accepts a list of 3 items - override, global value, and default value, e.g. usage for isHub:

```go
{{- include "apc-global-overrides.boolDefaults" (list ((.Values.cluster).isHub) ((((.Values.global).apc).cluster).isHub) false) }}
```

### Lists

Local override list is used when defined, otherwise global list is used.

### Dictionaries

Local override dict is used when defined, otherwise global dict is used.

Helper functions prefixed with `merge-` merge local and global dict giving preference to the local dict.

## Global configuration

Configuration currently supported by the apc-global-overrrides chart:

```yaml
global:
  apc:
    customer: ~
    repoURL: ~
    repoTargetRevision: HEAD # default HEAD
    environment: ~
    environmentShort: ~
    cluster:
      name: ~
      acmName: ~
      type: ~
      baseDomain: ~
      appsDomain: ~
      apiURL: ~
      kubeVersion: ~
      apiVersions: []
      services: {}
      isHub: false
      runsApps: false
    proxy: ~
    noProxy: ~
    proxyCIDRs: []
    services:
      certManager:
        defaultClusterIssuer: ~
      crossplane:
        kubeVaultProviderConfigName: ~
        kubeKeycloakProviderConfigName: ~
      externalSecretsOperator:
        defaultClusterSecretStore: ~
      keycloak:
        url: https://login.apps.lab.gr8it.cloud
        realm: apps
      metallb:
        namespace: metallb-system
      quay:
        host: ~
      vault:
        url: ~
        name: ~
        KVmountPlatform: apc-platform
        kubeAuthMountPath: ~
    caCertificates: {}
```

> [!NOTE]  
> where a value other than ~ (NIL) is stated, the value equals the default value

## Helper function list

|Name|Local override|Global|Output type|Default|Note|
|---|---|---|---|---|---|
|apc-global-overrides.boolDefaults|-|-|boolean|-|see [booleans](#booleans) do not use directly|
|apc-global-overrides.customer|customer|global.apc.customer|string|-|customer name, used as prefix|
|apc-global-overrides.require-customer|customer|global.apc.customer|string|-||
|apc-global-overrides.repoURL|repoURL|global.apc.repoURL|string|-|repo URL, used for GitOps|
|apc-global-overrides.require-repoURL|repoURL|global.apc.repoURL|string|-||
|apc-global-overrides.repoShort|repoShort|global.apc.repoShort|string|-|extracts organization and project name from repoURL and concatenates them using '-', e.g. gr8it-charts-openshift|
|apc-global-overrides.repoTargetRevision|repoTargetRevision|global.apc.repoTargetRevision|string|HEAD||
|apc-global-overrides.environment|environment|global.apc.environment|string|-|environment is the name of the environment at customer, which is different to cluster name. In the GitOps repo naming = meta environment, e.g. prod, hub, test, dev|
|apc-global-overrides.require-environment|environment|global.apc.environment|string|-||
|apc-global-overrides.environmentShort|environmentShort|global.apc.environmentShort|string|-|usually 1st character of environment, e.g. p for prod, h for hub, d for dev, t for test|
|apc-global-overrides.require-environmentShort|environmentShort|global.apc.environmentShort|string|-||
|apc-global-overrides.clusterName|cluster.name|global.apc.cluster.name|string|-||
|apc-global-overrides.require-clusterName|cluster.name|global.apc.cluster.name|string|-||
|apc-global-overrides.clusterAcmName|cluster.acmName|global.apc.cluster.acmName|string|-|name of the ACM managed cluster = for hub = local-cluster, for other clusters = name of the cluster above|
|apc-global-overrides.require-clusterAcmName|cluster.acmName|global.apc.cluster.acmName|string|-||
|apc-global-overrides.clusterType|cluster.type|global.apc.cluster.type|string|-|one of standalone, hcp|
|apc-global-overrides.require-clusterType|cluster.type|global.apc.cluster.type|string|-||
|apc-global-overrides.clusterBaseDomain|cluster.baseDomain|global.apc.cluster.baseDomain|string|-||
|apc-global-overrides.require-clusterBaseDomain|cluster.baseDomain|global.apc.cluster.baseDomain|string|-||
|apc-global-overrides.clusterAppsDomain|cluster.appsDomain|global.apc.cluster.appsDomain|string|-|ingress URL suffix|
|apc-global-overrides.require-clusterAppsDomain|cluster.appsDomain|global.apc.cluster.appsDomain|string|-||
|apc-global-overrides.clusterApiURL|cluster.apiURL|global.apc.cluster.apiURL|string|-||
|apc-global-overrides.require-clusterApiURL|cluster.apiURL|global.apc.cluster.apiURL|string|-||
|apc-global-overrides.clusterKubeVersion|cluster.kubeVersion|global.apc.cluster.kubeVersion|string|-|version of the Kubernetes API to adhere to|
|apc-global-overrides.require-clusterKubeVersion|cluster.kubeVersion|global.apc.cluster.kubeVersion|string|-||
|apc-global-overrides.clusterApiVersions|cluster.apiVersions|global.apc.cluster.apiVersions|list|-|List of supported Kubernetes API versions to be reported as available during helm template rendering, i.e. sets helms' --api-versions flag. Use only as last resort !!! Usually newer versions of helm charts do not need this. Always create a comment stating the component, which uses the particular apiVersion|
|apc-global-overrides.clusterServices|cluster.services|global.apc.cluster.services|dictionary|-|cluster local services - used to share values between helm charts|
|apc-global-overrides.merge-clusterServices|cluster.services|global.apc.cluster.services|dictionary|-||
|apc-global-overrides.clusterIsHub|cluster.isHub|global.apc.cluster.isHub|boolean|false|Is a hub cluster running ACM|
|apc-global-overrides.clusterRunsApps|cluster.runsApps|global.apc.cluster.runsApps|boolean|false|Cluster runs business applications (usually the all non-hub clusters run apps)|
|apc-global-overrides.proxy|proxy|global.apc.proxy|string|-||
|apc-global-overrides.require-proxy|proxy|global.apc.proxy|string|-||
|apc-global-overrides.noProxy|noProxy|global.apc.noProxy|string|-||
|apc-global-overrides.require-noProxy|noProxy|global.apc.noProxy|string|-||
|apc-global-overrides.proxyCIDRs|proxyCIDRs|global.apc.proxyCIDRs|list|-||
|apc-global-overrides.require-proxyCIDRs|proxyCIDRs|global.apc.proxyCIDRs|list|-||
|apc-global-overrides.services|services|global.apc.services|dictionary|-|global services. Used to share values between helm charts|
|apc-global-overrides.merge-services|services|global.apc.services|dictionary|-||
|apc-global-overrides.caCertificates|caCertificates|global.apc.caCertificates|dictionary|-|Custom CA certificates to trust, keys contain name of the CA with suffix .crt, and values contains one or more PEM encoded certificate(s)|
|apc-global-overrides.merge-caCertificates|caCertificates|global.apc.caCertificates|dictionary|-||
|apc-global-overrides.caCertificatesBundle|caCertificates|global.apc.caCertificates|string|-|flattened caCertificates to be used as a bundle|

### Service specific helpers

Helpers to query a specific service parameters available:

|Name|Local override|Global|Output type|Default|Note|
|---|---|---|---|---|---|
|apc-global-overrides.certManagerDefaultClusterIssuer|services.certManager.defaultClusterIssuer|global.apc.services.certManager.defaultClusterIssuer|string|-|Cert manager cluster issuer to use for cluster-config certificates|
|apc-global-overrides.require-certManagerDefaultClusterIssuer|services.certManager.defaultClusterIssuer|global.apc.services.certManager.defaultClusterIssuer|string|-||
|apc-global-overrides.crossplaneKubeVaultProviderConfigName|services.crossplane.kubeVaultProviderConfigName|global.apc.services.crossplane.kubeVaultProviderConfigName|string|-|name of the crossplane Vault provider config to be used when creating Vault resources using crossplane|
|apc-global-overrides.require-crossplaneKubeVaultProviderConfigName|services.crossplane.kubeVaultProviderConfigName|global.apc.services.crossplane.kubeVaultProviderConfigName|string|-||
|apc-global-overrides.crossplaneKubeKeycloakProviderConfigName|services.crossplane.kubeKeycloakProviderConfigName|global.apc.services.crossplane.kubeKeycloakProviderConfigName|string|-|name of the crossplane Keycloak provider config to be used when creating Keycloak resources using crossplane|
|apc-global-overrides.require-crossplaneKubeKeycloakProviderConfigName|services.crossplane.kubeKeycloakProviderConfigName|global.apc.services.crossplane.kubeVaultProviderConfigName|string|-||
|apc-global-overrides.ESODefaultClusterSecretStore|services.externalSecretsOperator.defaultClusterSecretStore|global.apc.services.externalSecretsOperator.defaultClusterSecretStore|string|-|External Secrets Operator default cluster secret store to use for cluster-config externalsecrets|
|apc-global-overrides.require-ESODefaultClusterSecretStore|services.externalSecretsOperator.defaultClusterSecretStore|global.apc.services.externalSecretsOperator.defaultClusterSecretStore|string|-||
|apc-global-overrides.keycloakUrl|services.keycloak.url|global.apc.services.keycloak.url|string|-|Keycloak ingress URL|
|apc-global-overrides.require-keycloakUrl|services.keycloak.url|global.apc.services.keycloak.url|string|-||
|apc-global-overrides.keycloakRealm|services.keycloak.Realm|global.apc.services.keycloak.Realm|string|-|Keycloak application Realm|
|apc-global-overrides.require-keycloakRealm|services.keycloak.Realm|global.apc.services.keycloak.Realm|string|-||
|apc-global-overrides.metallbNamespace|services.metallb.namespace|global.apc.services.metallb.namespace|string|metallb-system|namespace where metallb is installed|
|apc-global-overrides.quayHost|services.quay.host|global.apc.services.quay.host|string|-|Quay host, e.g. used for mirroring|
|apc-global-overrides.require-quayHost|services.quay.host|global.apc.services.quay.host|string|-||
|apc-global-overrides.vaultKubeAuthMountPath|services.vault.kubeAuthMountPath|global.apc.services.vault.kubeAuthMountPath|string|-|Cluster specific auth mount point to be used for kubernetes auth method to Vault|
|apc-global-overrides.require-vaultKubeAuthMountPath|services.vault.kubeAuthMountPath|global.apc.services.vault.kubeAuthMountPath|string|-||
|apc-global-overrides.vaultName|services.vault.name|global.apc.services.vault.name|string|-|Human friendly Vault name, e.g. used in resource names|
|apc-global-overrides.require-vaultName|services.vault.name|global.apc.services.vault.name|string|-||
|apc-global-overrides.vaultUrl|services.vault.url|global.apc.services.vault.url|string|-|URL of the Vault server|
|apc-global-overrides.require-vaultUrl|services.vault.url|global.apc.services.vault.url|string|-||
|apc-global-overrides.vaultKVmountPlatform|services.vault.KVmountPlatform|global.apc.services.vault.KVmountPlatform|string|apc-platform|Vault KV mount for platform secrets|

## Unit tests

As this chart is a library chart, unit tests can't be implemented here => unit tests are implemented in [APC Global Overrides Unit Tests chart](../../library-charts-unittests/apc-global-overrides-unit-tests/README.md)
