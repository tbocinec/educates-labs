# Run Java Producer

In this step, we'll run the Java producer to send messages to our Kafka topic.

---

## Start the Producer

Run the producer application that will send 50 messages:

```terminal:execute
command: ./run-producer.sh
background: false
```

**What the producer does:**
- 📝 Sends **50 numbered messages** to `test-messages` topic
- ⏰ Adds **current timestamp** to each message
- 🔑 Uses **unique keys** (`msg-1`, `msg-2`, etc.)
- 📊 Shows **partition and offset** for each sent message
- ⚡ **1 second delay** between messages

---

## Monitor Producer Logs

Watch the producer output carefully. You should see:

```
✅ Sent message #1 to partition 0 at offset 0
✅ Sent message #2 to partition 1 at offset 0
✅ Sent message #3 to partition 2 at offset 0
...
```

**Key observations:**
- Messages are distributed across **3 partitions** (0, 1, 2)
- Each partition maintains its own **offset counter**
- **Kafka automatically** balances message distribution

---

## Check Topic Activity in CLI

While producer is running, open a new terminal and check topic activity:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic test-messages --from-beginning --timeout-ms 10000
background: false
```

This shows the raw messages as they arrive in Kafka.

---

## View Producer Metrics

After producer finishes, check producer metrics:

```terminal:execute
command: docker exec kafka kafka-run-class kafka.tools.JmxTool --jmx-url service:jmx:rmi:///jndi/rmi://localhost:9999/jmxrmi --object-name kafka.producer:type=producer-metrics,client-id=* --attributes record-send-rate | head -20
background: false
```

---

## Understanding Message Distribution

Check how messages were distributed across partitions:

```terminal:execute
command: |
  for i in 0 1 2; do
    echo "=== Partition $i ==="
    docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic test-messages --partition $i --from-beginning --timeout-ms 5000 | wc -l
  done
background: false
```

---

## Producer Configuration Highlights

The producer uses these important configurations:

```java
// Reliability settings
props.put(ProducerConfig.ACKS_CONFIG, "all");          // Wait for all replicas
props.put(ProducerConfig.RETRIES_CONFIG, 3);           // Retry failed sends

// Performance settings  
props.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);    // Batch messages
props.put(ProducerConfig.LINGER_MS_CONFIG, 1);         // Wait time for batching
```

---

## Common Producer Patterns

**Asynchronous Sending:**
```java
producer.send(record, (metadata, exception) -> {
    if (exception == null) {
        // Success handling
    } else {
        // Error handling
    }
});
```

**Key Benefits:**
- ✅ **Non-blocking** - doesn't wait for acknowledgment
- ✅ **High throughput** - can send many messages quickly
- ✅ **Error handling** - callbacks for success/failure

---

## Next Steps

With messages sent to Kafka, we can now:
1. **Run the Consumer** to read these messages
2. **View activity** in Kafka UI dashboard
3. **Explore message details** and partitioning

The producer has successfully sent data to Kafka! 📨