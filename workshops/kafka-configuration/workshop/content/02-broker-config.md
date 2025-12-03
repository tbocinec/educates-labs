# Broker Configuration Fundamentals

Configure the core Kafka broker settings that control server behavior, performance, and resource usage. 🖥️

---

## Understanding Broker Configuration

**🔧 What is Broker Configuration?**
Broker configuration controls how Kafka servers operate - from basic networking to advanced performance tuning.

**📍 Configuration Methods:**
- **Static Configuration** - Requires broker restart (server.properties)
- **Dynamic Configuration** - Applied without restart (kafka-configs command)
- **Per-Broker Configuration** - Settings for specific broker nodes

---

## Current Broker Configuration

**View current broker settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe
background: false
```

**Get specific configuration values:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | grep -E "(log.segment|retention|compression)"
background: false
```

**📚 Documentation:** [Broker Configuration Reference](https://kafka.apache.org/documentation/#brokerconfigs)

---

## Core Broker Settings

**🎯 Essential broker configurations:**

### 1. Log Configuration

**Current log settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | grep log
background: false
```

**Modify log segment size:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config log.segment.bytes=52428800
background: false
```

**📊 Impact:** Smaller segments = more frequent rolling, better retention precision

---

## Network and Threading Configuration

**View current network settings:**

```terminal:execute
command: docker exec kafka bash -c 'echo "Current broker configuration:" && kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | grep -E "network|socket|thread"'
background: false
```

**Configure network threads (demonstration):**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config num.network.threads=6
background: false
```

**⚡ Use Case:** More network threads = better concurrent connection handling

**🔗 Reference:** [Network Configuration](https://kafka.apache.org/documentation/#brokerconfigs_num.network.threads)

---

## Memory and Buffer Settings

**Check memory-related settings:**

```terminal:execute
command: docker exec kafka bash -c 'echo "Memory and buffer settings:" && kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | grep -E "buffer|memory|cache"'
background: false
```

**Configure socket buffers:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config socket.send.buffer.bytes=131072
background: false
```

**🎯 Impact:** Larger buffers = better network performance, more memory usage

---

## Compression Configuration

**View compression settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | grep compression
background: false
```

**Set broker compression:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config compression.type=lz4
background: false
```

**📈 Compression Types:**
- `none` - No compression (lowest CPU, highest network)
- `gzip` - High compression ratio (high CPU, lowest network)  
- `lz4` - Balanced (medium CPU, good compression)
- `snappy` - Fast compression (low CPU, medium compression)
- `zstd` - Modern efficient compression

**🔗 Reference:** [Compression Configuration](https://kafka.apache.org/documentation/#brokerconfigs_compression.type)

---

## Replication and Availability

**Check replication settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | grep -E "replication|replica|isr"
background: false
```

**Configure ISR settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config replica.lag.time.max.ms=30000
background: false
```

**🛡️ Availability Settings:**
- `min.insync.replicas` - Minimum replicas for writes
- `unclean.leader.election.enable` - Allow data loss for availability
- `replica.lag.time.max.ms` - Max lag before removing from ISR

---

## Performance Configuration Examples

**Examine pre-configured performance profile:**

```terminal:execute
command: docker exec kafka cat /opt/kafka/config-examples/broker-high-throughput.properties
background: false
```

**Apply high-throughput settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config num.io.threads=16,socket.send.buffer.bytes=102400,socket.receive.buffer.bytes=102400
background: false
```

**🚀 High-Throughput Profile:**
- More I/O threads for disk operations
- Larger socket buffers for network
- Optimized segment and batch sizes

---

## Resource Limits and Quotas

**Configure connection limits:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config max.connections=1000
background: false
```

**Set request handling limits:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config queued.max.requests=500
background: false
```

**📊 Resource Management:**
- `max.connections` - Maximum client connections
- `queued.max.requests` - Request queue size
- `socket.request.max.bytes` - Maximum request size

---

## Configuration Validation

**Verify all applied configurations:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | head -20
background: false
```

**Check for configuration conflicts:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | grep -E "INVALID|ERROR" || echo "No configuration errors found"
background: false
```

---

## Visual Configuration Review

**Switch to Dashboard tab and explore:**
1. **Overview** - Cluster status with new settings
2. **Brokers** - Individual broker configuration
3. **Topics** - How broker settings affect topics

**Compare performance before/after configuration changes**

---

## Configuration Reset

**Reset specific settings to defaults:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --delete-config socket.send.buffer.bytes,num.network.threads
background: false
```

**📝 Configuration Management:**
- Always document configuration changes
- Test in development before production
- Monitor impact after changes
- Keep configuration versioned

---

## Common Configuration Patterns

**🎯 Use Case: High-Throughput Data Ingestion**
```properties
# Network optimization
num.network.threads=8
num.io.threads=16
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400

# Storage optimization  
log.segment.bytes=1073741824
log.flush.interval.messages=10000

# Compression
compression.type=lz4
```

**🎯 Use Case: Low-Latency Processing**
```properties
# Quick processing
num.replica.fetchers=4
replica.lag.time.max.ms=10000

# Fast networking
socket.send.buffer.bytes=131072
queued.max.requests=1600
```

**🎯 Use Case: Resource-Constrained Environment**
```properties
# Reduced resource usage
num.network.threads=3
num.io.threads=4
socket.send.buffer.bytes=65536
log.segment.bytes=104857600
```

---

## Key Takeaways

**🔧 Essential Broker Configurations:**
- **Network threads** - Scale with connection count
- **I/O threads** - Scale with partition count  
- **Buffer sizes** - Balance memory vs performance
- **Log settings** - Control storage and retention behavior

**📊 Performance Impact:**
- More threads = better concurrency, more overhead
- Larger buffers = better throughput, more memory
- Compression = CPU usage for network savings
- Smaller segments = more files, better retention precision

**🚀 Next Level:** Topic Configuration - Learn to configure individual topics for specific use cases.

**🔗 Essential References:**
- [Kafka Broker Configuration](https://kafka.apache.org/documentation/#brokerconfigs)
- [Performance Tuning Guide](https://kafka.apache.org/documentation/#hwandos)
- [Production Configuration](https://kafka.apache.org/documentation/#prodconfig)