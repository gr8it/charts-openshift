# RBAC roles Helm Chart

This repository holds configuration of OCP role aggregation rules, APC roles and the role binding settings which are applied in application namespaces by kyverno policy.  

## Overview

For OCP roles the configuration sets to which APC roles they will aggregate to. In actual implementation the workaround is implemented for [RH issue](https://access.redhat.com/support/cases/#/case/04259235) while the OCP roles are managed by ArgoCD.  

## Configuration

OCP and APC roles are defined in [```values.yaml```](values.yaml) file under key ```defaultRoles``` and can be overriden for specific environment defined under key ```rolesOverride.<environment>```. The overrides are defined in helper functions.  

## Todo

- refactor [```app-project-rolebindings.yaml```](./templates/app-project-rolebindings.yaml) that Kyverno context / templating is replaced with helm templating
- regactor the [```values.yaml```](values.yaml) in the way that values under key ```groupSuffix``` are placed under ```defaultRoles``` key, helpers function and role templating will have to be udpated as well
- once the [RH issue](https://access.redhat.com/support/cases/#/case/04259235) is resolver, remove the workaround in [```ocp-role.yaml```](./templates/ocp-role.yaml)