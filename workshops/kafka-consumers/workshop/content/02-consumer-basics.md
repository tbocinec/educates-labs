# Consumer Basics - Your First Consumer

Let's build and run your first Kafka consumer! This consumer uses **auto-commit** mode - the simplest pattern.

---

## 🎯 What You'll Learn

- Consumer group basics
- Poll loop mechanics
- Auto-commit offset management
- ConsumerRecord structure

---

## Consumer Architecture

A Kafka consumer has these key components:

```
┌─────────────────────────────────────┐
│     Kafka Consumer                  │
│                                     │
│  1. Subscribe to topic(s)          │
│  2. Join consumer group            │
│  3. Get partition assignment       │
│  4. Poll for messages              │
│  5. Process messages               │
│  6. Commit offsets (auto/manual)   │
└─────────────────────────────────────┘
```

---

## Examine the Basic Consumer Code

Let's look at the key parts of our basic consumer:

```editor:select-matching-text
file: ~/kafka-apps/consumer-basic/src/main/java/com/example/HumidityConsumerBasic.java
text: "createConsumer()"
```

**Key configuration:**
- `enable.auto.commit = true` - Automatic offset commits
- `auto.commit.interval.ms = 5000` - Commit every 5 seconds
- `auto.offset.reset = earliest` - Read from beginning if no offset
- `group.id` - Consumer group identifier

---

## The Poll Loop

The heart of every consumer is the **poll loop**:

```editor:select-matching-text
file: ~/kafka-apps/consumer-basic/src/main/java/com/example/HumidityConsumerBasic.java
text: "while (true)"
```

**Critical rules:**
- ✅ You must keep polling regularly
- ✅ If you stop polling, consumer is considered "dead"
- ✅ Dead consumers trigger rebalancing
- ✅ Poll timeout should be reasonable (100-1000ms)

---

## Run the Basic Consumer

Start the basic consumer:

```terminal:execute
command: ./run-consumer-basic.sh
background: false
```

**You should see:**
```
📖 Starting Basic Humidity Consumer...
📊 Consumer Group: humidity-monitor-group
🔄 Using AUTO-COMMIT mode

✅ Subscribed to topic: humidity_readings
🔄 Polling for messages...

🌡️  Reading #1:
   📍 Location: kitchen (Sensor 1)
   💧 Humidity: 65%
   ⏰ Timestamp: 2025-12-07T14:30:15Z
   📊 Kafka Metadata:
      - Key: sensor-1
      - Partition: 0
      - Offset: 0
```

**Let it run for 30 seconds to see multiple readings.**

---

## Understanding the Output

Each message shows:

- **Location & Sensor** - Which sensor sent the reading
- **Humidity** - The measured humidity percentage
- **Timestamp** - When the reading was taken
- **Kafka Metadata:**
  - **Key** - Message key (sensor-1, sensor-2, sensor-3)
  - **Partition** - Which partition holds this message
  - **Offset** - Position in that partition

---

## Consumer Groups

Check your consumer group status:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-monitor-group
background: false
```

**Output shows:**
- `CURRENT-OFFSET` - Latest consumed offset
- `LOG-END-OFFSET` - Latest message in partition
- `LAG` - Number of unconsumed messages
- `CONSUMER-ID` - Your consumer instance
- `HOST` - Where consumer is running
- `PARTITION` - Assigned partitions

---

## How Auto-Commit Works

With auto-commit enabled:

1. ⏱️ Every 5 seconds (interval)
2. 💾 Kafka automatically saves current offsets
3. ✅ Happens in background during `poll()`

**Pros:**
- ✅ Simple - no manual offset management
- ✅ Less code to write

**Cons:**
- ⚠️ May commit before processing completes
- ⚠️ Can lose messages if consumer crashes
- ⚠️ May process duplicates after rebalance

---

## Delivery Semantics with Auto-Commit

Auto-commit provides **AT-MOST-ONCE** semantics:

```
1. Poll messages
2. Auto-commit saves offsets
3. Process messages  ← If crash happens here
4. Messages are lost!
```

For critical data, you need **manual commit** (next section).

---

## Stop the Consumer

Stop the consumer with `Ctrl+C`:

```terminal:interrupt
session: 1
```

Notice the graceful shutdown message.

---

## Consumer Offset Storage

Offsets are stored in a special Kafka topic:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic __consumer_offsets --formatter "kafka.coordinator.group.GroupMetadataManager\$OffsetsMessageFormatter" --max-messages 5
background: false
```

This shows the internal offset storage. Each consumer group's progress is tracked here.

---

## Key Takeaways

✅ **Consumer groups** enable parallel processing  
✅ **Poll loop** is the heart of the consumer  
✅ **Auto-commit** is simple but has trade-offs  
✅ **Offsets** track consumer progress  
✅ **Rebalancing** redistributes partitions  

---

## Next Steps

You've built a basic consumer with auto-commit. Next, we'll dive deeper into the **ConsumerRecord** structure to understand what data Kafka provides with each message.

