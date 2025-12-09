# Wrap-Up and Best Practices

Congratulations! You've mastered Kafka producer essentials in 45 minutes!

---

## 🎓 What You Learned

### Core Concepts ✅

**ProducerRecord:**
- Topic + Value (required)
- Key (determines partition and ordering)
- Headers (metadata for tracing, versioning)

**Keys & Partitioning:**
- Same key → Same partition → Ordering guaranteed
- No key → Sticky partitioner (high throughput)
- `hash(key) % partitions` determines partition

**Send Modes:**
- Async fire-and-forget (fast, no errors)
- Async with callback (production standard)
- Sync (blocking, rare use)

**Error Handling:**
- Callbacks for error visibility
- Idempotence prevents duplicates
- Flush only on shutdown

---

## 📋 Production Checklist

### Essential Configuration

```java
Properties props = new Properties();

// 1. Connection
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, 
    "kafka1:9092,kafka2:9092,kafka3:9092");
props.put(ProducerConfig.CLIENT_ID_CONFIG, "humidity-service");

// 2. Serialization
props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, 
    StringSerializer.class.getName());
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, 
    StringSerializer.class.getName());

// 3. Reliability - Idempotence (CRITICAL!)
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
// Automatically sets: acks=all, retries=MAX, max.in.flight=5

// 4. Performance
props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");
props.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);
props.put(ProducerConfig.LINGER_MS_CONFIG, 10);
props.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 33554432);
```

---

## ✅ Best Practices

### 1. Always Use Callbacks

```java
// ✅ GOOD - Production pattern
producer.send(record, (metadata, exception) -> {
    if (exception != null) {
        logger.error("Send failed: key={}", record.key(), exception);
        metrics.increment("producer.errors");
    } else {
        logger.debug("Sent to p{} offset {}", 
                    metadata.partition(), metadata.offset());
        metrics.increment("producer.success");
    }
});
```

### 2. Enable Idempotence

```java
// ✅ ALWAYS enable for production
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
```

**Benefits:**
- No duplicates on retry
- Maintains ordering
- Exactly-once producer semantics

### 3. Use Keys for Ordering

```java
// ✅ GOOD - Same sensor always in order
String key = "sensor-" + sensorId;
ProducerRecord<String, String> record = 
    new ProducerRecord<>(topic, key, reading);
```

### 4. Implement Graceful Shutdown

```java
// ✅ GOOD - Ensures all messages sent
Runtime.getRuntime().addShutdownHook(new Thread(() -> {
    logger.info("Flushing producer...");
    producer.flush();
    producer.close(Duration.ofSeconds(10));
}));
```

### 5. Use Compression

```java
// ✅ GOOD - Reduces network and storage
props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");
// Options: none, gzip, snappy, lz4, zstd
```

**Recommendation:** Use `snappy` (good balance of speed/compression)

---

## ⚠️ Common Pitfalls

### ❌ Don't: Flush After Every Message

```java
// ❌ BAD - Destroys batching, kills performance
for (Event event : events) {
    producer.send(toRecord(event));
    producer.flush();  // ← NO!
}
```

### ❌ Don't: Use Fire-and-Forget for Critical Data

```java
// ❌ BAD - Silent failures
producer.send(record);  // What if this fails?
```

**Use callbacks instead!**

### ❌ Don't: Use Sync in Hot Paths

```java
// ❌ BAD - 50x slower than async
@PostMapping("/events")
public void handleEvent(Event event) {
    producer.send(toRecord(event)).get();  // ← Blocks!
}
```

### ❌ Don't: Create Producer Per Message

```java
// ❌ TERRIBLE - Creates connection overhead
for (Message msg : messages) {
    KafkaProducer producer = new KafkaProducer(props);  // ← NO!
    producer.send(toRecord(msg));
    producer.close();
}
```

**Producers are thread-safe - create once, reuse!**

### ❌ Don't: Send Without Keys If You Need Order

```java
// ❌ BAD - No ordering guarantee
for (SensorReading reading : sensorReadings) {
    producer.send(new ProducerRecord<>(topic, null, toJson(reading)));
    // ← Messages can arrive out of order!
}
```

---

## 🚀 Performance Tuning

### For Throughput

```java
// Maximize batching
props.put(ProducerConfig.BATCH_SIZE_CONFIG, 32768);
props.put(ProducerConfig.LINGER_MS_CONFIG, 20);
props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "lz4");
props.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 67108864); // 64MB

// Don't use keys if order doesn't matter
producer.send(new ProducerRecord<>(topic, value));  // No key = sticky partitioning
```

### For Latency

```java
// Send immediately
props.put(ProducerConfig.LINGER_MS_CONFIG, 0);
props.put(ProducerConfig.BATCH_SIZE_CONFIG, 1);
props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "none");

// But still enable idempotence!
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
```

### For Reliability

```java
// Maximum durability
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
props.put(ProducerConfig.ACKS_CONFIG, "all");
props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
props.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 30000);
```

---

## 📊 Monitoring

### Key Metrics to Track

**Success Rate:**
```java
metrics.increment("producer.success");
metrics.increment("producer.errors");
// Alert if error_rate > 1%
```

**Latency:**
```java
// Monitor p50, p95, p99 latency
long latency = System.currentTimeMillis() - startTime;
metrics.recordLatency("producer.send.latency", latency);
```

**Throughput:**
```java
metrics.increment("producer.messages.sent");
// Messages per second
```

**Buffer Usage:**
```java
// Monitor producer metrics
Map<MetricName, ? extends Metric> metrics = producer.metrics();
// Check: buffer-available-bytes, buffer-total-bytes
```

---

## 🔍 Debugging Tips

### View Messages in Kafka UI

Switch to the Kafka UI dashboard:

```dashboard:open-dashboard
name: Kafka UI
```

Then navigate:
1. **Topics** → **humidity_readings**
2. Click **Messages**
3. Inspect keys, partitions, offsets

### Console Consumer Verification

```bash
# View messages with keys and partitions
docker exec kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic humidity_readings \
    --from-beginning \
    --property print.key=true \
    --property print.partition=true \
    --max-messages 10
```

### Check Producer Logs

Enable debug logging:
```java
props.put(ProducerConfig.INTERCEPTOR_CLASSES_CONFIG, 
    "org.apache.kafka.clients.producer.ProducerInterceptor");
```

Or use SLF4J:
```xml
<logger name="org.apache.kafka.clients.producer" level="DEBUG"/>
```

---

## 🎯 Quick Reference Card

| Concept | Key Takeaway |
|---------|-------------|
| **ProducerRecord** | topic + key + value + headers |
| **Keys** | Same key → same partition → ordering |
| **No Key** | Sticky partitioner → high throughput |
| **Send Mode** | Use async with callback (production) |
| **Idempotence** | Always enable (no duplicates) |
| **Flush** | Only on shutdown, never in loops |
| **Errors** | Handle in callbacks, log + metric |
| **Performance** | Batch + compress + don't flush |

---

## 📚 Next Steps

**Continue Learning:**
1. **Kafka Consumers Essentials** - Complete the cycle
2. **Kafka Streams** - Real-time processing
3. **Schema Registry** - Avro/Protobuf serialization
4. **Kafka Connect** - Integration with external systems

**Deep Dive Topics:**
- Transactional producers
- Custom partitioners
- Schema evolution
- Multi-datacenter replication

**Resources:**
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [Confluent Blog](https://www.confluent.io/blog/)
- [Kafka: The Definitive Guide](https://www.confluent.io/resources/kafka-the-definitive-guide/)

---

## 🎉 Congratulations!

You now understand:

✅ How ProducerRecord works  
✅ Keys, partitioning, and ordering  
✅ Async vs sync send modes  
✅ Production-ready error handling  
✅ When to flush (and when not to!)  

**You're ready to build production Kafka producers!**

---

## Clean Up

Stop the workshop environment:

```terminal:execute
command: cd /home/eduk8s && docker compose down
background: false
```

---

## 💬 Feedback

How was this workshop? Let us know!

**Thank you for participating!** 🙌

