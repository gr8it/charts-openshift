# APC Vault bootstrap

This repository contains helm chart with custom manifests which will deploy Vault instance, initialize monitoring and backup. The deployment is done partially manually and partially via the APC Gitops framework. The afterwards Vault configuration is executed separately via another helm chart once the Vault instance is deployed.  

## Deployment process overview

Due to certain configuration of APC Vault instance the whole deployment cannot be done automatically and some parts have to be done manually.  

Deployment process steps:  

- create namespace (manual step)
- [create certificate and secret](./scripts/README.md) with certificate (manual step)
- create secret with autounseal token (manual step)
- deploy vault instance via APC Gitops

### Requirements

For successful Vault deployment following requirements have to be met:  

- [Bastion vault have to be deployed](https://github.com/gr8it/vault/tree/develop) with autounseal functionality enable (transit secret engine enabled)
- Available intermediate certificate from organization for which the vault will be deployed  

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

## Initialization process

Initialization process is done via the k8s jobs and is split into two parts:

### Vault initialization

- will check if vault is not already initialized and if not will initialize vault and store unseal and root token to secret init-log-$(date +%Y%m%d). All the tokens are stored under relevant keys in the secret.
- enable the audit logging

### Backup initialization

- check if backup is not already in place and if not
- in vault it will enable approle, create snapshot policy and create specific snapshot approle
- in k8s it will create secret for snapshot-agent and for OBC used for backup  

> [!IMPORTANT]  
> Backup secrets for snapshot agent and OBC credentials are not managed by argo!!!
