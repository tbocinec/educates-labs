# Monitoring Configuration

Configure comprehensive monitoring, metrics collection, alerting, and observability for Kafka clusters in production. 📊

---

## Understanding Kafka Monitoring

**📈 Monitoring Dimensions:**
- **Broker metrics** - Throughput, latency, resource utilization
- **Topic metrics** - Message rates, partition statistics, retention
- **Client metrics** - Producer/consumer performance and lag
- **System metrics** - CPU, memory, disk, network utilization

**🔧 Monitoring Stack Components:**
- JMX (Java Management Extensions) for Kafka metrics
- System monitoring tools (Prometheus, Grafana, etc.)
- Log aggregation and analysis
- Application-level metrics and traces

---

## JMX Metrics Configuration

**Enable JMX on Kafka broker:**

```terminal:execute
command: docker exec kafka bash -c "
# Create JMX-enabled broker configuration
tee /tmp/jmx-broker.properties << 'EOF'
# JMX-enabled Kafka broker configuration

## Basic Broker Settings
broker.id=1
listeners=PLAINTEXT://localhost:9092
advertised.listeners=PLAINTEXT://localhost:9092
log.dirs=/tmp/kafka-logs-jmx

## JMX Configuration
jmx.port=9999

## Metrics Configuration
metric.reporters=org.apache.kafka.common.metrics.JmxReporter
metrics.sample.window.ms=30000
metrics.num.samples=2
metrics.recording.level=INFO

## Additional Monitoring Settings
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
EOF

echo 'JMX broker configuration created'
"
background: false
```

**Create JMX monitoring script:**

```terminal:execute
command: docker exec kafka tee /tmp/jmx-monitor.sh << 'EOF'
#!/bin/bash
# JMX monitoring script for Kafka

echo "=== Kafka JMX Metrics Monitoring ==="

# Function to query JMX metric
query_jmx() {
    local mbean="$1"
    local attribute="$2"
    local description="$3"
    
    echo "📊 $description"
    # Simulated JMX query - in real environment would use JMX tools
    echo "   MBean: $mbean"
    echo "   Attribute: $attribute"
    echo "   Sample command: jmxterm -l localhost:9999 -n <<< \"get -b $mbean $attribute\""
    echo
}

echo "1. Broker Metrics"
query_jmx "kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec" "Count,FifteenMinuteRate" "Messages received per second"
query_jmx "kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec" "Count,FifteenMinuteRate" "Bytes received per second"  
query_jmx "kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec" "Count,FifteenMinuteRate" "Bytes sent per second"

echo "2. Request Metrics"
query_jmx "kafka.network:type=RequestMetrics,name=RequestsPerSec,request=Produce" "Count,FifteenMinuteRate" "Produce requests per second"
query_jmx "kafka.network:type=RequestMetrics,name=TotalTimeMs,request=Produce" "Mean,99thPercentile" "Produce request latency"
query_jmx "kafka.network:type=RequestMetrics,name=TotalTimeMs,request=FetchConsumer" "Mean,99thPercentile" "Consumer fetch latency"

echo "3. Partition Metrics"  
query_jmx "kafka.log:type=LogSize,name=Size,topic=*" "Value" "Log size by topic"
query_jmx "kafka.cluster:type=Partition,name=UnderReplicated,topic=*" "Value" "Under-replicated partitions"

echo "4. Controller Metrics"
query_jmx "kafka.controller:type=KafkaController,name=ActiveControllerCount" "Value" "Active controller count"
query_jmx "kafka.controller:type=ControllerStats,name=LeaderElectionRateAndTimeMs" "Count,Mean" "Leader election rate"

echo "=== JMX Monitoring Complete ==="
EOF

chmod +x /tmp/jmx-monitor.sh
/tmp/jmx-monitor.sh
background: false
```

**📚 Documentation:** [JMX Metrics Guide](https://kafka.apache.org/documentation/#monitoring)

---

## Key Kafka Metrics

**Create metrics reference guide:**

```terminal:execute
command: docker exec kafka tee /tmp/kafka-metrics-guide.txt << 'EOF'
# Essential Kafka Metrics Reference Guide

## 🚀 Broker Performance Metrics

### Throughput Metrics
- kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec
  * Count: Total messages received
  * FifteenMinuteRate: Messages per second (15min avg)
  
- kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec  
  * Measures data ingestion rate
  * Key for capacity planning

- kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec
  * Measures data consumption rate
  * Important for network capacity

### Request Metrics
- kafka.network:type=RequestMetrics,name=RequestsPerSec,request={Produce|FetchConsumer|FetchFollower}
  * Request rate by type
  * Monitor for load patterns

- kafka.network:type=RequestMetrics,name=TotalTimeMs,request={Produce|FetchConsumer}
  * End-to-end request latency
  * Critical for SLA monitoring

### Resource Metrics  
- kafka.server:type=BrokerTopicMetrics,name=TotalProduceRequestsPerSec
- kafka.server:type=BrokerTopicMetrics,name=TotalFetchRequestsPerSec
- kafka.server:type=BrokerTopicMetrics,name=FailedProduceRequestsPerSec

## 📊 Topic and Partition Metrics

### Log Metrics
- kafka.log:type=LogSize,name=Size,topic=*,partition=*
  * Current log size per partition
  * Monitor for retention policy effectiveness

- kafka.log:type=LogEndOffset,name=Value,topic=*,partition=*
  * Current offset (message count)
  * Track message volume per partition

### Replication Metrics
- kafka.server:type=ReplicaManager,name=UnderReplicatedPartitions
  * Partitions with insufficient replicas
  * Critical availability metric

- kafka.server:type=ReplicaManager,name=PartitionCount
  * Total partitions on broker
  * Capacity planning metric

## 👥 Consumer Group Metrics

### Lag Metrics  
- kafka.consumer:type=consumer-fetch-manager-metrics,client-id=*,topic=*,partition=*
  * records-lag-max: Maximum lag across partitions
  * records-lag-avg: Average lag

- kafka.consumer:type=consumer-coordinator-metrics,client-id=*
  * commit-latency-avg: Offset commit latency
  * assigned-partitions: Partitions assigned to consumer

## 🔧 Controller Metrics
- kafka.controller:type=KafkaController,name=ActiveControllerCount
  * Should always be 1 in healthy cluster
  * 0 indicates controller election in progress

- kafka.controller:type=ControllerStats,name=LeaderElectionRateAndTimeMs
  * Frequency and duration of leader elections
  * High values indicate instability

## 💾 JVM and System Metrics
- Memory usage: java.lang:type=Memory
- Garbage collection: java.lang:type=GarbageCollector,name=*
- Thread count: java.lang:type=Threading
- File descriptor usage: Operating system metrics
EOF
background: false
```

---

## Producer and Consumer Monitoring

**Create producer metrics monitoring:**

```terminal:execute
command: docker exec kafka bash -c "
# Create producer with metrics
tee /tmp/producer-with-metrics.properties << 'EOF'
bootstrap.servers=localhost:9092
acks=all
retries=3
batch.size=16384
linger.ms=5
buffer.memory=33554432

## Metrics Configuration
metrics.sample.window.ms=30000
metrics.num.samples=2
metric.reporters=org.apache.kafka.common.metrics.JmxReporter
EOF

# Test producer with metrics
echo 'Testing producer with metrics enabled:'
echo 'hello-world-with-metrics' | kafka-console-producer --bootstrap-server localhost:9092 --topic monitoring-test --producer.config /tmp/producer-with-metrics.properties

echo 'Producer metrics configuration created'
"
background: false
```

**Create consumer metrics monitoring:**

```terminal:execute
command: docker exec kafka bash -c "
# Create consumer with metrics
tee /tmp/consumer-with-metrics.properties << 'EOF'
bootstrap.servers=localhost:9092
group.id=monitoring-group
enable.auto.commit=true
auto.commit.interval.ms=1000
fetch.min.bytes=1
fetch.max.wait.ms=500

## Metrics Configuration  
metrics.sample.window.ms=30000
metrics.num.samples=2
metric.reporters=org.apache.kafka.common.metrics.JmxReporter
EOF

echo 'Consumer metrics configuration created'
echo 'Test command: kafka-console-consumer --bootstrap-server localhost:9092 --topic monitoring-test --consumer.config /tmp/consumer-with-metrics.properties --from-beginning --max-messages 1'
"
background: false
```

**Monitor consumer lag:**

```terminal:execute
command: docker exec kafka bash -c "
echo '=== Consumer Lag Monitoring ==='

# Create test consumer group
timeout 5 kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --group lag-test-group --max-messages 5 2>/dev/null || echo 'Consumer test completed'

echo '1. Consumer Group Lag Analysis:'
kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group lag-test-group 2>/dev/null || echo 'Consumer group created for monitoring'

echo -e '\n2. All Consumer Groups Overview:'
kafka-consumer-groups --bootstrap-server localhost:9092 --list

echo -e '\n3. Consumer Group State:'  
kafka-consumer-groups --bootstrap-server localhost:9092 --describe --all-groups | head -20
"
background: false
```

---

## Log-based Monitoring

**Configure detailed logging:**

```terminal:execute
command: docker exec kafka tee /tmp/monitoring-log4j.properties << 'EOF'
# Enhanced logging configuration for monitoring

## Root Logger
log4j.rootLogger=INFO, stdout, fileAppender

## Console Appender
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p [%t] %c{1}:%L - %m%n

## File Appender for All Logs
log4j.appender.fileAppender=org.apache.log4j.RollingFileAppender
log4j.appender.fileAppender.File=/opt/kafka/logs/kafka-monitoring.log
log4j.appender.fileAppender.layout=org.apache.log4j.PatternLayout  
log4j.appender.fileAppender.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p [%t] %c{1}:%L - %m%n
log4j.appender.fileAppender.MaxFileSize=100MB
log4j.appender.fileAppender.MaxBackupIndex=10

## Request Logging
log4j.logger.kafka.request.logger=INFO, requestAppender
log4j.additivity.kafka.request.logger=false

log4j.appender.requestAppender=org.apache.log4j.RollingFileAppender
log4j.appender.requestAppender.File=/opt/kafka/logs/kafka-request.log
log4j.appender.requestAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.requestAppender.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p [%t] %c: %m%n
log4j.appender.requestAppender.MaxFileSize=100MB
log4j.appender.requestAppender.MaxBackupIndex=5

## Controller Logging
log4j.logger.kafka.controller=INFO, controllerAppender  
log4j.additivity.kafka.controller=false

log4j.appender.controllerAppender=org.apache.log4j.RollingFileAppender
log4j.appender.controllerAppender.File=/opt/kafka/logs/kafka-controller.log
log4j.appender.controllerAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.controllerAppender.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p [%t] %c: %m%n
log4j.appender.controllerAppender.MaxFileSize=100MB
log4j.appender.controllerAppender.MaxBackupIndex=5

## State Change Logging
log4j.logger.state.change.logger=INFO, stateChangeAppender
log4j.additivity.state.change.logger=false

log4j.appender.stateChangeAppender=org.apache.log4j.RollingFileAppender
log4j.appender.stateChangeAppender.File=/opt/kafka/logs/kafka-state-change.log  
log4j.appender.stateChangeAppender.layout=org.apache.log4j.PatternLayout
log4j.appender.stateChangeAppender.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p [%t] %c: %m%n
log4j.appender.stateChangeAppender.MaxFileSize=100MB
log4j.appender.stateChangeAppender.MaxBackupIndex=5
EOF
background: false
```

**Create log analysis script:**

```terminal:execute
command: docker exec kafka tee /tmp/log-analysis.sh << 'EOF'
#!/bin/bash
# Kafka log analysis script

echo "=== Kafka Log Analysis ==="

# Function to analyze log file
analyze_log() {
    local log_file="$1"
    local description="$2"
    
    echo "📄 $description"
    if [ -f "$log_file" ]; then
        echo "   Last modified: $(stat -c %y "$log_file" 2>/dev/null || echo 'unknown')"
        echo "   Size: $(du -h "$log_file" 2>/dev/null | cut -f1 || echo 'unknown')"
        echo "   Recent entries:"
        tail -3 "$log_file" 2>/dev/null | sed 's/^/     /' || echo "     (no recent entries)"
    else
        echo "   Status: File not found"
    fi
    echo
}

echo "1. Main Kafka Logs"
analyze_log "/opt/kafka/logs/server.log" "Main server log"
analyze_log "/opt/kafka/logs/kafka-monitoring.log" "Enhanced monitoring log"

echo "2. Specialized Logs"  
analyze_log "/opt/kafka/logs/kafka-request.log" "Request logging"
analyze_log "/opt/kafka/logs/kafka-controller.log" "Controller events"
analyze_log "/opt/kafka/logs/kafka-state-change.log" "State changes"

echo "3. Error Analysis"
echo "🔍 Recent errors and warnings:"
if [ -f "/opt/kafka/logs/server.log" ]; then
    grep -i "error\|warn\|exception" /opt/kafka/logs/server.log 2>/dev/null | tail -5 | sed 's/^/     /' || echo "     (no recent errors found)"
else
    echo "     (server.log not available)"
fi

echo -e "\n4. Log Directory Overview"
if [ -d "/opt/kafka/logs" ]; then
    ls -lah /opt/kafka/logs/ | head -10
else
    echo "Logs directory not found"
fi

echo -e "\n=== Log Analysis Complete ==="
EOF

chmod +x /tmp/log-analysis.sh
/tmp/log-analysis.sh
background: false
```

---

## Health Checks and Alerts

**Create health check script:**

```terminal:execute
command: docker exec kafka tee /tmp/kafka-health-check.sh << 'EOF'
#!/bin/bash
# Comprehensive Kafka health check script

echo "=== Kafka Health Check ==="

# Exit codes for monitoring systems
EXIT_OK=0
EXIT_WARNING=1  
EXIT_CRITICAL=2

health_status=$EXIT_OK
warnings=0
critical=0

# Function to log health status
log_status() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $level: $message"
    
    case $level in
        "CRITICAL")
            critical=$((critical + 1))
            health_status=$EXIT_CRITICAL
            ;;
        "WARNING")
            warnings=$((warnings + 1))
            if [ $health_status -eq $EXIT_OK ]; then
                health_status=$EXIT_WARNING
            fi
            ;;
        "OK")
            ;;
    esac
}

echo "🏥 Starting health checks..."

# Check 1: Broker connectivity
echo -e "\n1. Broker Connectivity"
if timeout 10 kafka-broker-api-versions --bootstrap-server localhost:9092 >/dev/null 2>&1; then
    log_status "OK" "Broker is accessible on port 9092"
else
    log_status "CRITICAL" "Cannot connect to broker on port 9092"
fi

# Check 2: Topic operations
echo -e "\n2. Topic Operations"  
if timeout 10 kafka-topics --bootstrap-server localhost:9092 --list >/dev/null 2>&1; then
    topic_count=$(kafka-topics --bootstrap-server localhost:9092 --list 2>/dev/null | wc -l)
    log_status "OK" "Topic operations working, $topic_count topics found"
else
    log_status "CRITICAL" "Topic operations failing"
fi

# Check 3: Consumer group functionality
echo -e "\n3. Consumer Group Status"
if timeout 10 kafka-consumer-groups --bootstrap-server localhost:9092 --list >/dev/null 2>&1; then
    group_count=$(kafka-consumer-groups --bootstrap-server localhost:9092 --list 2>/dev/null | wc -l)
    log_status "OK" "Consumer group operations working, $group_count groups found"
else
    log_status "WARNING" "Consumer group operations may have issues"
fi

# Check 4: Disk space
echo -e "\n4. Disk Space"
disk_usage=$(df /tmp | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 90 ]; then
    log_status "CRITICAL" "Disk usage is ${disk_usage}% (>90%)"
elif [ "$disk_usage" -gt 80 ]; then
    log_status "WARNING" "Disk usage is ${disk_usage}% (>80%)"
else
    log_status "OK" "Disk usage is ${disk_usage}%"
fi

# Check 5: Process status
echo -e "\n5. Process Status"
if pgrep -f kafka >/dev/null; then
    process_count=$(pgrep -f kafka | wc -l)
    log_status "OK" "Kafka process running ($process_count processes)"
else
    log_status "CRITICAL" "Kafka process not found"
fi

# Check 6: Memory usage
echo -e "\n6. Memory Usage"
if command -v free >/dev/null; then
    memory_usage=$(free | grep '^Mem:' | awk '{printf("%.0f", ($3/$2)*100)}')
    if [ "$memory_usage" -gt 90 ]; then
        log_status "WARNING" "Memory usage is ${memory_usage}%"
    else
        log_status "OK" "Memory usage is ${memory_usage}%"
    fi
else
    log_status "WARNING" "Cannot check memory usage"
fi

# Summary
echo -e "\n=== Health Check Summary ==="
echo "Status: $([ $health_status -eq $EXIT_OK ] && echo "HEALTHY" || [ $health_status -eq $EXIT_WARNING ] && echo "WARNING" || echo "CRITICAL")"
echo "Warnings: $warnings"  
echo "Critical: $critical"
echo "Timestamp: $(date)"

exit $health_status
EOF

chmod +x /tmp/kafka-health-check.sh
/tmp/kafka-health-check.sh
background: false
```

**Create alerting configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/kafka-alerts.yaml << 'EOF'
# Kafka monitoring alerts configuration (example for Prometheus/AlertManager)

groups:
  - name: kafka-broker-alerts
    rules:
      ## Critical Alerts
      - alert: KafkaBrokerDown
        expr: up{job="kafka"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Kafka broker is down"
          description: "Kafka broker {{ $labels.instance }} has been down for more than 1 minute"

      - alert: KafkaUnderReplicatedPartitions
        expr: kafka_server_replicamanager_underreplicatedpartitions > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Under-replicated partitions detected"
          description: "{{ $value }} under-replicated partitions detected on {{ $labels.instance }}"

      ## Warning Alerts  
      - alert: KafkaHighRequestLatency
        expr: kafka_network_requestmetrics_totaltimems{quantile="0.99",request="Produce"} > 1000
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High produce request latency"
          description: "99th percentile produce latency is {{ $value }}ms on {{ $labels.instance }}"

      - alert: KafkaConsumerLag
        expr: kafka_consumer_lag_max > 1000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High consumer lag detected"
          description: "Consumer lag is {{ $value }} messages for {{ $labels.consumer_group }}"

      - alert: KafkaHighDiskUsage
        expr: (node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes > 0.8
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High disk usage on Kafka node"
          description: "Disk usage is {{ $value | humanizePercentage }} on {{ $labels.instance }}"

  - name: kafka-performance-alerts
    rules:
      - alert: KafkaLowThroughput
        expr: rate(kafka_server_brokertopicmetrics_messagesinpersec_total[5m]) < 100
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Low message ingestion rate"
          description: "Message ingestion rate is {{ $value }} msg/sec on {{ $labels.instance }}"

      - alert: KafkaHighMemoryUsage
        expr: (1 - (node_memory_available_bytes / node_memory_total_bytes)) > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on Kafka node"
          description: "Memory usage is {{ $value | humanizePercentage }} on {{ $labels.instance }}"
EOF
background: false
```

---

## Dashboard Configuration

**Create monitoring dashboard specification:**

```terminal:execute
command: docker exec kafka tee /tmp/kafka-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "Kafka Cluster Monitoring",
    "description": "Comprehensive Kafka cluster monitoring dashboard",
    "panels": [
      {
        "title": "Broker Throughput",
        "type": "graph",
        "metrics": [
          "kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec",
          "kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec",
          "kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec"
        ],
        "description": "Messages and bytes per second through the broker"
      },
      {
        "title": "Request Latency",
        "type": "graph", 
        "metrics": [
          "kafka.network:type=RequestMetrics,name=TotalTimeMs,request=Produce",
          "kafka.network:type=RequestMetrics,name=TotalTimeMs,request=FetchConsumer"
        ],
        "description": "Request processing latency (mean and 99th percentile)"
      },
      {
        "title": "Consumer Lag",
        "type": "graph",
        "metrics": [
          "kafka.consumer:type=consumer-fetch-manager-metrics,records-lag-max",
          "kafka.consumer:type=consumer-fetch-manager-metrics,records-lag-avg"
        ],
        "description": "Consumer lag across all partitions and groups"
      },
      {
        "title": "Under-Replicated Partitions", 
        "type": "singlestat",
        "metrics": [
          "kafka.server:type=ReplicaManager,name=UnderReplicatedPartitions"
        ],
        "description": "Number of partitions with insufficient replicas"
      },
      {
        "title": "Active Controller Count",
        "type": "singlestat",
        "metrics": [
          "kafka.controller:type=KafkaController,name=ActiveControllerCount"
        ],
        "description": "Number of active controllers (should be 1)"
      },
      {
        "title": "JVM Memory Usage",
        "type": "graph",
        "metrics": [
          "java.lang:type=Memory,HeapMemoryUsage.used",
          "java.lang:type=Memory,HeapMemoryUsage.max"
        ],
        "description": "JVM heap memory utilization"
      }
    ],
    "alerting": {
      "enabled": true,
      "notification_channels": ["email", "slack"],
      "rules": [
        {
          "name": "High Latency Alert",
          "condition": "TotalTimeMs.99thPercentile > 1000",
          "frequency": "1m"
        },
        {
          "name": "Under-Replicated Partitions",
          "condition": "UnderReplicatedPartitions > 0", 
          "frequency": "30s"
        }
      ]
    }
  }
}
EOF
background: false
```

**Create metrics collection script:**

```terminal:execute
command: docker exec kafka tee /tmp/collect-metrics.sh << 'EOF'
#!/bin/bash
# Metrics collection script for external monitoring systems

KAFKA_JMX_PORT=9999
BOOTSTRAP_SERVERS="localhost:9092"
OUTPUT_DIR="/tmp/kafka-metrics"

# Create output directory
mkdir -p $OUTPUT_DIR

echo "=== Kafka Metrics Collection ==="
echo "Timestamp: $(date -Iseconds)" > $OUTPUT_DIR/collection-$(date +%Y%m%d-%H%M%S).txt

# Collect broker metrics
echo "📊 Collecting broker metrics..."
{
    echo "## Broker Metrics"
    echo "messages_in_per_sec=$(kafka-run-class kafka.tools.JmxTool --jmx-url service:jmx:rmi:///jndi/rmi://localhost:9999/jmxrmi --object-name kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec --attributes FifteenMinuteRate 2>/dev/null || echo 'N/A')"
    
    echo "bytes_in_per_sec=$(kafka-run-class kafka.tools.JmxTool --jmx-url service:jmx:rmi:///jndi/rmi://localhost:9999/jmxrmi --object-name kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec --attributes FifteenMinuteRate 2>/dev/null || echo 'N/A')"
    
    echo "bytes_out_per_sec=$(kafka-run-class kafka.tools.JmxTool --jmx-url service:jmx:rmi:///jndi/rmi://localhost:9999/jmxrmi --object-name kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec --attributes FifteenMinuteRate 2>/dev/null || echo 'N/A')"
} >> $OUTPUT_DIR/collection-$(date +%Y%m%d-%H%M%S).txt

# Collect topic metrics
echo "📈 Collecting topic metrics..."
{
    echo -e "\n## Topic Metrics"
    kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --describe 2>/dev/null | grep -E "Topic:|PartitionCount:" | head -10
} >> $OUTPUT_DIR/collection-$(date +%Y%m%d-%H%M%S).txt

# Collect consumer group metrics
echo "👥 Collecting consumer group metrics..."
{
    echo -e "\n## Consumer Group Metrics"
    kafka-consumer-groups --bootstrap-server $BOOTSTRAP_SERVERS --describe --all-groups 2>/dev/null | head -20
} >> $OUTPUT_DIR/collection-$(date +%Y%m%d-%H%M%S).txt

# System metrics
echo "💻 Collecting system metrics..."
{
    echo -e "\n## System Metrics"
    echo "cpu_load=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | tr -d ' ')"
    echo "memory_usage=$(free | grep '^Mem:' | awk '{printf("%.2f", ($3/$2)*100)}')"
    echo "disk_usage=$(df /tmp | tail -1 | awk '{print $5}')"
} >> $OUTPUT_DIR/collection-$(date +%Y%m%d-%H%M%S).txt

echo "✅ Metrics collection completed"
echo "📁 Output saved to: $OUTPUT_DIR/collection-$(date +%Y%m%d-%H%M%S).txt"

# Show recent metrics file
echo -e "\n📋 Recent metrics:"
tail -20 $OUTPUT_DIR/collection-$(date +%Y%m%d-%H%M%S).txt
EOF

chmod +x /tmp/collect-metrics.sh
/tmp/collect-metrics.sh
background: false
```

---

## Monitoring Best Practices

**Create monitoring implementation guide:**

```terminal:execute
command: docker exec kafka tee /tmp/monitoring-best-practices.txt << 'EOF'
# Kafka Monitoring Best Practices Guide

## 🎯 Monitoring Strategy

### 1. Essential Metrics to Monitor
□ Broker throughput (MessagesInPerSec, BytesInPerSec, BytesOutPerSec)
□ Request latency (TotalTimeMs for Produce/Fetch requests)
□ Under-replicated partitions (critical for availability)
□ Consumer lag (by group and topic)
□ Active controller count (should always be 1)
□ JVM memory and GC metrics

### 2. Alert Thresholds by Environment

#### Production Thresholds
- Request latency 99th percentile: > 100ms (warning), > 500ms (critical)  
- Under-replicated partitions: > 0 (critical)
- Consumer lag: > 1000 messages (warning), > 10000 (critical)
- Disk usage: > 80% (warning), > 90% (critical)
- Memory usage: > 80% (warning), > 90% (critical)

#### Development Thresholds  
- Request latency: > 1s (warning)
- Consumer lag: > 10000 messages (warning)
- Disk usage: > 90% (warning)

### 3. Monitoring Architecture

#### Data Collection Layer
- JMX for Kafka-specific metrics
- System monitoring for OS metrics  
- Application metrics from clients
- Log aggregation for events

#### Storage and Analysis
- Time-series database (Prometheus, InfluxDB)
- Dashboard system (Grafana, Kibana)
- Alert management (AlertManager, PagerDuty)
- Log analysis (ELK stack, Splunk)

#### Visualization Strategy
- Real-time dashboards for operations
- Historical dashboards for trend analysis
- Executive dashboards for business metrics
- Troubleshooting dashboards for debugging

## 🔧 Implementation Guidelines

### JMX Configuration
- Enable JMX on all brokers with authentication
- Use firewall rules to secure JMX ports
- Monitor JMX endpoint availability
- Consider JMX proxy for remote access

### Metric Collection Frequency
- High-frequency metrics (1-10s): Throughput, latency
- Medium-frequency metrics (30-60s): Resource utilization  
- Low-frequency metrics (5-15m): Topic statistics, consumer groups
- Health checks (1-5m): Availability, basic functionality

### Alert Design Principles
- Alert on symptoms, not causes
- Reduce alert fatigue with proper thresholds
- Implement alert escalation policies
- Provide actionable information in alerts
- Test alerting regularly

## 📊 Monitoring Checklist

### Pre-Production Setup
□ JMX enabled on all brokers with proper security
□ Essential metrics collection configured
□ Dashboards created and tested
□ Alert rules defined with appropriate thresholds
□ On-call procedures documented
□ Monitoring system high availability configured

### Production Operations
□ Regular monitoring system health checks
□ Periodic alert threshold review and adjustment
□ Dashboard maintenance and updates
□ Monitoring data retention policy
□ Performance trending and capacity planning
□ Incident response playbook maintenance

### Performance Monitoring
□ Baseline metrics established
□ Capacity planning based on trends
□ Performance regression detection
□ Resource optimization opportunities identified
□ SLA compliance monitoring
□ Business impact correlation

## 🚨 Alert Response Procedures

### Critical Alerts
1. Broker down: Check broker status, restart if needed
2. Under-replicated partitions: Check broker health, network
3. Controller election storms: Investigate broker stability
4. Disk space critical: Clean up logs, add capacity

### Warning Alerts  
1. High latency: Check broker load, client configuration
2. Consumer lag: Scale consumer groups, check processing
3. High resource usage: Plan capacity expansion
4. Authentication failures: Check client credentials

## 📈 Capacity Planning Metrics

### Growth Trending
- Message volume growth rate
- Topic and partition count growth  
- Consumer group growth
- Storage utilization trend
- Network bandwidth utilization

### Resource Planning
- CPU utilization per message/byte
- Memory usage per partition
- Disk I/O capacity per throughput
- Network capacity per replication
- Connection scaling requirements

## 🔍 Troubleshooting Integration

### Correlation with Metrics
- Link alerts to relevant dashboards
- Provide metric context in alert messages
- Enable drill-down from dashboards to logs
- Correlate application metrics with Kafka metrics
- Track metrics before/during/after incidents
EOF
background: false
```

---

## Monitoring Integration Examples

**Create Prometheus configuration example:**

```terminal:execute
command: docker exec kafka tee /tmp/prometheus-kafka.yml << 'EOF'
# Prometheus configuration for Kafka monitoring

global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "kafka-alerts.yaml"

scrape_configs:
  # Kafka JMX metrics
  - job_name: 'kafka-jmx'
    static_configs:
      - targets: ['kafka-broker-1:9999', 'kafka-broker-2:9999', 'kafka-broker-3:9999']
    scrape_interval: 30s
    scrape_timeout: 10s
    metrics_path: /metrics

  # Kafka Exporter (if using JMX Exporter)
  - job_name: 'kafka-exporter'  
    static_configs:
      - targets: ['kafka-exporter:8080']
    scrape_interval: 30s

  # System metrics for Kafka nodes
  - job_name: 'kafka-nodes'
    static_configs:
      - targets: ['kafka-node-1:9100', 'kafka-node-2:9100', 'kafka-node-3:9100']
    scrape_interval: 15s

  # Consumer lag exporter
  - job_name: 'kafka-consumer-lag'
    static_configs:
      - targets: ['consumer-lag-exporter:8080']
    scrape_interval: 60s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

# Recording rules for complex calculations
recording_rules:
  - name: kafka-recording-rules
    rules:
      - record: kafka:throughput:rate5m
        expr: rate(kafka_server_brokertopicmetrics_messagesinpersec_total[5m])
      
      - record: kafka:latency:p99
        expr: histogram_quantile(0.99, kafka_network_requestmetrics_totaltimems_bucket)
      
      - record: kafka:consumer_lag:max_by_group
        expr: max by (consumer_group) (kafka_consumer_lag_max)
EOF
background: false
```

**Create monitoring setup script:**

```terminal:execute
command: docker exec kafka tee /tmp/setup-monitoring.sh << 'EOF'
#!/bin/bash
# Complete monitoring setup script

echo "=== Kafka Monitoring Setup ==="

# Create monitoring directories
echo "📁 Creating monitoring directories..."
mkdir -p /opt/kafka/monitoring/{config,dashboards,scripts,logs}

# Copy configuration files
echo "📋 Setting up monitoring configurations..."
cp /tmp/jmx-broker.properties /opt/kafka/monitoring/config/
cp /tmp/monitoring-log4j.properties /opt/kafka/monitoring/config/
cp /tmp/kafka-alerts.yaml /opt/kafka/monitoring/config/
cp /tmp/prometheus-kafka.yml /opt/kafka/monitoring/config/

# Copy scripts
echo "🔧 Installing monitoring scripts..."
cp /tmp/kafka-health-check.sh /opt/kafka/monitoring/scripts/
cp /tmp/collect-metrics.sh /opt/kafka/monitoring/scripts/
cp /tmp/jmx-monitor.sh /opt/kafka/monitoring/scripts/
cp /tmp/log-analysis.sh /opt/kafka/monitoring/scripts/

# Set permissions
chmod +x /opt/kafka/monitoring/scripts/*.sh

# Create systemd service file for health checks (example)
echo "⚙️  Creating monitoring service configuration..."
tee /opt/kafka/monitoring/config/kafka-health-check.service << 'SERVICE_EOF'
[Unit]
Description=Kafka Health Check
After=kafka.service

[Service]
Type=oneshot
ExecStart=/opt/kafka/monitoring/scripts/kafka-health-check.sh
User=kafka
Group=kafka
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Create timer for regular health checks
tee /opt/kafka/monitoring/config/kafka-health-check.timer << 'TIMER_EOF'
[Unit]
Description=Run Kafka health check every 5 minutes
Requires=kafka-health-check.service

[Timer] 
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
TIMER_EOF

echo "✅ Monitoring setup completed!"
echo "📁 Files installed in: /opt/kafka/monitoring/"
echo "🔧 Configuration files:"
ls -la /opt/kafka/monitoring/config/
echo -e "\n🔧 Monitoring scripts:"  
ls -la /opt/kafka/monitoring/scripts/

echo -e "\n📋 Next Steps:"
echo "1. Configure your monitoring system to collect from JMX (port 9999)"
echo "2. Set up dashboards using the provided configurations"
echo "3. Configure alerting using the provided alert rules"
echo "4. Schedule regular execution of monitoring scripts"
echo "5. Test health checks and alert notifications"
EOF

chmod +x /tmp/setup-monitoring.sh
/tmp/setup-monitoring.sh
background: false
```

---

## Key Takeaways

**📊 Monitoring Foundation:**
- **JMX metrics** - Primary source for Kafka-specific metrics
- **Log analysis** - Essential for troubleshooting and event tracking
- **Health checks** - Automated validation of cluster health
- **Alerting** - Proactive notification of issues and anomalies

**🔧 Essential Metrics Priority:**
1. **Availability** - Broker connectivity, under-replicated partitions
2. **Performance** - Throughput, latency, resource utilization
3. **Reliability** - Consumer lag, replication status, error rates
4. **Capacity** - Disk usage, memory usage, connection counts

**🚨 Alert Strategy:**
- **Critical alerts**: Immediate response required (broker down, data loss risk)
- **Warning alerts**: Investigation needed (performance degradation, capacity)
- **Info alerts**: Awareness (configuration changes, maintenance events)

**📈 Dashboard Design:**
- **Operational dashboards**: Real-time metrics for day-to-day operations
- **Executive dashboards**: High-level KPIs and business impact metrics
- **Troubleshooting dashboards**: Detailed metrics for problem diagnosis
- **Capacity planning dashboards**: Trend analysis and growth projection

**🔍 Monitoring Integration:**
- Correlate Kafka metrics with application and infrastructure metrics
- Link alerting to incident response procedures
- Implement automated remediation where appropriate
- Maintain monitoring system reliability and availability

**🚀 Next Level:** Configuration Mastery Summary - Best practices, decision frameworks, and troubleshooting guide.

**🔗 Essential References:**
- [Kafka Monitoring Guide](https://kafka.apache.org/documentation/#monitoring)
- [JMX Metrics Reference](https://kafka.apache.org/documentation/#remote_jmx)
- [Operational Monitoring](https://kafka.apache.org/documentation/#operations_monitoring)