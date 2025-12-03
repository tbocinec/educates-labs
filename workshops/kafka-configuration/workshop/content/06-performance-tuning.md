# Performance Tuning Mastery

Optimize Kafka performance across brokers, producers, consumers, and infrastructure for production workloads. 🚀

---

## Understanding Performance Optimization

**⚡ Performance Dimensions:**
- **Throughput** - Messages/records per second
- **Latency** - End-to-end message delivery time  
- **Resource efficiency** - CPU, memory, disk, network utilization
- **Reliability** - Consistency under load and failures

**📊 Performance Monitoring Stack:**
- Kafka JMX metrics
- Operating system metrics
- Application-level metrics
- Network and disk I/O

---

## JVM Performance Optimization

**Check current JVM settings:**

```terminal:execute
command: docker exec kafka java -XX:+PrintFlagsFinal -version | grep -E "(MaxHeapSize|NewRatio|GCTimeRatio)"
background: false
```

**View Kafka JVM configuration:**

```terminal:execute
command: docker exec kafka cat /opt/kafka/bin/kafka-server-start.sh | grep -A5 -B5 "KAFKA_HEAP_OPTS"
background: false
```

**🧠 JVM Tuning for Kafka:**

```terminal:execute
command: docker exec kafka tee /tmp/kafka-jvm-tuning.sh << 'EOF'
# High-performance JVM settings for Kafka
export KAFKA_HEAP_OPTS="-Xmx4g -Xms4g"
export KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -XX:MaxInlineLevel=15 -Djava.awt.headless=true"
export KAFKA_GC_LOG_OPTS="-Xloggc:/opt/kafka/logs/kafkaServer-gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M"
EOF
background: false
```

**📚 Documentation:** [JVM Performance Tuning](https://kafka.apache.org/documentation/#java)

---

## Operating System Optimization

**Check system limits:**

```terminal:execute
command: docker exec kafka bash -c "ulimit -n && ulimit -u"
background: false
```

**View memory and CPU info:**

```terminal:execute
command: docker exec kafka bash -c "free -h && nproc"
background: false
```

**🔧 OS Tuning Parameters:**

```terminal:execute
command: docker exec kafka tee /tmp/os-tuning.txt << 'EOF'
# Key OS tuning for Kafka performance

## File System Parameters
# vm.swappiness=1                    # Minimize swapping
# vm.dirty_background_ratio=5        # Background flush at 5%
# vm.dirty_ratio=60                  # Foreground flush at 60%
# vm.dirty_expire_centisecs=12000    # Flush dirty pages after 2 minutes

## Network Parameters  
# net.core.rmem_default=262144       # Default socket receive buffer
# net.core.rmem_max=16777216         # Maximum socket receive buffer
# net.core.wmem_default=262144       # Default socket send buffer
# net.core.wmem_max=16777216         # Maximum socket send buffer
# net.ipv4.tcp_window_scaling=1      # Enable TCP window scaling

## File Descriptor Limits
# fs.file-max=2097152                # Maximum open files system-wide
# nofile soft limit: 65536           # Per-process open file limit
# nofile hard limit: 65536
EOF
background: false
```

**🔗 Reference:** [OS Performance Tuning](https://kafka.apache.org/documentation/#os)

---

## Disk I/O Optimization

**Test disk performance:**

```terminal:execute
command: docker exec kafka bash -c "dd if=/dev/zero of=/tmp/test-write bs=1M count=100 oflag=direct 2>&1 | grep -E '(copied|MB/s)'"
background: false
```

**Check mount options:**

```terminal:execute
command: docker exec kafka mount | grep -E "(kafka|tmp)"
background: false
```

**💾 Disk Configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/disk-optimization.txt << 'EOF'
# Disk optimization for Kafka

## File System Choice
# XFS or ext4 recommended for Kafka log directories
# Avoid network file systems (NFS, CIFS) for log.dirs

## Mount Options for Performance
# noatime - Skip access time updates
# nodiratime - Skip directory access time updates  
# Example: /dev/sdb1 /kafka-logs xfs defaults,noatime,nodiratime 0 2

## Separate Disks Strategy
# OS disk: / (operating system)
# Kafka logs: /kafka-logs (separate fast SSD)
# ZooKeeper: /zookeeper-data (separate disk if using ZooKeeper)

## RAID Configuration
# RAID 10: Best performance and redundancy
# RAID 1: Good for smaller deployments
# Avoid RAID 5/6: Poor write performance for Kafka workloads
EOF
background: false
```

---

## Network Performance

**Test network performance:**

```terminal:execute
command: docker exec kafka bash -c "iperf3 -c kafka -p 9092 -t 5 2>/dev/null || echo 'Network test - would measure bandwidth to broker'"
background: false
```

**Check network configuration:**

```terminal:execute
command: docker exec kafka netstat -i
background: false
```

**🌐 Network Optimization:**

```terminal:execute
command: docker exec kafka tee /tmp/network-tuning.txt << 'EOF'
# Network tuning for Kafka

## TCP Buffer Sizes
# Larger buffers for high-bandwidth networks
# socket.send.buffer.bytes=102400
# socket.receive.buffer.bytes=102400
# socket.request.max.bytes=104857600

## Connection Pooling
# num.network.threads=8              # Network threads for broker
# num.io.threads=16                  # I/O threads for broker
# queued.max.requests=500            # Maximum queued requests

## Client Connection Limits  
# max.connections.per.ip=2147483647  # Connections per IP
# connections.max.idle.ms=600000     # Close idle connections

## Batch and Compression
# batch.size=16384                   # Producer batch size
# compression.type=lz4               # Fast compression
# linger.ms=5                        # Small batching delay
EOF
background: false
```

---

## Kafka Broker Performance Tuning

**Create high-performance broker configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/high-perf-broker.properties << 'EOF'
# High-performance Kafka broker configuration

## Core Performance Settings
num.network.threads=8
num.io.threads=16
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
num.replica.fetchers=4

## Log Settings for Performance  
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
log.cleaner.enable=true
log.cleaner.threads=2

## Replication for Performance
replica.fetch.max.bytes=1048576
replica.fetch.wait.max.ms=500
replica.high.watermark.checkpoint.interval.ms=5000

## Memory and Caching
log.flush.interval.messages=10000
log.flush.interval.ms=1000

## Compression
compression.type=lz4
EOF
background: false
```

**Performance monitoring configuration:**

```terminal:execute
command: docker exec kafka tee /tmp/monitoring-broker.properties << 'EOF'
# Kafka broker monitoring configuration

## JMX Monitoring
jmx.port=9999

## Metrics Recording
metric.reporters=org.apache.kafka.common.metrics.JmxReporter
metrics.sample.window.ms=30000
metrics.num.samples=2

## Request Handling Metrics
request.timeout.ms=30000
connections.max.idle.ms=600000

## Log Directory Monitoring
log.dirs=/kafka-logs-1,/kafka-logs-2,/kafka-logs-3
EOF
background: false
```

---

## Producer Performance Optimization

**High-throughput producer test:**

```terminal:execute
command: docker exec kafka kafka-producer-perf-test --topic high-throughput --num-records 10000 --record-size 1024 --throughput 5000 --producer-props bootstrap.servers=localhost:9092 batch.size=32768 linger.ms=10 compression.type=lz4 acks=1
background: false
```

**Low-latency producer test:**

```terminal:execute
command: docker exec kafka kafka-producer-perf-test --topic low-latency --num-records 1000 --record-size 100 --throughput 1000 --producer-props bootstrap.servers=localhost:9092 batch.size=1 linger.ms=0 acks=1
background: false
```

**Balanced producer test:**

```terminal:execute
command: docker exec kafka kafka-producer-perf-test --topic user-events --num-records 5000 --record-size 512 --throughput 2000 --producer-props bootstrap.servers=localhost:9092 batch.size=16384 linger.ms=5 compression.type=lz4 acks=all
background: false
```

---

## Consumer Performance Optimization

**High-throughput consumer performance:**

```terminal:execute
command: docker exec kafka kafka-consumer-perf-test --topic high-throughput --bootstrap-server localhost:9092 --messages 10000 --consumer-props fetch.min.bytes=50000 fetch.max.wait.ms=500 max.poll.records=1000
background: false
```

**Parallel consumer test:**

```terminal:execute
command: docker exec kafka bash -c "
kafka-consumer-perf-test --topic high-throughput --bootstrap-server localhost:9092 --messages 5000 --consumer-props group.id=parallel-1 max.poll.records=500 &
kafka-consumer-perf-test --topic high-throughput --bootstrap-server localhost:9092 --messages 5000 --consumer-props group.id=parallel-2 max.poll.records=500 &
wait
"
background: false
```

---

## Performance Monitoring and Metrics

**Enable JMX monitoring:**

```terminal:execute
command: docker exec kafka bash -c "JMX_PORT=9999 /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties &" 
background: false
```

**Key Kafka metrics to monitor:**

```terminal:execute
command: docker exec kafka tee /tmp/key-metrics.txt << 'EOF'
# Essential Kafka performance metrics

## Broker Metrics
# kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec
# kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec  
# kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec
# kafka.network:type=RequestMetrics,name=RequestsPerSec,request=Produce
# kafka.network:type=RequestMetrics,name=TotalTimeMs,request=Produce

## Producer Metrics
# kafka.producer:type=producer-metrics,client-id=*
# record-send-rate - Records sent per second
# batch-size-avg - Average batch size  
# compression-rate-avg - Compression efficiency

## Consumer Metrics  
# kafka.consumer:type=consumer-metrics,client-id=*
# records-consumed-rate - Records consumed per second
# fetch-latency-avg - Average fetch latency
# records-lag-max - Maximum lag across partitions

## Topic Metrics
# kafka.log:type=LogSize,name=Size,topic=*
# kafka.log:type=LogEndOffset,name=Value,topic=*
EOF
background: false
```

**📊 Performance Monitoring Setup:**

```terminal:execute
command: docker exec kafka tee /tmp/monitoring-setup.sh << 'EOF'
#!/bin/bash
# Performance monitoring script

echo "=== Kafka Cluster Performance Summary ==="

# Broker performance
echo "## Broker Status"
kafka-broker-api-versions --bootstrap-server localhost:9092 | head -5

# Topic throughput
echo -e "\n## Topic List"  
kafka-topics --bootstrap-server localhost:9092 --list

# Consumer group lag
echo -e "\n## Consumer Group Lag"
kafka-consumer-groups --bootstrap-server localhost:9092 --describe --all-groups | grep -E "(GROUP|LAG)" | head -10

# System resources
echo -e "\n## System Resources"
echo "Memory usage:"
free -h | grep -E "(Mem|Swap)"

echo -e "\nDisk usage:"
df -h | grep -E "(kafka|tmp)"

echo -e "\nProcess count:"
ps aux | grep kafka | wc -l
EOF
background: false
```

---

## Load Testing and Benchmarking

**Comprehensive load test:**

```terminal:execute
command: docker exec kafka bash -c "
echo 'Starting comprehensive load test...'

# Producer load test
echo '1. Testing producer throughput'
kafka-producer-perf-test --topic load-test --num-records 20000 --record-size 1024 --throughput 10000 --producer-props bootstrap.servers=localhost:9092 batch.size=16384 linger.ms=5 compression.type=lz4 acks=all

echo '2. Testing consumer throughput'  
kafka-consumer-perf-test --topic load-test --bootstrap-server localhost:9092 --messages 20000 --consumer-props fetch.min.bytes=1024 max.poll.records=500

echo 'Load test completed!'
"
background: false
```

**Stress test with multiple topics:**

```terminal:execute
command: docker exec kafka bash -c "
echo 'Running multi-topic stress test...'

# Create multiple topics for testing
kafka-topics --bootstrap-server localhost:9092 --create --topic stress-test-1 --partitions 3 --replication-factor 1 --if-not-exists
kafka-topics --bootstrap-server localhost:9092 --create --topic stress-test-2 --partitions 3 --replication-factor 1 --if-not-exists

# Parallel producer tests
kafka-producer-perf-test --topic stress-test-1 --num-records 10000 --record-size 512 --throughput 5000 --producer-props bootstrap.servers=localhost:9092 acks=1 &
kafka-producer-perf-test --topic stress-test-2 --num-records 10000 --record-size 512 --throughput 5000 --producer-props bootstrap.servers=localhost:9092 acks=1 &

wait
echo 'Stress test completed!'
"
background: false
```

---

## Performance Troubleshooting

**Diagnose performance issues:**

```terminal:execute
command: docker exec kafka bash -c "
echo '=== Performance Diagnostics ==='

echo '1. Check broker resource usage'
top -b -n1 | grep kafka | head -5

echo '2. Check network connections' 
netstat -an | grep 9092 | wc -l

echo '3. Check disk I/O'
iostat -x 1 1 2>/dev/null || echo 'iostat not available - would show disk utilization'

echo '4. Check memory usage'
free -m

echo '5. Check open file descriptors'
lsof | grep kafka | wc -l 2>/dev/null || echo 'File descriptors in use by Kafka'
"
background: false
```

**Performance issue checklist:**

```terminal:execute
command: docker exec kafka tee /tmp/performance-checklist.txt << 'EOF'
# Kafka Performance Issue Troubleshooting Checklist

## High Latency Issues
□ Check network round-trip time between clients and brokers
□ Verify linger.ms and batch.size settings for producers  
□ Check fetch.min.bytes and fetch.max.wait.ms for consumers
□ Monitor GC pauses and JVM heap usage
□ Verify disk I/O is not saturated

## Low Throughput Issues  
□ Increase producer batch.size and linger.ms
□ Verify sufficient network bandwidth
□ Check if compression is beneficial for your data
□ Monitor broker CPU and memory usage
□ Verify partition count matches expected parallelism

## Consumer Lag Issues
□ Scale consumer group members to match partition count
□ Optimize consumer fetch settings (fetch.min.bytes, max.poll.records)
□ Check processing time per message in consumer application
□ Monitor broker-side metrics for bottlenecks
□ Consider adding more partitions to topics

## Resource Utilization Issues
□ Monitor JVM heap and garbage collection
□ Check disk space and I/O utilization  
□ Verify network utilization and connection limits
□ Monitor CPU usage across all cores
□ Check operating system limits (file descriptors, memory)

## Replication Lag Issues
□ Check replica.fetch.max.bytes setting
□ Monitor network between brokers
□ Verify replica.fetch.wait.max.ms configuration
□ Check broker CPU and disk I/O
□ Monitor in-sync replica count
EOF
background: false
```

---

## Performance Optimization Patterns

**🚀 Pattern: Maximum Throughput**

```terminal:execute
command: docker exec kafka tee /tmp/max-throughput-config.txt << 'EOF'
# Maximum throughput configuration pattern

## Producer Configuration
acks=1                              # Accept some risk for speed
batch.size=32768                    # Large batches
linger.ms=20                        # Allow batching time
compression.type=lz4                # Fast compression
buffer.memory=33554432              # Large buffer
max.in.flight.requests.per.connection=5

## Consumer Configuration  
fetch.min.bytes=50000               # Large fetch sizes
fetch.max.wait.ms=500               # Reasonable wait time
max.poll.records=1000               # Large poll batches
session.timeout.ms=30000            # Stable sessions

## Broker Configuration
num.network.threads=8               # More network threads
num.io.threads=16                   # More I/O threads  
replica.fetch.max.bytes=1048576     # Large replica fetches
log.segment.bytes=1073741824        # Large log segments
EOF
background: false
```

**⚡ Pattern: Minimum Latency**

```terminal:execute
command: docker exec kafka tee /tmp/min-latency-config.txt << 'EOF'
# Minimum latency configuration pattern

## Producer Configuration
acks=1                              # Fast acknowledgment
batch.size=1                        # No batching  
linger.ms=0                         # No wait time
compression.type=none               # No compression overhead
max.in.flight.requests.per.connection=1

## Consumer Configuration
fetch.min.bytes=1                   # Fetch immediately
fetch.max.wait.ms=0                 # No wait time
max.poll.records=1                  # Process immediately
session.timeout.ms=10000            # Quick failure detection

## Broker Configuration  
replica.fetch.wait.max.ms=100       # Quick replication
log.flush.interval.messages=1       # Immediate flush
log.flush.interval.ms=1             # Immediate flush
EOF
background: false
```

**⚖️ Pattern: Balanced Performance**

```terminal:execute
command: docker exec kafka tee /tmp/balanced-config.txt << 'EOF'
# Balanced performance configuration pattern

## Producer Configuration
acks=all                            # Reliability with performance
batch.size=16384                    # Moderate batching
linger.ms=5                         # Small delay for batching
compression.type=lz4                # Fast compression
max.in.flight.requests.per.connection=3

## Consumer Configuration
fetch.min.bytes=1024                # Moderate fetch size
fetch.max.wait.ms=500               # Reasonable wait
max.poll.records=100                # Moderate batch size
session.timeout.ms=20000            # Balanced stability

## Broker Configuration
replica.fetch.wait.max.ms=500       # Balanced replication
log.flush.interval.ms=1000          # Moderate durability
num.network.threads=6               # Adequate threading
num.io.threads=12                   # Adequate I/O capacity
EOF
background: false
```

---

## Performance Validation

**Test throughput configuration:**

```terminal:execute
command: docker exec kafka kafka-producer-perf-test --topic high-throughput --num-records 10000 --record-size 1024 --throughput -1 --producer-props bootstrap.servers=localhost:9092 batch.size=32768 linger.ms=20 compression.type=lz4 acks=1
background: false
```

**Test latency configuration:**

```terminal:execute
command: docker exec kafka kafka-producer-perf-test --topic low-latency --num-records 1000 --record-size 100 --throughput 1000 --producer-props bootstrap.servers=localhost:9092 batch.size=1 linger.ms=0 acks=1
background: false
```

**Benchmark comparison:**

```terminal:execute
command: docker exec kafka bash -c "
echo '=== Performance Benchmark Results ==='

echo 'High Throughput Test:'
kafka-producer-perf-test --topic high-throughput --num-records 5000 --record-size 1024 --throughput -1 --producer-props bootstrap.servers=localhost:9092 batch.size=32768 linger.ms=20 acks=1 | tail -1

echo 'Low Latency Test:'  
kafka-producer-perf-test --topic low-latency --num-records 1000 --record-size 100 --throughput 1000 --producer-props bootstrap.servers=localhost:9092 batch.size=1 linger.ms=0 acks=1 | tail -1

echo 'Balanced Test:'
kafka-producer-perf-test --topic user-events --num-records 3000 --record-size 512 --throughput 2000 --producer-props bootstrap.servers=localhost:9092 batch.size=16384 linger.ms=5 acks=all | tail -1
"
background: false
```

---

## Key Takeaways

**🔧 Performance Tuning Priorities:**
1. **JVM optimization** - G1GC, appropriate heap size, GC tuning
2. **Operating system** - File descriptors, memory settings, disk I/O
3. **Network configuration** - Buffer sizes, connection limits
4. **Kafka configuration** - Threading, batching, compression

**📊 Monitoring Strategy:**
- Establish baseline metrics before optimization
- Monitor key metrics: throughput, latency, resource utilization
- Use JMX for detailed Kafka metrics
- Set up alerting for performance degradation

**🎯 Configuration Patterns:**
- **High throughput**: Large batches, compression, relaxed durability
- **Low latency**: Small batches, no compression, immediate processing  
- **Balanced**: Moderate settings optimizing for both throughput and latency

**🚀 Next Level:** Security Configuration - Implementing authentication, authorization, and encryption.

**🔗 Essential References:**
- [Kafka Performance Tuning](https://kafka.apache.org/documentation/#tuning)
- [JVM Performance Guide](https://kafka.apache.org/documentation/#java)
- [Operating System Tuning](https://kafka.apache.org/documentation/#os)