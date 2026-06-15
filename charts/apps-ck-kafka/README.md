# APC Kafka

This chart creates a Strimzi Kafka instance:

- Kafka
  - (optional) HA configuration using KRaft
  - default endpoint 9093 with SASL SCRAM-SHA-512 Authentication
    - uses certificates provided by Vault
  - simple authorization enabled
  - enabled entity operator
    - creates topics
    - creates users
- monitoring is realized using Podmonitor and Prometheusrules
- backup is done by OADP using standard schedule
- with Kafbat Kafka GUI via kafka-ui dependency
  - authenticated using openshift oauth proxy with subject access review (sar) requiring read privilege for the created kafka resource 

For configuration options see <values.yaml>, or <values.small.example.yaml> / <values.large.example.yaml> (HA).

## Assumptions

- cert-manager installed with default issuer configured used to secure the Kafka cluster
- trust-manager configured with ca bundle available at ca-cert-bundle configMap
- external-secrets installed used for creation of kafka UI cookie secret

## Kafka UI

- external secret is used to generate cookie secret

## Kafka Mirror support

Kafka mirroring with use of Kafka Mirrormaker2 is possible now. Kafka Mirromaker2 setup is covered in [separate helm](../apps-ck-kafka-mm2/README.md) chart.  
Mirror instancies (source and target) are deployed via this helm chart. Primary configuration is done via the component values of the source kafka instance. Users (except the kafka superuser) and topics have to be the same for both kafka instances. Only very little configuraiton is needed for the target instance.  

### Component configuration

For the target kafka instance to use configuration from source kafka instance use the ```upstreamConfig``` option in component configuration in GitOps versions configuration.  

Example configuration for target kafka instance:  

```yaml
  apps-ck-kafka-mirror:
    render:
      chart: gr8it-openshift/apps-ck-kafka
      chartVersion: "1.3.0"
    destination:
      namespace: ck-kafka-mirror
    managedNamespaceMetadata:
      labels:
        apc.namespace.type: platform
    syncOptions:
      - CreateNamespace=true
    upstreamConfig: apps-ck-kafka
```

### Mirror configuration  

Configuraiton is specified in component values under ```.Values.mirror```

| option | value | source instance | target instance | description |
|--------|-------|-----------------|-----------------|-------------|
| enabled | true/false | true      | true            | Instances deployed for mirror setup. |
| primary | true/false | true      | false           | Specify if the instance is source (primary) kafka instance |
| primaryKafka | string | not specified | name of the primary kafka instance | Defines the name of primary kafka instance |

### Failover management

Source (primary) kafka instance is exposed via the k8s service of type ExternalName. This service is configured to redicert the traffic to service of source (primary) kafka instance. In case of failover switch the synchronization of the applicaiton in APC Gitops have to be disabled and service have to be manualy updated to point to service of target kafka instance.  
This is place for improvment in future development.  

<details>

<summary>Example of failover swtch </summary>

Failover service pointing to source/primary kafka instance:  

```yaml
apiVersion: v1
kind: Service
metadata:
  ...
  ...
  name: ck-kafka-bootstrap
  namespace: ck-kafka
spec:
  externalName: ck-kafka-kafka-bootstrap.ck-kafka.svc.cluster.local
  sessionAffinity: None
  type: ExternalName
status:
  loadBalancer: {}
```

Failover service pointing to source/primary kafka instance:  

```yaml
apiVersion: v1
kind: Service
metadata:
  ...
  ...
  name: ck-kafka-bootstrap
  namespace: ck-kafka
spec:
  externalName: ck-kafka-mirror-kafka-bootstrap.ck-kafka-mirror.svc.cluster.local
  sessionAffinity: None
  type: ExternalName
status:
  loadBalancer: {}
```

</details>


## TODO

- Kafka monitoring
  - prometheus rules review <https://github.com/search?q=repo%3Astrimzi%2Fstrimzi-kafka-operator%20prometheusrule&type=code>
  - dashboards <https://github.com/strimzi/strimzi-kafka-operator/tree/0.49.1/examples/metrics/grafana-dashboards>
  - KSM <https://github.com/strimzi/strimzi-kafka-operator/blob/b3ed3ac0f60eee2b6b198fb7fd7f6d68c343b4c7/examples/metrics/kube-state-metrics/README.md>
  - entity operator
  - ..
- Kafka external access -> define defaults, e.g. service of type loadbalancer
- Backup through Kafka Connect
- kafka-ui
  - integrate metrics in brokers.metrics GUI
- user credentials secret synchronization to target namespace, e.g. eds?
- set jvmOptions in Kafka CR (commented out) ? Should be set optimally
