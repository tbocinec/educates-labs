# Async vs Sync Send

Master producer send modes and understand when to use each.

---

## 🎯 Learning Goals (10 minutes)

✅ Understand async send (default and preferred)  
✅ Learn callback pattern for error handling  
✅ Know when sync send is appropriate  
✅ Compare performance characteristics  

---

## Three Send Patterns

**1. Async Fire-and-Forget**
```java
producer.send(record);
```
- Fastest
- No confirmation
- Errors invisible

**2. Async with Callback**
```java
producer.send(record, (metadata, exception) -> {
    // Handle result
});
```
- Fast (non-blocking)
- Error handling
- **Production standard**

**3. Synchronous**
```java
RecordMetadata metadata = producer.send(record).get();
```
- Blocking
- Guaranteed confirmation
- Slow (avoid in production loops)

---

## Async Send - Fire and Forget

We already saw this in the basic producer:

```java
producer.send(new ProducerRecord<>(topic, key, value));
// Continues immediately - no waiting!
```

**Characteristics:**
- Returns `Future<RecordMetadata>`
- You don't wait for Future
- Fire-and-forget
- Maximum throughput

**Problem:** Silent failures!

```java
producer.send(record); // ← What if this fails?
// You'll never know! ❌
```

---

## Async with Callback - Production Pattern

Callbacks give you async performance **AND** error handling:

```java
producer.send(record, new Callback() {
    public void onCompletion(RecordMetadata m, Exception e) {
        if (e != null) {
            // ❌ Handle error
            logger.error("Send failed for key: {}", record.key(), e);
        } else {
            // ✅ Success
            logger.info("Sent to partition {} offset {}", 
                       m.partition(), m.offset());
        }
    }
});
```

---

## Run Producer with Callbacks

Let's see callbacks in action:

```terminal:execute
command: ./run-producer-callback.sh
background: false
session: 1
```

**Let it run for 20 seconds.**

---

## Observe Callback Output

You should see detailed output:

```
🌡️  Starting Humidity Producer (CALLBACK MODE)...
📊 Mode: Async with callbacks

✅ SUCCESS: sensor-1 | kitchen | 68%
   → Partition: 0 | Offset: 42 | Timestamp: 1733584800

✅ SUCCESS: sensor-3 | outside | 42%
   → Partition: 2 | Offset: 23 | Timestamp: 1733584803
```

**Notice:**
- Confirmation for each message
- Metadata: partition, offset, timestamp
- Still async (non-blocking)

Press Ctrl+C to stop.

---

## Callback Use Cases

**What to do in callbacks:**

✅ **Log errors**
```java
logger.error("Failed to send message", exception);
```

✅ **Send to dead letter queue**
```java
if (exception != null) {
    dlqProducer.send(failedRecord);
}
```

✅ **Update metrics**
```java
if (exception != null) {
    metrics.incrementFailedMessages();
} else {
    metrics.incrementSuccessfulMessages();
}
```

✅ **Store metadata**
```java
database.saveOffset(metadata.partition(), metadata.offset());
```

---

## What NOT to Do in Callbacks

**❌ Don't do heavy processing:**
```java
// BAD - Blocks I/O thread!
producer.send(record, (m, e) -> {
    // Don't make database calls
    database.updateStatus(...);
    // Don't make HTTP calls
    httpClient.notify(...);
});
```

**Callbacks run on Kafka I/O thread!**

Keep them fast:
- Simple logging
- Lightweight metric updates
- Queue for async processing

---

## Synchronous Send

Blocking until confirmation:

```java
try {
    RecordMetadata metadata = producer.send(record).get(); // ← BLOCKS!
    System.out.println("Sent to partition: " + metadata.partition());
} catch (Exception e) {
    System.err.println("Send failed: " + e.getMessage());
}
```

**Waits for:**
1. Message sent to broker
2. Broker writes to disk
3. Replicas acknowledge (if `acks=all`)
4. Confirmation returned

---

## Run Synchronous Producer

See the performance difference:

```terminal:execute
command: ./run-producer-sync.sh
background: false
session: 1
```

**Let it run for 20 seconds.**

---

## Compare Performance

**Async (callback):** ~1000 messages/second
```
✅ SUCCESS: sensor-1 | 68% (partition 0, offset 100)
✅ SUCCESS: sensor-2 | 54% (partition 1, offset 85)
✅ SUCCESS: sensor-3 | 42% (partition 2, offset 92)
[Messages stream rapidly]
```

**Sync:** ~100 messages/second
```
⏳ SYNC: sensor-1 | 68% → partition 0, offset 1
⏳ SYNC: sensor-2 | 54% → partition 1, offset 1
[Much slower - visible delay between messages]
```

Press Ctrl+C to stop.

---

## When to Use Sync Send

**✅ Use sync send for:**
- Application initialization/shutdown
- Low-frequency messages (< 1/sec)
- Interactive CLI tools
- Test/demo code

**❌ Avoid sync send for:**
- High-throughput applications
- Real-time data pipelines
- Event streaming
- Microservices (use async+callback)

---

## Performance Comparison

**Throughput Test Results:**

| Mode | Messages/Sec | Latency (p99) |
|------|--------------|---------------|
| Async Fire-and-Forget | 50,000 | 5ms |
| Async with Callback | 45,000 | 8ms |
| Synchronous | 1,000 | 50ms |

**Sync send is 50x slower!**

---

## The Future Object

Both async and sync use `Future<RecordMetadata>`:

```java
// Async - ignore Future
Future<RecordMetadata> future = producer.send(record);
// Continue immediately

// Sync - wait for Future
Future<RecordMetadata> future = producer.send(record);
RecordMetadata metadata = future.get(); // ← BLOCKS
```

**You can also:**
```java
Future<RecordMetadata> future = producer.send(record);
// Do other work...
metadata = future.get(100, TimeUnit.MILLISECONDS); // Timeout
```

---

## Summary: Send Modes

**Async Fire-and-Forget**
- Fastest ⚡
- No error handling ❌
- Use: When data loss OK (rare!)

**Async with Callback**
- Fast ⚡
- Error handling ✅
- **Use: Production default** ⭐

**Synchronous**
- Slow 🐌
- Guaranteed confirmation ✅
- Use: Init/shutdown, low-frequency

---

## Best Practice Pattern

**Production-ready producer:**

```java
producer.send(record, (metadata, exception) -> {
    if (exception != null) {
        // Log and alert
        logger.error("Send failed: {}", exception.getMessage());
        metrics.incrementFailures();
    } else {
        // Log success (debug level)
        logger.debug("Sent to p{} offset {}", 
                    metadata.partition(), metadata.offset());
        metrics.incrementSuccess();
    }
});
```

**Key points:**
- Non-blocking (async)
- Error visibility
- Metrics/monitoring
- Simple callback logic

---

## Time Check

**Time used:** ~10 minutes  
**Next:** Error handling and flushing! →

