# ProducerRecord Essentials

Understanding the building blocks of Kafka messages.

---

## 🎯 Learning Goals (8 minutes)

✅ Understand ProducerRecord components  
✅ Learn the role of keys in messages  
✅ Explore headers for metadata  
✅ See how keys affect partitioning  

---

## ProducerRecord Components

A `ProducerRecord` contains:

**Required:**
- **topic** - Where to send the message
- **value** - The message content

**Optional:**
- **key** - Determines partition and ordering
- **partition** - Explicit partition (overrides key)
- **timestamp** - Event time (defaults to current time)
- **headers** - Metadata (tracing, correlation)

---

## Basic ProducerRecord

Simplest form - just topic and value:

```java
ProducerRecord<String, String> record = 
    new ProducerRecord<>("humidity_readings", 
                        "{\"sensor_id\":1,\"humidity\":65}");
```

**Result:** Message sent to random partition (sticky partitioner)

---

## ProducerRecord with Key

Key determines the partition:

```java
ProducerRecord<String, String> record = 
    new ProducerRecord<>("humidity_readings",
                        "sensor-1",  // ← KEY
                        "{\"sensor_id\":1,\"humidity\":65}");
```

**Result:** All messages with `"sensor-1"` go to the same partition!

**Why it matters:**
- **Ordering** - Messages with same key are ordered
- **Co-location** - Related data stays together
- **Parallelism** - Different keys can be processed in parallel

---

## ProducerRecord with Headers

Headers carry metadata without polluting the message:

```java
ProducerRecord<String, String> record = 
    new ProducerRecord<>("humidity_readings",
                        "sensor-1",
                        "{\"sensor_id\":1,\"humidity\":65}");

record.headers()
    .add("trace-id", "abc-123".getBytes())
    .add("source", "iot-gateway".getBytes())
    .add("version", "v2".getBytes());
```

**Common use cases:**
- Distributed tracing
- Message versioning
- Routing metadata
- Correlation IDs

---

## Run Basic Producer

Let's see ProducerRecord in action:

```terminal:execute
command: ./run-producer-basic.sh
background: false
session: 1
```

The producer sends humidity readings from 3 sensors.

**Let it run for 20 seconds**, then press Ctrl+C.

---

## Examine the Output

You should see:

```
🌡️  Starting Humidity Producer (BASIC MODE)...
📊 Mode: Fire-and-forget (no callbacks)

📤 Sent: sensor-1 | kitchen | 68%
📤 Sent: sensor-3 | outside | 42%
📤 Sent: sensor-2 | bedroom | 54%
```

**Notice:**
- Each message has a key (`sensor-1`, `sensor-2`, `sensor-3`)
- Keys are based on sensor location
- No delivery confirmation (fire-and-forget)

---

## View Messages in Kafka UI

Switch to the Kafka UI dashboard:

```dashboard:open-dashboard
name: Kafka UI
```

Then navigate:
1. **Topics** → **humidity_readings**
2. Click **Messages**

**Observe:**
- Messages distributed across 3 partitions
- Key column shows `sensor-1`, `sensor-2`, `sensor-3`
- Messages with same key are in same partition

---

## Inspect Message Details

In Kafka UI, click on any message to see:

- **Key** - The sensor identifier
- **Value** - JSON humidity reading
- **Partition** - Which partition (0, 1, or 2)
- **Offset** - Position in partition
- **Timestamp** - When message was produced

---

## Key Takeaways

**ProducerRecord Structure:**
```
topic     → Required (where to send)
key       → Optional (determines partition)
value     → Required (the message)
headers   → Optional (metadata)
partition → Optional (overrides key)
timestamp → Optional (defaults to now)
```

**Key's Critical Role:**
- Same key → Same partition
- Same partition → Ordered delivery
- No key → Random/sticky partition

---

## Time Check

**Time used:** ~8 minutes  
**Next:** Deep dive into keys, partitioning, and ordering! →

