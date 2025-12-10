# kafka-topics - Topic Management

The `kafka-topics` tool manages topic lifecycle: creation, modification, and deletion.

## Basic Syntax

```bash
kafka-topics --bootstrap-server <brokers> <action> [options]
```

**Actions:**
- `--create` - Create new topic
- `--list` - List all topics
- `--describe` - Show topic details
- `--alter` - Modify existing topic
- `--delete` - Delete topic

## Create a Topic

### Simple Topic (Development)

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic demo-topic \
    --partitions 1 \
    --replication-factor 1
session: 1
```

**Parameters:**
- `--topic` - Topic name
- `--partitions` - Number of partitions
- `--replication-factor` - Number of replicas

### Verify Creation

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP --list | grep demo-topic
session: 1
```

## Describe Topics

View detailed information:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic demo-topic
session: 1
```

**Output shows:**
- **PartitionCount** - Number of partitions
- **ReplicationFactor** - Number of replicas
- **Leader** - Which broker leads each partition
- **Replicas** - Broker IDs hosting replicas
- **Isr** - In-Sync Replicas (synchronized copies)

## Production-Ready Topic

For production, use **multiple partitions** and **replication factor > 1**:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic orders \
    --partitions 6 \
    --replication-factor 3 \
    --config min.insync.replicas=2
session: 1
```

**Why this configuration?**
- **6 partitions**: Parallelism for consumers
- **RF=3**: Survives 2 broker failures
- **min.insync.replicas=2**: Ensures write durability

### Verify Configuration

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic orders
session: 1
```

Notice:
- Leaders are **distributed across brokers** (load balancing)
- **ISR** shows all 3 replicas are synchronized
- Each partition has 3 copies on different brokers

## Topic Configuration

### Retention Time

Control how long messages are retained:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic logs-shortterm \
    --partitions 3 \
    --replication-factor 2 \
    --config retention.ms=3600000
session: 1
```

`retention.ms=3600000` = 1 hour

**Use case:** Temporary data, caches, ephemeral events

### Compression

Enable compression to save disk space and network bandwidth:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic events-compressed \
    --partitions 4 \
    --replication-factor 3 \
    --config compression.type=snappy
session: 1
```

**Compression types:** `gzip`, `snappy`, `lz4`, `zstd`

**Use case:** Large messages, high-throughput topics

### Message Size Limit

Increase maximum message size:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic large-payloads \
    --partitions 2 \
    --replication-factor 2 \
    --config max.message.bytes=5242880
session: 1
```

`5242880` bytes = 5 MB (default is 1 MB)

**Use case:** File uploads, binary data, large JSON documents

## Partitions - Key Concepts

### Single Partition (Ordered Processing)

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic sequential-logs \
    --partitions 1 \
    --replication-factor 2
session: 1
```

**Use when:**
- ✅ Need strict message ordering
- ✅ Low throughput
- ❌ Cannot scale consumers (max 1 per group)

### Multiple Partitions (Parallel Processing)

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic high-volume-events \
    --partitions 12 \
    --replication-factor 3
session: 1
```

**Use when:**
- ✅ High throughput required
- ✅ Multiple consumers for parallelism
- ✅ Load balancing across brokers
- ⚠️ No global ordering (only per-partition)

## Alter Topics

### Increase Partitions

You can **increase** partitions (but not decrease):

```terminal:execute
command: |
  echo "Current partitions:"
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic demo-topic | grep PartitionCount
  
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --alter \
    --topic demo-topic \
    --partitions 3
  
  echo "New partition count:"
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic demo-topic | grep PartitionCount
session: 1
```

**Important:**
- ✅ Increase partitions - Allowed
- ❌ Decrease partitions - Not supported
- ⚠️ Affects key-based routing for existing keys

## Delete Topics

**Warning:** Deletion is permanent and removes all data!

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --delete \
    --topic demo-topic
session: 1
```

### Verify Deletion

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP --list | grep demo-topic || \
    echo "✓ Topic deleted successfully"
session: 1
```

## Real-World Use Cases

### Dead Letter Queue (DLQ)

For messages that fail processing:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic orders-dlq \
    --partitions 3 \
    --replication-factor 3 \
    --config retention.ms=2592000000
session: 1
```

Retention: 30 days to review failed messages

### Compacted Topic (State Store)

For maintaining latest state per key:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic user-profiles \
    --partitions 6 \
    --replication-factor 3 \
    --config cleanup.policy=compact \
    --config min.compaction.lag.ms=60000
session: 1
```

**Use case:** User profiles, configuration updates, product catalogs

### Test Topic (Auto-cleanup)

For temporary testing with fast data expiration:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic test-temp \
    --partitions 1 \
    --replication-factor 1 \
    --config retention.ms=60000 \
    --config segment.ms=60000
session: 1
```

Data deletes after 1 minute

## Topic Naming Best Practices

### ✅ Good Names

```
orders
user-events
payment-transactions
inventory-updates
logs-application-prod
```

### ❌ Avoid

```
test               # Too generic
tmp                # Unclear purpose
UPPERCASE          # Case-sensitive filesystem issues
my_topic_123       # Underscores and numbers
```

**Recommendations:**
- Use lowercase
- Separate words with hyphens (`-`)
- Descriptive names (avoid abbreviations)
- Include environment suffix (`-prod`, `-dev`)

## Common Errors

### Error: Replication Factor Too High

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic invalid-rf \
    --partitions 3 \
    --replication-factor 5 2>&1 || \
    echo "✗ Error: RF=5 but cluster has only 3 brokers"
session: 1
```

**Fix:** RF cannot exceed number of brokers

### Error: Topic Already Exists

Use `--if-not-exists` for idempotent scripts:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic orders \
    --partitions 6 \
    --replication-factor 3 \
    --if-not-exists
  
  echo "✓ Command succeeded (topic may have already existed)"
session: 1
```

## Check Kafka UI

Open **Kafka UI** (port 8080):
1. Click **Topics**
2. View all created topics
3. Click on `orders` to see partitions, replicas, and configuration

CLI changes are instantly visible in the UI!

## Summary

You now know how to:
- ✅ List and describe topics
- ✅ Create topics with proper configuration
- ✅ Modify partition count
- ✅ Delete topics
- ✅ Configure retention, compression, and durability
- ✅ Apply production best practices
- ✅ Handle common errors

## Next Steps

In the next level, we'll use **kafka-console-producer** to publish messages to these topics.
