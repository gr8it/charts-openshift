# group-sync-config Helm Chart

This Helm chart deploys configuration resources for group synchronization in OpenShift.
Group sync operator and related custom resources are described by [group-sync-operatorm/redhat-cop/group-sync-operator)

- Note: Supports only [LDAP group sync](https://github.com/redhat-cop/group-sync-operator#ldap)


## Configuration

The following values can be set in `values.yaml` or via `--set` on the command line:

| Parameter                | Description                                 | Default |
|--------------------------|---------------------------------------------|---------|
| `vaultKVmountPlatform`   | HC Vault Mount for secrets, when secrets are provided from HC Vault with External Secret Operator, for more details see [vaultKVmountPlatform and HC Vault secrets info](#vaultkvmountplatform-and-hc-vault-secrets-info)   | apc-platform  |
| `caCertificates`         | CA Certificates to communicate securely to the Identity providers     | ~ |
| `groupSync`      | List of group sync, structure is similar to [CR](https://github.com/redhat-cop/group-sync-operator#ldap), with exception decribed in [#]          | ~ |

### vaultKVmountPlatform and HC Vault secrets info

- external secret operator syncs secrets from path {{ vaultKVmountPlatform }}/{{ environmentShort }}/{{ namespace }}/group-sync/{{ groupSync }}-{{ provider }}, where
    - vaultKVmountPlatform - mount point for platform secrets in vault apc-platform
    - environmentShort - 1st character of environment, e.g. p for prod, h for hub, d for dev, t for test
    - namespace - namespace where group-sync is deployed
    - groupSync - name for group sync CR
    - provider - name for provider in groupSyunc

###  groupSync value specification
- name - group sync CR name
- schedule - cron style expression - to regular synchronization events
- providers - list of providers
- providers[].name - provider name
- providers[].ldap - provider configuration according to [group sync operator](https://github.com/redhat-cop/group-sync-operator#ldap), except .ldap.ca, .ldap.credentialsSecret
- providers[].credentialsSecret - when bind username and password provided as helm input ( not suitable for production use case, recommendation is to use HC Vault Secrets)


## Example

[example-values.yaml](./example-values.yaml)


## Templates

This chart includes the following templates:
- `configmap-ca.yaml`: ConfigMaps for CA certificates
- `group-sync.yaml`: Main group sync configurations
- `secret-idp.yaml`: Secrets for identity provider

