# Crossplane Vault Provider bootstrap

Due to missing functionality (kubernetes auth with mount point other than kubernetes) of Crossplane Vault provider, the component was changed to work with tokens only! Waiting for PR <https://github.com/upbound/provider-vault/pull/93> to be merged.

[V2](../crossplane-vault-provider-bootstrap-v2/) of this provider keeps the to be functionality..

> [!WARNING]  
> As the chart is implemented as an ACM policy, meaning the component has to be installed on the hub cluster only!

The chart is implemented as an ACM policy and does following:

- Starts Kubernetes Auth Setup
  - Provisions the Vault CRs (Auth Backend, AuthBackendConfig, AuthBackendRole, Policy) required for Kubernetes Auth
  - Waits for the Token secret to be created - see [Token Secret generation](#token-secret-generation)
- Checks if Kubernetes Auth CRs provisioned
  - All CRs created in the Kubernetes Auth Setup must by in Sync & Ready status
  - If Kube Auth CRs are provisioned
    - Sets Vault Provider to use Kubernetes auth
    - Removes the Token secret

## Token Secret generation

1) Extend the maximum validity of a token temporarily (BAD PRACTICE)

```bash
vault write sys/auth/token/tune max_lease_ttl=9000h
```

1) create a token using `vault token create -ttl=365d -explicit-max-ttl=365d --renewable=false`

   ```bash
   Key                  Value
   ---                  -----
   token                hvs.CAESFrBiuq2OJ4J1Vcr6-tiEyY0kZVeDQzTXh9fpiBVt1BBmnxEFWGh4KHGh2cy42R2IGmpsTXBOZ0xJYkZuQ25kemg
   token_accessor       wpVWsKklJhRTIEE374JbeyF7
   token_duration       8760h
   token_renewable      false
   token_policies       ["admin" "default"]
   identity_policies    []
   policies             ["admin" "default"]
   ```

> [!NOTE]  
> Policies of the creating (admin) user will be reused by default. Or specify policy to be used using `-policy <policy-name>, e.g. admin`

> [!WARNING]  
> Do not create using root token, as it would create a long lived root token copy!!!

1) Change the maximum validity of a token back

```bash
vault write sys/auth/token/tune max_lease_ttl=768h
```

1) Copy the token from the `token` parameter

1) Store the token to a file:

   ```bash
   cat <<EOF > /tmp/vault-credentials
   {
     "token_name": "admin",
     "token": "<token>"
   }
   EOF
   ```

1) Create the Token secret on MANAGED CLUSTER(s)

   ```bash
   kubectl create secret generic <secret-name> -n apc-crossplane-system --from-file=credentials=/tmp/vault-credentials
   rm -f /tmp/vault-credentials
   ```

   Where secret-name is generated from the Vault name global service parameter suffixed with `-token`, e.g.:

> [!NOTE]  
> The Token secret to be used hint is available in the ACM GUI -> Governance -> Policies -> crossplane-vault-provider-bootstrap -> Results -> *-providerconfig-token-auth policy Message:
>
> ![Token Auth Check hint](images/token-secret-policy.png)

### Helm Chart Parameters

|Parameter|Default|Description|
|---|---|---|
|cluster.name|`.global.apc.cluster.name`|Cluster name to be used instead of local-cluster|
|caCertificates|`.global.apc.caCertificates`|PEM encoded CA cert to trust when Vault makes contact to the Kube API|
|services.vault.url|`.global.apc.services.vault.url`|Vault URL|
|services.vault.name|`.global.apc.services.vault.name`|Vault Name|
|services.vault.kubeVaultProviderConfigName|`.global.apc.services.vault.kubeVaultProviderConfigName`|Name of the Vault provider config to create|
|vaultKubeAuthMountPath|-|For testing only as it only support 1 cluster only !!! => Kube auth mount path in Vault |
|vaultKubernetesRole|crossplane|Kubernetes role in Vault for Crossplane to use|
|crossplaneNamespace|apc-crossplane-system|Namespace where Crossplane is installed, and configurations are created|

## Removal

- remove the policy.policy.open-cluster-management.io
- remove the kube auth from Vault

### Bootstrap

- to run the bootstrap process again, set the particular Provider Config credentials source to `Secret`, e.g.

```bash
kubectl patch providerconfig vault.lab.gr8it.cloud --type="merge" -p '{"spec": {"credentials":{"source": "Secret"}}}'
```

## TODO

- Monitoring Governance pravidiel!? Ak su non-compliant, mal by prist alarm ..
