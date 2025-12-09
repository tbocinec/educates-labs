# Keys → Partitioning → Ordering

Master the relationship between keys, partitions, and message ordering.

---

## 🎯 Learning Goals (12 minutes)

✅ Understand partitioning strategies  
✅ See how keys guarantee ordering  
✅ Learn when to use keys vs no keys  
✅ Observe ordering in action  

---

## Partitioning Rules

Kafka uses these rules to determine partition:

**1. Explicit Partition Specified**
```java
new ProducerRecord<>(topic, partition, key, value)
```
→ Goes to specified partition

**2. Key Provided (No Explicit Partition)**
```java
new ProducerRecord<>(topic, key, value)
```
→ `hash(key) % num_partitions`

**3. No Key, No Partition**
```java
new ProducerRecord<>(topic, value)
```
→ Sticky partitioner (batches to same partition, then switches)

---

## The Ordering Guarantee

**Critical Rule:**  
Ordering is guaranteed **ONLY within a single partition**

**With Keys:**
```
sensor-1 → partition 0 → [msg1, msg2, msg3] ← ORDERED
sensor-2 → partition 1 → [msg1, msg2, msg3] ← ORDERED
sensor-3 → partition 2 → [msg1, msg2, msg3] ← ORDERED
```

**Without Keys:**
```
messages → random partitions → NO ORDERING
```

---

## When to Use Keys

**✅ Use Keys When:**
- You need ordering for related messages
- Same entity's events must stay together
- Examples: user-id, sensor-id, order-id, device-id

**❌ Don't Use Keys When:**
- Order doesn't matter
- Maximum throughput needed
- Messages are independent
- Examples: logs, metrics, analytics events

---

## Demo 1: Key-Based Partitioning

Let's prove that same key → same partition.

First, clear existing messages:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --delete --topic humidity_readings && sleep 2 && docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic humidity_readings --partitions 3 --replication-factor 1
background: false
session: 2
```

Now run producer for 15 seconds:

```terminal:execute
command: timeout 15 ./run-producer-basic.sh || true
background: false
session: 1
```

---

## Verify Partition Distribution

Check which partition each key landed in:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic humidity_readings --from-beginning --property print.key=true --property print.partition=true --max-messages 12
background: false
session: 2
```

**You'll see output like:**
```
Partition:2     sensor-3        {"sensor_id":3, ...}
Partition:2     sensor-3        {"sensor_id":3, ...}
Partition:1     sensor-1        {"sensor_id":1, ...}
Partition:1     sensor-1        {"sensor_id":1, ...}
Partition:1     sensor-2        {"sensor_id":2, ...}
Partition:1     sensor-1        {"sensor_id":1, ...}
Partition:1     sensor-2        {"sensor_id":2, ...}
```

**Notice:** Each sensor (key) consistently goes to the same partition!

---

## Kafka UI Verification

Switch to the Kafka UI dashboard:

```dashboard:open-dashboard
name: Kafka UI
```

Then navigate:
1. **Topics** → **humidity_readings**
2. Click **Messages**
3. Group by **Partition**

**Observe:**
- Partition 0: No messages 
- Partition 1: From `sensor-1` and `sensor-2` messages
- Partition 2: Only `sensor-3` messages
---

Why did `sensor-1` and `sensor-2` go to the same partition? Small key space and hash collisions!
(In free time you can experiment to increase number of generated sensors to observe better distribution)

---

## The Hashing Formula

Kafka uses this algorithm:

```java
partition = murmur2(key) % number_of_partitions
```

**Example with 3 partitions:**
```
hash("sensor-1") % 3 → partition 0
hash("sensor-2") % 3 → partition 1
hash("sensor-3") % 3 → partition 2
```

**Important:** Hash is deterministic - same key always produces same partition!

---

## Demo 2: Ordering Within Partition

Run a test to verify ordering:

```editor:open-file
file: ~/kafka-apps/producer-basic/src/main/java/com/example/HumidityProducerBasic.java
line: 63
```

**Current behavior:** Random sensor selection

**What if** we only sent from sensor-1?  
→ All messages go to partition 1  
→ **Strict ordering guaranteed**

---

## Ordering Breakdown Scenario

**What breaks ordering?**

High `max.in.flight.requests.per.connection` + retries

```
1. Send msg-1 to partition 0
2. Send msg-2 to partition 0
3. msg-1 fails, retrying...
4. msg-2 succeeds (offset 100)
5. msg-1 succeeds (offset 101) ← OUT OF ORDER!
```

**Solution:**
```java
props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 1);
// OR
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true); // ← Better!
```

Idempotence maintains ordering even with retries!

---

## Sticky Partitioner (No Keys)

When no key is provided, Kafka uses **sticky partitioner**:

```
Batch 1: [msg1, msg2, msg3, msg4] → partition 0
Batch 2: [msg5, msg6, msg7, msg8] → partition 1  
Batch 3: [msg9, msg10, ...     ] → partition 2
```

**Benefits:**
- Better batching (higher throughput)
- Fewer requests to brokers
- More efficient than round-robin

**Trade-off:** No ordering guarantees

---

## Key Size Matters

**Keep keys small!**

```java
// ❌ BAD - Large key
String key = entireUserProfile; // 10KB

// ✅ GOOD - Small key
String key = userId; // 36 bytes (UUID)
```

**Why?**
- Keys transmitted with every message
- Affects network and storage
- No need for large keys - just needs to be unique per entity

---

## Partition Count Considerations

**Adding partitions later = key distribution changes!**

```
Topic with 3 partitions:
hash("sensor-1") % 3 = partition 0 ✅

Topic increased to 5 partitions:
hash("sensor-1") % 5 = partition 3 ← DIFFERENT!
```

**Best practice:** Choose partition count carefully upfront

---

## Summary: Keys & Partitioning

**The Golden Rules:**

1. **Same key → Same partition → Ordering guaranteed**
2. **No key → Sticky partitioner → High throughput, no ordering**
3. **Ordering exists ONLY within a partition**
4. **Enable idempotence for safe retries with ordering**
5. **Don't change partition count after production data exists**

---

## Time Check

**Time used:** ~12 minutes  
**Next:** Async vs Sync send modes! →

