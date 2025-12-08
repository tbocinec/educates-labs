# Admin Tools & Operations - Advanced Kafka Management

Master essential administrative operations for maintaining and troubleshooting Kafka clusters in production! 🔧

---

## Learning Objectives

In this level you'll master:
- ✅ **Log directories** - Inspect storage and disk usage
- ✅ **Partition management** - Reassignment and leadership
- ✅ **Broker administration** - Cluster health and metadata
- ✅ **Performance analysis** - Throughput and latency tools
- ✅ **Data operations** - Delete records and manage segments
- ✅ **Troubleshooting** - Common operational issues
- ✅ **Monitoring tools** - Built-in diagnostic utilities

---

## 1. Kafka Log Directory Analysis

Explore where Kafka stores data on disk:

```terminal:execute
command: docker exec kafka kafka-log-dirs --bootstrap-server localhost:9092 --describe --json | python3 -m json.tool
background: false
```

**Understanding log directory structure:**
- Each partition has its own directory
- Segment files (.log), index files (.index), timeindex (.timeindex)
- Current size and lag information per partition

**Check specific topic log information:**

```terminal:execute
command: docker exec kafka kafka-log-dirs --bootstrap-server localhost:9092 --describe --topic-list user-events --json | python3 -m json.tool
background: false
```

---

## 2. Broker Configuration and Metadata

**View broker information:**

```terminal:execute
command: docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092
background: false
```

**Get cluster metadata:**

```terminal:execute
command: docker exec kafka kafka-metadata-shell --snapshot /opt/kafka/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log --print --help
background: false
```

**Check broker configuration:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe
background: false
```

---

## 3. Partition Leadership and Reassignment

**Check current partition leadership:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events
background: false
```

**Create a reassignment plan (simulation):**

```terminal:execute
command: docker exec kafka tee /tmp/reassignment.json << 'EOF'
{
  "partitions": [
    {
      "topic": "user-events",
      "partition": 0,
      "replicas": [1]
    },
    {
      "topic": "user-events", 
      "partition": 1,
      "replicas": [1]
    }
  ]
}
EOF
background: false
```

**Verify reassignment plan:**

```terminal:execute
command: docker exec kafka kafka-reassign-partitions --bootstrap-server localhost:9092 --reassignment-json-file /tmp/reassignment.json --verify
background: false
```

**📝 Note:** In a single-broker setup, reassignment is limited, but this shows the tools for multi-broker clusters.

---

## 4. Performance Testing Tools

**Producer performance test:**

```terminal:execute
command: docker exec kafka kafka-producer-perf-test --topic user-events --num-records 10000 --record-size 100 --throughput 1000 --producer-props bootstrap.servers=localhost:9092
background: false
```

**Consumer performance test:**

```terminal:execute
command: docker exec kafka kafka-consumer-perf-test --topic user-events --messages 10000 --bootstrap-server localhost:9092 --reporting-interval 1000
background: false
```

**📊 Performance metrics explained:**
- **Throughput** - Records/second, MB/second
- **Latency** - Average, 95th, 99th percentile
- **Batch efficiency** - Records per request

---

## 5. Replica and Leader Management

**Check replica lag and synchronization:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --under-replicated-partitions
background: false
```

**Force leader election (emergency operations):**

```terminal:execute
command: docker exec kafka kafka-leader-election --bootstrap-server localhost:9092 --election-type preferred --all-topic-partitions
background: false
```

**Check partition details with replica info:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events --under-min-isr-partitions
background: false
```

---

## 6. Data Management Operations

**Delete specific records (by offset):**

Create a deletion specification:

```terminal:execute
command: docker exec kafka tee /tmp/delete-records.json << 'EOF'
{
  "partitions": [
    {
      "topic": "temp-cache",
      "partition": 0,
      "offset": 5
    }
  ]
}
EOF
background: false
```

**Execute record deletion:**

```terminal:execute
command: docker exec kafka kafka-delete-records --bootstrap-server localhost:9092 --offset-json-file /tmp/delete-records.json
background: false
```

**Verify deletion:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic temp-cache --from-beginning --max-messages 10 --property "print.offset=true"
background: false
```

---

## 7. Segment and Index Analysis

**Generate data for segment analysis:**

```terminal:execute
command: docker exec kafka bash -c 'for i in {1..500}; do echo "segment-test-$i:Data for segment analysis $i"; done | kafka-console-producer --bootstrap-server localhost:9092 --topic frequent-rotation --property "parse.key=true" --property "key.separator=:"'
background: false
```

**Analyze segment files in log directory:**

```terminal:execute
command: docker exec kafka find /opt/kafka/kraft-combined-logs -name "frequent-rotation*" -type f | head -20
background: false
```

**Check segment sizes:**

```terminal:execute
command: docker exec kafka ls -lah /opt/kafka/kraft-combined-logs/frequent-rotation-* | head -10
background: false
```

---

## 8. Topic Statistics and Analysis

**Get detailed topic statistics:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topics-with-overrides
background: false
```

**Check all topic sizes:**

```terminal:execute
command: docker exec kafka kafka-log-dirs --bootstrap-server localhost:9092 --describe | grep -E "\"topic\"|\"size\""
background: false
```

**Count messages in specific topic:**

```terminal:execute
command: docker exec kafka bash -c 'kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --from-beginning --timeout-ms 5000 | wc -l'
background: false
```

---

## 9. Cluster Health Monitoring

**Check cluster ID and broker status:**

```terminal:execute
command: docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 | head -5
background: false
```

**Monitor consumer group lag across all topics:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --all-groups | head -20
background: false
```

**Check for problematic topics:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --unavailable-partitions
background: false
```

---

## 10. Advanced Configuration Management

**Dynamically modify broker configurations:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --add-config log.segment.bytes=67108864
background: false
```

**List all configurable broker properties:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --describe | head -10
background: false
```

**Reset broker configuration:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name 1 --alter --delete-config log.segment.bytes
background: false
```

---

## 11. Transaction and Producer ID Management

**Check producer ID mappings (advanced):**

```terminal:execute
command: docker exec kafka kafka-transactions --bootstrap-server localhost:9092 --list
background: false
```

**Send transactional messages (demonstration):**

```terminal:execute
command: docker exec kafka kafka-console-producer --bootstrap-server localhost:9092 --topic user-events --producer-property transactional.id=demo-transaction --producer-property enable.idempotence=true
background: false
```

**Note:** Type a few messages, then Ctrl+C. Transactions require special handling in production.

---

## 12. Quota Management and Throttling

**Set producer quotas (bytes/second):**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type users --entity-name default --alter --add-config producer_byte_rate=1048576
background: false
```

**Set consumer quotas:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type users --entity-name default --alter --add-config consumer_byte_rate=2097152
background: false
```

**Check quota settings:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type users --entity-name default --describe
background: false
```

**Remove quotas:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type users --entity-name default --alter --delete-config producer_byte_rate,consumer_byte_rate
background: false
```

---

## 13. Diagnostic and Troubleshooting Tools

**Dump topic configuration details:**

```terminal:execute
command: docker exec kafka kafka-dump-log --files /opt/kafka/kraft-combined-logs/user-events-0/00000000000000000000.log --print-data-log | head -20
background: false
```

**Check message format and structure:**

```terminal:execute
command: docker exec kafka kafka-run-class kafka.tools.DumpLogSegments --files /opt/kafka/kraft-combined-logs/user-events-0/00000000000000000000.log --print-data-log | head -10
background: false
```

**Verify consumer group state:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing --state
background: false
```

---

## 14. Backup and Recovery Operations

**Export topic configuration (backup):**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events > /tmp/user-events-backup.txt
background: false
```

**Export consumer group offsets:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing --export > /tmp/offsets-backup.csv
background: false
```

**Check backup files:**

```terminal:execute
command: docker exec kafka ls -la /tmp/*backup*
background: false
```

---

## 15. Visual Administrative Interface

Switch to **Dashboard** tab and explore administrative features:

1. **Overview** - Cluster health and broker status
2. **Topics** - Administrative view of all topics
3. **Consumer Groups** - Group management and monitoring
4. **Brokers** - Broker configuration and health

**Compare CLI vs UI administrative capabilities** - both are essential for comprehensive cluster management.

---

## Essential Admin Commands Reference

**🔍 Inspection Tools:**
```bash
# Log directories and sizes
kafka-log-dirs --bootstrap-server localhost:9092 --describe

# Broker information
kafka-broker-api-versions --bootstrap-server localhost:9092

# Partition leadership
kafka-topics --bootstrap-server localhost:9092 --describe --topic TOPIC

# Consumer group details
kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group GROUP
```

**⚡ Performance Tools:**
```bash
# Producer performance test
kafka-producer-perf-test --topic TOPIC --num-records N --record-size SIZE --throughput RATE --producer-props bootstrap.servers=localhost:9092

# Consumer performance test
kafka-consumer-perf-test --topic TOPIC --messages N --bootstrap-server localhost:9092
```

**🔧 Management Operations:**
```bash
# Reassign partitions
kafka-reassign-partitions --bootstrap-server localhost:9092 --reassignment-json-file FILE.json --execute

# Delete records
kafka-delete-records --bootstrap-server localhost:9092 --offset-json-file FILE.json

# Broker configuration
kafka-configs --bootstrap-server localhost:9092 --entity-type brokers --entity-name ID --alter --add-config KEY=VALUE
```

---

## Operational Best Practices

**🎯 Daily Operations:**
1. **Monitor disk usage** - Use `kafka-log-dirs` to track space
2. **Check partition health** - Look for under-replicated partitions
3. **Review consumer lag** - Ensure consumers keep up with producers
4. **Validate configurations** - Regular config audits

**🚨 Emergency Procedures:**
1. **Partition reassignment** - Balance load across brokers
2. **Leader election** - Fix stuck partitions
3. **Record deletion** - Remove problematic messages
4. **Configuration rollback** - Revert problematic settings

**📊 Performance Monitoring:**
1. **Throughput testing** - Regular performance benchmarks
2. **Latency analysis** - Track 95th/99th percentiles
3. **Resource utilization** - CPU, memory, disk, network
4. **Quota enforcement** - Prevent resource abuse

---

## Common Administrative Scenarios

**Scenario 1: High Disk Usage**
```bash
# 1. Check disk usage per topic
kafka-log-dirs --bootstrap-server localhost:9092 --describe

# 2. Reduce retention for large topics
kafka-configs --entity-type topics --entity-name TOPIC --alter --add-config retention.ms=86400000

# 3. Force log cleanup
kafka-configs --entity-type topics --entity-name TOPIC --alter --add-config segment.ms=1000
```

**Scenario 2: Consumer Lag Issues**
```bash
# 1. Identify lagging consumer groups
kafka-consumer-groups --bootstrap-server localhost:9092 --describe --all-groups

# 2. Add more consumers or increase partition count
kafka-topics --bootstrap-server localhost:9092 --alter --topic TOPIC --partitions 8

# 3. Reset offsets if needed
kafka-consumer-groups --group GROUP --reset-offsets --to-latest --topic TOPIC --execute
```

**Scenario 3: Performance Optimization**
```bash
# 1. Run performance tests
kafka-producer-perf-test --topic TOPIC --num-records 100000 --record-size 1024 --throughput -1

# 2. Tune topic configuration
kafka-configs --entity-type topics --entity-name TOPIC --alter --add-config compression.type=lz4,batch.size=16384

# 3. Monitor improvement
kafka-consumer-perf-test --topic TOPIC --messages 100000 --bootstrap-server localhost:9092
```

---

## Current Cluster State

Let's review our cluster's administrative status:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list --exclude-internal | wc -l
background: false
```

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --list | wc -l
background: false
```

```terminal:execute
command: docker exec kafka kafka-log-dirs --bootstrap-server localhost:9092 --describe | grep -c "\"topic\""
background: false
```

**Administrative summary:**
- **Topics created:** Multiple test topics with various configurations
- **Consumer groups:** Several active and inactive groups
- **Storage usage:** Distributed across partitions
- **Performance:** Tested with synthetic workloads

**🚀 Ready for Level 7!**

Next: **Security & ACL** - Access control lists and authentication mechanisms (optional advanced topic).

**🔗 Essential References:**
- [Kafka Admin Tools](https://kafka.apache.org/documentation/#basic_ops)
- [Performance Testing](https://kafka.apache.org/documentation/#basic_ops_performance)
- [Troubleshooting Guide](https://kafka.apache.org/documentation/#troubleshooting)