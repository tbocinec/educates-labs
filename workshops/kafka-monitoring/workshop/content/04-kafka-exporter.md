# Kafka Exporter Monitoring

Learn specialized consumer group and topic monitoring with Kafka Exporter - purpose-built for Kafka observability.

## Understanding Kafka Exporter

**Kafka Exporter** is different from JMX Exporter:

| Feature | JMX Exporter | Kafka Exporter |
|---------|--------------|----------------|
| **Source** | JVM metrics | Kafka APIs |
| **Focus** | Broker internals | Consumer groups & topics |
| **Lag tracking** | Limited | Per-partition detail |
| **Setup** | Requires JVM agent | Standalone service |
| **Best for** | Broker health | Consumer monitoring |

**Kafka Exporter** používa Kafka Admin API na získanie metrík špecifických pre consumer groups a témy, čo JMX Exporter neposkytuje v takej detailnosti.

## Grafana Dashboard

Pre vizualizáciu Kafka Exporter metrík odporúčame **oficiálny dashboard**:

📊 **[Kafka Exporter Overview (Dashboard 7589)](https://grafana.com/grafana/dashboards/7589-kafka-exporter-overview/)**

Tento dashboard poskytuje:
- 📈 **Consumer Group Lag** - Lag per group a partition
- 👥 **Consumer Group Members** - Počet aktívnych consumerov
- 📦 **Topic Offsets** - High water marks
- ⚠️ **Under-replicated Partitions** - Replication health
- 🔄 **Offset Commit Rate** - Consumer activity

**Import dashboardu:**
1. Prejdi do **Grafana** (port 3000)
2. Klikni **Dashboards** → **New** → **Import**
3. Zadaj ID: **7589**
4. Vyber datasource: **Prometheus**
5. Klikni **Import**

Alebo automaticky pri štarte (pridaj do `grafana/dashboards/`):
```bash
curl -o grafana/dashboards/kafka-exporter-overview.json \
  'https://grafana.com/api/dashboards/7589/revisions/1/download'
```


## Switch to Kafka Exporter Setup

Stop the current environment and start with Kafka Exporter:

```terminal:execute
command: |
  echo "Stopping current environment..."
  docker compose down
  echo "Starting environment with Kafka Exporter..."
  docker compose -f docker-compose-exporter.yml up -d
session: 1
```

Wait for services to be ready:

```terminal:execute
command: docker compose -f docker-compose-exporter.yml ps
session: 1
```

## Verify Kafka Exporter

Check that Kafka Exporter is running and exposing metrics:

```terminal:execute
command: |
  echo "=== Kafka Exporter Metrics ==="
  curl -s http://localhost:9308/metrics | head -n 40
session: 1
```

Key metric families from Kafka Exporter:
- `kafka_consumergroup_*` - Consumer group metrics
- `kafka_topic_*` - Topic-level metrics  
- `kafka_brokers` - Broker count

## Recreate Test Environment

Create topic and start producers/consumers:

```terminal:execute
command: |
  # Create topic
  docker exec kafka kafka-topics --create \
    --topic monitoring-demo \
    --partitions 3 \
    --replication-factor 1 \
    --bootstrap-server localhost:9092 \
    --if-not-exists
  
  # Start producer
  nohup ./generators/simple-producer.sh monitoring-demo 10 > producer.log 2>&1 &
  
  echo "Environment ready"
session: 1
```

## Consumer Group Lag Monitoring

Create multiple consumer groups to demonstrate lag tracking:

### Fast Consumer (No Lag)

```terminal:execute
command: |
  docker exec -d kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic monitoring-demo \
    --group fast-consumer \
    --from-beginning > /dev/null 2>&1
  echo "Fast consumer started"
session: 1
```

### Slow Consumer (With Lag)

```terminal:execute
command: |
  nohup ./generators/slow-consumer.sh monitoring-demo slow-consumer 500 > slow.log 2>&1 &
  echo "Slow consumer started (processes 2 msg/sec)"
session: 2
```

### Very Slow Consumer (High Lag)

```terminal:execute
command: |
  nohup ./generators/slow-consumer.sh monitoring-demo very-slow-consumer 2000 > very-slow.log 2>&1 &
  echo "Very slow consumer started (processes 0.5 msg/sec)"
session: 2
```

## Query Kafka Exporter Metrics

### Consumer Group Lag

```terminal:execute
command: |
  echo "=== Consumer Group Lag by Group ==="
  curl -s http://localhost:9308/metrics | grep "kafka_consumergroup_lag{" | grep -v "# "
session: 1
```

### Lag by Partition

```terminal:execute
command: |
  echo "=== Lag per Partition ==="
  curl -s http://localhost:9308/metrics | \
    grep 'kafka_consumergroup_lag{.*topic="monitoring-demo"' | \
    grep -v "# " | \
    sort -t= -k2 -n
session: 1
```

### Current Offset by Consumer Group

```terminal:execute
command: |
  echo "=== Current Offsets ==="
  curl -s http://localhost:9308/metrics | grep "kafka_consumergroup_current_offset{" | grep -v "# "
session: 1
```

### Uncommitted Offsets

```terminal:execute
command: |
  echo "=== Uncommitted Offsets ==="
  curl -s http://localhost:9308/metrics | grep "kafka_consumergroup_uncommitted_offsets" | grep -v "# "
session: 1
```

## Topic Metrics

### Partition Count

```terminal:execute
command: |
  echo "=== Topic Partitions ==="
  curl -s http://localhost:9308/metrics | grep "kafka_topic_partitions" | grep -v "# "
session: 1
```

### Topic Offset (High Water Mark)

```terminal:execute
command: |
  echo "=== Topic Offsets (Latest) ==="
  curl -s http://localhost:9308/metrics | grep 'kafka_topic_partition_current_offset{.*topic="monitoring-demo"'
session: 1
```

### Replicas and ISR

```terminal:execute
command: |
  echo "=== Replica Information ==="
  curl -s http://localhost:9308/metrics | grep -E "kafka_topic_partition_(replicas|in_sync_replica)" | grep monitoring-demo
session: 1
```

## Prometheus Queries for Kafka Exporter

Open the **Prometheus** tab and try these queries:

### Query 1: Total Consumer Lag per Group

```
sum by (consumergroup) (kafka_consumergroup_lag)
```

### Query 2: Lag Rate of Change

```
rate(kafka_consumergroup_lag[5m])
```

Positive values = lag increasing (consumer falling behind)
Negative values = lag decreasing (consumer catching up)

### Query 3: Consumers At Risk

```
kafka_consumergroup_lag > 100
```

Shows groups with more than 100 messages lag.

### Query 4: Partition Distribution

```
sum by (partition) (kafka_topic_partition_current_offset{topic="monitoring-demo"})
```

### Query 5: Consumer Group Members

```
kafka_consumergroup_members
```

## Watch Lag Evolution

Monitor how lag changes over time:

```terminal:execute
command: |
  echo "=== Consumer Lag Summary ==="
  echo "Group | Total Lag"
  echo "------|----------"
  
  curl -s http://localhost:9308/metrics | \
    grep 'kafka_consumergroup_lag{' | \
    awk '{
      match($0, /consumergroup="([^"]+)"/, group);
      match($0, /} ([0-9.]+)/, lag);
      groups[group[1]] += lag[1];
    } END {
      for (g in groups) printf "%-20s | %10.0f\n", g, groups[g]
    }' | sort
session: 1
```

You should see:
- **fast-consumer**: Lag stays at 0
- **slow-consumer**: Lag grows slowly
- **very-slow-consumer**: Lag grows quickly

## Comparing JMX vs Kafka Exporter

### JMX Exporter Strengths
- Broker-level metrics (CPU, memory, disk I/O)
- Request latencies
- JVM performance
- Network throughput

### Kafka Exporter Strengths  
- **Per-partition lag** (JMX only shows totals)
- **Consumer group details** (members, coordinator)
- **Simpler setup** (no JVM agent needed)
- **Topic metadata** (replicas, ISR status)

## Best Use: Combine Both!

Production monitoring typically uses:
1. **JMX Exporter** - Broker health and performance
2. **Kafka Exporter** - Consumer lag and topic metrics
3. **Both in Prometheus** - Unified view in Grafana

## Alerting with Kafka Exporter

Example Prometheus alert rules:

```editor:append-lines-to-file
file: ~/kafka-exporter-alerts.yml
text: |
  groups:
  - name: kafka_exporter_alerts
    interval: 30s
    rules:
    - alert: ConsumerGroupLagHigh
      expr: kafka_consumergroup_lag > 1000
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Consumer group {{ $labels.consumergroup }} lag is high"
        description: "Partition {{ $labels.partition }} has {{ $value }} messages lag"
    
    - alert: ConsumerGroupLagGrowing
      expr: rate(kafka_consumergroup_lag[10m]) > 0
      for: 15m
      labels:
        severity: warning
      annotations:
        summary: "Consumer group {{ $labels.consumergroup }} is falling behind"
        description: "Lag is increasing at {{ $value }} msg/sec"
    
    - alert: NoConsumerGroupMembers
      expr: kafka_consumergroup_members == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Consumer group {{ $labels.consumergroup }} has no active members"
        description: "No consumers are processing messages"
    
    - alert: PartitionUnderReplicated
      expr: kafka_topic_partition_in_sync_replica < kafka_topic_partition_replicas
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Partition {{ $labels.topic }}-{{ $labels.partition }} is under-replicated"
        description: "ISR: {{ $value }}, Replicas: {{ $labels.replicas }}"
```

## Cleanup

Stop the slow consumers:

```terminal:execute
command: |
  pkill -f slow-consumer.sh
  pkill -f simple-producer.sh
  echo "Generators stopped"
session: 2
```

## Summary

Kafka Exporter provides:
- ✅ **Granular lag tracking** - Per partition, per consumer
- ✅ **Consumer health** - Group membership and coordination
- ✅ **Topic insights** - Replication status
- ✅ **Easy setup** - No JVM modification needed

Perfect complement to JMX metrics! Next, we'll visualize everything in Grafana.
