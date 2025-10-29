# identityProviders-configuration Helm Chart

This Helm chart manages the configuration of identity providers for your OpenShift cluster.

## Overview

The `identityProviders-configuration` chart allows you to define and deploy identity provider settings for OpenShift as Kubernetes resources:
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
        - details for type / property name can be found in [01-secret-idp.yaml](./templates/01-secret-idp.yaml)
    - secret must be available in Vault, created in Vault manually 


## Configuration

| Parameter         | Description                                                                        | Default   | Example |
|-------------------|------------------------------------------------------------------------------------|-----------|-----------|
| `identityProviders`       | List of identity provider configs, where identity providers is defined according to [Redhat documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/authentication_and_authorization/understanding-identity-provider)    | `[]` |  [values.example.yaml](values.example.yaml) |
| `services.externalSecretsOperator.defaultClusterSecretStore`| cluster secret store for ESO, see also [apc-global-overrides](https://github.com/gr8it/charts-openshift/tree/main/charts/apc-global-overrides) | vault-hub-secret-store | vault-hub-secret-store |
| `environmentShort` | usually 1st character of environment, e.g. p for prod, h for hub, d for dev, t for test, [apc-global-overrides](https://github.com/gr8it/charts-openshift/tree/main/charts/apc-global-overrides)  | ~ | d  |
| `vaultKVmountPlatform` | mount point for platform secrets in vault apc-platform | apc-platform  | apc-platform  |
| `caCertificates.caCrt` | CA bundle to trust identity provider, see also [apc-global-overrides](https://github.com/gr8it/charts-openshift/tree/main/charts/apc-global-overrides) | ~ | ~ |



You can customize values by creating a `values.yaml` file:

```yaml
identityProviders:
  - ldap:
      attributes:
        email:
          - mail
        id:
          - sAMAccountName
        name:
          - cn
        preferredUsername:
          - sAMAccountName
      bindDN: 'CN=1BA-SA-APC-OCP_AD_r,OU=T1-Service Accounts,OU=Tier 1,OU=Admin Tier Model,DC=example,DC=com'
      bindPassword:
        name: ad-ldap-bind-secret
      insecure: false
      url: 'ldaps://example.com/DC=example,DC=com?sAMAccountName?sub?(objectClass=person)'
    mappingMethod: claim
    name: Prihlásenie pre používateľov APC
    type: LDAP
  - name: APC LDAP
    mappingMethod: claim 
    type: LDAP
    ldap:
      attributes:
        id: 
        - dn
        email: 
        - mail
        name: 
        - cn
        preferredUsername: 
        - uid
      bindDN: cn=OCP HUB01,ou=Technical-Accounts,ou=hub,ou=Project-Users,dc=example,dc=com
      bindPassword: 
        name: comm-ldap-bind-secret
      insecure: false
      url: ldaps://ldap.comm.apc.example.com/OU=Project-Users,dc=example,dc=com?uid
  - name: oidcidp
    mappingMethod: claim
    type: OpenID
    openID:
      clientID: ...
      clientSecret:
        name: idp-secret
        name: ca-config-map
      extraScopes:
      - email
      - profile
      extraAuthorizeParameters:
        include_granted_scopes: "true"
      claims:
        preferredUsername:
        - preferred_username
        - email
        name:
        - nickname
        - given_name
        - name
        email:
        - custom_email_claim
        - email
        groups:
        - groups
      issuer: https://www.idp-issuer.com
```


## Maintainers
- [Peter Sedlak](mailto:peter.sedlak@aspecta.sk)
