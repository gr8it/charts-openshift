# Crossplane Keycloak Provider bootstrap

Component bootstraps Crossplane Keycloak provider using an admin account.

## Prerequisites

- admin user for realm provisioning (created in **master** realm)
- admin user credentials stored in Vault

### Admin user account

- login to Keycloak using initial admin credentials (secret keycloak-initial-admin)
- navigate to **master** realm
- create a local user
  - name: keycloak-provisioning
  - email verified: true
  - add email: \<keycloak-provisioning-apps@example.com>
  - add name: keycloak
  - add surname: provisioning
- set credentials in Credentials

> [!NOTE]  
> unset `temporary` flag for credentials to persist the credentials indefinitely!

- add admin realm role in Role mapping

### Vault

Store admin user credentials in Vault:

\<vaultKVmountPlatform>/\<environmentShort>/keycloak/<realm>/provisioning, e.g. apc-platform/d/keycloak/appDev/provisioning for Keycloak on dev

With keys username / password holding respective credentials.

## Alternative approaches

- use an ACM policy for automation like in crossplane-vault-provider-bootstrap
  - use keycloak-initial-admin secret to create an provisioning user in keycloak, and change provider config to use the new user
  - the difference here is that Vault provider was installed on all clusters, where as this one is targeting only the cluster with keycloak
    - note: both policy and keycloak are on hub cluster
