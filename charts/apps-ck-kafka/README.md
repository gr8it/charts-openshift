# APC Kafka

This chart creates a Strimzi Kafka instance:

- Kafka
  - (optional) HA configuration using KRaft
  - default endpoint 9093 with SASL SCRAM-SHA-512 Authentication
    - uses certificates provided by Vault
  - simple authorization enabled
  - users credentials are uploaded to Vault
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

Kafka mirroring with use of Kafka Mirrormaker2 is available. Kafka Mirromaker2 setup is covered in [separate helm](../apps-ck-kafka-mm2/README.md) chart.  
Mirror instances (source and target) are deployed via this helm chart. Primary configuration is done via the component values of the source kafka instance (also called upstreamComponent). Users (except the kafka superuser) and topics have to be the same for both kafka instances. Only very little configuraiton is needed for the target instance.  

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

| option | value | source (upstream) instance | target instance | description |
|--------|-------|-----------------|-----------------|-------------|
| enabled | true/false | true      | true            | Instances deployed for mirror setup. |
| upstreamComponent | string | name of the upstreamComponent | not specified | Defines the name of upstream kafka instance which holds the main configuration |
| activeService | string | service name | not specified | service fqdn of kafka instance which is active |

### Failover management

Source (primary) kafka instance is exposed via the k8s service of type ExternalName. This service is configured to redirect the traffic to broker service of source (upstream) kafka instance. In case of failover the ```activeService``` have to be reconfigured in upstreamComponent to point to broker service of target kafka instance and application have to be rerendered and configuration applied in APC Gitops.

### Failover scenario

In case of data disruption on source kafka instance perform following steps:

- stop the mirroring by setting the [```replica: 0```](../apps-ck-kafka-mm2/values.yaml#11) in kafka mirrormaker2 component
- reconfigure the ```activeService``` to point to target kafka instance
- in case that producers/consumers uses for connection the standard broker service of source kafka instance then they have do the reconfiguration to point connection to ```activeService``` or to service of the target kafka instance (not preffered)

### Failback scenario

If the servis is stabilized on the target kafka instance, the failback to originally source kafka instance is not directly necessary. Preferably new mirror connection is estabilished to the originally source kafka instance which will become the target one and original target kafka becomes source kafka instance for the actual mirroring.  
If the failback is desired then the [Failover scenario](#failover-scenario) can be applied and mirroring have to be once again reconfigured to enable the mirroring in correct way.

### Mirroring reconfiguration after failover

After the failover mirroring have to be reestabilished. This can be achieved with just to changing the type of source/target in [apps-ck-kafka-mm2 configuration](../apps-ck-kafka-mm2/values.yaml#25).  
If the mirroring is estabilished between two geographically divided clusters, its recommended to redeploy the mirrormaker2 instance next to the new target cluster.
  
> [!IMPORTANT]  
> Before reestabilishing the mirror connection the new target kafka instance have to be in functional and stabilized state with kafkatopics and kafkausers in place. The situation have to be the same as new mirroring is going to be configured.  
Also make sure the communication for the mirroring between the new source and target kafka instance is allowed by network policy.  

### Backup in mirroring scenario

Backup of kafka instance is enabled by default for the instance, however is configurable and is suggested that for the target kafka instance the backup is disabled and enabled only on the failover scenario. With this approach there are significant savings in storage requirements.  

> [!IMPORTANT]  
> After failover check the ```backup.enabled``` option in target kafka instance and if set to ```false``` change to ```true``` and apply the configuration.

## Kafka user management

With Kafka mirror support the user management is as follows:

- users defined in component configuration have in [KafkaUser](./templates/kafkausers.yaml#25) manifest defined secret with password, secret have the same name as user and have suffix ```-eso```
- secret is [synchronized](./templates/externalsecret-kusers.yaml) from vault isntance, the path is ```apc-platform/<env_short>/<upstreamComponent>/<username>```
- secret is generated and pushed to vault with use of [PushSecret](./templates/pushsecret.yaml) with setting of ```updatePolicy: IfNotExists``` which will prevent the secret override in the vault if that already exists there

By this approach if there is going to be deployed new pair of kafka instances for mirroring purpose, the first one will create users and push them to vault, sync them back for kafkauser usage and the second kafka instance will sync already created secrets from vault. 

> [!IMPORTANT]
> If kafka mirror is going to be configured against kafka instance with already created kafkausers with pregenerated passwords, those passwords have to be stored to vault prior the configuration, as the passwords can be overriden by the generated ones from vault.

### Password change

With actual kafka user management there is specific procedure for password reset if needed. Following steps have to be performed:

- delete the secret from vault
- force new pushsecret with ```oc annotate pushsecret <username> force-sync=$(date +%s) --overwrite```
- force secret synchronization from vault with ```oc annotate externalsecret <username> force-sync=$(date +%s) --overwrite```
- you can wait few moments or force the kafkauser reconciliation ```oc annotate kafkauser <username> strimzi.io/force-reconciliation="true" --overwrite```

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
