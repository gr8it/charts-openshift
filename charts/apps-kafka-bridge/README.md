# Kafka Bridge

This helm chart deploys [Kafka Bridges](https://strimzi.io/docs/bridge/latest/) which serves as a HTTP Bridge to make HTTP requests to a Kafka cluster. The kafka bridge itself is accessible via the HTTPS endpoint with authentication support via the oauth-proxy supporting Openshift authentication.  

## APC Implementation

Actual implementation is serving one customer/project support ( 1:1 - project:bridge), however the chart is prepared for scenario where one Kafka Bridge can serve for multiple projects.  

APC implementation details:

- deploys in ck-kafka namespace
- communication to openshift route via HTTPS
- if application SA is not specified the ```apps-kafka-bridge-<app-ns>-account-access``` SA is used for authentication  
- CA for HTTPS is in ca-cert-bundle secret under key ca-bundle.crt

## Configuration

For actual implementation minimal configuration is required in component values.

Component values:

- ```bridgeApps```: list of namespaces from which the kafka bridge is accessed, in actual implementation only one
- ```bridgeApps.<app-ns>.appSa```: application serviceaccount, if specified the SA is used to generate the SA token used for openshift authentication
- ```kafkaBridge.user```: user used for cummunication from kafka bridge to kafta cluster

Example component configuration:

```yaml
bridgeApps:
  ekp:
    networkPolicy:
      enabled: false
    appSa: ~
kafkaBridge:
  user: ekp
```

Default values:
(only most important, for full list of options consult [values.yaml](values.yaml))

- ```kafkaBridge.bootstrapServers```: service pointing to kafka cluster

## Usage

- create SA token for authentication  

```oc create token apps-kafka-bridge-ekp-account-access -n ekp```
 
- [long-lived token](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#create-token) can be used, but if application SA is used [provisioned volume](https://kubernetes.io/docs/concepts/storage/projected-volumes/#serviceaccounttoken) with token can be used
- send message to topic

```bash
curl -vv --cacert /tmp/ca.crt -H "Authorization: Bearer <TOKEN" \
-X POST  https://apps-kafka-bridge-ekp.apps.test01.cloud.socpoist.sk/topics/socpoist.sp.bpm.evt.case-state.v1 \
  -H "Content-Type: application/vnd.kafka.json.v2+json" \
  -d '{
    "records":[
      {"value":{"test":"testing tls with auth"}}
    ]
  }'

## Note on future updates

Helm chart is prepared for use case where one kafka bridge can serve multiple projects as HTTPS API interface to kafka instance. If there will be requirement for such an use case following changes have to be implemented:  

- create kafka user with wider kafka priviledges which will be used for communication from kafka bridge to kafka cluster
- create unique names for k8s objects:  

  - [NetworkPolicy](./templates/NetworkPolicy.yaml)
  - [RoleBinding](./templates/RoleBinding.yaml)
  - [ServiceAccount](./templates/ServiceAccount-accountAccess.yaml)

- create separate ```--openshift-delegate-urls``` argument for oauth proxy in [Deployment](./templates/Deployment.yaml) pointing to correct endpoint used in kafka cluster
- rename the Helm chart and update Gitops naming and migrate the ArgoCD application to new one
