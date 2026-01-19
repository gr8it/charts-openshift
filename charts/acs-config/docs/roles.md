# ACS roles


## Auditor Custom Permission Set and Role


- [reference PrivateCloud documentation](https://github.com/gr8it/privatecloud/blob/develop/docs/openshift/security/acs-config-sso.md#custom-permission-set-and-role)

Custom permission set - Auditor:

- create new permission set and define for it access level Read Access for ALL ACS resources
- ![auditor permission set](img/acs-auditor-permission-set.png)

Custom role - Auditor:

- create new role, select permission set "Auditor" and Access Scope "Unrestricted"
- ![auditor role](img/acs-auditor-role.png)

Assign role to group:

- select authentication provider and assign Auditor role to select group
- ![auditor assigment](img/acs-auditor-role-assignment.png)

## Role assigments

- for authentication provider OCPhub01IDP set role assignment to following
![OCPhub01IDP roles assign](img/OCPhub01IDP-roles-assign.png)
