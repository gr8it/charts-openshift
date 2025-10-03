# External Secrets Operator Configuration

Creates:

- platform access to Vault
  - cluster secret store
  - policy with access to apc-platform/\<env>
  - auth delegator cluster role binding for the external secrets operator service account used for auth
- application access to Vault
  - kyverno policy to create access to Vault per app namespace
    - secret store
    - service account
    - auth delegator cluster role binding for the SA
    - vault auth backend role crated in Vault using Crossplane 
  - kyverno policy to create templated policy
    - usage of kyverno policy is required because vault templated policies use accessor names, which is read from the backend CR on the cluster!
  - cluster roles to add required kyverno policies
