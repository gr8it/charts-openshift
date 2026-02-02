# APC Vault bootstrap

This repository contains helm chart with custom manifests which will deploy Vault instance, set up monitoring and backup. The deployment is done partially manually and partially via the APC Gitops framwerok. The afterwards Vault configuration is executed separately via another helm chart once the Vault instance is deployed.  

## Deployment process overwiev

Due to certain configuration of APC Vault instance the whole deployment cannot be done automatically and some parts have to be done manually.  

Deployment process steps:  

- create namespace (manual step)
- [create certificate and secret](./scripts/README.md) with certificate (manual step)
- create secret with autounseal token (manual step)
- deploy vault instance via APC Gitops

### Reguirements

For successful Vault deployment following requirements have to be met:  

- [Bastion vault have to be deployed](https://github.com/gr8it/vault/tree/develop) with autounseal functionality enable (transit secret engine enabled)
- Available intermediate certficate from organization for which the vault will be deployed  

### Autounseal token

Autonseal token have to be stored in secretd placed in namespace where vault will be deployed.  

Secret example:

```bash
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: vault-autounseal-token
  namespace: apc-vault
type: Opaque
stringData:
  VAULT_TOKEN: <!!! get token from bastion with 'vault token create -orphan -policy="hub-unseal" -period=24h -field=token' !!!>
EOF
```
