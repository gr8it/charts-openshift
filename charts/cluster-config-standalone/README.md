# Cluster Config for Standalone clusters

Helm chart configures a standalone (= non HCP) cluster. Parameters configurable are similar to the ones configurable by [HCP cluster](../hosted-control-planes-cluster/README.md) component, see headlines below.

## Image proxy

Configures tag / hash image proxying through a image proxy (Quay, Harbor).

|parameter|default|type|description|
|---|---|---|---|
|.imageProxy.host|-|string|proxy host. If specified, image proxying is configured|
|.imageProxy.port|443|integer|port to be used on the host used for proxying|
|.imageProxy.sources|registry.redhat.io, registry.connect.redhat.com, docker.io, quay.io, ghcr.io|list|list of image registries to proxy *|
|.imageProxy.caCertificates|apc-global-overrides.caCertificatesBundle|multiline string|PEM encoded CA certificate to use when connecting to the proxy|

\* assumes the image repo to proxy is available at the proxy host as <host>:<port>/<source>, e.g. docker.io => proxy.example.com/docker.io

If image proxy authentication is used, please configure globally using [pull secret](#pull-secret)

## Pull secret

Configures global pull-secret to be used by kubelet for accessing image registries, e.g. openshift repo, image proxy, custom git repo.

|parameter|default|type|description|
|---|---|---|---|
|.pullSecret.enabled|true|boolean|if enabled, creates external secret to manage secret pull-secret in namespace openshift-config|
|.pullSecret.vaultKey|cluster-config|string|vault path to get property containing pull secret from|
|.pullSecret.vaultProperty|pull-secret|string|property of vaultKey containing pull-secret|

Pull-secret is "downloaded" from Vault using default cluster secret store based external secret pointing to `<apc-global-overrides.vaultKVmountPlatform>/<apc-global-overrides.environmentShort>/<.pullSecret.vaultKey>/<.pullSecret.vaultProperty>`, e.g. `apc-platform/h/cluster-config/pull-secret`.

Vault property should contain docker configs auth section to be applied to the cluster, e.g.

```json
{
  "auths": {
    "disabled.cloud.openshift.com": {
      "auth": "<redacted>",
      "email": "janko.hrasko@example.com"
    },
    "registry.connect.redhat.com": {
      "auth": "<redacted>",
      "email": "janko.hrasko@example.com"
    },
    "registry.redhat.io": {
      "auth": "<redacted>",
      "email": "janko.hrasko@example.com"
    },
    "quay.example.com/docker.io": {
      "auth": "<redacted>",
      "email": ""
    },
    "quay.example.com/quay.io": {
      "auth": "<redacted>",
      "email": ""
    },
    "quay.example.com/ghcr.io": {
      "auth": "<redacted>",
      "email": ""
    },
    "quay.example.com/registry.connect.redhat.com": {
      "auth": "<redacted>",
      "email": ""
    },
    "quay.example.com/registry.redhat.io": {
      "auth": "<redacted>",
      "email": ""
    },
    "gitlab.example.com:5050": {
      "auth": "<redacted>"
    }
  }
}
```

> [!NOTE]  
> Please use only fields, required for authentication = `email` (usually empty) and `auth` containing token

> [!WARNING]  
> The pull-secret must always include credentials to `registry.redhat.io`, otherwise cluster won't be able to pull cluster critical images and will stop working!

## Oauth

Configuration of identity providers for your OpenShift cluster.

### IdentityProviders

The oauth.identityProviders  allows you to define and deploy identity provider settings for OpenShift as Kubernetes resources:
- config.openshift.io/v1/oauth/config - set identity providers in OpenShift built-in OAuth server
  - except following entries:
    - identityProvider.ldap|openID.ca - where CA is injected from configmap
- configMap - cabundle for identity provider integration
- secret 
    - required sensitive information ( for example bind password, openID.clientSecret ) for identity provider integration
    - secret is sync from Vault using external secret operator from path {{ vaultKVmountPlatform }}/{{ environmentShort }}/openshift-config/oauth/identityProvider/{{ idpSecret }}, where
        - vaultKVmountPlatform - mount point for platform secrets in vault apc-platform
        - environmentShort - 1st character of environment, e.g. p for prod, h for hub, d for dev, t for test
        - idpSecret - name of secret for identity provider  identityProviders
        - details for type / property name can be found in [](./templates/externalsecrets-oauth.yaml)
    - secret must be available in Vault, created in Vault manually 


### Configuration for Oauth

| Parameter         | Description                                                                        | Default   | Example |
|-------------------|------------------------------------------------------------------------------------|-----------|-----------|
| `oauth.dentityProviders`       | List of identity provider configs, where identity providers is defined according to [Redhat documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/authentication_and_authorization/understanding-identity-provider)    | `[]` |  [values.example.yaml](values.example.yaml) |
| `oauth.templates` | CA bundle to trust identity provider, see also [apc-global-overrides]() | ~ | ~ |
| `oauth.tokenConfig` | CA bundle to trust identity provider, see also [apc-global-overrides]() | ~ | ~ |
| `services.externalSecretsOperator.defaultClusterSecretStore`| cluster secret store for ESO, see also [apc-global-overrides](https://github.com/gr8it/charts-openshift/tree/main/charts/apc-global-overrides) | vault-hub-secret-store | vault-hub-secret-store |
| `environmentShort` | usually 1st character of environment, e.g. p for prod, h for hub, d for dev, t for test, [apc-global-overrides](https://github.com/gr8it/charts-openshift/tree/main/charts/apc-global-overrides)  | ~ | d  |
| `vaultKVmountPlatform` | mount point for platform secrets in vault apc-platform | apc-platform  | apc-platform  |
| `caCertificates.caCrt` | CA bundle to trust identity provider, see also [apc-global-overrides](https://github.com/gr8it/charts-openshift/tree/main/charts/apc-global-overrides) | ~ | ~ |

