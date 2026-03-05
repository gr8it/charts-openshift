# APC Vault configuration

This repository contains basic configuration for APC Vault deployment in HUB. The configuration is done by Crossplane. Further configuration will be done in vault-config2 Helm Chart.

## Requirements

- Crossplane deployed in HUB cluster.
- Crossplane vault provider deployed and configured in HUB cluster.
- PKI issuer created (manual intervention)

## Configuration process

Following Vault configuration can be created/managed by the helm chart:

- enable secret engines (kv-2, pki, etc...)
- create roles for PKI issuer
- create Vault policies 
- enable auth methods 

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

- configuration placeholder in `values.yaml` at `pkiIssuers.pkiRoles.roles`, main configuration done via the components values
- actual implementation configure default settings for created roles, defaults are specified at `pkiIssuers.pkiRoles.defaltSettings`
- for now only default settings are prepared

<details>

<summary> Issuer role example </summary>

```yaml
pkiIssuers:
  issuerName: APCCAi-Sp2
  pkiRoles:
    roles:
      dev01:
        name: apps.dev01.{{ .Values.global.apc.cluster.domain }}
        backend: pki # mount path of pki secret engine
        allowedDomains:
          - apps.dev01.{{ .Values.global.apc.cluster.appsDomain }}
          - cluster.local
          - svc
          - service.dev01.{{ .Values.global.apc.cluster.baseDomain }}
      test01:
        name: apps.test01.{{ .Values.global.apc.cluster.domain }}
        backend: pki # mount path of pki secret engine
        allowedDomains:
          - apps.test01.{{ .Values.global.apc.cluster.appsDomain }}
          - cluster.local
          - svc
          - service.test01.{{ .Values.global.apc.cluster.baseDomain }}
      prod01:
        name: apps.prod01.{{ .Values.global.apc.cluster.baseDomain }}
        backend: pki # mount path of pki secret engine
        allowedDomains:
          - apps.prod01.{{ .Values.global.apc.cluster.baseDomain }}
          - cluster.local
          - svc
          - service.prod01.{{ .Values.global.apc.cluster.baseDomain }}
      hub01:
        name: apps.hub01.{{ .Values.global.apc.cluster.baseDomain }}
        backend: pki # mount path of pki secret engine
        allowedDomains:
          - apps.hub01.{{ .Values.global.apc.cluster.baseDomain }}
          - cluster.local
          - svc
          - service.hub01.{{ .Values.global.apc.cluster.baseDomain }}
```

</details>

### Vault policies

- configuration done under `policies.<policy_name>.rules`
- rules are standard vault policy definition

### Auth methods

- enable auth methods
- structure:

```yaml
authMethods:
  <auth_type>:
    - name: <name of the authMethod>
    - enabled: [true|false]
```
