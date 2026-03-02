# Kafka Cluster Architecture Diagram

## High-Level Deployment Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster (OpenShift)                     │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ Kafka Namespace (kafka)                                          │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │                                                                  │  │
│  │  BROKER NODE POOL (3 replicas)           CONTROLLER NODE POOL    │  │
│  │  ┌────────────────────────────────────┐  (3 replicas)            │  │
│  │  │ kafka-broker-0                     │  ┌─────────────────┐     │  │
│  │  ├─ JMX Metrics (5556)                │  │ kafka-ctr-0     │     │  │
│  │  ├─ TLS Client (9093)                 │  │ (KRaft meta)    │     │  │
│  │  ├─ PLAIN (9092, internal only)       │  └─────────────────┘     │  │
│  │  ├─ PVC: 100Gi (data)                 │  ┌─────────────────┐     │  │
│  │  └─ Resources: 1CPU/2GB (req) ...     │  │ kafka-ctr-1     │     │  │
│  │                                       │  └─────────────────┘     │  │
│  │  ┌────────────────────────────────────┐  ┌─────────────────┐     │  │
│  │  │ kafka-broker-1                     │  │ kafka-ctr-2     │     │  │
│  │  ├─ (same as broker-0)                │  └─────────────────┘     │  │
│  │  └─ PVC: 100Gi                        │                          │  │
│  │                                       │  KRaft Quorum:           │  │
│  │  ┌────────────────────────────────────┐  - Metadata quorum       │  │
│  │  │ kafka-broker-2                     │  - Controller election   │  │
│  │  ├─ (same as broker-0)                │  - Auto failover         │  │
│  │  └─ PVC: 100Gi                        │                          │  │
│  │                                       │                          │  │
│  │  Services:                            │ Storage (3x 20Gi):       │  │
│  │  • kafka-kafka-bootstrap:9093 (TLS)   │  Quorum metadata         │  │
│  │  • kafka-kafka-0.kafka....:9093       │                          │  │
│  │  • kafka-kafka-1.kafka....:9093       │                          │  │
│  │  • kafka-kafka-2.kafka....:9093       │                          │  │
│  │                                       │                          │  │
│  └───────────────────────────────────────┴──────────────────────────┘  │
│                                                                        │
│  ┌──────────────────────────────────────┐                              │
│  │ MONITORING STACK                     │                              │
│  ├──────────────────────────────────────┤                              │
│  │ PodMonitor: kafka-brokers            │                              │
│  │   ↓ scrapes JMX metrics              │                              │
│  │ Prometheus (external namespace)      │                              │
│  │   ↓ evaluates rules                  │                              │
│  │ PrometheusRules: kafka-alerts        │                              │
│  │   ↓ fires alerts                     │                              │
│  │ AlertManager → Slack/PagerDuty       │                              │
│  └──────────────────────────────────────┘                              │
│                                                                        │
│  ┌──────────────────────────────────────┐                              │
│  │ ENTITY OPERATOR                      │                              │
│  ├──────────────────────────────────────┤                              │
│  │ ├─ TopicOperator: KafkaTopic CRs     │                              │
│  │ └─ UserOperator: KafkaUser CRs       │                              │
│  │    (SCRAM-SHA-512 auth, ACLs)        │                              │
│  └──────────────────────────────────────┘                              │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                          KAFKA BROKERS                               │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  CLIENT CONNECTION (e.g., app-producer)                            │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ 1. TLS Handshake                                             │  │
│  │    - Client: kafka-cluster-ca-cert (trusted)                │  │
│  │    - Broker: kafka-brokers secret (tls.crt, tls.key)       │  │
│  │    → Encrypted channel established                          │  │
│  │                                                              │  │
│  │ 2. SASL SCRAM-SHA-512 Authentication                        │  │
│  │    - Username: app-producer                                 │  │
│  │    - Password: stored in app-producer secret               │  │
│  │    - Challenge-response authentication                      │  │
│  │    → Client identity verified                               │  │
│  │                                                              │  │
│  │ 3. ACL Authorization Check                                  │  │
│  │    - Principal: User:app-producer                           │  │
│  │    - Resource: Topic "my-topic"                             │  │
│  │    - Operation: Write                                       │  │
│  │    - ACL Rule: ✅ Found in simple authorizer               │  │
│  │    → Access granted                                         │  │
│  │                                                              │  │
│  │ 4. Data Transfer                                            │  │
│  │    - Messages encrypted via TLS                             │  │
│  │    - Replicated to other brokers (inter-broker TLS)        │  │
│  │    - Persisted to disk (encryption at rest optional)       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

## Data Flow & Replication

```
PRODUCER WRITE FLOW
═════════════════════════════════════════════════════════════════════

Client (app-producer)
  │
  ├─ Connects to kafka-kafka-bootstrap:9093 (TLS)
  │
  ├─ SASL Auth: "app-producer" / password
  │
  ├─ Topic: "my-topic" (3 partitions, replication factor: 3)
  │
  ├─ Metadata Request → Broker-0
  │  ("my-topic" partitions on brokers 0, 1, 2)
  │
  └─ Produce Request to Leader (e.g., Broker-0)
      │
      ├─ Broker-0 (Leader): appends to log
      │
      ├─ Replicates to Broker-1 (Follower): async send
      │  │
      │  ├─ Broker-1 receives → appends to log → ACK
      │  │
      │  └─ In-Sync Replicas (ISR): [0, 1, 2]
      │
      ├─ Replicates to Broker-2 (Follower): async send
      │  │
      │  └─ Broker-2 receives → appends to log → ACK
      │
      └─ Producer ACK
         (3 replicas have data, min.insync.replicas=2 met)


CONTROLLER / KRAFT METADATA FLOW
═════════════════════════════════════════════════════════════════════

Brokers   ←→   KRaft Controllers
┌──────────────┐  ┌──────────────────────┐
│ Broker-0     │  │ Controller Quorum      │
│ Broker-1     │  │ ┌──────────────────┐  │
│ Broker-2     │  │ │ Leader Controller │  │
└──────────────┘  │ │ (election-based)  │  │
      ↓           │ ├──────────────────┤  │
  Write logs      │ │ Follower Ctr-1    │  │
  Topic changes   │ │ Follower Ctr-2    │  │
      ↑           │ └──────────────────┘  │
  Read metadata   │ Replicated metadata   │
  Partition ISR   │ Quorum consensus      │
      ↑           │ (Raft protocol)       │
  Heartbeats      │                       │
                  └──────────────────────┘
```

## Monitoring & Alerting Architecture

```
METRICS COLLECTION
═════════════════════════════════════════════════════════════════════

Kafka Broker (JVM)
  │
  ├─ Application Metrics (Kafka internals)
  │  - kafka_server_brokertopicmetrics_*
  │  - kafka_network_requestmetrics_*
  │  - kafka_controller_kafkacontroller_*
  │
  ├─ JMX Prometheus Exporter (sidecar)
  │  Listens on :5556/metrics
  │
  └─ PodMonitor (Prometheus Operator)
     Scrapes every 30s → Prometheus storage


ALERTING RULES
═════════════════════════════════════════════════════════════════════

PrometheusRules: kafka-alerts
├─ KafkaBrokerDown (severity: critical)
│  if: brokers_healthy < 2 for 5m
│  action: → Page on-call
│
├─ KafkaUnderReplicatedPartitions (severity: warning)
│  if: under_replicated_partitions > 0 for 5m
│  action: → Slack alert
│
├─ KafkaOfflinePartitions (severity: critical)
│  if: offline_partitions > 0 for 1m
│  action: → Page on-call (data loss risk!)
│
├─ KafkaHighRequestLatency (severity: warning)
│  if: p99_latency > 500ms for 5m
│  action: → Performance team alert
│
├─ KafkaConsumerGroupLagHigh (severity: warning)
│  if: consumer_lag > 100k messages for 10m
│  action: → Application team alert
│
└─ KafkaKRaftQuorumUnhealthy (severity: critical)
   if: active_controllers != 1 for 2m
   action: → Page on-call (cluster unstable)


GRAFANA DASHBOARD
═════════════════════════════════════════════════════════════════════

Row 1: Cluster Health
├─ Broker Status (up/down)
├─ ISR Status (in-sync replicas)
└─ Quorum Health (KRaft active controller)

Row 2: Throughput & Performance
├─ Messages/sec by topic
├─ Bytes in/out per broker
└─ Request latency (p50, p95, p99)

Row 3: Replication & Durability
├─ Under-replicated partitions
├─ Offline partitions
└─ ISR shrinks per broker

Row 4: Consumer Activity
├─ Consumer lag (by group)
├─ Fetch rate per group
└─ Commit rate per group

Row 5: Resource Usage
├─ CPU per broker
├─ Memory per broker
└─ Disk space per broker
```

## Network & Connectivity

```
INTERNAL CLUSTER COMMUNICATION
═════════════════════════════════════════════════════════════════════

Brokers Inter-communication (TLS)
  kafka-broker-0:9093 ←→ kafka-broker-1:9093
  kafka-broker-1:9093 ←→ kafka-broker-2:9093
  (Uses kafka-brokers client certificate)

Broker ← → Controller Communication (TLS)
  kafka-broker-0:9093 ←→ kafka-controller-0:9093
  (KRaft quorum metadata updates)

Service Names (Internal DNS)
  kafka-kafka-bootstrap.kafka.svc.cluster.local:9093
  kafka-kafka-0.kafka-kafka-brokers.kafka.svc:9093
  kafka-kafka-1.kafka-kafka-brokers.kafka.svc:9093
  kafka-kafka-2.kafka-kafka-brokers.kafka.svc:9093


EXTERNAL CLIENT ACCESS (Optional)
═════════════════════════════════════════════════════════════════════

If enabled via values.with-external-access.yaml:

External Client
  │
  ├─ Resolves: kafka-0.example.com
  │
  └─ Connects to: NodePort / LoadBalancer
     kafka-0.example.com:9094 (TLS)
     kafka-1.example.com:9094 (TLS)
     kafka-2.example.com:9094 (TLS)
     │
     ├─ TLS Handshake
     │  (uses kafka-brokers client cert)
     │
     ├─ SASL SCRAM-SHA-512
     │  (external-producer credentials)
     │
     └─ ACL Check
        (access to "external-*" topics)
```

## State Diagram: Kafka Broker Lifecycle

```
┌─────────┐
│ Pending │
│ (PVC    │
│ waiting)│
└────┬────┘
     │ PVC Created
     ↓
┌──────────┐
│ Creating │ (downloading image, mounting PVC)
└────┬─────┘
     │ Container Started
     ↓
┌─────────────┐
│ Booting     │ (JVM startup, log recovery)
└────┬────────┘
     │ Ready signal
     ↓
┌──────────────┐
│ Ready        │ (accepting connections, serving clients)
│ - Producing │
│ - Consuming │
│ - Replicating
└────┬─────────┘
     │ (optional) Rolling Update → Graceful Shutdown
     ↓
┌──────────────┐
│ Terminating  │ (in-flight requests complete, log sync)
└────┬─────────┘
     │ Kubelet kills pod
     ↓
┌─────────────┐
│ Terminated  │
└─────────────┘
```

## Storage Architecture

```
PERSISTENT VOLUME LAYOUT (per broker)
═════════════════════════════════════════════════════════════════════

PVC: data-kafka-broker-0 (100Gi by default)
│
├─ /var/lib/kafka/data-0/
│  ├─ log-0/
│  │  ├─ 00000000000000000000.log (segment, 1GB)
│  │  ├─ 00000000000000000000.index
│  │  └─ ... (new segments as data grows)
│  │
│  ├─ log-1/
│  │  └─ ... (partition 1 logs)
│  │
│  └─ __cluster_metadata-0/ (KRaft metadata only on controllers)
│     ├─ 00000000000000000000.log
│     └─ 00000000000000000000.index
│
└─ recovery-point-offset-checkpoint
   committed-log-dirs-checkpoint

Total per broker: 100Gi (100+ partitions/replicas)
```

## Scaling Implications

```
HORIZONTAL SCALING (Add Brokers)
═════════════════════════════════════════════════════════════════════

Before:  3 Brokers (100Gi each) = 300Gi total
             │
             ├─ Partition 0: Leader=B0, Replicas=[B0,B1,B2]
             ├─ Partition 1: Leader=B1, Replicas=[B1,B2,B0]
             └─ Partition 2: Leader=B2, Replicas=[B2,B0,B1]

After: +2 Brokers → 5 Brokers (100Gi each) = 500Gi total
           │
           ├─ Strimzi reassigns replicas
           ├─ Data rebalances across B0-B4
           ├─ Throughput increases (more brokers handle requests)
           └─ Network bandwidth increases during rebalance


VERTICAL SCALING (Bigger Brokers)
═════════════════════════════════════════════════════════════════════

Before:  1000m CPU, 2Gi RAM per broker
         Small: 1 broker, single core bottleneck

After: +Resource limits → 2000m CPU, 4Gi RAM per broker
       Medium: 3 brokers, parallel processing
       → Throughput ↑ (threading), Latency ↓ (memory buffers)
       → But: diminishing returns after 8 cores per broker
```

---

**Use this document to understand the cluster structure, architecture decisions, and data flows.**
