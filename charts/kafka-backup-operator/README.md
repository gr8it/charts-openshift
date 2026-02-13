# PoC Kafka Backup Operator

This is a PoC helm chart for <https://kafkabackup.com/operator/>, which is based on:

- [kafka backup helm chart](https://github.com/osodevops/helm-charts/tree/main/charts/kafka-backup-operator)
- [kafka backup](https://github.com/osodevops/kafka-backup)

**THIS IS A WORK IN PROGRESS**

- Kafka Backup is rather new = first commit 30.11.2025
- one (1) issue only in the kafka-backup repo!
  - meaning although the product as such seems quite nice, it is missing polish of more mature products
    - the documentation and implementation differ, e.g.
      - missing retention parameter in kafkabackup CR
      - helm repo url (correct in helm chart repo)
    - logging is not helpful
    - doesn't work in Openshift on several places
      - operator = fixed by specifying user / group = null
      - local volume backup = permission denied
    - using s3 ends with no topics defined with *, or specific topic defined

## TODO

- make it work
- HA
- add resource requests / limits spec
- add security context
- monitoring + alerting
- specify backup tiers https://kafkabackup.com/operator/guides/scheduled-backups#multi-tier-backup-strategy
