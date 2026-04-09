# APC Vault configuration

This repository contains basic configuration for APC Vault deployment in HUB. The configuration is done by Crossplane. Further configuration will be done in vault-config2 Helm Chart.

## Requirements

- Crossplane deployed in HUB cluster.
- Crossplane vault provider deployed and configured in HUB cluster.
- PKI issuer created (manual intervention)

## Configuration process

Following Vault configuration can be created/managed by the helm chart:

- secret engines (kv-2, pki, etc...)
- roles for PKI issuer
- Vault policies
- auth methods
- audit

## Detailed configuration

### Secret engines 

- are defined in `values.yaml`
- structure:

```yaml
secretEngines:
  <mount_path>: 
    type: <type of the engine>
```

### PKI issuer roles

- chart will create one role for the cluster the chart is deployed to (hub01 for example)
- additional roles can be specified in component values at `pkiIssuer.pkiRoles.roles`
- actual implementation configures default settings for created roles; defaults are specified at `pkiIssuer.pkiRoles.defaultSettings`
- default settings can be adjusted in component values

<details>

<summary> additional issuer role example </summary>

```yaml
pkiIssuer:
  issuerName: APCCAi-Sp2
  pkiRoles:
    roles:
      apc:
        name: apc.socpoist.sk
        backend: pki
        defaultPkiPolicy: true
        settings:
          allowBareDomains: false
        allowedDomains:
          - "apc.socpoist.sk"
      hw:
        name: hw.apc.socpoist.sk
        backend: pki
        defaultPkiPolicy: true
        settings:
          allowSubdomains: false
          allowGlobDomains: true
          allowWildcardCertificates: false
        allowedDomains:
          - "*.hw.apc.socpoist.sk"
          - SR-BA-xAPC1-P1HM01i
          - SR-BA-xAPC1-P1HM02i
          - SR-BA-xAPC1-P1HW01i
          - SR-BA-xAPC1-P1HW02i
          - SR-BA-xAPC1-P1PW01i
          - SR-BA-xAPC1-P1PW02i
          - SR-BA-xAPC1-P1TW01i
          - SR-BA-xAPC1-P1DW01i
          - SR-BA-xAPC1-P2HM03i
          - SR-BA-xAPC1-P2HW03i
          - SR-BA-xAPC1-P2PW03i
          - SR-BA-xAPC1-P2PW04i
          - SR-BA-xAPC1-P2TW02i
          - SR-BA-xAPC1-P2TW03i
          - SR-BA-xAPC1-P2DW02i
          - SR-BA-xAPC1-P2DW03i
          - SR-BA-xAPC1XCA-P11
          - SR-BA-wAPC1-P1BKP1i
      cloud:
        name: cloud.socpoist.sk
        backend: pki
        defaultPkiPolicy: true
        allowedDomains:
          - cloud.socpoist.sk
          - svc
          - cluster.local
```

</details>

### Vault policies

- you can create default PKI policy by specifying `pkiIssuer.pkiRoles.roles.<role_name>.defaultPkiPolicy: true`
- other policies are specified in values under `policies.customPolicies.<policy_name>.rules`
- if policy holds hardcoded domain identification or any specific value it should be placed in component values
- rules are standard vault policy definition


### Auth methods

- enable auth methods
- structure:

```yaml
authMethods:
  <auth_type>:
    - name: <name of the authMethod>
      enable: [true|false]
```

### Audit

- enable audit to stdout

## TODO

- Review the possibility to break the `pki-spoke-cluster-issuer` policy for each of the spoke cluster separately.
