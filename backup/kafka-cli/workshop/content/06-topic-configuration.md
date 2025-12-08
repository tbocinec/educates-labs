# Topic Configuration & Retention Policies

Master Kafka's powerful data lifecycle management with comprehensive topic configuration and retention strategies! ⚙️

---

## Learning Objectives

In this level you'll master:
- ✅ **Retention policies** - Time-based and size-based cleanup
- ✅ **Cleanup strategies** - Delete vs compact policies
- ✅ **Segment management** - How Kafka organizes data files
- ✅ **Compression settings** - Storage optimization techniques
- ✅ **Performance tuning** - Configuration for different workloads
- ✅ **Real-world scenarios** - Practical retention strategies

---

## 1. Understanding Current Topic Configurations

Let's examine the configurations of our existing topics:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events
background: false
```

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name user-events --describe
background: false
```

**🔍 Key configuration categories:**
- **Retention** - How long to keep data
- **Cleanup** - How to handle old data
- **Segments** - File organization
- **Compression** - Storage optimization

---

## 2. Time-Based Retention

Create topics with different time-based retention policies:

**Short-term cache (1 hour retention):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic temp-cache --partitions 2 --replication-factor 1 --config retention.ms=3600000 --config cleanup.policy=delete
background: false
```

**Daily logs (24 hours retention):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic daily-logs --partitions 3 --replication-factor 1 --config retention.ms=86400000 --config cleanup.policy=delete
background: false
```

**Long-term archive (30 days retention):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic archive-data --partitions 1 --replication-factor 1 --config retention.ms=2592000000 --config cleanup.policy=delete
background: false
```

**Verify configurations:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name temp-cache --describe
background: false
```

---

## 3. Size-Based Retention

Create topics with size-based retention limits:

**Small topic (10MB max):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic small-buffer --partitions 1 --replication-factor 1 --config retention.bytes=10485760 --config segment.bytes=1048576
background: false
```

**Medium topic (100MB max):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic medium-storage --partitions 4 --replication-factor 1 --config retention.bytes=104857600 --config segment.bytes=10485760
background: false
```

**Check size-based settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name small-buffer --describe
background: false
```

**📏 Size retention formula:**
- `retention.bytes` - Total bytes to keep per partition
- `segment.bytes` - Size of each segment file
- Cleanup happens when segment is older than retention AND segment is full

---

## 4. Log Compaction Setup

Create a compacted topic for key-based state storage:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic user-profiles --partitions 3 --replication-factor 1 --config cleanup.policy=compact --config min.cleanable.dirty.ratio=0.1 --config segment.ms=60000
background: false
```

**Send user profile updates:**

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic user-profiles --property "parse.key=true" --property "key.separator=:"
background: false
```

**Send evolving user data:**
```
user-123:{"name":"John","email":"john@example.com","version":1}
user-456:{"name":"Mary","email":"mary@example.com","version":1}
user-123:{"name":"John","email":"john@newdomain.com","version":2}
user-789:{"name":"Bob","email":"bob@example.com","version":1}
user-123:{"name":"John","email":"john@newdomain.com","status":"premium","version":3}
user-456:{"name":"Mary","email":"mary@newdomain.com","version":2}
```

**📝 Log compaction behavior:**
- Keeps only the latest value for each key
- Older versions are eventually removed
- Perfect for state storage and change logs

---

## 5. Combined Retention Policies

Create a topic with both time AND size limits:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic hybrid-retention --partitions 2 --replication-factor 1 --config retention.ms=604800000 --config retention.bytes=52428800 --config cleanup.policy=delete
background: false
```

**Understanding hybrid retention:**
- Data is deleted when EITHER condition is met
- `retention.ms=604800000` - 7 days OR
- `retention.bytes=52428800` - 50MB per partition
- Whichever limit is reached first triggers cleanup

---

## 6. Segment Configuration Deep Dive

Create a topic optimized for different segment strategies:

**High-frequency rotation (small, frequent segments):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic frequent-rotation --partitions 2 --replication-factor 1 --config segment.bytes=1048576 --config segment.ms=300000 --config retention.ms=3600000
background: false
```

**Batch processing (large, infrequent segments):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic batch-segments --partitions 1 --replication-factor 1 --config segment.bytes=104857600 --config segment.ms=86400000 --config retention.ms=2592000000
background: false
```

**⚙️ Segment settings explained:**
- `segment.bytes` - Max size before rolling new segment
- `segment.ms` - Max time before rolling new segment
- Smaller segments = More frequent cleanup + Higher overhead
- Larger segments = Less frequent cleanup + Lower overhead

---

## 7. Compression Configuration

Test different compression algorithms:

**LZ4 compression (fast compression/decompression):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic lz4-compressed --partitions 2 --replication-factor 1 --config compression.type=lz4 --config segment.bytes=10485760
background: false
```

**GZIP compression (high compression ratio):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic gzip-compressed --partitions 2 --replication-factor 1 --config compression.type=gzip --config segment.bytes=10485760
background: false
```

**Test compression effectiveness:**

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic lz4-compressed
background: false
```

**Send repetitive data to see compression benefits:**
```
This is a repetitive message with lots of repeated words and repeated patterns and repeated data structures
This is a repetitive message with lots of repeated words and repeated patterns and repeated data structures
This is a repetitive message with lots of repeated words and repeated patterns and repeated data structures
```

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic gzip-compressed
background: false
```

**Send same data to compare compression ratios.**

---

## 8. Dynamic Configuration Changes

Modify retention settings on existing topics:

**Change retention time:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name user-events --alter --add-config retention.ms=1209600000
background: false
```

**Add size-based retention:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name user-events --alter --add-config retention.bytes=209715200
background: false
```

**Verify changes:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name user-events --describe
background: false
```

**⚡ Dynamic configuration benefits:**
- No topic recreation needed
- No data loss during changes
- Changes take effect immediately

---

## 9. Performance Tuning Configurations

Create topics optimized for different performance patterns:

**High-throughput writes:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic high-throughput --partitions 6 --replication-factor 1 --config compression.type=lz4 --config batch.size=32768 --config linger.ms=5 --config buffer.memory=67108864
background: false
```

**Low-latency processing:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic low-latency --partitions 1 --replication-factor 1 --config compression.type=none --config linger.ms=0 --config batch.size=1
background: false
```

**Reliable storage:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic reliable-storage --partitions 2 --replication-factor 1 --config acks=all --config min.insync.replicas=1 --config unclean.leader.election.enable=false
background: false
```

---

## 10. Retention Monitoring and Verification

Generate data to test retention policies:

```terminal:execute
command: docker exec kafka bash -c 'for i in {1..100}; do echo "temp-data-$i:Temporary message $i $(date)"; done | kafka-console-producer --bootstrap-server localhost:9092 --topic temp-cache --property "parse.key=true" --property "key.separator=:"'
background: false
```

**Check topic size and message count:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic temp-cache
background: false
```

**Force log segment rolling (for testing):**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name temp-cache --alter --add-config segment.ms=1000
background: false
```

**Wait and check again (segments will roll frequently):**

```terminal:execute
command: sleep 5 && docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic temp-cache
background: false
```

---

## 11. Cleanup Policy Comparison

**Demonstrate delete policy:**

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic daily-logs
background: false
```

```
2024-01-15 10:00:00 ERROR Database connection failed
2024-01-15 10:00:05 INFO Retrying database connection
2024-01-15 10:00:10 INFO Database connection restored
2024-01-15 10:00:15 WARN High memory usage detected
2024-01-15 10:00:20 INFO Memory garbage collection completed
```

**Demonstrate compact policy:**

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic user-profiles --property "parse.key=true" --property "key.separator=:"
background: false
```

```
config-1:{"max_connections":100}
config-2:{"timeout":30}
config-1:{"max_connections":200}
config-3:{"retry_attempts":5}
config-1:{"max_connections":300}
```

**Read compacted topic:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-profiles --from-beginning --property "print.key=true" --property "key.separator=:"
background: false
```

**🔄 Notice:** Only latest values for each key are retained in compacted topics.

---

## 12. Real-World Retention Scenarios

**Scenario 1: Transaction logs (compliance requirement)**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic transaction-logs --partitions 4 --replication-factor 1 --config retention.ms=31536000000 --config cleanup.policy=delete --config compression.type=gzip
background: false
```

**Scenario 2: Real-time metrics (short retention, high volume)**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic realtime-metrics --partitions 8 --replication-factor 1 --config retention.ms=3600000 --config segment.bytes=1048576 --config compression.type=lz4
background: false
```

**Scenario 3: User state management (compacted)**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic user-state --partitions 6 --replication-factor 1 --config cleanup.policy=compact --config delete.retention.ms=86400000 --config min.cleanable.dirty.ratio=0.5
background: false
```

---

## 13. Configuration Validation and Troubleshooting

**List all topic configurations:**

```terminal:execute
command: docker exec kafka bash -c 'kafka-topics --bootstrap-server localhost:9092 --list | grep -v "^__" | xargs -I {} kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name {} --describe'
background: false
```

**Check for configuration conflicts:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name hybrid-retention --describe | grep -E "(retention|cleanup|segment)"
background: false
```

**Reset configurations to defaults:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name temp-cache --alter --delete-config segment.ms
background: false
```

---

## 14. Visual Configuration Management

Switch to **Dashboard** tab and explore:

1. **Topics → Select any topic → Configs tab**
2. **Review retention settings** visually
3. **Compare different topics** and their configurations
4. **Notice default vs custom** settings

**Key UI features:**
- Configuration overview
- Size and time retention display
- Compression settings visualization

---

## Key Configuration Commands

**Essential Operations:**
```bash
# View topic configuration
kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name TOPIC --describe

# Add/modify configuration
kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name TOPIC --alter --add-config key=value

# Remove configuration (use default)
kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name TOPIC --alter --delete-config key

# Create topic with configuration
kafka-topics --bootstrap-server localhost:9092 --create --topic TOPIC --partitions N --replication-factor N --config key=value
```

---

## Configuration Categories Reference

**🕒 Retention Settings:**
```bash
retention.ms=86400000          # 24 hours in milliseconds
retention.bytes=104857600      # 100MB per partition
cleanup.policy=delete          # delete vs compact
delete.retention.ms=86400000   # How long to keep tombstones
```

**📁 Segment Settings:**
```bash
segment.bytes=104857600        # 100MB segment size
segment.ms=86400000           # 24 hour segment rolling
segment.index.bytes=10485760   # 10MB index size
```

**🗜️ Compression Settings:**
```bash
compression.type=lz4           # none, gzip, snappy, lz4, zstd
```

**🔧 Performance Settings:**
```bash
min.cleanable.dirty.ratio=0.5  # Compaction trigger ratio
max.message.bytes=1000000      # Max message size
```

---

## Retention Strategy Decision Matrix

**Choose based on your use case:**

| **Use Case** | **Cleanup Policy** | **Retention Time** | **Segment Size** | **Compression** |
|--------------|-------------------|-------------------|-----------------|----------------|
| **Event Logs** | delete | 7-30 days | Large (100MB) | gzip |
| **Metrics** | delete | 1-24 hours | Small (1MB) | lz4 |
| **State Store** | compact | infinite | Medium (10MB) | lz4 |
| **Cache** | delete | 1 hour | Small (1MB) | none |
| **Audit Logs** | delete | 7 years | Large (100MB) | gzip |

---

## Current Configuration Summary

Review all our configured topics:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list --exclude-internal
background: false
```

**Topics created with specific retention strategies:**
- `temp-cache` - 1 hour retention
- `daily-logs` - 24 hours retention  
- `archive-data` - 30 days retention
- `user-profiles` - Compacted (infinite retention)
- `small-buffer` - 10MB size limit
- `hybrid-retention` - 7 days OR 50MB

**🚀 Ready for Level 6!**

Next: **Admin Tools & Operations** - Advanced Kafka cluster administration and maintenance tasks.

**🔗 Essential References:**
- [Topic Configuration Guide](https://kafka.apache.org/documentation/#topicconfigs)
- [Log Compaction](https://kafka.apache.org/documentation/#compaction)
- [Retention Policies](https://kafka.apache.org/documentation/#impl_log)