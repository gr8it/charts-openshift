# APC roles

## Overview

This helm chart creates clusterRoleBindings and roleBindings between specific cluster wide roles, namespace scoped roles and specific user groups defined in identity provider.

## Detailed description

The rolebindings allow users defined in IdP groups to access specific cluster information.

There are two sources of user identieis:

- Active Direcotry
  - where customer users are defined
  - group format (all in uppercase): "\<adGroupPrefix>-\<environmentShort> \<group>"
- LDAP where
  - where delivery users are defined
  - group format (all in lower case): "\<ldapGroupPrefix>\_\<group>\_\<environment>", except the `admins` ClusterRoleBinding group which uses "\<ldapAdminsGroupPrefix>\_\<environment>"

Mapping between the user groups and roles, clusterRoles are defined in [values.yaml](./values.yaml).

By default, the LDAP `admins` group is bound to the `cluster-admin` role. Its binding name uses `ldapAdminsGroupPrefix`, and its subject uses that prefix with the environment name.

Set `projectRequestMessage` to customize the message shown when a user is denied a project request. It is empty by default, so the chart leaves the cluster's existing message unchanged.
