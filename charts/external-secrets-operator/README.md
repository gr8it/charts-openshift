# external-secrets-operator

Source repository for this operator: https://github.com/external-secrets/external-secrets

## 🐞 Bug Rendering ServiceMonitor object

### Description

Actual version of ESO (v0.11.0) needs for rendering serviceMonitor object apiVersion monitoring.coreos.com/v1 in .Capabilities.APIVersions. This apiVersion was added into list of apiVersions in environments. apiVersion can be deleted from the list after upgrade ESO to version v0.20.1.
