# Kafka Production Deployment Guide

This guide walks through deploying the production-ready Kafka configuration step-by-step.

## Quick Start (5 minutes)

### 1. Prerequisites Check
```bash
# Verify Kubernetes cluster is accessible
kubectl cluster-info

# Check Strimzi operator is installed
kubectl get operatorgroup -n strimzi-kafka
kubectl get subscription strimzi-kafka-operator -n strimzi-kafka

# Verify storage provisioner exists
kubectl get storageclass
```

### 2. Deploy Kafka
```bash
# Create namespace
kubectl create namespace kafka

# Deploy with production defaults (3-node cluster, HA, monitoring)
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --create-namespace

# Watch deployment progress
kubectl rollout status statefulset/kafka-broker -n kafka --timeout=10m
kubectl rollout status statefulset/kafka-controller -n kafka --timeout=10m
```

### 3. Verify Cluster is Healthy
```bash
# Check all pods are running
kubectl get pods -n kafka

# Check Kafka cluster status
kubectl get kafka -n kafka
kubectl describe kafka kafka -n kafka

# Test internal connectivity
kubectl exec -it kafka-broker-0 -n kafka -- bash
/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
exit
```

### 4. Create Your First User
```bash
# Edit values.yaml to add your application user:
# kafkaUsers:
#   enabled: true
#   users:
#     - name: my-app
#       acls:
#         - resourceType: topic
#           resourceName: "my-app-*"
#           patternType: Prefix
#           operations: [Write, Create]

# Apply changes
helm upgrade kafka ./apps-kafka-config-2 -n kafka

# Get credentials
kubectl get secret my-app -n kafka -o jsonpath='{.data.password}' | base64 -d
```

### 5. Test Producer/Consumer
```bash
# Get bootstrap server
BOOTSTRAP=kafka-kafka-bootstrap:9093

# Create test topic
kubectl exec -it kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server $BOOTSTRAP \
  --create \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 3

# Send test message
kubectl exec -it kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-console-producer.sh \
  --bootstrap-server $BOOTSTRAP \
  --producer-property security.protocol=SASL_SSL \
  --producer-property sasl.mechanism=SCRAM-SHA-512 \
  --producer-property sasl.jaas.config='org.apache.kafka.common.security.scram.ScramLoginModule required username="app-producer" password="<PASSWORD>";' \
  --topic test-topic
# Type message and press Ctrl+D

# Consume test message
kubectl exec -it kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server $BOOTSTRAP \
  --consumer-property security.protocol=SASL_SSL \
  --consumer-property sasl.mechanism=SCRAM-SHA-512 \
  --consumer-property sasl.jaas.config='org.apache.kafka.common.security.scram.ScramLoginModule required username="app-consumer" password="<PASSWORD>";' \
  --topic test-topic \
  --from-beginning
```

---

## Deployment Scenarios

### Scenario A: Development / Testing Cluster
```bash
# Small, single-node cluster (not HA - data loss risk!)
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --create-namespace \
  -f values.small.yaml

# Resource usage: ~1 CPU, 1.5 GB RAM
```

### Scenario B: Production (Recommended)
```bash
# 3-node brokers + 3-node controllers (default)
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --create-namespace

# Resource usage: ~3 CPU, 6 GB RAM (scales with replicas)
```

### Scenario C: High-Throughput Production
```bash
# 5-node brokers + 5-node controllers with larger storage
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --create-namespace \
  -f values.large.yaml

# Resource usage: ~15 CPU, 30 GB RAM
# Throughput: 500k+ messages/sec (depends on message size, network)
```

### Scenario D: Multi-Datacenter / External Access
```bash
# Brokers accessible from outside cluster via LoadBalancer/NodePort
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --create-namespace \
  -f values.with-external-access.yaml

# Requires:
# 1. Update bootstrap/broker hostnames in values.with-external-access.yaml
# 2. DNS records pointing to LoadBalancer/NodePort endpoints
# 3. Distribute TLS CA certificate to external clients
```

---

## Configuration Customization

### Change Storage Class
```bash
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --set kafka.brokers.storage.size=500Gi \
  --set kafka.brokers.storage.className=fast-ssd
```

### Change Resource Limits
```bash
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --set kafka.brokers.resources.requests.cpu=2000m \
  --set kafka.brokers.resources.requests.memory=4Gi \
  --set kafka.brokers.resources.limits.cpu=4000m \
  --set kafka.brokers.resources.limits.memory=8Gi
```

### Adjust Replication & Durability
```bash
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --set kafka.config.defaultReplicationFactor=2 \
  --set kafka.config.minISR=1
# WARNING: Reduces durability guarantees!
```

### Create Multiple Users with Roles
```yaml
# Create custom-users.yaml
kafkaUsers:
  enabled: true
  users:
    - name: events-producer
      acls:
        - resourceType: topic
          resourceName: "events-*"
          patternType: Prefix
          operations: [Write, Create, Describe]
    
    - name: analytics-consumer
      acls:
        - resourceType: topic
          resourceName: "events-*"
          patternType: Prefix
          operations: [Read, Describe]
        - resourceType: group
          resourceName: "analytics-*"
          patternType: Prefix
          operations: [Read]
    
    - name: kafka-admin
      acls:
        - resourceType: "*"
          resourceName: "*"
          patternType: literal
          operations: [All]
```

Then deploy:
```bash
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  -f custom-users.yaml
```

---

## Monitoring & Observability

### Verify Prometheus Integration
```bash
# Check PodMonitor was created
kubectl get podmonitor -n kafka
kubectl describe podmonitor kafka-brokers-monitoring -n kafka

# Check if Prometheus is scraping metrics
kubectl port-forward -n prometheus prometheus-0 9090:9090
# Visit http://localhost:9090/targets → Search "kafka"
```

### View Kafka Metrics
```bash
# Port-forward to JMX metrics endpoint
kubectl port-forward kafka-0 5556:5556 -n kafka

# Fetch metrics
curl http://localhost:5556/metrics | grep kafka_

# Key metrics:
# - kafka_server_brokertopicmetrics_messagesinpersec{} → Throughput
# - kafka_server_replicamanager_underreplicatedpartitions{} → Replication health
# - kafka_network_requestmetrics_produce_latency_p99{} → Latency (p99)
```

### Check PrometheusRules
```bash
# Verify alerting rules are loaded
kubectl get prometheusrule -n kafka
kubectl describe prometheusrule kafka-alerts -n kafka

# Test that alerts would fire (check Prometheus UI)
# http://localhost:9090/alerts
```

### Create Grafana Dashboard
Example Prometheus queries for dashboard:

```
# Messages/second by topic
sum(rate(kafka_server_brokertopicmetrics_messagesinpersec[5m])) by (topic)

# Broker CPU and memory (node exporter)
node_cpu_seconds_total{pod=~"kafka-.*"}
container_memory_usage_bytes{pod=~"kafka-.*"}

# Under-replicated partitions
kafka_server_replicamanager_underreplicatedpartitions

# Consumer lag
kafka_consumergroup_lag

# Disk usage
kubelet_volume_stats_used_bytes{persistentvolumeclaim=~"data-kafka-.*"}
```

---

## Backup & Disaster Recovery

### Backup Procedure
```bash
# 1. Export cluster configuration
kubectl get kafka,kafkauser,kafkatopic -n kafka -o yaml > kafka-backup-$(date +%Y%m%d).yaml

# 2. Create PVC snapshots (storage-dependent)
# For ceph: rook-ceph snapshots
# For EBS: AWS volume snapshots
# For local: Rsync to remote storage

# 3. Export Prometheus rules and monitoring config
kubectl get prometheusrule -n kafka -o yaml > kafka-prometheus-rules.yaml
```

### Restore Procedure
```bash
# 1. Ensure cluster has fresh Strimzi operator running
kubectl get operatorgroup -n strimzi-kafka

# 2. Restore cluster objects
kubectl apply -f kafka-backup-20240101.yaml

# 3. Wait for brokers to start
kubectl rollout status statefulset/kafka-broker -n kafka

# 4. Verify data (check topic replicas)
kubectl exec kafka-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe
```

### Single Broker Recovery (KRaft Mode)
If one broker's disk fails:

```bash
# 1. Delete the failed broker's PVC
kubectl delete pvc/data-kafka-1 -n kafka

# 2. Delete the pod (Strimzi will recreate)
kubectl delete pod/kafka-1 -n kafka

# 3. Wait for recovery (data synced from replicas)
kubectl logs kafka-1 -n kafka -f | grep "started"

# 4. Verify replication
kubectl exec kafka-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe --under-replicated-partitions
```

---

## Scaling Operations

### Add Brokers
```bash
# Scale from 3 to 5 brokers
helm upgrade kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --set kafka.brokers.replicas=5

# Watch progression
kubectl get statefulset kafka-broker -n kafka -w
```

### Add Controllers (KRaft)
```bash
# Scale from 3 to 5 controllers
helm upgrade kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --set kafka.controllers.replicas=5

# Watch progression
kubectl get statefulset kafka-controller -n kafka -w
```

### Upgrade Kafka Version
```bash
helm upgrade kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --set kafka.version=4.1.0 \
  --set kafka.metadataVersion=4.1-IV0

# Brokers restart one-by-one (rolling update)
kubectl get statefulset kafka-broker -n kafka -w
```

---

## Troubleshooting

### Brokers stuck in pending/not starting
```bash
# Check logs
kubectl logs kafka-0 -n kafka

# Check events
kubectl describe pod kafka-0 -n kafka
kubectl get events -n kafka --sort-by='.lastTimestamp'

# Common causes:
# - PersistentVolume not provisioning (check storage class)
# - Insufficient resources (check node capacity)
# - TLS secret missing (check: kubectl get secret -n kafka)
```

### Replication lag or under-replicated partitions
```bash
# Check broker status
kubectl get kafka -n kafka -o yaml | grep -A10 conditions

# Check which brokers are slow
kubectl exec kafka-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe --under-replicated-partitions

# Check broker disk space
kubectl exec kafka-0 -n kafka -- df -h /var/lib/kafka

# Check broker CPU/memory
kubectl top pod kafka-0 -n kafka
```

### KRaft quorum issues
```bash
# Check active controller
kubectl logs kafka-controller-0 -n kafka | grep -i "active controller"

# Verify all controllers are running
kubectl get pods -n kafka -l strimzi.io/pool-name=controllers

# Check quorum status
kubectl exec kafka-controller-0 -n kafka -- \
  /opt/kafka/bin/kafka-metadata.sh \
  --snapshot /var/lib/kafka/quorum-state/__cluster_metadata-0/00000000000000000000.log
```

### Consumer lag not decreasing
```bash
# Check if consumer is actually connected
kubectl exec kafka-0 -n kafka -- \
  /opt/kafka/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --list

# Describe consumer group
kubectl exec kafka-0 -n kafka -- \
  /opt/kafka/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --group my-group \
  --describe

# Check network connectivity between brokers
kubectl exec kafka-0 -n kafka -- nc -zv kafka-1:9092
```

---

## Production Readiness Checklist

- [ ] All prerequisites installed (Strimzi operator, storage provisioner)
- [ ] Chose appropriate deployment scenario (dev/test vs production)
- [ ] Configured storage class and size for expected data volume
- [ ] Set resource requests/limits for your workload
- [ ] Configured all required KafkaUsers with appropriate ACLs
- [ ] Validated TLS/SCRAM authentication with test client
- [ ] Enabled monitoring (Prometheus/PrometheusRules)
- [ ] Created sample Grafana dashboards
- [ ] Tested backup/restore procedure
- [ ] Documented disaster recovery runbooks
- [ ] Verified network policies allow monitoring scrape
- [ ] Set up log aggregation (ELK, Splunk, etc.)
- [ ] Configured alerting (PagerDuty, Slack, etc.)
- [ ] Loaded test data and verified replication
- [ ] Capacity planning document created
- [ ] On-call runbook shared with team

---

## Support & Resources

- **Strimzi Documentation**: https://strimzi.io/docs/
- **Apache Kafka Docs**: https://kafka.apache.org/documentation/
- **KRaft Mode Guide**: https://kafka.apache.org/documentation/#kraft
- **Prometheus Operator**: https://prometheus-operator.dev/
- **Community Support**: Strimzi Slack/GitHub issues
