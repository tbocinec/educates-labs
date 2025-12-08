# KMinion - Advanced Kafka Monitoring

Explore enterprise-grade Kafka monitoring with KMinion from Redpanda Data - the next generation of Kafka observability.

## What is KMinion?

**KMinion** (Kafka Minion) is a modern Kafka exporter created by Redpanda Data that goes beyond traditional exporters:

| Feature | Kafka Exporter | JMX Exporter | **KMinion** |
|---------|----------------|--------------|-------------|
| **Consumer Lag** | ✅ Basic | ❌ No | ✅ **Advanced** |
| **Topic Info** | ✅ Basic | ❌ No | ✅ **Detailed** |
| **End-to-End Latency** | ❌ No | ❌ No | ✅ **Yes!** |
| **Topic Configuration** | ❌ No | ❌ No | ✅ **Yes** |
| **ACL Monitoring** | ❌ No | ❌ No | ✅ **Yes** |
| **Log Dir Sizes** | ❌ No | ⚠️ Limited | ✅ **Detailed** |
| **Setup Complexity** | Easy | Medium | **Easy** |
| **Performance** | Good | Medium | **Excellent** |

### Unique KMinion Features

**1. End-to-End Latency Monitoring**
- Measures actual message roundtrip time
- Creates "canary" messages to test real latency
- Critical for SLA monitoring

**2. Topic Configuration Tracking**
- Monitors retention policies
- Tracks min.insync.replicas changes
- Alerts on misconfiguration

**3. Log Directory Sizes**
- Per-topic disk usage
- Partition size distribution
- Capacity planning metrics

**4. Modern Architecture**
- Written in Go (fast, low memory)
- Cloud-native design
- Kubernetes-ready

## Why KMinion Was Created

Redpanda Data (creators of Redpanda, Kafka-compatible streaming platform) built KMinion because:
- Existing exporters lacked end-to-end visibility
- No good way to measure actual user experience
- Need for configuration drift detection
- Production-grade observability requirements

## Switch to KMinion Setup

Stop current environment and start with KMinion:

```terminal:execute
command: |
  cd ~/kafka-monitoring
  echo "Stopping current environment..."
  docker compose down
  echo "Starting environment with KMinion..."
  docker compose -f docker-compose-kminion.yml up -d
session: 1
```

Wait for services to be ready:

```terminal:execute
command: |
  cd ~/kafka-monitoring
  echo "Waiting for Kafka to be healthy..."
  sleep 10
  docker compose -f docker-compose-kminion.yml ps
session: 1
```

## Verify KMinion

Check that KMinion is running and collecting metrics:

```terminal:execute
command: |
  echo "=== KMinion Health ==="
  curl -s http://localhost:8081/metrics | head -n 50
session: 1
```

Key metric families from KMinion:
- `kminion_kafka_*` - Kafka cluster metrics
- `kminion_consumer_group_*` - Consumer group details
- `kminion_topic_*` - Topic-level metrics
- `kminion_partition_*` - Partition-specific data
- `kminion_end_to_end_*` - Latency measurements

## Setup Test Environment

Create topics and start traffic generators:

```terminal:execute
command: |
  # Create main topic
  docker exec kafka kafka-topics --create \
    --topic monitoring-demo \
    --partitions 3 \
    --replication-factor 1 \
    --bootstrap-server localhost:9092 \
    --if-not-exists
  
  # Create topic with different config
  docker exec kafka kafka-topics --create \
    --topic high-retention \
    --partitions 2 \
    --replication-factor 1 \
    --config retention.ms=604800000 \
    --bootstrap-server localhost:9092 \
    --if-not-exists
  
  # Start producer
  nohup ./generators/simple-producer.sh monitoring-demo 10 > producer.log 2>&1 &
  
  echo "✅ Topics created and producer started"
  sleep 5
session: 1
```

## KMinion Consumer Group Metrics

KMinion provides enhanced consumer group monitoring:

### Consumer Group Lag (Enhanced)

```terminal:execute
command: |
  echo "=== Consumer Group Lag (KMinion) ==="
  curl -s http://localhost:8081/metrics | grep "kminion_consumer_group_topic_lag{" | head -n 20
session: 1
```

Notice the rich labels:
- `consumer_group` - Group name
- `topic` - Topic name
- `partition` - Partition number
- `group_state` - State (Stable, Dead, etc.)

### Consumer Group Offset Commit Rate

```terminal:execute
command: |
  echo "=== Offset Commit Rate ==="
  curl -s http://localhost:8081/metrics | grep "kminion_consumer_group_commit_count"
session: 1
```

### Consumer Group Members

```terminal:execute
command: |
  echo "=== Active Consumer Members ==="
  curl -s http://localhost:8081/metrics | grep "kminion_consumer_group_members{"
session: 1
```

## Topic Metrics (Advanced)

KMinion provides detailed topic analytics:

### Topic Configuration

```terminal:execute
command: |
  echo "=== Topic Retention Configuration ==="
  curl -s http://localhost:8081/metrics | grep "kminion_topic_info.*retention"
session: 1
```

### Topic Partition Count

```terminal:execute
command: |
  echo "=== Topic Partitions ==="
  curl -s http://localhost:8081/metrics | grep "kminion_kafka_topic_partition_count{"
session: 1
```

### Topic Log Directory Size

```terminal:execute
command: |
  echo "=== Topic Disk Usage ==="
  curl -s http://localhost:8081/metrics | grep "kminion_kafka_topic_log_dir_size_total{"
session: 1
```

This shows actual disk space used by each topic!

## Partition-Level Metrics

### High Water Mark

```terminal:execute
command: |
  echo "=== Partition High Water Marks ==="
  curl -s http://localhost:8081/metrics | \
    grep 'kminion_kafka_topic_partition_high_water_mark{.*topic="monitoring-demo"'
session: 1
```

### Partition Size Distribution

```terminal:execute
command: |
  echo "=== Partition Sizes ==="
  curl -s http://localhost:8081/metrics | \
    grep 'kminion_kafka_partition_log_dir_size{.*topic="monitoring-demo"'
session: 1
```

## End-to-End Latency Monitoring

This is KMinion's killer feature!

### How It Works

KMinion can produce "canary" messages to topics and measure:
1. **Produce Latency** - Time to write message
2. **Commit Latency** - Time to replicate (if RF > 1)
3. **Consume Latency** - Time to read message back
4. **Roundtrip Latency** - Total end-to-end time

### View Latency Metrics

```terminal:execute
command: |
  echo "=== End-to-End Latency Metrics ==="
  curl -s http://localhost:8081/metrics | grep "kminion_end_to_end"
session: 1
```

**Note**: End-to-end monitoring requires configuration (see KMinion docs for setup).

## Broker Metrics

### Broker Information

```terminal:execute
command: |
  echo "=== Kafka Brokers ==="
  curl -s http://localhost:8081/metrics | grep "kminion_kafka_broker_info"
session: 1
```

### Broker Log Directory Size

```terminal:execute
command: |
  echo "=== Broker Storage Usage ==="
  curl -s http://localhost:8081/metrics | grep "kminion_kafka_broker_log_dir_size"
session: 1
```

## Prometheus Queries for KMinion

Open the **Prometheus** tab and try these advanced queries:

### Query 1: Consumer Lag by Topic

```
sum by (topic, consumer_group) (kminion_consumer_group_topic_lag)
```

### Query 2: Topic Size Growth Rate

```
rate(kminion_kafka_topic_log_dir_size_total[5m])
```

This shows which topics are growing fastest (bytes/sec).

### Query 3: Partition Size Skew

```
stddev by (topic) (kminion_kafka_partition_log_dir_size)
```

High standard deviation = unbalanced partitions.

### Query 4: Consumer Groups by State

```
count by (group_state) (kminion_consumer_group_members)
```

Shows how many groups are Stable, Dead, Empty, etc.

### Query 5: Topics Approaching Retention

```
kminion_kafka_topic_log_dir_size_total / kminion_topic_info{config="retention.bytes"} > 0.8
```

Alerts when topic is 80%+ of retention limit.

## Create Advanced Consumers for Testing

### Normal Consumer

```terminal:execute
command: |
  docker exec -d kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic monitoring-demo \
    --group kminion-test-consumer \
    --from-beginning > /dev/null 2>&1
  echo "✅ Consumer started"
session: 2
```

### Slow Consumer (Creates Lag)

```terminal:execute
command: |
  nohup ./generators/slow-consumer.sh monitoring-demo slow-kminion-consumer 1000 > slow-kminion.log 2>&1 &
  echo "✅ Slow consumer started (lag will increase)"
session: 2
```

Wait 30 seconds and check metrics:

```terminal:execute
command: |
  echo "=== Current Consumer Lag ==="
  curl -s http://localhost:8081/metrics | \
    grep 'kminion_consumer_group_topic_lag{.*consumer_group="slow-kminion-consumer"'
session: 1
```

## Grafana Dashboards for KMinion

KMinion má oficiálne Grafana dashboardy pre rôzne oblasti monitoringu:

### Oficiálne KMinion Dashboardy

**1. 📊 Cluster Dashboard (ID: 14012)**
- Celkový prehľad Kafka klastra
- Broker health a status
- Cluster-wide metriky
- 🔗 https://grafana.com/grafana/dashboards/14012

**2. 👥 Consumer Group Dashboard (ID: 14014)**
- Detailné consumer group lag metriky
- Group state monitoring
- Per-partition lag visualization
- Consumer member tracking
- 🔗 https://grafana.com/grafana/dashboards/14014

**3. 📦 Topic Dashboard (ID: 14013)**
- Topic-level metrics
- Partition distribution
- Disk usage per topic
- Retention policy tracking
- 🔗 https://grafana.com/grafana/dashboards/14013

### Manuálny Import Dashboardov

Otvor **Grafana** (port 3000) a pre každý dashboard:

1. Klikni na **Dashboards** → **New** → **Import**
2. Zadaj Dashboard ID:
   - **14012** pre Cluster Dashboard
   - **14014** pre Consumer Group Dashboard
   - **14013** pre Topic Dashboard
3. Klikni **Load**
4. Vyber datasource: **Prometheus**
5. Klikni **Import**

### Čo jednotlivé dashboardy zobrazujú

**Cluster Dashboard (14012):**
- 🟢 Broker Online Status
- 📊 Total Topics & Partitions
- 💾 Total Disk Usage
- ⚡ Cluster Throughput (messages/sec, bytes/sec)
- 🎯 Active Controllers

**Consumer Group Dashboard (14014):**
- 📈 Lag Trend per Consumer Group
- 🔥 Lag Heatmap (partition-level)
- 👤 Consumer Group Members Count
- ⏱️ Offset Commit Rate
- ⚠️ Groups with High Lag

**Topic Dashboard (14013):**
- 📦 Topic List with Partition Count
- 💾 Disk Usage per Topic
- 📊 Message Rate per Topic
- 🔄 Replication Status
- ⚙️ Topic Configuration (retention, cleanup policy)

### Prečo Tri Samostatné Dashboardy?

KMinion rozdeľuje monitoring do logických celkov:
- **Cluster** = Infrastructure ops team (SRE)
- **Consumer Groups** = Application teams (developers)
- **Topics** = Data platform team (data engineers)

Každý tím môže sledovať len svoje oblasti!

### Alternative: GitHub Dashboards

Môžeš si stiahnuť JSON súbory priamo z GitHub:

```bash
# Cluster Dashboard
curl -o grafana/dashboards/kminion-cluster.json \
  https://grafana.com/api/dashboards/14012/revisions/latest/download

# Consumer Group Dashboard  
curl -o grafana/dashboards/kminion-consumer-groups.json \
  https://grafana.com/api/dashboards/14014/revisions/latest/download

# Topic Dashboard
curl -o grafana/dashboards/kminion-topics.json \
  https://grafana.com/api/dashboards/14013/revisions/latest/download
```

Potom reštartuj Grafanu aby sa načítali automaticky.

## KMinion vs Other Exporters

### When to Use KMinion

✅ **Best for:**
- Production SLA monitoring (end-to-end latency)
- Multi-tenant Kafka (per-topic tracking)
- Capacity planning (disk usage trends)
- Configuration compliance
- Large-scale deployments

⚠️ **Not needed if:**
- Small dev/test cluster
- Only need basic lag monitoring
- Already using enterprise monitoring (Confluent Control Center)

### Combining Exporters

Many teams use **multiple exporters**:

```
JMX Exporter    → Broker JVM health (memory, GC, threads)
Kafka Exporter  → Basic consumer lag
KMinion         → Advanced metrics + end-to-end latency
```

Each provides different insights!

## Comparing Metrics

Let's compare the same metric across exporters:

### Consumer Lag - Different Views

**Kafka Exporter:**
```bash
curl -s localhost:9308/metrics | grep "kafka_consumergroup_lag"
# Basic lag count per partition
```

**KMinion:**
```bash
curl -s localhost:8081/metrics | grep "kminion_consumer_group_topic_lag"
# Lag + group state + coordinator info
```

KMinion adds context (group state, coordinator) that helps debugging.

## Configuration Monitoring Example

Check topic retention settings:

```terminal:execute
command: |
  echo "=== Topic Retention Policies ==="
  curl -s http://localhost:8081/metrics | \
    grep 'kminion_topic_info{' | \
    grep 'config="retention.ms"'
session: 1
```

This is invaluable for:
- Auditing retention compliance
- Detecting configuration drift
- Capacity planning

## Best Practices with KMinion

### 1. Enable End-to-End Monitoring for Critical Topics

Configure KMinion to produce canary messages to your most important topics.

### 2. Alert on Configuration Changes

```promql
changes(kminion_topic_info[10m]) > 0
```

Alerts when topic configs change unexpectedly.

### 3. Monitor Storage Growth

```promql
predict_linear(kminion_kafka_topic_log_dir_size_total[1h], 7*24*3600) > 1e12
```

Predicts which topics will exceed 1TB in 7 days.

### 4. Track Consumer Group Health

```promql
kminion_consumer_group_members{group_state!="Stable"} > 0
```

Alerts on unhealthy consumer groups.

## Cleanup

Stop generators:

```terminal:execute
command: |
  pkill -f simple-producer.sh
  pkill -f slow-consumer.sh
  echo "✅ Generators stopped"
session: 2
```

## Summary

KMinion provides enterprise-grade monitoring:

- ✅ **End-to-end latency** - Real user experience metrics
- ✅ **Configuration tracking** - Audit and compliance
- ✅ **Disk usage monitoring** - Capacity planning
- ✅ **Advanced consumer metrics** - Detailed lag analysis
- ✅ **Production-ready** - Used by Redpanda and customers
- ✅ **Low overhead** - Efficient Go implementation

**Key Takeaways:**
- KMinion complements JMX and Kafka Exporter
- Best for production environments with SLA requirements
- Official Redpanda tool, actively maintained
- End-to-end latency is unique to KMinion
- Configuration monitoring prevents drift

**Next Steps:**
- Import KMinion Grafana dashboard
- Configure end-to-end monitoring
- Set up alerts for critical metrics
- Combine with JMX metrics for complete visibility

KMinion represents the future of Kafka observability - giving you insights that traditional exporters simply can't provide!
