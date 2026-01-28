# Keycloak

Helm chart installs:

- Keycloak instance
- CNPG PostgreSQL instance
- S3 backup storage using NooBaa
- CNPG scheduled backup
- ca certificates for trust
- routes to access Keycloak GUI (admin / login)
- servicemonitor for the Keycloak instance

## Configuration examples

See [example-configuration](./example-configuration/) for Keycloak configuration examples using Crossplane Keycloak Provider.

> [!NOTE]  
> ultimately these should be included in the template dir and provisioned based on the environment values file (which is out of scope of the current task)

## TODO

- make example-configuration configurable and include in the template to be provisioned based on the environment values file
