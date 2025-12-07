# Error Handling and Retry Logic

Build robust consumers that gracefully handle failures and implement smart retry strategies.

---

## 🎯 What You'll Learn

- Common consumer error scenarios
- Retry patterns and strategies  
- Dead Letter Queue (DLQ) pattern
- Circuit breaker implementation
- Poison pill handling

---

## Common Error Scenarios

### 1. Deserialization Failures

```java
// Message can't be parsed
ConsumerRecord<String, String> record = ...;
HumidityReading reading = objectMapper.readValue(record.value(), ...);
// ❌ JsonParseException - malformed JSON
```

### 2. Processing Failures

```java
// Business logic error
processHumidityReading(reading);
// ❌ DatabaseException - database unavailable
// ❌ ValidationException - invalid humidity value
```

### 3. Network Failures

```java
consumer.poll(timeout);
// ❌ TimeoutException - broker unreachable
// ❌ NetworkException - network partition
```

### 4. Commit Failures

```java
consumer.commitSync();
// ❌ CommitFailedException - rebalance occurred
// ❌ RetriableException - temporary broker issue
```

---

## Error Handling Strategies

### Strategy 1: Skip and Log

```java
try {
    processRecord(record);
} catch (Exception e) {
    logger.error("Failed to process record at partition {} offset {}", 
        record.partition(), record.offset(), e);
    // Continue with next message
}
```

**When to use:** Non-critical data, monitoring use cases  
**Pros:** Simple, doesn't block pipeline  
**Cons:** Data loss

### Strategy 2: Fail Fast

```java
try {
    processRecord(record);
} catch (FatalException e) {
    logger.error("Fatal error, shutting down", e);
    throw e;  // Stop consumer
}
```

**When to use:** Critical errors, corrupted state  
**Pros:** Prevents cascading failures  
**Cons:** Requires manual intervention

### Strategy 3: Retry with Backoff

```java
int maxRetries = 3;
for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
        processRecord(record);
        break;  // Success
    } catch (RetriableException e) {
        if (attempt == maxRetries - 1) {
            sendToDeadLetterQueue(record);
        } else {
            Thread.sleep((long) Math.pow(2, attempt) * 1000);  // Exponential backoff
        }
    }
}
```

**When to use:** Transient failures (network, temporary database issues)  
**Pros:** Handles temporary issues  
**Cons:** Increases latency

### Strategy 4: Dead Letter Queue (DLQ)

```java
try {
    processRecord(record);
} catch (Exception e) {
    logger.error("Processing failed, sending to DLQ", e);
    sendToDeadLetterQueue(record, e);
    // Continue processing other messages
}
```

**When to use:** Production systems  
**Pros:** No data loss, doesn't block pipeline  
**Cons:** Requires DLQ infrastructure

---

## Dead Letter Queue Pattern

### Setup DLQ Topic

Create a DLQ topic for failed humidity readings:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic humidity_readings_dlq --partitions 1 --replication-factor 1 --if-not-exists
background: false
```

### DLQ Implementation

```java
public class DeadLetterQueue {
    private final KafkaProducer<String, String> producer;
    private final String dlqTopic;
    private final ObjectMapper mapper = new ObjectMapper();
    
    public void send(ConsumerRecord<String, String> failedRecord, Exception error) {
        try {
            // Create DLQ message with metadata
            DLQMessage dlqMsg = new DLQMessage(
                failedRecord.topic(),
                failedRecord.partition(),
                failedRecord.offset(),
                failedRecord.key(),
                failedRecord.value(),
                error.getClass().getName(),
                error.getMessage(),
                Instant.now()
            );
            
            String json = mapper.writeValueAsString(dlqMsg);
            ProducerRecord<String, String> dlqRecord = 
                new ProducerRecord<>(dlqTopic, failedRecord.key(), json);
            
            // Add headers with error context
            dlqRecord.headers()
                .add("original.topic", failedRecord.topic().getBytes())
                .add("original.partition", String.valueOf(failedRecord.partition()).getBytes())
                .add("original.offset", String.valueOf(failedRecord.offset()).getBytes())
                .add("error.class", error.getClass().getName().getBytes())
                .add("error.timestamp", Instant.now().toString().getBytes());
            
            producer.send(dlqRecord).get();
            logger.info("Sent failed message to DLQ: partition {} offset {}", 
                failedRecord.partition(), failedRecord.offset());
                
        } catch (Exception e) {
            logger.error("Failed to send to DLQ!", e);
            // Last resort: log to file or alert system
        }
    }
    
    record DLQMessage(
        String originalTopic,
        int originalPartition,
        long originalOffset,
        String originalKey,
        String originalValue,
        String errorType,
        String errorMessage,
        Instant timestamp
    ) {}
}
```

---

## Retry Strategies

### Exponential Backoff

```java
public void processWithRetry(ConsumerRecord<K, V> record) {
    int maxRetries = 5;
    long baseDelay = 1000;  // 1 second
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
            processRecord(record);
            return;  // Success
            
        } catch (RetriableException e) {
            long delay = (long) (baseDelay * Math.pow(2, attempt));
            logger.warn("Retry attempt {} after {}ms: {}", 
                attempt + 1, delay, e.getMessage());
            
            if (attempt < maxRetries - 1) {
                Thread.sleep(delay);  // 1s, 2s, 4s, 8s, 16s
            } else {
                logger.error("Max retries reached, sending to DLQ");
                sendToDeadLetterQueue(record, e);
            }
        }
    }
}
```

### Fibonacci Backoff

```java
long fibonacciDelay(int attempt) {
    // 1s, 1s, 2s, 3s, 5s, 8s, 13s, 21s...
    if (attempt <= 1) return 1000;
    return fibonacciDelay(attempt - 1) + fibonacciDelay(attempt - 2);
}
```

### Jittered Backoff (Prevents Thundering Herd)

```java
long jitteredDelay(int attempt) {
    long baseDelay = (long) (1000 * Math.pow(2, attempt));
    Random random = new Random();
    long jitter = random.nextInt(1000);  // 0-1000ms jitter
    return baseDelay + jitter;
}
```

---

## Circuit Breaker Pattern

Prevent repeated calls to failing dependencies:

```java
public class CircuitBreaker {
    private enum State { CLOSED, OPEN, HALF_OPEN }
    
    private State state = State.CLOSED;
    private int failureCount = 0;
    private int failureThreshold = 5;
    private Instant openedAt;
    private Duration timeout = Duration.ofMinutes(1);
    
    public void execute(Runnable action) throws Exception {
        if (state == State.OPEN) {
            if (Instant.now().isAfter(openedAt.plus(timeout))) {
                state = State.HALF_OPEN;
                logger.info("Circuit breaker entering HALF_OPEN state");
            } else {
                throw new CircuitBreakerOpenException("Circuit breaker is OPEN");
            }
        }
        
        try {
            action.run();
            
            if (state == State.HALF_OPEN) {
                state = State.CLOSED;
                failureCount = 0;
                logger.info("Circuit breaker CLOSED after successful call");
            }
            
        } catch (Exception e) {
            failureCount++;
            
            if (failureCount >= failureThreshold) {
                state = State.OPEN;
                openedAt = Instant.now();
                logger.error("Circuit breaker OPEN after {} failures", failureCount);
            }
            
            throw e;
        }
    }
}

// Usage
CircuitBreaker databaseCircuit = new CircuitBreaker();

try {
    databaseCircuit.execute(() -> saveToDatabase(reading));
} catch (CircuitBreakerOpenException e) {
    // Database is down, send to DLQ immediately
    sendToDeadLetterQueue(record, e);
}
```

---

## Poison Pill Handling

A "poison pill" is a message that always fails processing:

### Detecting Poison Pills

```java
Map<String, Integer> retryCount = new ConcurrentHashMap<>();

for (ConsumerRecord<K, V> record : records) {
    String recordId = record.partition() + ":" + record.offset();
    int attempts = retryCount.getOrDefault(recordId, 0);
    
    if (attempts >= MAX_ATTEMPTS) {
        logger.error("Poison pill detected: {}", recordId);
        sendToDeadLetterQueue(record, 
            new PoisonPillException("Max retry attempts reached"));
        retryCount.remove(recordId);
        continue;  // Skip this message
    }
    
    try {
        processRecord(record);
        retryCount.remove(recordId);  // Success
    } catch (Exception e) {
        retryCount.put(recordId, attempts + 1);
        // Don't commit this offset - will retry
    }
}
```

### Skipping Poison Pills

```java
// Last resort: skip the message
consumer.seek(
    new TopicPartition(record.topic(), record.partition()),
    record.offset() + 1  // Move past poison pill
);
```

---

## Deserialization Error Handling

Custom deserializer with error handling:

```java
public class SafeJsonDeserializer<T> implements Deserializer<T> {
    private final ObjectMapper mapper = new ObjectMapper();
    private final Class<T> targetType;
    
    @Override
    public T deserialize(String topic, byte[] data) {
        try {
            return mapper.readValue(data, targetType);
        } catch (Exception e) {
            logger.error("Deserialization failed for topic {}", topic, e);
            
            // Option 1: Return null and handle in consumer
            return null;
            
            // Option 2: Return default/placeholder object
            // return createDefaultInstance();
            
            // Option 3: Throw and let error handler deal with it
            // throw new SerializationException(e);
        }
    }
}

// In consumer
ConsumerRecord<String, HumidityReading> record = ...;
if (record.value() == null) {
    logger.warn("Skipping malformed message at partition {} offset {}",
        record.partition(), record.offset());
    continue;
}
```

---

## Practical Example: Robust Processing

Let's build a robust processor:

```terminal:execute
command: cat > /tmp/robust-processor.java << 'EOF'
public class RobustHumidityProcessor {
    private final DeadLetterQueue dlq;
    private final CircuitBreaker databaseCircuit;
    private final MetricsRecorder metrics;
    
    public void process(ConsumerRecord<String, String> record) {
        String recordId = record.partition() + ":" + record.offset();
        
        try {
            // 1. Deserialize with validation
            HumidityReading reading = parseAndValidate(record.value());
            
            // 2. Business logic with circuit breaker
            databaseCircuit.execute(() -> saveToDatabase(reading));
            
            // 3. Success metrics
            metrics.recordSuccess(record.topic());
            
        } catch (ValidationException e) {
            // Bad data - don't retry
            logger.error("Validation failed for {}: {}", recordId, e.getMessage());
            dlq.send(record, e);
            metrics.recordValidationError(record.topic());
            
        } catch (CircuitBreakerOpenException e) {
            // Database down - send to DLQ
            logger.error("Circuit breaker open, sending to DLQ: {}", recordId);
            dlq.send(record, e);
            metrics.recordCircuitBreakerError(record.topic());
            
        } catch (RetriableException e) {
            // Transient error - let caller retry
            logger.warn("Retriable error for {}: {}", recordId, e.getMessage());
            metrics.recordRetriableError(record.topic());
            throw e;
            
        } catch (Exception e) {
            // Unknown error - send to DLQ
            logger.error("Unexpected error for {}", recordId, e);
            dlq.send(record, e);
            metrics.recordUnknownError(record.topic());
        }
    }
}
EOF
cat /tmp/robust-processor.java
background: false
```

---

## Monitoring and Alerting

Track error metrics:

```java
// Error rate
errorRate = errors / totalMessages

// DLQ size
dlqLag = currentDLQSize

// Retry attempts
avgRetries = totalRetries / processedMessages

// Circuit breaker state
circuitBreakerOpen = (state == State.OPEN)
```

Set up alerts:
- Error rate > 5%
- DLQ growing faster than consumption
- Circuit breaker open for > 5 minutes

---

## Check DLQ Messages

View messages in the DLQ:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic humidity_readings_dlq --from-beginning --max-messages 10 --property print.key=true --property print.headers=true
background: false
```

---

## Key Takeaways

✅ **Always handle deserialization errors**  
✅ **Use DLQ for failed messages** - don't lose data  
✅ **Implement retry with backoff** for transient errors  
✅ **Circuit breakers** prevent cascading failures  
✅ **Detect and skip poison pills** to unblock pipeline  
✅ **Monitor error rates** and alert on anomalies  
✅ **Log with context** (partition, offset, error type)  

---

## Next Steps

You now have robust error handling! Next, let's explore **Kafka UI** for visual monitoring and troubleshooting.

