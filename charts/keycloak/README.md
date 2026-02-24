# Keycloak

Helm chart installs:

- Keycloak instance
- CNPG PostgreSQL instance
- S3 backup storage using NooBaa
- CNPG scheduled backup
- ca certificates for trust
- routes to access Keycloak GUI (admin / login)
- servicemonitor for the Keycloak instance

- identity provider if configured (using crossplane + ESO)
- authentication first broker flow without profile review

## Identity Provider Config

At IDP a client must be created:

- CONFIDENTIAL
- Standard Flow enabled
- Client scopes (keycloak-apc-dedicated) => Group Membership mapper => `groups` claim, Full group path

All groups used by clients of this Keycloak instance must be loaded in IDP per environment, i.e. groups `APC-<envshorName | upper>-CK-*`, e.g. `APC-D-CK-BPM-READER`

## Prerequisites

If identity provider is configured, client credentials should be available in Vault at `<apc-platform-kv>/<env-short-name>/keycloak/<realm>/identity-providers/<idp-name>/credentials` as keys `client-id` and `client-id`, e.g. `apc-platform/d/keycloak/AppDev/identity-providers/keycloak-oidc/credentials`

## Post installation

If identity provider is configured, modify `authnetication` -> `browser` flow -> `identity provider redirector` set `Default Identity Provider` to name of the IDP from .Values.identityProviders, e.g. keycloak-oidc.

See [TODO](#todo) for automation.

## Configuration examples

See [example-configuration](./example-configuration/) for Keycloak configuration examples using Crossplane Keycloak Provider.

> [!NOTE]  
> ultimately these should be included in the template dir and provisioned based on the environment values file (which is out of scope of the current task)

## TODO

- make example-configuration configurable and include in the template to be provisioned based on the environment values file
- modify authnetication browser flow `identity provider redirector` Default Identity Provider in code. Probably a new custom flow must be created, and bound as default.
