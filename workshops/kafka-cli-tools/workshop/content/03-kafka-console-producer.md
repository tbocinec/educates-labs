# kafka-console-producer - Publishing Messages

The `kafka-console-producer` tool publishes messages to Kafka topics from the command line.

## Use Cases

- **Testing**: Verify topic connectivity and producer configuration
- **Data injection**: Manually insert test data or corrections
- **Debugging**: Troubleshoot producer configuration issues
- **Prototyping**: Quick experimentation without writing code

## Basic Syntax

```bash
kafka-console-producer --bootstrap-server <brokers> --topic <topic-name> [options]
```

## Simple Message Publishing

Create a test topic:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic messages \
    --partitions 3 \
    --replication-factor 2
session: 1
```

Send messages interactively:

```terminal:execute
command: |
  echo -e "Hello Kafka!\nMessage 1\nMessage 2\nMessage 3" | \
  kafka-console-producer --bootstrap-server $BOOTSTRAP --topic messages
session: 1
```

Verify messages were sent:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic messages \
    --from-beginning \
    --max-messages 4 \
    --timeout-ms 3000
session: 1
```

## Publishing with Keys

Keys enable:
- **Partitioning**: Messages with the same key go to the same partition
- **Ordering**: Guaranteed order for messages with the same key
- **Compaction**: Retain only the latest value per key

Create a topic for keyed messages:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic user-events \
    --partitions 3 \
    --replication-factor 2
session: 1
```

Send key-value pairs (key:value format):

```terminal:execute
command: |
  echo -e "user123:login\nuser456:signup\nuser123:page_view\nuser789:purchase\nuser123:logout" | \
  kafka-console-producer \
    --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --property "parse.key=true" \
    --property "key.separator=:"
session: 1
```

Read messages with keys:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --from-beginning \
    --property print.key=true \
    --property key.separator=" => " \
    --timeout-ms 3000
session: 1
```

> All messages for `user123` are routed to the same partition, preserving order.

## Producer Properties

### Acknowledgments (acks)

Control durability vs performance trade-off:

```terminal:execute
command: |
  echo "Critical transaction data" | kafka-console-producer \
    --bootstrap-server $BOOTSTRAP \
    --topic messages \
    --property acks=all \
    --property retries=3
session: 1
```

**acks options:**
- `acks=0` - No acknowledgment (fastest, least durable)
- `acks=1` - Leader acknowledgment only
- `acks=all` - All in-sync replicas (slowest, most durable)

### Compression

Reduce network and disk usage:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic compressed-logs \
    --partitions 2 \
    --replication-factor 2 --if-not-exists
  
  for i in {1..20}; do
    echo "Log entry $i with repeated text content for compression"
  done | kafka-console-producer \
    --bootstrap-server $BOOTSTRAP \
    --topic compressed-logs \
    --property compression.type=snappy
session: 1
```

**Compression types:** `snappy`, `lz4`, `gzip`, `zstd`

**Use case:** High-volume logs, large JSON payloads

## Sending JSON Messages

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic orders \
    --partitions 3 \
    --replication-factor 3 --if-not-exists
  
  echo -e '{"order_id": "ORD-001", "amount": 99.99, "status": "pending"}\n{"order_id": "ORD-002", "amount": 149.50, "status": "completed"}\n{"order_id": "ORD-003", "amount": 75.00, "status": "pending"}' | \
  kafka-console-producer --bootstrap-server $BOOTSTRAP --topic orders
session: 1
```

Verify JSON messages:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic orders \
    --from-beginning \
    --max-messages 3 \
    --timeout-ms 3000
session: 1
```

## Performance Testing

Generate high-volume test data:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic load-test \
    --partitions 12 \
    --replication-factor 2 --if-not-exists
  
  for i in {1..100}; do
    echo "Message $i: $(date +%s%N)"
  done | kafka-console-producer \
    --bootstrap-server $BOOTSTRAP \
    --topic load-test \
    --property compression.type=lz4 \
    --property linger.ms=10 \
    --property batch.size=16384
  
  echo "✓ Sent 100 messages with batching and compression"
session: 1
```

**Performance properties:**
- `linger.ms` - Wait time to batch messages
- `batch.size` - Maximum batch size in bytes
- `buffer.memory` - Total memory for buffering

## Specific Partition Targeting

Send to a specific partition:

```terminal:execute
command: |
  echo "Partition 0 message" | kafka-console-producer \
    --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --property partition=0
session: 1
```

Verify partition placement:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --partition 0 \
    --from-beginning \
    --timeout-ms 2000
session: 1
```

## Common Errors

### Error: Topic Does Not Exist

If `auto.create.topics.enable=false` on broker:

```
ERROR: Topic 'nonexistent' does not exist
```

**Fix:** Create topic first with `kafka-topics --create`

### Error: Message Too Large

```
ERROR: Message size exceeds max.message.bytes
```

**Fix:** Increase topic's `max.message.bytes` or reduce message size

### Error: Not Enough In-Sync Replicas

```
ERROR: Number of insync replicas is below required minimum
```

**Fix:** Ensure enough brokers are running and in-sync

## Production Best Practices

### 1. Always Use acks=all for Critical Data

```bash
--property acks=all --property retries=5
```

### 2. Enable Idempotence

Prevents duplicate messages on retry:

```bash
--property enable.idempotence=true
```

### 3. Use Compression for High Volume

```bash
--property compression.type=lz4
```

### 4. Set Appropriate Timeouts

```bash
--property request.timeout.ms=30000
```

## Summary

You now know how to:
- ✅ Send simple messages to topics
- ✅ Use keys for partitioning and ordering
- ✅ Configure producer properties (acks, compression)
- ✅ Send JSON and structured data
- ✅ Generate test data at scale
- ✅ Target specific partitions
- ✅ Handle common errors

## Next Steps

Next, we'll learn **kafka-console-consumer** to read and filter these messages.
