# Kafka Helm Chart - Quick Reference

## Installation Commands

```bash
# Production (3 brokers, 3 controllers, HA, monitoring)
helm install kafka ./apps-kafka-config-2 -n kafka --create-namespace

# Development (single node, no monitoring)
helm install kafka ./apps-kafka-config-2 -n kafka -f values.small.yaml --create-namespace

# Large cluster (5 brokers, 5 controllers, high throughput)
helm install kafka ./apps-kafka-config-2 -n kafka -f values.large.yaml --create-namespace

# With external client access (LoadBalancer/NodePort)
helm install kafka ./apps-kafka-config-2 -n kafka -f values.with-external-access.yaml --create-namespace
```

## Common Configuration Changes

```bash
# Scale brokers (e.g., 3 → 5)
helm upgrade kafka ./apps-kafka-config-2 -n kafka \
  --set kafka.brokers.replicas=5

# Change storage size
helm upgrade kafka ./apps-kafka-config-2 -n kafka \
  --set kafka.brokers.storage.size=500Gi

# Increase resource limits
helm upgrade kafka ./apps-kafka-config-2 -n kafka \
  --set kafka.brokers.resources.requests.cpu=2000m \
  --set kafka.brokers.resources.requests.memory=4Gi

# Upgrade Kafka version
helm upgrade kafka ./apps-kafka-config-2 -n kafka \
  --set kafka.version=4.1.0 \
  --set kafka.metadataVersion=4.1-IV0

# Disable monitoring
helm upgrade kafka ./apps-kafka-config-2 -n kafka \
  --set monitoring.enabled=false

# Add user (edit values.yaml, then upgrade)
helm upgrade kafka ./apps-kafka-config-2 -n kafka -f values.yaml
```

## Status & Inspection

```bash
# Kafka cluster status
kubectl get kafka -n kafka
kubectl describe kafka kafka -n kafka

# Broker status
kubectl get statefulset kafka-broker -n kafka
kubectl get pods kafka-broker-* -n kafka

# Controller status
kubectl get statefulset kafka-controller -n kafka
kubectl get pods kafka-controller-* -n kafka

# Users and credentials
kubectl get kafkauser -n kafka
kubectl get secret app-producer -n kafka -o jsonpath='{.data.password}' | base64 -d

# Check resources usage
kubectl top pod kafka-broker-0 -n kafka
kubectl top node -l strimzi.io/cluster=kafka
```

## Connectivity & Testing

```bash
# Get bootstrap server
kubectl get svc kafka-kafka-bootstrap -n kafka

# Test internal connectivity (inside pod)
kubectl exec kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-broker-api-versions.sh \
  --bootstrap-server localhost:9092

# List topics
kubectl exec kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --list

# Create topic
kubectl exec kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create --topic test-topic \
  --partitions 3 --replication-factor 3 --if-not-exists

# Describe topic
kubectl exec kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe --topic test-topic

# Check replication
kubectl exec kafka-broker-0 -n kafka -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --describe --under-replicated-partitions
```

## Monitoring & Metrics

```bash
# View metrics endpoint (JMX Prometheus Exporter)
kubectl port-forward kafka-broker-0 5556:5556 -n kafka
curl http://localhost:5556/metrics | grep kafka_

# Prometheus targets
kubectl port-forward -n prometheus prometheus-0 9090:9090
# Visit http://localhost:9090/targets

# Check PodMonitor exists
kubectl get podmonitor -n kafka

# Check PrometheusRules
kubectl get prometheusrule -n kafka
kubectl describe prometheusrule kafka-alerts -n kafka

# View alerts
# http://localhost:9090/alerts (in Prometheus UI)
```

## Logs & Troubleshooting

```bash
# Broker logs
kubectl logs kafka-broker-0 -n kafka
kubectl logs -f kafka-broker-0 -n kafka | grep -i error

# Controller logs
kubectl logs kafka-controller-0 -n kafka
kubectl logs -f kafka-controller-0 -n kafka | grep -i quorum

# Operator logs
kubectl logs -n strimzi-kafka -l app.kubernetes.io/name=strimzi-cluster-operator

# Kubernetes events
kubectl get events -n kafka --sort-by='.lastTimestamp'
kubectl describe pod kafka-broker-0 -n kafka

# Check PVC status
kubectl get pvc -n kafka
kubectl describe pvc data-kafka-broker-0 -n kafka
```

## Backup & Recovery

```bash
# Export configuration
kubectl get kafka,kafkauser,kafkatopic -n kafka -o yaml > kafka-backup.yaml

# Restore configuration
kubectl apply -f kafka-backup.yaml

# Delete and recreate cluster
kubectl delete kafka kafka -n kafka  # Deletes cluster but keeps PVCs
helm install kafka ./apps-kafka-config-2 -n kafka  # Recreates from PVCs

# Single broker recovery
kubectl delete pvc/data-kafka-broker-1 -n kafka
kubectl delete pod kafka-broker-1 -n kafka
# Wait for recovery...
kubectl logs -f kafka-broker-1 -n kafka | grep started
```

## Advanced Operations

```bash
# Port forward to interact directly
kubectl port-forward svc/kafka-kafka-bootstrap 9092:9092 -n kafka
# Then use: kafka-console-producer --bootstrap-server localhost:9092

# Execute commands in broker pod
kubectl exec -it kafka-broker-0 -n kafka -- bash
# Inside pod:
cd /opt/kafka/bin
./kafka-topics.sh --bootstrap-server localhost:9092 --list
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# Check disk usage
kubectl exec kafka-broker-0 -n kafka -- du -sh /var/lib/kafka
kubectl exec kafka-broker-0 -n kafka -- df -h /var/lib/kafka

# Verify TLS certificates
kubectl get secret kafka-brokers -n kafka -o yaml | grep tls.crt | head -1 | \
  awk '{print $2}' | base64 -d | openssl x509 -text -noout

# Check SASL user secrets
kubectl get secret app-producer -n kafka -o yaml | \
  grep password | awk '{print $2}' | base64 -d
```

## Uninstall/Cleanup

```bash
# Uninstall helm release (keeps PVCs/data)
helm uninstall kafka -n kafka

# Delete entire namespace (deletes all Kafka resources)
kubectl delete namespace kafka
# Note: PVCs may be retained depending on deleteClaim setting

# Force delete stuck finalizers (if needed)
kubectl patch kafka kafka -n kafka -p '{"metadata":{"finalizers":[]}}' --type=merge
```

## Useful Links

- **Chart source**: `./apps-kafka-config-2/`
- **Values reference**: `./apps-kafka-config-2/values.yaml`
- **Helm templates**: `./apps-kafka-config-2/templates/`
- **README**: `./apps-kafka-config-2/README.md`
- **Deployment guide**: `./apps-kafka-config-2/DEPLOYMENT_GUIDE.md`
- **Strimzi docs**: https://strimzi.io/docs/
- **Kafka docs**: https://kafka.apache.org/documentation/

## Environment Variables / Configuration

All Helm values can be overridden via command-line:

```bash
helm install kafka ./apps-kafka-config-2 \
  -n kafka \
  --set kafka.brokers.replicas=5 \
  --set kafka.brokers.storage.size=100Gi \
  --set kafka.config.defaultReplicationFactor=3 \
  --set kafka.config.minISR=2 \
  --set kafka.config.logRetentionHours=336 \
  --set monitoring.enabled=true \
  --set kafkaUsers.enabled=true \
  -f custom-values.yaml
```

For complex overrides, create a YAML file and pass it via `-f`.
