# Understanding ConsumerRecords

Deep dive into the structure and metadata that Kafka provides with each consumed message.

---

## 🎯 What You'll Learn

- ConsumerRecord structure and all fields
- Metadata available for each message
- Headers and their use cases
- Timestamps and their types

---

## ConsumerRecord Structure

Every message consumed from Kafka is wrapped in a `ConsumerRecord` object:

```java
ConsumerRecord<K, V> {
    String topic();           // Topic name
    int partition();          // Partition number
    long offset();            // Offset in partition
    long timestamp();         // Message timestamp
    TimestampType timestampType();  // CREATE_TIME or LOG_APPEND_TIME
    K key();                  // Message key
    V value();                // Message value
    Headers headers();        // Custom headers
    int serializedKeySize();  // Key size in bytes
    int serializedValueSize(); // Value size in bytes
    Optional<Integer> leaderEpoch(); // Leader epoch
}
```

---

## Key Metadata Fields

### Topic and Partition

```java
String topic = record.topic();        // "humidity_readings"
int partition = record.partition();   // 0, 1, or 2
```

**Why it matters:**
- Know which partition processed this message
- Understand message ordering (only within partition)
- Debug partition assignment issues

### Offset

```java
long offset = record.offset();  // Position in partition
```

**Key points:**
- ✅ Monotonically increasing per partition
- ✅ Unique within partition
- ✅ Used for commit and seek operations
- ⚠️ NOT globally unique across partitions

### Timestamp

```java
long timestamp = record.timestamp();
TimestampType type = record.timestampType();
```

**Two types:**
- `CREATE_TIME` - When producer created the message (default)
- `LOG_APPEND_TIME` - When broker stored the message

---

## Inspect Message Metadata

Let's examine the metadata from our humidity readings. Run this command to see raw message details:

```terminal:execute
command: docker exec kafka kafka-run-class kafka.tools.DumpLogSegments --deep-iteration --print-data-log --files /tmp/kraft-combined-logs/humidity_readings-0/00000000000000000000.log | head -30
background: false
```

This shows the low-level log segment structure including offsets, timestamps, and message sizes.

---

## Message Headers

Headers are key-value metadata attached to messages:

```java
Headers headers = record.headers();
for (Header header : headers) {
    String key = header.key();
    byte[] value = header.value();
    System.out.printf("Header: %s = %s%n", key, new String(value));
}
```

**Common use cases:**
- 🔐 Authentication tokens
- 📋 Trace IDs for distributed tracing
- 🏷️ Message type/version information
- 🌍 Source system identification

---

## Key vs Value

**Message Key:**
```java
String key = record.key();  // "sensor-1"
```

**Purpose:**
- 🎯 Determines partition (messages with same key → same partition)
- 📊 Enables ordering per key
- 🗜️ Used in compaction (latest value per key)
- 🔍 Semantic identifier

**Message Value:**
```java
String value = record.value();  // JSON payload
```

**Purpose:**
- 📦 The actual data/payload
- 🔄 Business information
- 📝 Can be null (tombstone for deletion)

---

## Offset Semantics

Understanding offset behavior is critical:

### Offset Gaps

Offsets may have gaps due to:
- Log compaction
- Transactional messages (aborted transactions)
- Log retention

```
Valid offsets: 0, 1, 2, 5, 7, 8, 11  (gaps at 3-4, 6, 9-10)
```

### Offset Commit Position

When you commit offset `N`, you're saying:
- ✅ "I've processed up to and including offset N-1"
- 🔄 "Next poll should start at offset N"

---

## Exploring ConsumerRecords Collection

A `poll()` returns `ConsumerRecords<K, V>` - a collection of records:

```java
ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));

// Records per topic
records.count();  // Total count

// Records per partition
Set<TopicPartition> partitions = records.partitions();
for (TopicPartition partition : partitions) {
    List<ConsumerRecord<String, String>> partitionRecords = 
        records.records(partition);
    System.out.printf("Partition %d has %d records%n", 
        partition.partition(), partitionRecords.size());
}
```

---

## Practical Exercise: Analyze Message Distribution

Let's analyze how messages are distributed across partitions. First, consume some messages and save to a file:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic humidity_readings --from-beginning --max-messages 30 --property print.key=true --property print.partition=true --property print.offset=true --property print.timestamp=true > /tmp/messages.txt 2>&1; cat /tmp/messages.txt
background: false
```

**Observe:**
- Which sensors go to which partitions?
- Are offsets sequential within each partition?
- How are messages distributed?

---

## Message Key Partitioning

Our producer uses keys: `sensor-1`, `sensor-2`, `sensor-3`

Kafka's default partitioner uses: `hash(key) % num_partitions`

Verify partition assignment:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic humidity_readings --from-beginning --max-messages 20 --property print.key=true --property print.partition=true | awk '{print $1, $2}' | sort
background: false
```

You should see each sensor consistently goes to the same partition!

---

## Size Metadata

Check message sizes:

```java
int keySize = record.serializedKeySize();
int valueSize = record.serializedValueSize();
```

**Why it matters:**
- 📊 Monitor message size growth
- 💾 Calculate storage requirements
- ⚠️ Detect anomalies (unusually large messages)
- 🔧 Tune batch sizes and buffers

---

## Timestamp Patterns

Different timestamp uses:

### Event Time (default)
```java
// Producer sets timestamp when event occurred
ProducerRecord<String, String> record = 
    new ProducerRecord<>(topic, key, value);
// Uses current time
```

### Custom Event Time
```java
// Explicitly set event timestamp
long eventTime = parseEventTimestamp(data);
ProducerRecord<String, String> record = 
    new ProducerRecord<>(topic, partition, eventTime, key, value);
```

### Log Append Time
```java
// Broker overwrites with append time
// Configure topic: message.timestamp.type=LogAppendTime
```

---

## Checking Record Metadata in Code

Examine the `displayReading` method in our consumer:

```editor:open
file: ~/kafka-apps/consumer-basic/src/main/java/com/example/HumidityConsumerBasic.java
line: 85
```

Notice how we extract:
- Partition and offset
- Timestamp
- Key
- Value (parsed as JSON)

---

## Key Takeaways

✅ **ConsumerRecord** provides rich metadata beyond just the message  
✅ **Offsets** are per-partition, monotonic, but may have gaps  
✅ **Keys** determine partitioning and enable ordering  
✅ **Headers** carry additional metadata  
✅ **Timestamps** track event time or log append time  
✅ **ConsumerRecords** collection groups records by partition  

---

## Next Steps

Now that you understand the full structure of consumed messages, let's explore **manual offset management** for more control over delivery semantics.

