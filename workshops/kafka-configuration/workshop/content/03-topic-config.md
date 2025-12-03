# Topic Configuration Deep Dive

Configure individual topics for specific use cases: retention, performance, storage, and data lifecycle management. 📁

---

## Understanding Topic Configuration

**🔧 What is Topic Configuration?**
Topic configuration controls how individual topics store, retain, and process messages - independent of broker defaults.

**📍 Configuration Scope:**
- **Topic-level** - Overrides broker defaults for specific topics
- **Dynamic** - Can be changed without restart
- **Inheritance** - Uses broker defaults when not specified

---

## Current Topic Configurations

**List existing topics and their configs:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list
background: false
```

**Create a sample topic for configuration testing:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic config-demo --partitions 3 --replication-factor 1
background: false
```

**View topic configuration:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --describe
background: false
```

**📚 Documentation:** [Topic Configuration Reference](https://kafka.apache.org/documentation/#topicconfigs)

---

## Retention Configuration

**Time-based retention:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --alter --add-config retention.ms=3600000
background: false
```

**Size-based retention:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --alter --add-config retention.bytes=104857600
background: false
```

**Verify retention settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --describe | grep retention
background: false
```

**⏰ Retention Patterns:**
- `retention.ms=3600000` - 1 hour (logs, temporary data)
- `retention.ms=86400000` - 24 hours (daily processing)
- `retention.ms=604800000` - 7 days (weekly aggregation)
- `retention.ms=-1` - Infinite retention (with compaction)

**🔗 Reference:** [Retention Configuration](https://kafka.apache.org/documentation/#topicconfigs_retention.ms)

---

## Cleanup Policies

**Configure delete policy:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic logs-topic --partitions 2 --replication-factor 1 --config cleanup.policy=delete --config retention.ms=86400000
background: false
```

**Configure compact policy:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic state-topic --partitions 2 --replication-factor 1 --config cleanup.policy=compact --config min.cleanable.dirty.ratio=0.1
background: false
```

**View pre-configured topic examples:**

```terminal:execute
command: docker exec kafka cat /opt/kafka/config-examples/topic-configs.json
background: false
```

**🔄 Cleanup Policy Use Cases:**
- **delete** - Event logs, metrics, temporary data
- **compact** - User state, configuration data, changelog topics

**🔗 Reference:** [Log Compaction](https://kafka.apache.org/documentation/#compaction)

---

## Segment Configuration

**Configure segment size:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --alter --add-config segment.bytes=52428800
background: false
```

**Configure segment time:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --alter --add-config segment.ms=3600000
background: false
```

**📦 Segment Sizing Guidelines:**
- **Small segments** (1-10MB) - Frequent cleanup, more files
- **Medium segments** (100MB) - Balanced approach
- **Large segments** (1GB+) - High throughput, less overhead

**🎯 Segment Strategy by Use Case:**
```
Real-time analytics: segment.bytes=10485760 (10MB)
Batch processing: segment.bytes=1073741824 (1GB)  
Log aggregation: segment.bytes=104857600 (100MB)
```

---

## Compression Configuration

**Set topic-specific compression:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --alter --add-config compression.type=lz4
background: false
```

**Create topics with different compression:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic metrics-lz4 --partitions 1 --replication-factor 1 --config compression.type=lz4
background: false
```

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic logs-gzip --partitions 1 --replication-factor 1 --config compression.type=gzip
background: false
```

**📊 Compression Selection:**
- **lz4** - Low CPU, good throughput (metrics, events)
- **gzip** - High compression, higher CPU (logs, archives)  
- **snappy** - Balanced (general purpose)
- **producer** - Let producer decide (mixed workloads)

---

## Performance Tuning Configurations

**High-throughput topic configuration:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic high-throughput --partitions 6 --replication-factor 1 --config compression.type=lz4 --config segment.bytes=104857600 --config batch.size=32768
background: false
```

**Low-latency topic configuration:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic low-latency --partitions 1 --replication-factor 1 --config compression.type=none --config segment.ms=60000 --config flush.ms=1000
background: false
```

**⚡ Performance Configurations:**
```properties
# High throughput
segment.bytes=104857600
compression.type=lz4  
batch.size=32768

# Low latency
compression.type=none
flush.ms=1000
segment.ms=60000
```

---

## Reliability and Durability

**Configure reliable topic:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic reliable-data --partitions 3 --replication-factor 1 --config min.insync.replicas=1 --config unclean.leader.election.enable=false
background: false
```

**Configure transactional topic:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name reliable-data --alter --add-config max.message.bytes=1000000
background: false
```

**🛡️ Reliability Settings:**
- `min.insync.replicas=1` - Minimum replicas for writes
- `unclean.leader.election.enable=false` - Prevent data loss
- `max.message.bytes` - Control message size limits

---

## Index and Memory Settings

**Configure index settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --alter --add-config segment.index.bytes=10485760,segment.jitter.ms=300000
background: false
```

**🗂️ Index Configuration:**
- `segment.index.bytes` - Index file size (affects seek performance)
- `segment.jitter.ms` - Random delay in segment rolling
- Larger indexes = better seek performance, more memory

---

## Use Case Configurations

**Examine pre-configured examples:**

```terminal:execute
command: docker exec kafka jq '.["high-throughput"]' /opt/kafka/config-examples/topic-configs.json
background: false
```

```terminal:execute
command: docker exec kafka jq '.["low-latency"]' /opt/kafka/config-examples/topic-configs.json
background: false
```

```terminal:execute
command: docker exec kafka jq '.["compacted"]' /opt/kafka/config-examples/topic-configs.json
background: false
```

**Create use case topics:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic user-events --partitions 4 --replication-factor 1 --config compression.type=lz4 --config retention.ms=604800000 --config segment.bytes=104857600
background: false
```

---

## Configuration Validation and Testing

**Validate all topic configurations:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --describe | head -30
background: false
```

**Test configuration with data:**

```terminal:execute
command: docker exec kafka bash -c 'echo "test-message-$(date)" | kafka-console-producer --bootstrap-server localhost:9092 --topic config-demo'
background: false
```

**Monitor configuration impact:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic config-demo
background: false
```

---

## Visual Configuration Management

**Switch to Dashboard and explore:**
1. **Topics → Select topic → Configs tab**
2. **Compare different topic configurations**
3. **Observe storage and performance differences**

**Visual configuration features:**
- Configuration overview per topic
- Default vs custom settings
- Configuration inheritance display

---

## Configuration Templates

**🎯 Template: Event Streaming**
```bash
kafka-topics --create --topic events \
  --partitions 6 \
  --replication-factor 1 \
  --config compression.type=lz4 \
  --config retention.ms=259200000 \
  --config segment.bytes=104857600
```

**🎯 Template: State Store**  
```bash
kafka-topics --create --topic state \
  --partitions 3 \
  --replication-factor 1 \
  --config cleanup.policy=compact \
  --config min.cleanable.dirty.ratio=0.1 \
  --config delete.retention.ms=86400000
```

**🎯 Template: Log Aggregation**
```bash
kafka-topics --create --topic logs \
  --partitions 12 \
  --replication-factor 1 \
  --config compression.type=gzip \
  --config retention.ms=604800000 \
  --config segment.bytes=1073741824
```

---

## Configuration Best Practices

**📋 Topic Configuration Checklist:**
- ✅ **Choose appropriate retention** based on data lifecycle
- ✅ **Set compression** based on CPU vs network trade-offs
- ✅ **Configure segments** for optimal cleanup frequency
- ✅ **Plan partition count** for scalability needs
- ✅ **Document configuration** decisions and use cases

**⚠️ Common Pitfalls:**
- Over-configuring topics (use defaults when possible)
- Mismatched producer/consumer and topic settings
- Ignoring storage implications of retention settings
- Not testing configuration changes in development

---

## Configuration Cleanup

**Reset topic configuration:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name config-demo --alter --delete-config retention.ms,retention.bytes,compression.type
background: false
```

---

## Key Takeaways

**🔧 Essential Topic Configurations:**
- **Retention** - Controls data lifecycle and storage
- **Compression** - Balances CPU usage vs network/storage
- **Segments** - Affects cleanup frequency and file management
- **Cleanup policy** - Determines how old data is handled

**📊 Configuration Impact:**
- Retention settings directly affect storage requirements
- Compression choice impacts CPU and network usage  
- Segment size affects cleanup precision and file count
- Partition count affects parallelism and ordering

**🚀 Next Level:** Producer Configuration - Optimize clients that write data to your configured topics.

**🔗 Essential References:**
- [Topic Configuration Guide](https://kafka.apache.org/documentation/#topicconfigs)
- [Log Compaction Details](https://kafka.apache.org/documentation/#compaction)
- [Retention Policy Guide](https://kafka.apache.org/documentation/#design_log)