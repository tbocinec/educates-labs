# kafka-configs - Dynamic Configuration

The `kafka-configs` tool manages Kafka configuration dynamically without broker restarts.

## Use Cases

- **Topic configuration**: Change retention, compression, segment size
- **Broker tuning**: Modify broker settings without downtime
- **Client quotas**: Throttle problematic producers/consumers
- **Hot fixes**: Apply configuration changes immediately
- **Per-topic optimization**: Fine-tune settings for specific workloads

## Basic Syntax

```bash
kafka-configs --bootstrap-server <brokers> --entity-type <type> --entity-name <name> <action>
```

**Entity Types:**
- `topics` - Topic-level configuration
- `brokers` - Broker-level configuration
- `clients` - Client quotas
- `users` - User quotas

## Describe Topic Configuration

View current topic configuration:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic config-demo \
    --partitions 3 \
    --replication-factor 2 --if-not-exists
session: 1
```

Check configuration:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name config-demo \
    --describe
session: 1
```

> Empty output means using broker default configurations

## Change Retention Policy

Set retention to 1 hour:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name config-demo \
    --alter \
    --add-config retention.ms=3600000
  
  echo "✓ Retention set to 1 hour (3600000 ms)"
session: 1
```

Verify change:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name config-demo \
    --describe
session: 1
```

Test with messages:

```terminal:execute
command: |
  for i in {1..10}; do
    echo "Message $i - timestamp: $(date +%s)"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic config-demo
  
  echo "✓ Messages will be deleted after 1 hour"
session: 1
```

## Enable Compression

Set topic-level compression:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic compressed-topic \
    --partitions 3 \
    --replication-factor 2 --if-not-exists
  
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name compressed-topic \
    --alter \
    --add-config compression.type=snappy
  
  echo "✓ Compression enabled"
session: 1
```

Verify:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name compressed-topic \
    --describe
session: 1
```

Send compressible data:

```terminal:execute
command: |
  for i in {1..100}; do
    echo "Repeated text pattern: $(head -c 300 /dev/zero | tr '\0' 'A')"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic compressed-topic
  
  echo "✓ Data sent with compression"
session: 1
```

## Multiple Configurations

Set multiple configs at once:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic production-topic \
    --partitions 6 \
    --replication-factor 3 --if-not-exists
  
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name production-topic \
    --alter \
    --add-config retention.ms=86400000,compression.type=lz4,min.insync.replicas=2,max.message.bytes=2097152
  
  echo "✓ Multiple configs applied"
session: 1
```

View all configurations:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name production-topic \
    --describe
session: 1
```

**Configurations applied:**
- `retention.ms=86400000` - 24 hours retention
- `compression.type=lz4` - Fast compression
- `min.insync.replicas=2` - Durability guarantee
- `max.message.bytes=2097152` - 2 MB max message size

## Segment Configuration

Control log segment size and rotation:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic segmented-topic \
    --partitions 2 \
    --replication-factor 2 --if-not-exists
  
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name segmented-topic \
    --alter \
    --add-config segment.bytes=10485760,segment.ms=600000
  
  echo "✓ Segment config: 10MB or 10 minutes"
session: 1
```

**Use case:** Smaller segments for faster compaction and deletion

## Cleanup Policy

### Log Compaction

Enable compaction for state topics:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic user-profiles \
    --partitions 4 \
    --replication-factor 2 --if-not-exists
  
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name user-profiles \
    --alter \
    --add-config cleanup.policy=compact,min.compaction.lag.ms=60000
  
  echo "✓ Compaction enabled"
session: 1
```

Send keyed messages (compaction keeps latest per key):

```terminal:execute
command: |
  printf 'user1:{"name":"Alice","version":1}\nuser2:{"name":"Bob","version":1}\nuser1:{"name":"Alice","version":2}\nuser3:{"name":"Charlie","version":1}\nuser1:{"name":"Alice","version":3}' | \
  kafka-console-producer \
    --bootstrap-server $BOOTSTRAP \
    --topic user-profiles \
    --property "parse.key=true" \
    --property "key.separator=:"
  
  echo "✓ Compaction will keep only latest version per user"
session: 1
```

### Delete Policy

Standard time-based deletion:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name config-demo \
    --alter \
    --add-config cleanup.policy=delete
session: 1
```

## Remove Configuration

Delete custom config to revert to broker defaults:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name config-demo \
    --alter \
    --delete-config retention.ms
  
  echo "✓ Reverted to broker default retention"
session: 1
```

Verify removal:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name config-demo \
    --describe
session: 1
```

## Broker Configuration

View broker configuration:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type brokers \
    --entity-name 1 \
    --describe
session: 1
```

Modify broker config (example - log flush):

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type brokers \
    --entity-name 1 \
    --alter \
    --add-config log.flush.interval.messages=1000
  
  echo "✓ Broker 1 config updated"
session: 1
```

## Client Quotas

Throttle a specific producer/consumer:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type clients \
    --entity-name test-client \
    --alter \
    --add-config producer_byte_rate=1048576,consumer_byte_rate=2097152
  
  echo "✓ Client quotas: 1 MB/s produce, 2 MB/s consume"
session: 1
```

View client quotas:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type clients \
    --entity-name test-client \
    --describe
session: 1
```

## List All Configured Entities

Find all topics with custom configurations:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --describe --all | grep "Configs for" | head -10
session: 1
```

## Real-World Scenarios

### Scenario 1: Emergency Retention Increase

Disk space issue - temporarily increase retention:

```terminal:execute
command: |
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name large-topic \
    --alter \
    --add-config retention.ms=7200000
  
  echo "✓ Retention reduced to 2 hours to free disk space"
session: 1
```

### Scenario 2: Performance Tuning

Optimize high-throughput topic:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic high-perf \
    --partitions 12 \
    --replication-factor 2 --if-not-exists
  
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name high-perf \
    --alter \
    --add-config compression.type=lz4,segment.bytes=52428800,min.insync.replicas=1
  
  echo "✓ Optimized for throughput"
session: 1
```

### Scenario 3: Compliance Requirement

Set short retention for sensitive data:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic sensitive-logs \
    --partitions 3 \
    --replication-factor 2 --if-not-exists
  
  kafka-configs --bootstrap-server $BOOTSTRAP \
    --entity-type topics \
    --entity-name sensitive-logs \
    --alter \
    --add-config retention.ms=3600000,min.insync.replicas=2
  
  echo "✓ 1-hour retention for compliance"
session: 1
```

## Common Configuration Reference

| Config | Values | Use Case |
|--------|--------|----------|
| `retention.ms` | milliseconds | How long to keep messages |
| `compression.type` | `gzip`, `snappy`, `lz4`, `zstd` | Save disk/network |
| `cleanup.policy` | `delete`, `compact` | Deletion vs compaction |
| `min.insync.replicas` | number | Write durability |
| `max.message.bytes` | bytes | Message size limit |
| `segment.bytes` | bytes | Log segment size |
| `segment.ms` | milliseconds | Max segment age |

## Best Practices

### 1. Document Configuration Changes

Keep a log of config changes:

```bash
echo "$(date): Changed retention for config-demo to 1h" >> /tmp/config-changes.log
```

### 2. Test Before Production

Test configuration changes on non-critical topics first.

### 3. Monitor After Changes

Watch metrics after config changes to verify desired effect.

### 4. Use Descriptive Names

Name topics clearly to understand retention requirements.

## Summary

You now know how to:
- ✅ View and modify topic configurations
- ✅ Change retention, compression, and cleanup policies
- ✅ Set multiple configurations simultaneously
- ✅ Configure brokers and client quotas
- ✅ Remove configurations to revert to defaults
- ✅ Apply real-world configuration scenarios
- ✅ Optimize topics for different workloads

## Next Steps

Next, we'll learn **kafka-acls** for security and authorization management.
