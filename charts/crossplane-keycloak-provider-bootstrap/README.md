# Crossplane Keycloak Provider bootstrap

**WIP** **WIP** **WIP** **WIP** **WIP**

Configures provider using already existing secret, e.g.:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-credentials
  namespace: apc-crossplane-system
  labels: 
    type: provider-credentials
type: Opaque
stringData:
  credentials: |
    {
      "client_id":"admin-cli",
      "username": "provisioning",
      "password": "<redacted>",
      "url": "https://keycloak.apps.example.com",
      "base_path": "/auth",
      "realm": "apps"
    }
```

- the main question is, whether to include some manual steps
  - login to keycloak using keycloak-initial-admin secret, create a provisioning user and than create a providerconfig secret with provisioning credentials
- or use an ACM policy for automation like in crossplane-vault-provider-bootstrap
  - use keycloak-initial-admin secret to create an provisioning user in keycloak, and change provider config to use the new user
  - the difference here is that Vault provider was installed on all clusters, where as this one is targeting only the cluster with keycloak
    - note: both policy and keycloak are on hub cluster

## Manual steps

............. describe manual steps required to create "provisioning" user per cluster and where to store it ............. 
