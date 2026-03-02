# Kafka Production Configuration - KRaft Mode

This Helm chart deploys a **production-ready, highly-available Apache Kafka cluster** using the **Strimzi Kafka Operator** with KRaft (Kraft) mode (no Zookeeper dependency).

## Architecture Overview

### Deployment Model
- **3 Kafka Brokers** (default) - handles data/client traffic
- **3 KRaft Controllers** (default) - manages cluster metadata and coordination
- **Separate node pools** - brokers and controllers optimized independently
- **HA by default** - 3 replicas of each component, min.insync.replicas=2

### Security Configuration
- **TLS Encryption**: All endpoints use TLS (inter-broker, client connections)
- **SCRAM-SHA-512**: Username/password authentication for clients
- **ACL-based Authorization**: Fine-grained access control per user/topic
- **Auto-generated certs** by Strimzi (production-ready via cert-manager)

### Observability
- **JMX Prometheus Exporter**: Built-in metrics collection
- **PodMonitor**: Kubernetes Prometheus Operator compatible
- **PrometheusRules**: Pre-configured alerts for cluster health
  - Broker down detection
  - Under-replicated partitions
  - Offline partitions (critical)
  - High latency detection
  - Consumer lag monitoring
  - KRaft quorum health

## Prerequisites

1. **Strimzi Operator**: Must be installed cluster-wide
   ```bash
   helm install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
     --namespace strimzi-kafka --create-namespace
   ```

2. **Kubernetes 1.25+**: Required for current Strimzi version

3. **Prometheus Operator** (optional): For monitoring integration
   ```bash
   helm install prometheus-operator prometheus-community/kube-prometheus-stack
   ```

4. **Storage**: PersistentVolume provisioner (local-path, ceph, EBS, etc.)

## Installation

### Basic Deployment (Production Defaults)
```bash
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --create-namespace
```

### Custom Storage Class
```bash
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --create-namespace \
  --set kafka.brokers.storage.size=500Gi \
  -f custom-values.yaml
```

## Configuration

### Key Helm Values

#### Cluster Sizing
```yaml
kafka:
  brokers:
    replicas: 3                    # Number of broker nodes
    storage:
      size: "100Gi"               # PV size per broker
    resources:
      requests: {cpu: "1000m", memory: "2Gi"}
      limits:   {cpu: "2000m", memory: "4Gi"}

  controllers:
    replicas: 3                    # Number of KRaft controllers
    storage:
      size: "20Gi"                # KRaft metadata storage
```

#### Kafka Configuration
```yaml
kafka:
  config:
    defaultReplicationFactor: 3    # Topics: 3 replicas by default
    minISR: 2                      # Minimum replicas in-sync (for acks=all)
    logRetentionHours: 168         # 7 days retention
    logCleanupPolicy: "delete"     # or "compact"
```

#### Authentication & Authorization
```yaml
kafkaUsers:
  enabled: true
  users:
    - name: app-producer
      acls:
        - resourceType: topic
          resourceName: "*"
          patternType: Prefix
          operations: [Write, Create]
```

#### Monitoring
```yaml
monitoring:
  enabled: true
  scrapeInterval: "30s"
  alerts:
    minBrokersUp: 2                # Alert if < 2 brokers are healthy
    consumerLagThreshold: 100000   # Alert if consumer lag > 100k messages
```

## Security

### TLS Certificates
- **Auto-generated** by Strimzi's built-in CA
- Certificates stored in Kubernetes secrets: `kafka-brokers` (client cert), `kafka-cluster-ca`
- For custom certificates, provide `kafka.brokers.tls.secretName`

### SCRAM-SHA-512 Authentication
Users defined in `values.yaml` are automatically created as `KafkaUser` resources:
```bash
# Get credentials for a user
kubectl get secret app-producer -n kafka -o jsonpath='{.data.password}' | base64 -d

# Connect with SASL
kafka-console-producer --bootstrap-server kafka-kafka-bootstrap:9093 \
  --producer-property security.protocol=SASL_SSL \
  --producer-property sasl.mechanism=SCRAM-SHA-512 \
  --producer-property sasl.jaas.config='org.apache.kafka.common.security.scram.ScramLoginModule required username="app-producer" password="<password>";' \
  --producer-property ssl.truststore.location=/etc/kafka/secrets/ca-cert \
  --topic test-topic
```

### ACL-based Authorization
Permissions are managed via `KafkaUser` resources:
```yaml
acls:
  - resourceType: topic          # topic | group | cluster | transactionalId
    resourceName: "app-*"        # Topic/group name or pattern
    patternType: Prefix          # literal | Prefix
    operations: [Read, Write]    # Read, Write, Create, Delete, Alter, etc.
```

## Topics

### Auto-Creating Topics on Deployment
Topics can be automatically created when the cluster is deployed using `KafkaTopic` resources:

```yaml
kafkaTopics:
  enabled: true
  topics:
    - name: "events"
      partitions: 3
      replicationFactor: 3
      config:
        retention.ms: "604800000"  # 7 days
        compression.type: "snappy"

    - name: "logs"
      partitions: 6
      replicationFactor: 3
      config:
        retention.ms: "86400000"   # 1 day
        cleanup.policy: "delete"

    - name: "state-store"
      partitions: 1
      replicationFactor: 3
      config:
        cleanup.policy: "compact"  # Log compaction for stateful topics
        min.cleanable.dirty.ratio: "0.5"
```

### Topic Configuration Options
- **partitions**: Number of partitions (affects parallelism)
- **replicationFactor**: Number of replicas (must be ≤ broker count)
- **config**: Topic-level settings
  - `retention.ms`: How long messages are kept (milliseconds)
  - `compression.type`: `snappy`, `lz4`, `gzip`, or `none`
  - `cleanup.policy`: `delete` (default) or `compact`
  - `min.insync.replicas`: Minimum in-sync replicas for producer acks=all

### Creating Topics with Helm
```bash
# Deploy cluster with pre-created topics
helm install kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --create-namespace \
  -f values.with-topics.yaml

# Or add topics to existing cluster
helm upgrade kafka ./apps-kafka-config-2 \
  --namespace kafka \
  -f values.with-topics.yaml
```

### Verifying Topics
```bash
# List all topics
kubectl get kafkatopic -n kafka

# Describe a specific topic
kubectl describe kafkatopic events -n kafka

# Check topic details
kubectl get kafkatopic events -n kafka -o yaml
```

### Manual Topic Management
If you prefer not to use Helm for topic creation, you can manage topics manually:
```bash
# Create topic
kubectl exec kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create \
  --topic my-topic \
  --partitions 3 \
  --replication-factor 3

# Delete topic
kubectl exec kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --delete \
  --topic my-topic
```

## Monitoring & Alerting

### Prometheus Integration
PodMonitor automatically discovered by Prometheus Operator:
```bash
# Verify scrape config
kubectl port-forward -n prometheus prometheus-0 9090:9090
# Visit http://localhost:9090 → Targets → Search "kafka-brokers"
```

### Available Metrics
Key metrics for dashboarding:
- `kafka_server_brokertopicmetrics_messagesinpersec` - Throughput
- `kafka_server_replicamanager_underreplicatedpartitions` - Replication health
- `kafka_network_requestmetrics_produce_latency_p99` - Performance
- `kafka_consumergroup_lag` - Consumer lag

### PrometheusRules (Alerts)
Pre-configured alerts fire when:
1. **Brokers down**: < 2 brokers healthy (5m)
2. **Under-replicated**: Partitions with fewer in-sync replicas (5m)
3. **Offline partitions**: Data loss risk (1m) - CRITICAL
4. **High latency**: P99 produce latency > 500ms (5m)
5. **Consumer lag**: Lag > 100k messages (10m)
6. **Failed requests**: Fetch/produce failures spike (5m)
7. **Leader elections**: Cluster instability indicator (2m)
8. **KRaft quorum**: Active controller != 1 (2m) - CRITICAL

### Custom Dashboards
Example queries for Grafana:
```
# Messages/sec by topic
sum(rate(kafka_server_brokertopicmetrics_messagesinpersec[1m])) by (topic)

# Broker disk usage
kubelet_volume_stats_used_bytes{persistentvolumeclaim=~"kafka-.*"}

# Consumer lag trend
kafka_consumergroup_lag
```

## Operations

### Scale Broker Replicas
```bash
kubectl patch kafka kafka -n kafka -p '{"spec":{"kafka":{"brokers":{"replicas":5}}}}' --type=merge
# Wait for rolling update: kubectl rollout status statefulset/kafka-broker -n kafka
```

### Update Kafka Version
```bash
helm upgrade kafka ./apps-kafka-config-2 \
  --namespace kafka \
  --set kafka.version=4.1.0 \
  --set kafka.metadataVersion=4.1-IV0
```

### Add New User
```bash
# Edit values.yaml and add to kafkaUsers.users[]
helm upgrade kafka ./apps-kafka-config-2 --namespace kafka
```

### Check Cluster Status
```bash
# Broker status
kubectl get kafka -n kafka
kubectl get kafkanodepool -n kafka
kubectl logs -n kafka kafka-0 | grep "started"

# User credentials
kubectl get kafkauser -n kafka
kubectl get secret app-producer -n kafka

# Metrics available
kubectl port-forward kafka-0 5556:5556 -n kafka
curl localhost:5556/metrics | grep kafka_
```

## Backup & Recovery

### Backup Topics and Users
```bash
# Export cluster config
kubectl get kafka,kafkauser,kafkatopic -n kafka -o yaml > kafka-backup.yaml

# Export PVC snapshots (storage-dependent)
# Consult your storage provider's snapshot procedures
```

### Restore from Backup
```bash
kubectl apply -f kafka-backup.yaml
```

### Rebuilding Broker (KRaft mode)
KRaft-based clusters are more resilient:
1. Controller replicas maintain quorum metadata
2. Broker PVC loss: Data replicated across other brokers
3. Controller PVC loss: Quorum lost if >50% fail

Restore procedure (single broker):
```bash
# Delete failing broker PVC and pod
kubectl delete pvc/data-kafka-1 pod/kafka-1 -n kafka
# Strimzi auto-recreates PVC and restores from replicas
kubectl get statefulset kafka-broker -n kafka -w  # Watch recovery
```

## Troubleshooting

### Brokers not starting
```bash
kubectl logs kafka-0 -n kafka
# Check: storage, resources, TLS secrets, network policies
```

### High latency or producer timeouts
```bash
# Check broker disk usage
kubectl exec kafka-0 -n kafka -- df -h

# Check network:
kubectl get events -n kafka --sort-by='.lastTimestamp'

# Check metrics:
kubectl port-forward kafka-0 5556:5556 -n kafka
# Look for: network_thread_idle_percent, io_thread_idle_percent
```

### Consumer lag stuck or growing
```bash
# Check broker logs for errors
kubectl logs kafka-0 -n kafka | grep -i error

# Verify topic replication
kubectl exec kafka-0 -n kafka -- /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe --topic <topic-name>
```

### KRaft quorum issues
```bash
# Check controller logs
kubectl logs kafka-controller-0 -n kafka | grep -i quorum

# Verify all controllers are running
kubectl get pods -n kafka -l strimzi.io/kind=KafkaNodePool,strimzi.io/pool-name=controllers
```

## Production Checklist

- [ ] Storage class selected and tested (persistent volumes working)
- [ ] Resource requests/limits tuned for your workload
- [ ] Replication factor and min.insync.replicas validated for durability needs
- [ ] TLS certificates integrated with your PKI (if not using auto-generated)
- [ ] All required KafkaUsers created with appropriate ACLs
- [ ] Monitoring enabled and dashboards configured
- [ ] Prometheus rules tested and alerting configured
- [ ] Backup/recovery procedure documented and tested
- [ ] Network policies configured (egress to monitoring, logging)
- [ ] Log aggregation configured (ELK, Splunk, etc.)
- [ ] Consumer lag alerting configured
- [ ] Capacity planning for growth (storage, CPU/memory headroom)

## References

- [Strimzi Operator Documentation](https://strimzi.io/docs/)
- [Apache Kafka in KRaft Mode](https://kafka.apache.org/documentation/#kraft)
- [Kafka Security Best Practices](https://kafka.apache.org/documentation/#security)
- [Monitoring Kafka with Prometheus](https://strimzi.io/docs/operators/latest/deploying.html#proc-metrics-config-str)

## Support

For issues or questions:
1. Check Kafka and Strimzi logs: `kubectl logs -n kafka`
2. Verify operator status: `kubectl get operatorgroup -n strimzi-kafka`
3. Check PrometheusRules: `kubectl get prometheusrule -n kafka`
4. Consult [Strimzi troubleshooting guide](https://strimzi.io/docs/operators/latest/deploying.html#proc-metrics-config-str)
