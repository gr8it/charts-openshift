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
