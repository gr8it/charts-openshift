# Production Deployment Checklist

Use this checklist to ensure your Kafka cluster is properly configured and ready for production workloads.

## Pre-Deployment Phase

### Prerequisites Verification
- [ ] Kubernetes cluster version 1.25+
  ```bash
  kubectl version --short
  ```

- [ ] Strimzi operator installed
  ```bash
  kubectl get operatorgroup -n strimzi-kafka
  kubectl get subscription strimzi-kafka-operator -n strimzi-kafka
  ```

- [ ] Storage provisioner available
  ```bash
  kubectl get storageclass
  # Should see: fast-ssd, standard, ceph-rbd, or similar
  ```

- [ ] Prometheus Operator installed (optional but recommended)
  ```bash
  kubectl api-resources | grep prometheus
  ```

- [ ] Adequate cluster resources
  - For 3-node HA: minimum 3 worker nodes with 2+ CPU and 4GB RAM each
  - For 5-node production: minimum 5 nodes with 4+ CPU and 8GB RAM each
  ```bash
  kubectl top nodes
  # Verify free capacity
  ```

### Configuration Preparation
- [ ] Reviewed [values.yaml](values.yaml) for production defaults
- [ ] Customized storage size for expected data volume
  - Small: 10-50Gi (dev/test)
  - Medium: 100Gi (standard production)
  - Large: 500Gi+ (high-throughput)

- [ ] Confirmed resource limits match cluster capacity
  ```yaml
  kafka.brokers.resources.requests: {cpu: 1000m, memory: 2Gi}
  kafka.brokers.resources.limits: {cpu: 2000m, memory: 4Gi}
  ```

- [ ] Selected appropriate deployment profile
  - [ ] Production (default): 3 brokers, HA, monitoring
  - [ ] Development: single node, no monitoring
  - [ ] Large: 5+ brokers, high-throughput
  - [ ] External access: with LoadBalancer/NodePort

- [ ] Planned namespace and naming
  ```bash
  KAFKA_NS="kafka"  # or your namespace
  KAFKA_RELEASE="kafka"  # or your release name
  ```

- [ ] Created custom values file (if needed)
  ```bash
  cp values.yaml custom-values.yaml
  # Edit custom-values.yaml
  ```

---

## Deployment Phase

### Cluster Creation
- [ ] Created namespace
  ```bash
  kubectl create namespace kafka
  ```

- [ ] Deployed Kafka cluster
  ```bash
  helm install kafka ./apps-kafka-config-2 \
    --namespace kafka \
    --create-namespace \
    -f custom-values.yaml  # if customized
  ```

- [ ] Verified all pods are running (5-10 minutes)
  ```bash
  kubectl rollout status statefulset/kafka-broker -n kafka --timeout=10m
  kubectl rollout status statefulset/kafka-controller -n kafka --timeout=10m
  ```

- [ ] All pods in Running status
  ```bash
  kubectl get pods -n kafka
  # All kafka-broker-*, kafka-controller-*, kafka-entity-operator should be Running
  ```

### Cluster Validation
- [ ] Verified Kafka cluster object created
  ```bash
  kubectl get kafka -n kafka
  # Should show: kafka-kafka-brokers in conditions
  ```

- [ ] Checked broker readiness
  ```bash
  kubectl describe kafka kafka -n kafka
  # Should show "Type: Ready, Status: True"
  ```

- [ ] Tested internal connectivity
  ```bash
  kubectl exec kafka-broker-0 -n kafka -- \
    /opt/kafka/bin/kafka-broker-api-versions.sh \
    --bootstrap-server localhost:9092
  # Should show: API versions supported
  ```

- [ ] Verified JMX metrics are available
  ```bash
  kubectl port-forward kafka-broker-0 5556:5556 -n kafka
  curl http://localhost:5556/metrics | head -20
  # Should show prometheus-format metrics
  ```

---

## Security Configuration Phase

### SCRAM Authentication
- [ ] Reviewed example users in values.yaml
- [ ] Created all required KafkaUsers
  ```bash
  # Verify users were created
  kubectl get kafkauser -n kafka
  # Should show: app-producer, app-consumer, admin (or your custom users)
  ```

- [ ] Retrieved user credentials
  ```bash
  for user in app-producer app-consumer admin; do
    echo "=== $user ==="
    kubectl get secret $user -n kafka \
      -o jsonpath='{.data.password}' | base64 -d
  done
  ```

- [ ] Stored credentials securely
  - [ ] Never commit to git
  - [ ] Use secrets management system (Vault, AWS Secrets Manager, etc.)
  - [ ] Distribute only to authorized applications

### TLS Configuration
- [ ] Verified TLS certificates were generated
  ```bash
  kubectl get secret kafka-brokers -n kafka
  kubectl get secret kafka-cluster-ca-cert -n kafka
  ```

- [ ] Tested TLS connection with SCRAM auth
  ```bash
  kubectl exec -it kafka-broker-0 -n kafka -- bash
  # Inside pod:
  /opt/kafka/bin/kafka-broker-api-versions.sh \
    --bootstrap-server localhost:9093 \
    --command-config /etc/kafka/secrets/client.properties
  exit
  ```

- [ ] Extracted CA certificate for external clients (if needed)
  ```bash
  kubectl get secret kafka-cluster-ca-cert -n kafka \
    -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
  ```

### ACL Verification
- [ ] Listed all ACLs
  ```bash
  kubectl exec kafka-broker-0 -n kafka -- \
    /opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server localhost:9092 \
    --list
  ```

- [ ] Verified each user has appropriate permissions
  - [ ] app-producer can write to expected topics
  - [ ] app-consumer can read from expected topics
  - [ ] admin user has cluster admin rights

---

## Monitoring & Observability Phase

### Prometheus Integration
- [ ] Verified PodMonitor was created
  ```bash
  kubectl get podmonitor -n kafka
  # Should show: kafka-brokers
  ```

- [ ] Checked Prometheus is scraping metrics
  ```bash
  kubectl port-forward -n prometheus prometheus-0 9090:9090
  # Visit: http://localhost:9090/targets
  # Search: "kafka"
  # All endpoints should show "UP" (green)
  ```

- [ ] Verified metrics are being collected
  ```bash
  # At Prometheus: http://localhost:9090/graph
  # Query: kafka_server_brokertopicmetrics_messagesinpersec
  # Should return results with non-zero values
  ```

### PrometheusRules & Alerting
- [ ] Verified PrometheusRules were created
  ```bash
  kubectl get prometheusrule -n kafka
  # Should show: kafka-alerts
  ```

- [ ] Checked alert rules are loaded
  ```bash
  # In Prometheus UI: http://localhost:9090/rules
  # Filter: "kafka"
  # Should show 8 rules listed
  ```

- [ ] Configured AlertManager (external to this chart)
  ```bash
  # Configure webhook/integration for:
  # - PagerDuty
  # - Slack
  # - Email
  # - Custom webhook
  ```

### Grafana Dashboards
- [ ] Created Grafana datasource for Prometheus
  ```
  URL: http://prometheus:9090
  Access: Server
  ```

- [ ] Created sample dashboard queries
  - [ ] Messages/sec by topic
  - [ ] Broker CPU/memory usage
  - [ ] Under-replicated partitions
  - [ ] Consumer lag by group

---

## Testing & Validation Phase

### Topic Creation & Testing
- [ ] Created test topic
  ```bash
  kubectl exec kafka-broker-0 -n kafka -- \
    /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create --topic test-topic \
    --partitions 3 \
    --replication-factor 3 \
    --if-not-exists
  ```

- [ ] Verified topic replication
  ```bash
  kubectl exec kafka-broker-0 -n kafka -- \
    /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --describe --topic test-topic
  # All partitions should have: Replicas: [0,1,2] Isr: [0,1,2]
  ```

- [ ] Produced test messages
  ```bash
  kubectl exec -it kafka-broker-0 -n kafka -- \
    /opt/kafka/bin/kafka-console-producer.sh \
    --bootstrap-server localhost:9092 \
    --topic test-topic
  # Type: "message1", "message2", etc. then Ctrl+D
  ```

- [ ] Consumed test messages
  ```bash
  kubectl exec -it kafka-broker-0 -n kafka -- \
    /opt/kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server localhost:9092 \
    --topic test-topic \
    --from-beginning
  # Should see: message1, message2, etc.
  ```

### Authentication Testing
- [ ] Tested SCRAM auth with valid credentials
  ```bash
  # Create credentials file
  cat > client.properties <<EOF
  security.protocol=SASL_SSL
  sasl.mechanism=SCRAM-SHA-512
  sasl.username=app-producer
  sasl.password=<PASSWORD_FROM_SECRET>
  ssl.truststore.location=/path/to/ca.crt
  EOF
  
  # Test connection
  kafka-console-producer --bootstrap-server localhost:9093 \
    --producer.config client.properties \
    --topic test-topic
  ```

- [ ] Tested with invalid credentials (should fail)
  ```bash
  # Attempt with wrong password - should be rejected
  ```

### Performance Testing
- [ ] Baseline throughput test
  ```bash
  # Using kafka-producer-perf-test
  # Document results for capacity planning
  ```

- [ ] Latency test
  ```bash
  # Using kafka-run-class org.apache.kafka.tools.ProducerPerformance
  # P50, P95, P99 latencies acceptable?
  ```

---

## Production Hardening Phase

### Network Policies
- [ ] Applied network policies to restrict access
  ```bash
  kubectl apply -f templates/netpol.yaml
  # Or create custom network policies
  ```

- [ ] Tested connectivity from allowed sources
- [ ] Blocked connectivity from unauthorized sources

### Backup Strategy
- [ ] Created initial backup
  ```bash
  kubectl get kafka,kafkauser,kafkatopic -n kafka -o yaml > kafka-backup-$(date +%Y%m%d).yaml
  ```

- [ ] Set up automated backups
  - [ ] Daily backup of cluster configuration
  - [ ] PVC snapshots (storage-dependent)
  - [ ] Tested restore procedure on non-prod cluster

- [ ] Documented backup retention policy
  - [ ] Configuration backups: 30 days
  - [ ] PVC snapshots: 7 days
  - [ ] Archive of monthly snapshots: 1 year

### Disaster Recovery
- [ ] Documented recovery procedures
  ```bash
  # See: README.md "Backup & Recovery"
  # See: DEPLOYMENT_GUIDE.md "Backup & Disaster Recovery"
  ```

- [ ] Tested broker recovery (single PVC failure)
- [ ] Tested cluster recovery (from configuration backup)
- [ ] Tested controller quorum recovery (KRaft specific)

### Logging & Log Aggregation
- [ ] Configured log forwarding to centralized system
  - [ ] ELK Stack
  - [ ] Splunk
  - [ ] CloudWatch
  - [ ] Stack Driver

- [ ] Set up log indexing and retention
  - [ ] Broker logs: 7 days minimum
  - [ ] Controller logs: 7 days minimum
  - [ ] Operator logs: 3 days

- [ ] Created log parsing rules for common issues

---

## Documentation & Runbook Phase

### Operations Documentation
- [ ] Reviewed and customized [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- [ ] Reviewed and customized [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- [ ] Created environment-specific runbooks
  - [ ] Cluster bootstrap procedure
  - [ ] Adding brokers procedure
  - [ ] Version upgrade procedure
  - [ ] Emergency shutdown procedure

### On-Call Documentation
- [ ] Created on-call runbook
  - [ ] Common issues and solutions
  - [ ] Contact information
  - [ ] Escalation procedures

- [ ] Shared [QUICK_REFERENCE.md](QUICK_REFERENCE.md) with team
- [ ] Created cheat sheet with:
  - [ ] Bootstrap server address
  - [ ] Namespace name
  - [ ] Key metrics to monitor
  - [ ] Escalation contacts

### Training
- [ ] Team trained on cluster operations
  - [ ] How to check cluster health
  - [ ] How to troubleshoot common issues
  - [ ] How to add/remove brokers
  - [ ] How to upgrade Kafka version

- [ ] Team reviewed security model
  - [ ] TLS/SCRAM authentication
  - [ ] ACL management
  - [ ] User secret handling

---

## Post-Deployment Verification

### Day 1: Immediate Checks
- [ ] No errors in operator logs
  ```bash
  kubectl logs -n strimzi-kafka -l app.kubernetes.io/name=strimzi-cluster-operator
  ```

- [ ] All brokers healthy
  ```bash
  kubectl get kafka -n kafka -o yaml | grep -A20 "conditions:"
  ```

- [ ] Metrics flowing to Prometheus
  ```bash
  # Prometheus UI: check kafka_* metrics
  ```

- [ ] All alerts evaluating correctly
  ```bash
  # Prometheus: Rules page should show kafka-alerts
  ```

### Day 7: First Week Checks
- [ ] Monitor resource utilization
  ```bash
  kubectl top pods -n kafka
  # CPU/memory usage reasonable?
  ```

- [ ] Review any alerts that fired
  - [ ] Were they legitimate issues or false positives?
  - [ ] Do alert thresholds need adjustment?

- [ ] Check replication lag
  ```bash
  # Metrics: kafka_server_replicamanager_underreplicatedpartitions should be 0
  ```

- [ ] Review disk usage
  ```bash
  kubectl exec kafka-broker-0 -n kafka -- df -h /var/lib/kafka
  # Sufficient free space? Growing as expected?
  ```

### Monthly: Ongoing Checks
- [ ] Review capacity metrics
  - [ ] Storage growth trend
  - [ ] CPU/memory utilization trends
  - [ ] Network bandwidth trends

- [ ] Test backup/restore procedure
- [ ] Review and rotate KafkaUser credentials
- [ ] Check for Kafka/Strimzi security updates
- [ ] Review alert tuning (too many false positives?)

---

## Scale-Out Validation (When Needed)

### Adding Brokers
- [ ] Recorded baseline metrics before scaling
- [ ] Increased replica count in values.yaml
- [ ] Verified new broker pods started
- [ ] Verified data rebalancing occurred
- [ ] Verified ISR stabilized (all replicas in-sync)
- [ ] Compared post-scaling metrics to baseline

### Adding Controllers (KRaft Quorum)
- [ ] Verified current quorum size (should be odd: 3, 5, 7)
- [ ] Increased controller replicas
- [ ] Verified new controller pods started
- [ ] Verified quorum election completed
- [ ] No leader election storms (1 active controller)

---

## Security Audit Checklist

- [ ] All endpoints use TLS encryption
  ```bash
  kubectl get kafka kafka -n kafka -o yaml | grep -A20 "listeners:"
  ```

- [ ] All users use SCRAM-SHA-512 (not plaintext)
  ```bash
  kubectl get kafkauser -n kafka -o yaml | grep "type: scram"
  ```

- [ ] ACLs are restrictive (principle of least privilege)
  ```bash
  kubectl exec kafka-broker-0 -n kafka -- \
    /opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --list
  ```

- [ ] No default users with weak passwords
- [ ] CA certificates validated and trusted
- [ ] Certificates will be renewed before expiration
- [ ] Network policies restrict access to Kafka namespace
- [ ] Secrets not visible in logs
  ```bash
  kubectl logs -n kafka kafka-broker-0 | grep -i password  # Should be empty
  ```

---

## Go/No-Go Decision

### Ready for Production if ALL of the following are true:
- [ ] All prerequisite checks passed
- [ ] Cluster deployed and healthy
- [ ] TLS and SCRAM authentication working
- [ ] ACLs properly configured
- [ ] Monitoring and alerting operational
- [ ] Backup/recovery tested
- [ ] Performance acceptable for workload
- [ ] Team trained and runbooks created
- [ ] Security audit passed
- [ ] Week 1 metrics look healthy

### If any items are unchecked, DO NOT PROCEED to production. Address gaps first.

---

## Sign-Off

- [ ] **Prepared By:** __________________ Date: ________
- [ ] **Reviewed By:** __________________ Date: ________
- [ ] **Approved By:** _________________ Date: ________

**GO TO PRODUCTION:** ☐ YES ☐ NO

---

**If you have questions about any items, consult:**
- General: [INDEX.md](INDEX.md)
- Deployment: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- Commands: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Reference: [README.md](README.md)
