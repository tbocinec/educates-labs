# Manual Offset Management

Take full control of offset commits to achieve **at-least-once** delivery semantics and prevent message loss.

---

## 🎯 What You'll Learn

- Manual vs auto-commit trade-offs
- Synchronous and asynchronous commits
- At-least-once delivery guarantees
- Handling duplicates
- Commit strategies

---

## Why Manual Commit?

### Auto-Commit Problems

```java
// With auto-commit enabled
while (true) {
    ConsumerRecords<K, V> records = consumer.poll(Duration.ofMillis(1000));
    
    // Auto-commit happens here (in background)
    // Even if processing hasn't started!
    
    for (ConsumerRecord<K, V> record : records) {
        processRecord(record);  // ← Crash here = message lost!
    }
}
```

**Problem:** Offsets committed before processing completes.

### Manual Commit Solution

```java
// With manual commit
while (true) {
    ConsumerRecords<K, V> records = consumer.poll(Duration.ofMillis(1000));
    
    for (ConsumerRecord<K, V> record : records) {
        processRecord(record);  // Process first
    }
    
    consumer.commitSync();  // ← Commit AFTER processing
}
```

**Benefit:** Offsets committed only after successful processing.

---

## Delivery Semantics Comparison

### At-Most-Once (Auto-Commit)
```
1. Poll messages
2. Commit offsets  ← Auto-commit happens
3. Process messages
   ❌ Crash = Messages lost
```

### At-Least-Once (Manual Commit)
```
1. Poll messages
2. Process messages
3. Commit offsets  ← Manual commit after processing
   ✅ Crash = Messages reprocessed (duplicates possible)
```

### Exactly-Once
```
Requires transactional processing
(Kafka Streams or Transactions API)
```

---

## Examine Manual Commit Consumer

Look at our manual commit consumer code:

```editor:open
file: ~/kafka-apps/consumer-manual/src/main/java/com/example/HumidityConsumerManual.java
line: 50
```

**Key configuration:**
```java
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
```

---

## Run Manual Commit Consumer

Stop any running consumers first, then start the manual commit consumer:

```terminal:execute
command: ./run-consumer-manual.sh
background: false
```

**You should see:**
```
📖 Starting Manual Commit Humidity Consumer...
📊 Consumer Group: humidity-processor-group
✋ Using MANUAL COMMIT mode
🎯 Guarantees: AT-LEAST-ONCE delivery

📦 Batch #1 - Processing 5 messages...
🌡️  [1] kitchen: 67% (partition 0, offset 15)
🌡️  [2] bedroom: 54% (partition 1, offset 12)
...
✅ Committed offsets for 3 partitions
```

**Let it run for 30 seconds** to see batch processing with manual commits.

---

## Understanding Commit Timing

Notice the consumer commits **after each batch** is processed:

```java
// Process all messages
for (ConsumerRecord<K, V> record : records) {
    processRecord(record);  // May throw exception
}

// Commit only if ALL processing succeeded
consumer.commitSync();
```

**This ensures:**
- ✅ No commits if processing fails
- ✅ Messages reprocessed on restart if crashed
- ✅ At-least-once delivery guarantee

---

## Synchronous vs Asynchronous Commits

### commitSync() - Synchronous

```java
try {
    consumer.commitSync();
    // Blocks until commit succeeds or fails
} catch (CommitFailedException e) {
    // Handle commit failure
}
```

**Characteristics:**
- ✅ Blocks until acknowledged
- ✅ Throws exception on failure
- ✅ Guarantees commit before proceeding
- ⚠️ Higher latency

### commitAsync() - Asynchronous

```java
consumer.commitAsync((offsets, exception) -> {
    if (exception != null) {
        // Handle commit failure
        logger.error("Commit failed", exception);
    } else {
        // Commit succeeded
        logger.info("Committed offsets: {}", offsets);
    }
});
// Continues immediately, callback invoked later
```

**Characteristics:**
- ✅ Non-blocking, better throughput
- ✅ Callback for result notification
- ⚠️ May fail silently if no callback
- ⚠️ No automatic retries

---

## Per-Partition Offset Tracking

Our manual consumer tracks offsets per partition:

```editor:select-matching-text
file: ~/kafka-apps/consumer-manual/src/main/java/com/example/HumidityConsumerManual.java
text: "Map<TopicPartition, OffsetAndMetadata> offsets"
```

**Why?**
- Different partitions may have different offsets
- Allows fine-grained commit control
- Essential for parallel processing

---

## Commit Strategies

### Strategy 1: Commit After Each Batch (Current)

```java
ConsumerRecords<K, V> records = consumer.poll(timeout);
processAllRecords(records);
consumer.commitSync();  // Commit entire batch
```

**Pros:** Simple, good balance  
**Cons:** May reprocess entire batch on failure

### Strategy 2: Commit Per Record

```java
for (ConsumerRecord<K, V> record : records) {
    processRecord(record);
    Map<TopicPartition, OffsetAndMetadata> offset = Map.of(
        new TopicPartition(record.topic(), record.partition()),
        new OffsetAndMetadata(record.offset() + 1)
    );
    consumer.commitSync(offset);
}
```

**Pros:** Minimal reprocessing  
**Cons:** Slow, many commits

### Strategy 3: Commit Every N Records

```java
int count = 0;
for (ConsumerRecord<K, V> record : records) {
    processRecord(record);
    count++;
    if (count % 100 == 0) {
        consumer.commitSync();
    }
}
```

**Pros:** Balance between 1 and 2  
**Cons:** May reprocess up to N records

---

## Handling Commit Failures

What to do when commit fails:

```java
try {
    consumer.commitSync();
} catch (CommitFailedException e) {
    // Rebalance occurred
    logger.error("Commit failed due to rebalance", e);
    // Don't retry - partitions already reassigned
    
} catch (Exception e) {
    // Other error (network, etc.)
    logger.error("Commit failed", e);
    // Can retry or send to monitoring
}
```

**Important:** Don't retry `CommitFailedException` - partition already reassigned!

---

## Check Committed Offsets

View the committed offsets for the manual commit group:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-processor-group
background: false
```

**Compare with basic consumer group:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-monitor-group
background: false
```

Notice the different offset positions!

---

## Demonstrating Message Reprocessing

Let's prove at-least-once semantics. Stop the consumer (Ctrl+C), then check current offsets:

```terminal:interrupt
session: 1
```

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-processor-group
background: false
```

Note the `CURRENT-OFFSET` for each partition. Now restart the consumer:

```terminal:execute
command: ./run-consumer-manual.sh
background: false
```

The consumer will resume from the last **committed** offset, reprocessing any messages that were polled but not yet committed when it stopped.

---

## Dealing with Duplicates

Since at-least-once may produce duplicates, you need idempotent processing:

### Pattern 1: Idempotent Operations

```java
// Naturally idempotent
database.updateHumidity(sensorId, humidity);  // Last write wins
```

### Pattern 2: Deduplication with IDs

```java
String messageId = record.key() + ":" + record.offset();
if (!processedIds.contains(messageId)) {
    processRecord(record);
    processedIds.add(messageId);
}
```

### Pattern 3: Database Constraints

```sql
CREATE UNIQUE INDEX ON sensor_readings(sensor_id, timestamp);
-- Duplicate inserts will fail gracefully
```

---

## Offset Reset Behavior

If consumer starts with no committed offsets, `auto.offset.reset` determines behavior:

```java
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
// or "latest"
// or "none" (throws exception)
```

Test this by resetting offsets:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group humidity-processor-group --reset-offsets --to-earliest --topic humidity_readings --execute
background: false
```

Now restart consumer - it will reprocess all messages!

---

## Key Takeaways

✅ **Manual commit** prevents message loss  
✅ **At-least-once** semantics require idempotent processing  
✅ **commitSync()** is safe, commitAsync() is fast  
✅ **Commit after processing** ensures durability  
✅ **Track offsets per partition** for fine control  
✅ **Handle duplicates** at application level  

---

## Next Steps

You now understand offset management! Next, we'll explore **partition rebalancing** - what happens when consumers join or leave the group.

