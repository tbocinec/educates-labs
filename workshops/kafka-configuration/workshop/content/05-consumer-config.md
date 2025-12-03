# Consumer Configuration Optimization

Configure Kafka consumers for optimal throughput, latency, resource usage, and reliable message processing. 📥

---

## Understanding Consumer Configuration

**🔧 What is Consumer Configuration?**
Consumer configuration controls how clients read data from Kafka - affecting performance, memory usage, and processing reliability.

**📍 Configuration Scope:**
- **Consumer group** - Shared across group members
- **Individual consumer** - Per consumer instance
- **Fetch behavior** - How data is retrieved from brokers

---

## Examine Consumer Configuration Examples

**View pre-configured consumer settings:**

```terminal:execute
command: docker exec kafka cat /opt/kafka/config-examples/consumer-performance.properties
background: false
```

**Test default consumer behavior:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --group default-group --max-messages 5
background: false
```

**📚 Documentation:** [Consumer Configuration Reference](https://kafka.apache.org/documentation/#consumerconfigs)

---

## Fetch Configuration

**Configure fetch size:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --group fetch-test --consumer-property fetch.min.bytes=1024 --consumer-property fetch.max.wait.ms=500 --max-messages 5
background: false
```

**Large fetch size test:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --group large-fetch --consumer-property fetch.min.bytes=10240 --consumer-property fetch.max.wait.ms=1000 --max-messages 5
background: false
```

**📦 Fetch Parameters:**
- `fetch.min.bytes` - Minimum data per fetch request
- `fetch.max.wait.ms` - Maximum wait time for fetch.min.bytes
- `fetch.max.bytes` - Maximum data per fetch request

**⚡ Fetch Trade-offs:**
```
Large fetch.min.bytes: Higher throughput, higher latency
Small fetch.min.bytes: Lower latency, more network requests
Long fetch.max.wait.ms: Better batching, higher latency
```

**🔗 Reference:** [Consumer Fetch Configuration](https://kafka.apache.org/documentation/#consumerconfigs_fetch.min.bytes)

---

## Poll and Processing Configuration

**Configure poll behavior:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --group poll-test --consumer-property max.poll.records=100 --consumer-property max.poll.interval.ms=300000 --max-messages 10
background: false
```

**Small batch processing:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --group small-batch --consumer-property max.poll.records=10 --max-messages 5
background: false
```

**🔄 Poll Configuration:**
- `max.poll.records` - Records returned per poll()
- `max.poll.interval.ms` - Maximum time between polls
- `max.partition.fetch.bytes` - Maximum data per partition per fetch

**🎯 Processing Patterns:**
```
Batch processing: max.poll.records=1000
Real-time: max.poll.records=1
Balanced: max.poll.records=500
```

---

## Offset Management

**Test auto-commit behavior:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group auto-commit --consumer-property enable.auto.commit=true --consumer-property auto.commit.interval.ms=5000 --max-messages 3
background: false
```

**Manual offset management:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group manual-commit --consumer-property enable.auto.commit=false --max-messages 3
background: false
```

**🔄 Offset Management:**
- `enable.auto.commit=true` - Automatic offset commits
- `auto.commit.interval.ms` - Frequency of auto commits
- `enable.auto.commit=false` - Manual offset control

**📊 Offset Strategy by Use Case:**
```
Fire-and-forget: enable.auto.commit=true
Exactly-once: enable.auto.commit=false  
At-least-once: enable.auto.commit=true, short interval
```

---

## Consumer Group Configuration

**Configure session and heartbeat:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group heartbeat-test --consumer-property session.timeout.ms=30000 --consumer-property heartbeat.interval.ms=10000 --max-messages 3
background: false
```

**Check consumer group coordination:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group heartbeat-test
background: false
```

**👥 Group Configuration:**
- `session.timeout.ms` - Time before consumer is considered dead
- `heartbeat.interval.ms` - Heartbeat frequency
- `group.instance.id` - Static group membership

**🎯 Group Settings by Environment:**
```
Stable environment: session.timeout.ms=45000
Dynamic environment: session.timeout.ms=10000
Critical processing: heartbeat.interval.ms=3000
```

---

## Performance Testing

**High-throughput consumer test:**

```terminal:execute
command: docker exec kafka kafka-consumer-perf-test --topic high-throughput --bootstrap-server localhost:9092 --messages 1000 --consumer.config /opt/kafka/config-examples/consumer-performance.properties
background: false
```

**Low-latency consumer test:**

```terminal:execute
command: docker exec kafka kafka-consumer-perf-test --topic low-latency --bootstrap-server localhost:9092 --messages 500 --consumer-props bootstrap.servers=localhost:9092 fetch.min.bytes=1 max.poll.records=1
background: false
```

**Balanced consumer test:**

```terminal:execute
command: docker exec kafka kafka-consumer-perf-test --topic user-events --bootstrap-server localhost:9092 --messages 500 --consumer-props bootstrap.servers=localhost:9092 fetch.min.bytes=1024 max.poll.records=100
background: false
```

---

## Consumer Configuration Files

**Create high-performance consumer config:**

```terminal:execute
command: docker exec kafka tee /tmp/high-perf-consumer.properties << 'EOF'
bootstrap.servers=localhost:9092
group.id=high-perf-group
fetch.min.bytes=10240
fetch.max.wait.ms=500
max.poll.records=1000
enable.auto.commit=true
auto.commit.interval.ms=1000
session.timeout.ms=30000
heartbeat.interval.ms=10000
EOF
background: false
```

**Create reliable consumer config:**

```terminal:execute
command: docker exec kafka tee /tmp/reliable-consumer.properties << 'EOF'
bootstrap.servers=localhost:9092
group.id=reliable-group
enable.auto.commit=false
max.poll.records=100
session.timeout.ms=45000
heartbeat.interval.ms=15000
auto.offset.reset=earliest
isolation.level=read_committed
EOF
background: false
```

**Test with configuration files:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --consumer.config /tmp/high-perf-consumer.properties --max-messages 5
background: false
```

---

## Memory and Resource Management

**Configure memory settings:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --group memory-test --consumer-property fetch.max.bytes=52428800 --consumer-property max.partition.fetch.bytes=1048576 --max-messages 5
background: false
```

**🧠 Memory Configuration:**
- `fetch.max.bytes` - Maximum total fetch size
- `max.partition.fetch.bytes` - Maximum per partition fetch
- `receive.buffer.bytes` - Socket receive buffer

**💡 Memory Guidelines:**
```
High memory: fetch.max.bytes=52428800 (50MB)
Medium memory: fetch.max.bytes=10485760 (10MB)
Low memory: fetch.max.bytes=1048576 (1MB)
```

---

## Error Handling and Recovery

**Configure retry and timeout behavior:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic reliable-data --group error-handling --consumer-property retry.backoff.ms=1000 --consumer-property request.timeout.ms=30000 --max-messages 3
background: false
```

**Test offset reset behavior:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group reset-test --consumer-property auto.offset.reset=earliest --max-messages 3
background: false
```

**🔧 Error Handling:**
- `retry.backoff.ms` - Delay between retries
- `request.timeout.ms` - Request timeout
- `auto.offset.reset` - Behavior when no offset exists

---

## Consumer Configuration Patterns

**🎯 Pattern: High-Throughput Data Processing**

```terminal:execute
command: docker exec kafka tee /tmp/throughput-consumer.properties << 'EOF'
# High throughput configuration
bootstrap.servers=localhost:9092
group.id=throughput-processors
fetch.min.bytes=10240
fetch.max.wait.ms=500
max.poll.records=1000
enable.auto.commit=true
auto.commit.interval.ms=5000
session.timeout.ms=30000
EOF
background: false
```

**🎯 Pattern: Real-Time Stream Processing**

```terminal:execute
command: docker exec kafka tee /tmp/realtime-consumer.properties << 'EOF'
# Real-time processing configuration
bootstrap.servers=localhost:9092
group.id=realtime-processors  
fetch.min.bytes=1
fetch.max.wait.ms=100
max.poll.records=1
enable.auto.commit=false
session.timeout.ms=10000
heartbeat.interval.ms=3000
EOF
background: false
```

**🎯 Pattern: Reliable Message Processing**

```terminal:execute
command: docker exec kafka tee /tmp/reliable-consumer.properties << 'EOF'
# Reliable processing configuration
bootstrap.servers=localhost:9092
group.id=reliable-processors
enable.auto.commit=false
isolation.level=read_committed
max.poll.records=50
session.timeout.ms=45000
auto.offset.reset=earliest
EOF
background: false
```

---

## Configuration Validation

**Test consumer configurations:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic high-throughput --consumer.config /tmp/throughput-consumer.properties --max-messages 5
background: false
```

**Monitor consumer group performance:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group throughput-processors
background: false
```

---

## Consumer Lag Monitoring

**Check consumer lag across groups:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --all-groups | grep -E "(GROUP|LAG)"
background: false
```

**Monitor specific consumer group:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group high-perf-group
background: false
```

---

## Key Takeaways

**🔧 Essential Consumer Configurations:**
- **fetch.min.bytes** - Controls throughput vs latency trade-off
- **max.poll.records** - Controls batch size for processing
- **enable.auto.commit** - Controls offset management strategy
- **session.timeout.ms** - Controls failure detection speed

**📊 Performance Impact:**
- Larger fetch sizes = higher throughput, more memory usage
- More records per poll = better throughput, longer processing
- Auto-commit = simpler code, potential message loss
- Shorter timeouts = faster failure detection, more rebalancing

**🚀 Next Level:** Performance Tuning - Advanced optimization across all Kafka components.

**🔗 Essential References:**
- [Consumer Configuration Guide](https://kafka.apache.org/documentation/#consumerconfigs)
- [Consumer Performance Tuning](https://kafka.apache.org/documentation/#consumertuning)
- [Offset Management](https://kafka.apache.org/documentation/#impl_offsettracking)