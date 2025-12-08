# (EXTRA) Error Handling & Flushing

Learn production-ready error handling and when to flush.

---

## 🎯 Learning Goals (7 minutes)

✅ Understand common producer errors  
✅ Learn proper error handling patterns  
✅ Know when to flush (and when NOT to)  
✅ Configure idempotence for reliability  

---

## Common Producer Errors

**1. Serialization Failures**
```
org.apache.kafka.common.errors.SerializationException
```
- Invalid data format
- Encoding issues
- Happens **before** network send

**2. Message Too Large**
```
org.apache.kafka.common.errors.RecordTooLargeException
```
- Exceeds `max.request.size` (1MB default)
- Exceeds broker's `message.max.bytes`

**3. Timeout Errors**
```
org.apache.kafka.common.errors.TimeoutException
```
- Broker unreachable
- Network issues
- Slow acknowledgments

**4. Not Enough Replicas**
```
org.apache.kafka.common.errors.NotEnoughReplicasException
```
- With `acks=all`, not enough replicas available

---

## Error Types: Retriable vs Non-Retriable

**Retriable Errors** (Kafka retries automatically):
- `TimeoutException`
- `NotEnoughReplicasException`
- Network disconnects

**Non-Retriable Errors** (Fail immediately):
- `SerializationException`
- `RecordTooLargeException`
- `InvalidTopicException`

**Producer config:**
```java
props.put(ProducerConfig.RETRIES_CONFIG, 3);
props.put(ProducerConfig.RETRY_BACKOFF_MS_CONFIG, 100);
```

---

## Error Handling via Callbacks

**Basic error handling:**

```java
producer.send(record, (metadata, exception) -> {
    if (exception != null) {
        // Check exception type
        if (exception instanceof SerializationException) {
            logger.error("Invalid data format: {}", record.value());
            // Log to dead letter queue
            sendToDeadLetterQueue(record, exception);
        } else if (exception instanceof TimeoutException) {
            logger.warn("Timeout - already retrying: {}", exception.getMessage());
            // Kafka will retry automatically
        } else {
            logger.error("Unexpected error: ", exception);
            // Alert operations team
            alerting.sendAlert("Producer error", exception);
        }
    }
});
```

---

## Idempotent Producer

**The Problem:**

```
1. Producer sends message
2. Broker receives and writes it
3. Network failure before ack reaches producer
4. Producer retries (thinks it failed)
5. ❌ DUPLICATE MESSAGE in Kafka!
```

**The Solution:** Idempotence

```java
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
```

**What it does:**
- Kafka assigns sequence number to each message
- Broker detects and ignores duplicates
- Guarantees exactly-once producer semantics

---

## Idempotence Configuration

When you enable idempotence, Kafka automatically sets:

```java
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);

// Automatically implies:
// acks=all (strongest durability)
// retries=Integer.MAX_VALUE (retry until success)
// max.in.flight.requests.per.connection=5 (maintains order)
```

**Result:** At-least-once delivery WITHOUT duplicates!

---

## Production Error Handling Pattern

**Complete error handling:**

```java
producer.send(record, (metadata, exception) -> {
    if (exception != null) {
        handleError(record, exception);
    } else {
        handleSuccess(metadata);
    }
});

void handleError(ProducerRecord record, Exception e) {
    // 1. Log with context
    logger.error("Failed to send: key={}, topic={}", 
                record.key(), record.topic(), e);
    
    // 2. Update metrics
    metrics.increment("producer.errors", 
                     "error_type", e.getClass().getSimpleName());
    
    // 3. Send to DLQ for non-retriable errors
    if (!(e instanceof RetriableException)) {
        deadLetterQueue.send(record, e);
    }
    
    // 4. Alert if critical
    if (errorRate.exceedsThreshold()) {
        alerting.critical("High producer error rate");
    }
}

void handleSuccess(RecordMetadata m) {
    metrics.increment("producer.success");
    logger.debug("Sent to p{} offset {}", m.partition(), m.offset());
}
```

---

## Flushing - When and Why

**What is flush?**

```java
producer.flush();
```

Forces all buffered messages to be sent immediately and waits for acknowledgment.

**Internal behavior:**
```
1. Sends all buffered records
2. Waits for all acks
3. Blocks until complete
```

---

## When to Flush

**✅ DO flush:**

**1. Application Shutdown**
```java
Runtime.getRuntime().addShutdownHook(new Thread(() -> {
    producer.flush();  // Ensure all messages sent
    producer.close();
}));
```

**2. Transactional Boundaries (Rare)**
```java
processOrder(order);
producer.send(orderEvent);
producer.flush();  // Ensure written before commit
database.commit();
```

**3. Small Scripts/Tools**
```java
for (String line : file.readLines()) {
    producer.send(new ProducerRecord<>(topic, line));
}
producer.flush();  // Send all before exit
```

---

## When NOT to Flush

**❌ DO NOT flush:**

**1. After Every Message**
```java
// ❌ TERRIBLE - Destroys batching!
for (Event event : events) {
    producer.send(record);
    producer.flush();  // ← NO! Kills performance
}
```

**2. Inside Loops**
```java
// ❌ BAD
while (true) {
    producer.send(record);
    producer.flush();  // ← NO!
}
```

**3. In Hot Paths**
```java
// ❌ BAD - High-throughput API
@PostMapping("/events")
public void handleEvent(Event event) {
    producer.send(toRecord(event));
    producer.flush();  // ← NO! Use callback instead
}
```

---

## Flush vs Close

**flush():**
- Sends buffered messages
- Waits for acks
- Producer still usable after

**close():**
- Calls flush() internally
- Releases resources
- Producer unusable after

**Best practice:**
```java
try (KafkaProducer<String, String> producer = createProducer()) {
    // Use producer...
}  // ← close() called automatically (includes flush)
```

---

## Proper Shutdown Pattern

**Complete shutdown handling:**

```java
public class HumidityService {
    private final KafkaProducer<String, String> producer;
    
    public HumidityService() {
        this.producer = createProducer();
        
        // Register shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            logger.info("Shutting down producer...");
            
            try {
                // Flush pending messages
                producer.flush();
                logger.info("All messages flushed");
                
                // Close producer
                producer.close(Duration.ofSeconds(10));
                logger.info("Producer closed");
            } catch (Exception e) {
                logger.error("Error during shutdown", e);
            }
        }));
    }
}
```

---

## Performance Impact of Flushing

**Without flush (normal):**
```
Batch 1: [100 messages] → sent together
Batch 2: [100 messages] → sent together
Throughput: 10,000 msg/sec
```

**With flush after each message:**
```
Message 1 → flush → wait
Message 2 → flush → wait
Message 3 → flush → wait
Throughput: 100 msg/sec ❌
```

**Flush destroys batching = 100x slower!**

---

## Summary: Error Handling & Flushing

**Error Handling Best Practices:**
1. Always use callbacks for error visibility
2. Enable idempotence (`enable.idempotence=true`)
3. Log errors with context
4. Send non-retriable errors to DLQ
5. Monitor error rates

**Flushing Rules:**
1. **Only flush on shutdown** (or rare transactional boundaries)
2. **Never flush in loops** or after every message
3. **Never flush in hot paths** (high-throughput code)
4. Use `close()` for shutdown (includes flush)

**Production Config:**
```java
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
props.put(ProducerConfig.ACKS_CONFIG, "all");
props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
```

---

## Time Check

**Time used:** ~7 minutes  
**Next:** Final wrap-up and best practices! →

