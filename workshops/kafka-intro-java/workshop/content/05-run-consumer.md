# Run Java Consumer

In this step, we'll run the Java consumer to read messages from our Kafka topic.

---

## Start the Consumer

Run the consumer application to read messages:

```terminal:execute
command: ./run-consumer.sh
background: false
```

**What the consumer does:**
- 📖 **Subscribes** to `test-messages` topic
- 👥 Joins **consumer group** `test-consumer-group`
- 🔄 **Continuously polls** for new messages
- 📺 **Displays** each message with details
- ⏰ Shows **timestamps, partitions, and offsets**

---

## Understanding Consumer Output

You should see output like this:

```
📨 Message #1:
   🔑 Key: msg-1
   💬 Value: Message #1 - Timestamp: 2025-11-30 14:30:15
   📍 Partition: 0, Offset: 0
   ⏰ Timestamp: Sat Nov 30 14:30:15 CET 2025
   --------------------------------------------------
```

**Key information:**
- **Key/Value** - The message content
- **Partition** - Which partition stored this message  
- **Offset** - Position in that partition
- **Timestamp** - When message was created

---

## Consumer Groups

The consumer uses **consumer group** `test-consumer-group`:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group test-consumer-group
background: false
```

This shows:
- **Current lag** - How many messages are unprocessed
- **Partition assignment** - Which partitions this consumer reads
- **Latest offsets** - Current reading position

---

## Send Message via Kafka UI

While the consumer is running, let's send a custom message through Kafka UI:

**Step 1:** Open **Dashboard** tab (Kafka UI)

**Step 2:** Navigate to **Topics** → **test-messages**

**Step 3:** Click **Produce Message** button

**Step 4:** Fill in the message:
- **Key:** `manual-msg-1`
- **Value:** `Hello from Kafka UI! Sent at [current time]`
- **Partition:** Leave empty (auto-assign)

**Step 5:** Click **Produce**

**Step 6:** Watch your consumer terminal - the new message should appear immediately!

**What you'll see:**
```
📨 Message received:
   🔑 Key: manual-msg-1
   💬 Value: Hello from Kafka UI! Sent at [current time]
   📍 Partition: 1, Offset: 17
   ⏰ Timestamp: ...
```

This demonstrates **real-time message processing** and **UI-to-code integration**.

---

## Reset Consumer Position

To re-read all messages from the beginning:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group test-consumer-group --reset-offsets --to-earliest --topic test-messages --execute
background: false
```

Then restart the consumer to see all messages again.

---

## Consumer Configuration Highlights

The consumer uses these important settings:

```java
// Group and positioning
props.put(ConsumerConfig.GROUP_ID_CONFIG, "test-consumer-group");
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

// Auto-commit settings
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true");
props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, "1000");

// Performance tuning
props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, "100");
```

---

## Consumer Patterns

**Polling Loop:**
```java
while (true) {
    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));
    
    for (ConsumerRecord<String, String> record : records) {
        // Process each message
        processMessage(record);
    }
}
```

**Key Benefits:**
- ✅ **Scalable** - Add more consumers to process faster
- ✅ **Fault tolerant** - Failed consumers can be replaced
- ✅ **At-least-once** delivery guarantee

---

## Stop Consumer

When you're ready, stop the consumer with:

**Ctrl+C**

The consumer will:
- **Gracefully disconnect** from Kafka
- **Commit final offsets** 
- **Leave the consumer group**

---

## Next Steps

With producer and consumer working, we can:
1. **Explore results** in Kafka UI
2. **View message flow** and metrics
3. **Understand partitioning** effects

The consumer has successfully read messages from Kafka! 📖