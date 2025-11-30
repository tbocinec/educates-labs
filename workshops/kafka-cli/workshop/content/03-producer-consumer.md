# Producers & Consumers - Message Flow Fundamentals

Now that we have topics, let's learn to send and receive messages using Kafka's CLI tools! 📤📥

---

## Learning Objectives

In this level you'll master:
- ✅ **Console Producer** - Send messages from command line
- ✅ **Console Consumer** - Read messages in real-time
- ✅ **Key-Value messages** - Structured message patterns
- ✅ **Message formatting** - Custom serializers and display
- ✅ **Producer properties** - Performance and reliability settings
- ✅ **Consumer properties** - Reading patterns and offsets
- ✅ **Live demonstration** - Real-time message flow

---

## 1. Your First Producer - Simple Messages

Let's send messages to our `user-events` topic using the console producer:

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic user-events
background: false
```

**📝 Instructions:**
1. Type messages and press **Enter** to send
2. Try these sample messages:
   ```
   User john logged in
   User mary created account
   User bob purchased item-123
   User alice updated profile
   ```
3. Press **Ctrl+C** to exit producer

**💡 How it works:**
- Each line becomes a separate message
- Messages are distributed across partitions
- Timestamps are automatically added

---

## 2. Your First Consumer - Reading Messages

In a **new terminal**, start a consumer to read your messages:

**🚀 Click to open another terminal and run:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --from-beginning
background: false
```

**What you'll see:**
- All messages you sent (potentially in different order)
- Consumer continues listening for new messages
- Press **Ctrl+C** to stop consumer

**Key parameters:**
- `--from-beginning` - Read all existing messages
- Without it: only reads new messages from now on

---

## 3. Real-Time Message Flow Demo

Let's see live message streaming in action!

**Step 1:** Keep your consumer running, or start a new one:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events
background: false
```

**Step 2:** In another terminal, start a producer:

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic user-events
background: false
```

**Step 3:** Send messages and watch them appear in real-time in the consumer!

```
🛍️ Order order-001 placed by user-456
💳 Payment payment-789 processed
📦 Shipment ship-012 dispatched
✅ Delivery delivery-345 completed
```

**🎯 Observation:** Messages appear instantly in the consumer - this is Kafka's real-time streaming in action!

---

## 4. Key-Value Messages

Real applications often need structured data. Let's use key-value pairs:

**Producer with keys:**

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic user-events --property "parse.key=true" --property "key.separator=:"
background: false
```

**Send structured messages:**
```
user-123:{"action":"login","timestamp":"2024-01-15T10:30:00Z","location":"mobile"}
user-456:{"action":"purchase","item":"laptop-pro","amount":1299.99}
user-789:{"action":"logout","session_duration":3600}
user-123:{"action":"purchase","item":"coffee-mug","amount":15.99}
```

**💡 Key Benefits:**
- **Partitioning:** Messages with same key go to same partition
- **Ordering:** All messages for `user-123` stay in order
- **Routing:** Consumers can process user data consistently

---

## 5. Consumer with Key Display

Read messages showing both keys and values:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --from-beginning --property "print.key=true" --property "key.separator=:" --property "print.timestamp=true"
background: false
```

**Enhanced output shows:**
- **Timestamp** - When message was created
- **Key** - Message identifier (user-123)
- **Value** - Message content (JSON data)

---

## 6. Producer Performance Settings

Create a high-throughput producer for our `metrics-data` topic:

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic metrics-data --producer-property acks=1 --producer-property batch.size=16384 --producer-property linger.ms=5
background: false
```

**Send batch data:**
```
cpu.usage:85.2
memory.usage:72.5
disk.io:1024
network.rx:2048
network.tx:1536
```

**🚀 Performance settings:**
- `acks=1` - Wait for leader acknowledgment only (faster than acks=all)
- `batch.size=16384` - Send messages in 16KB batches
- `linger.ms=5` - Wait up to 5ms to batch messages

---

## 7. Consumer Groups Introduction

Start multiple consumers in the same consumer group:

**Terminal 1:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group analytics-team --property "print.key=true" --property "key.separator=:"
background: false
```

**Terminal 2 (if available):**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group analytics-team --property "print.key=true" --property "key.separator=:"
background: false
```

**What happens:**
- Consumers automatically share partitions
- Each message goes to only ONE consumer in the group
- Partitions rebalance when consumers join/leave

---

## 8. Different Consumer Groups

Start a consumer in a different group:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group marketing-team --from-beginning --property "print.key=true" --property "key.separator=:"
background: false
```

**🔍 Key insight:** Different consumer groups receive ALL messages independently!

**Use cases:**
- `analytics-team` - Process for reporting
- `marketing-team` - Process for campaigns
- `fraud-detection` - Process for security

---

## 9. Message Offset Management

Check current consumer group positions:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group analytics-team
background: false
```

**Understanding the output:**
- **TOPIC, PARTITION** - Which partition
- **CURRENT-OFFSET** - Next message to read
- **LOG-END-OFFSET** - Latest message in partition
- **LAG** - How many messages behind

---

## 10. Custom Message Formats

Send JSON messages with proper formatting:

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic product-catalog-updates --property "parse.key=true" --property "key.separator=|"
background: false
```

**Send product updates:**
```
PROD-001|{"name":"Wireless Headphones","price":199.99,"category":"electronics","stock":50}
PROD-002|{"name":"Coffee Maker","price":89.99,"category":"appliances","stock":25}
PROD-003|{"name":"Running Shoes","price":129.99,"category":"sports","stock":100}
```

**Read with formatted output:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic product-catalog-updates --from-beginning --property "print.key=true" --property "key.separator=|" --property "print.timestamp=true"
background: false
```

---

## 11. Error Handling and Message Limits

Test consumer with message limits:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --max-messages 5 --property "print.key=true" --property "key.separator=:"
background: false
```

**Read only latest messages:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --partition 0 --offset latest --max-messages 3
background: false
```

---

## 12. Visual Verification in Kafka UI

Switch to **Dashboard** tab and explore:

1. **Topics → user-events → Messages**
2. View messages with keys and values
3. **Notice partition distribution** of your key-value messages
4. **Consumer Groups section** - See your active consumer groups

**Compare CLI vs UI message browsing** - both methods give you valuable insights!

---

## 13. Cleanup - Stop Consumers

Make sure to stop any running consumers:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --list
background: false
```

**If you see active consumer groups, stop them with Ctrl+C in their terminals.**

---

## Key Commands Mastered

**Producer Commands:**
```bash
# Simple producer
kafka-console-producer --bootstrap-server localhost:9092 --topic TOPIC

# Key-value producer
kafka-console-producer --bootstrap-server localhost:9092 --topic TOPIC \
  --property "parse.key=true" --property "key.separator=:"

# Producer with properties
kafka-console-producer --bootstrap-server localhost:9092 --topic TOPIC \
  --producer-property acks=1 --producer-property batch.size=16384
```

**Consumer Commands:**
```bash
# Simple consumer
kafka-console-consumer --bootstrap-server localhost:9092 --topic TOPIC

# Consumer from beginning
kafka-console-consumer --bootstrap-server localhost:9092 --topic TOPIC --from-beginning

# Consumer with key display
kafka-console-consumer --bootstrap-server localhost:9092 --topic TOPIC \
  --property "print.key=true" --property "key.separator=:"

# Consumer group
kafka-console-consumer --bootstrap-server localhost:9092 --topic TOPIC --group GROUP_NAME
```

---

## Message Flow Patterns

**📊 What we learned:**

1. **Point-to-Point:** One producer → One consumer
2. **Pub-Sub:** One producer → Multiple consumer groups
3. **Load Balancing:** One producer → Multiple consumers in same group
4. **Key-based Partitioning:** Messages with same key stay together

**🎯 Production Patterns:**
- Use **keys** for related data that needs ordering
- Use **consumer groups** for scaling processing
- Use **different groups** for different use cases
- Monitor **lag** to ensure consumers keep up

---

## Current Message Inventory

Check what data we've created across topics:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --max-messages 3 --property "print.key=true" --property "key.separator=:"
background: false
```

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic product-catalog-updates --max-messages 2 --property "print.key=true" --property "key.separator=|"
background: false
```

**🚀 Ready for Level 3!**

Next up: **Partitions & Ordering** - Understanding how Kafka distributes and orders your messages across partitions.

**🔗 Essential References:**
- [Kafka Producer API](https://kafka.apache.org/documentation/#producerapi)
- [Kafka Consumer API](https://kafka.apache.org/documentation/#consumerapi)
- [Message Format and Serialization](https://kafka.apache.org/documentation/#serialization)