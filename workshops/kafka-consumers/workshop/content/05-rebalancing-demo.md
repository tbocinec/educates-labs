# Partition Rebalancing in Action

Understand how Kafka redistributes partitions when consumers join or leave a group.

---

## 🎯 What You'll Learn

- What triggers rebalancing
- How partitions are reassigned
- Assignment strategies (Range, RoundRobin, Cooperative Sticky)
- Rebalance listeners
- Minimizing rebalance impact

---

## What is Rebalancing?

**Rebalancing** = Reassigning partitions among consumers in a group

```
Before rebalance (1 consumer):
Consumer-1: [P0, P1, P2]

After rebalance (2 consumers):
Consumer-1: [P0, P1]
Consumer-2: [P2]
```

---

## What Triggers Rebalancing?

### 1. Consumer Joins Group
```
New consumer subscribes → triggers rebalance
```

### 2. Consumer Leaves Group
```
Consumer stops/crashes → triggers rebalance
```

### 3. Consumer Considered Dead
```
Missing heartbeats > session.timeout.ms → triggers rebalance
Poll interval > max.poll.interval.ms → triggers rebalance
```

### 4. Topic Partition Changes
```
New partitions added to topic → triggers rebalance
```

---

## Rebalance Impact

During rebalancing:
- ⏸️ **Processing stops** for affected consumers
- 🔄 **Partitions reassigned** among group members  
- 📍 **Offsets committed** (if auto-commit enabled)
- ⚠️ **Possible duplicates** if uncommitted messages exist
- ⏱️ **Latency spike** while rebalancing completes

**Goal:** Minimize rebalance frequency and duration!

---

## Demo: Single Consumer

First, let's see a single consumer with all partitions:

```terminal:execute
command: ./run-consumer-manual.sh
background: true
```

Wait a few seconds, then check partition assignment:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-processor-group
background: false
```

**You should see:**
- One consumer instance
- All 3 partitions assigned to it

---

## Demo: Adding a Second Consumer

Open a second terminal and start another consumer in the **same group**:

```dashboard:create-dashboard
name: Second Consumer
url: terminal:2
```

In the new terminal:

```terminal:execute
command: cd /home/eduk8s && ./run-consumer-manual.sh
background: true
session: 2
```

**What happens:**
1. 🔔 Second consumer joins group
2. 🔄 Rebalance triggered
3. 📦 Partitions redistributed
4. ✅ Both consumers resume processing

---

## Observe the Rebalance

Check the partition assignment again:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-processor-group
background: false
```

**You should now see:**
- Two consumer instances
- Partitions split between them (e.g., Consumer-1: [P0, P1], Consumer-2: [P2])

**Watch the logs** in both terminals - you'll see rebalance messages!

---

## Demo: Removing a Consumer

Stop the second consumer:

```terminal:interrupt
session: 2
```

Check partition assignment again:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-processor-group
background: false
```

**Another rebalance occurred:**
- Second consumer left
- All partitions reassigned to first consumer
- Processing continues

---

## Partition Assignment Strategies

Kafka supports different strategies for assigning partitions:

### Range (Default)

Assigns partitions in ranges to consumers (ordered by name):

```
Topic with 3 partitions, 2 consumers:
Consumer-1: [P0, P1]
Consumer-2: [P2]
```

**Pros:** Simple  
**Cons:** Uneven distribution if partitions not divisible by consumers

### RoundRobin

Distributes partitions evenly across consumers:

```
Topic with 5 partitions, 2 consumers:
Consumer-1: [P0, P2, P4]
Consumer-2: [P1, P3]
```

**Pros:** Better balance  
**Cons:** More partition movement on rebalance

### CooperativeSticky (Recommended)

Minimizes partition movement during rebalance:

```
Initial:
Consumer-1: [P0, P1]
Consumer-2: [P2, P3]

After Consumer-2 leaves:
Consumer-1: [P0, P1, P2, P3]  ← Only P2, P3 moved
```

**Pros:** Faster rebalance, less disruption  
**Cons:** Slightly more complex

---

## Configure Assignment Strategy

You can set the strategy in consumer configuration:

```java
props.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG,
    "org.apache.kafka.clients.consumer.CooperativeStickyAssignor");
```

Or use multiple strategies (in preference order):

```java
props.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG,
    "org.apache.kafka.clients.consumer.CooperativeStickyAssignor," +
    "org.apache.kafka.clients.consumer.RangeAssignor");
```

---

## Rebalance Listeners

You can hook into rebalance events:

```java
consumer.subscribe(List.of(TOPIC_NAME), new ConsumerRebalanceListener() {
    
    @Override
    public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
        // Called BEFORE rebalance
        System.out.println("⚠️ Partitions revoked: " + partitions);
        
        // Commit pending offsets before losing partitions
        consumer.commitSync();
    }
    
    @Override
    public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
        // Called AFTER rebalance
        System.out.println("✅ Partitions assigned: " + partitions);
        
        // Initialize state for new partitions
        for (TopicPartition partition : partitions) {
            long position = consumer.position(partition);
            System.out.printf("Starting from offset %d for %s%n", 
                position, partition);
        }
    }
});
```

**Use cases:**
- Commit offsets before losing partitions
- Close resources (databases, files)
- Initialize state for new partitions
- Log partition changes

---

## Critical Timeout Configurations

### session.timeout.ms (default: 10000)

Maximum time between heartbeats before consumer considered dead.

```java
props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 30000);
```

**Too low:** Frequent false rebalances  
**Too high:** Slow failure detection

### heartbeat.interval.ms (default: 3000)

How often to send heartbeats.

```java
props.put(ConsumerConfig.HEARTBEAT_INTERVAL_MS_CONFIG, 3000);
```

**Rule:** Should be < session.timeout.ms / 3

### max.poll.interval.ms (default: 300000)

Maximum time between poll() calls before consumer considered dead.

```java
props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 600000);
```

**Too low:** Rebalances during slow processing  
**Too high:** Slow detection of stuck consumers

---

## Demo: Slow Consumer Failure

Let's simulate a slow consumer that exceeds `max.poll.interval.ms`.

First, check current timeout:

```terminal:execute
command: grep -A 50 "createConsumer" kafka-apps/consumer-manual/src/main/java/com/example/HumidityConsumerManual.java | grep MAX_POLL_INTERVAL
background: false
```

Our consumer has `MAX_POLL_INTERVAL_MS_CONFIG = 300000` (5 minutes).

**In production**, if processing takes longer than this, consumer is kicked out!

---

## Minimizing Rebalance Impact

### 1. Increase Timeouts (Carefully)

```java
props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 30000);
props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 600000);
```

Prevents rebalancing due to temporary slowdowns.

### 2. Use Cooperative Sticky Assignor

```java
props.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG,
    "org.apache.kafka.clients.consumer.CooperativeStickyAssignor");
```

Reduces partition movement.

### 3. Keep Poll Loop Fast

```java
// Bad: Heavy processing in poll loop
for (ConsumerRecord r : records) {
    heavyProcessing(r);  // May exceed max.poll.interval
}

// Good: Offload to worker threads
for (ConsumerRecord r : records) {
    workerPool.submit(() -> heavyProcessing(r));
}
// Wait for workers, then commit
```

### 4. Commit Before Rebalance

```java
new ConsumerRebalanceListener() {
    public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
        consumer.commitSync();  // Save progress
    }
}
```

### 5. Static Group Membership

```java
props.put(ConsumerConfig.GROUP_INSTANCE_ID_CONFIG, "consumer-1");
```

Prevents rebalance on consumer restart (if within session timeout).

---

## Monitoring Rebalances

Track rebalance metrics:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-processor-group --state
background: false
```

Shows:
- Group state (Stable, PreparingRebalance, etc.)
- Assignment strategy
- Members

---

## Clean Up

Stop the first consumer:

```terminal:interrupt
session: 1
```

Verify group is empty:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-processor-group
background: false
```

---

## Key Takeaways

✅ **Rebalancing** redistributes partitions when group changes  
✅ **Triggers:** Consumer join/leave, timeout, topic changes  
✅ **Impact:** Processing pause, possible duplicates  
✅ **Strategies:** Range, RoundRobin, CooperativeSticky  
✅ **Listeners** let you handle rebalance events  
✅ **Timeouts** control when consumer is considered dead  
✅ **Fast poll loops** prevent timeout rebalances  

---

## Next Steps

You've seen rebalancing in action! Next, we'll explore **consumer configuration tuning** for optimal performance and reliability.

