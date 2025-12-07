# Manual Offset Control

Learn to control offset commits for AT-LEAST-ONCE delivery semantics.

---

## 🎯 Learning Goals (15 minutes)

✅ Understand manual commit vs auto-commit  
✅ Implement at-least-once processing  
✅ Handle message reprocessing  
✅ Learn production-ready patterns  

---

## Why Manual Commit?

### Auto-Commit Problem

```
1. Poll messages
2. Auto-commit saves offsets ← Happens before processing!
3. Process messages
4. ❌ Crash here = Messages LOST
```

**Result:** AT-MOST-ONCE (may lose data)

### Manual Commit Solution

```
1. Poll messages
2. Process messages
3. Commit offsets ← Only after successful processing
4. ✅ Crash before commit = Messages REPROCESSED
```

**Result:** AT-LEAST-ONCE (no data loss, possible duplicates)

---

## Switch to Manual Commit Mode

Edit the consumer code to enable manual commit:

```editor:open
file: ~/kafka-apps/consumer/src/main/java/com/example/HumidityConsumer.java
line: 22
```

Change this line:
```java
private static final boolean USE_MANUAL_COMMIT = false;
```

To:
```java
private static final boolean USE_MANUAL_COMMIT = true;
```

Save the file (Ctrl+S or Cmd+S).

---

## Rebuild Consumer

Rebuild with manual commit enabled:

```terminal:execute
command: cd kafka-apps/consumer && mvn clean package -q && cd ../..
background: false
```

---

## Run Manual Commit Consumer

Now run the consumer in manual commit mode:

```terminal:execute
command: ./run-consumer.sh
background: false
```

**You'll see:**
```
📖 Starting Kafka Consumer...
📊 Consumer Group: humidity-monitor
🔄 Commit Mode: MANUAL
⚙️  Config: Manual commit enabled (at-least-once)

🌡️  [1] bedroom: 54%
    Key: sensor-2 | Partition: 1 | Offset: 12
    --------------------------------------------------
🌡️  [2] kitchen: 68%
    Key: sensor-1 | Partition: 0 | Offset: 15
    --------------------------------------------------
✅ Committed 2 messages
```

**Notice:** "Committed X messages" appears AFTER processing!

**Let it run for 30 seconds.**

---

## Manual Commit Code

The key difference in the code:

```java
// Process all messages first
for (var record : records) {
    processMessage(record);
    trackOffset(record);  // Remember offset
}

// Commit ONLY after all processing succeeds
try {
    consumer.commitSync(offsets);  // ← Manual commit
    System.out.println("✅ Committed");
} catch (Exception e) {
    // Commit failed - messages will be reprocessed
}
```

**Critical:** Commit only after successful processing!

---

## Test Message Reprocessing

Let's prove at-least-once semantics.

1. **Stop the consumer** (Ctrl+C)

2. **Check current offsets:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-monitor
background: false
```

Note the `CURRENT-OFFSET` for each partition.

3. **Restart the consumer:**

```terminal:execute
command: ./run-consumer.sh
background: false
```

**Observation:** Consumer resumes from last COMMITTED offset.

Any messages polled but NOT committed before stopping were reprocessed!

---

## Commit Timing Matters

### Commit After Batch (Our Implementation)

```java
for (record : batch) {
    process(record);
}
consumer.commitSync();  // Commit all after batch
```

**Pros:** Good balance  
**Cons:** May reprocess entire batch on failure

### Commit Per Message (Slowest)

```java
for (record : batch) {
    process(record);
    consumer.commitSync();  // Commit each one
}
```

**Pros:** Minimal reprocessing  
**Cons:** Very slow (many commits)

### Commit Every N Messages

```java
if (count % 100 == 0) {
    consumer.commitSync();
}
```

**Pros:** Balance between above  
**Cons:** May reprocess up to N messages

---

## Delivery Semantics Comparison

| Semantic | Commits | Message Loss? | Duplicates? | Use Case |
|----------|---------|---------------|-------------|----------|
| **At-most-once** | Before processing | Yes ❌ | No | Metrics, logs |
| **At-least-once** | After processing | No ✅ | Yes | Most use cases |
| **Exactly-once** | Transactional | No ✅ | No | Financial, critical |

**Production recommendation:** Use at-least-once (manual commit)

---

## Handling Duplicates

Since at-least-once may produce duplicates:

### Option 1: Idempotent Operations

```java
// Naturally idempotent - safe to repeat
database.update("sensor_id = ?", humidity);  // Last write wins
```

### Option 2: Deduplication

```java
String messageId = record.partition() + ":" + record.offset();
if (!processed.contains(messageId)) {
    process(record);
    processed.add(messageId);
}
```

### Option 3: Database Constraints

```sql
CREATE UNIQUE INDEX ON readings(sensor_id, timestamp);
-- Duplicate inserts fail gracefully
```

---

## Offset Reset Behavior

What if consumer starts with NO committed offsets?

Controlled by `auto.offset.reset`:

```java
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
```

**Values:**
- `earliest` - Read from beginning (oldest message)
- `latest` - Read only new messages
- `none` - Throw exception

Our consumer uses `earliest` to process all messages.

---

## Reset Offsets Manually

Reset offsets to reprocess all messages:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group humidity-monitor --reset-offsets --to-earliest --topic humidity_readings --execute
background: false
```

Now restart consumer - it reprocesses everything from beginning!

```terminal:execute
command: ./run-consumer.sh
background: false
```

---

## Monitor in Kafka UI

Check offset management in Kafka UI:

1. Open http://localhost:8080
2. **Consumer Groups** → **humidity-monitor**
3. **Offsets** tab

You'll see:
- Current offset (last committed)
- Log end offset (latest message)
- Lag
- Last commit timestamp

---

## Key Takeaways

**Manual Commit:**
✅ Prevents message loss  
✅ Commits only after successful processing  
✅ Required for at-least-once semantics  
✅ Production-ready pattern  

**Trade-offs:**
- More code complexity
- Need to handle duplicates
- Must call commit explicitly

**Best Practice:**
```java
// Process batch
for (record : records) {
    process(record);
}

// Commit only if all succeeded
consumer.commitSync();
```

---

## Time Check ✅

**Completed:**
- ✅ Enabled manual commit
- ✅ Understood at-least-once semantics
- ✅ Tested message reprocessing
- ✅ Learned commit strategies

**Time used:** ~15 minutes  
**Next:** Workshop wrap-up! →

