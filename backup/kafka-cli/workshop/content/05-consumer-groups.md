# Consumer Groups & Offsets Management

Consumer groups are Kafka's way of coordinating multiple consumers for scalability and fault tolerance. Master these advanced consumer coordination concepts! 👥

---

## Learning Objectives

In this level you'll master:
- ✅ **Consumer group mechanics** - How consumers coordinate
- ✅ **Partition assignment** - Automatic load balancing
- ✅ **Offset management** - Tracking message positions
- ✅ **Lag monitoring** - Performance and health metrics
- ✅ **Offset reset strategies** - Recovery and replay scenarios
- ✅ **Consumer rebalancing** - Handling consumer changes
- ✅ **Production monitoring** - Essential operational commands

---

## 1. Understanding Consumer Groups

First, let's see what consumer groups exist in our system:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --list
background: false
```

**Clean up any previous consumer groups (if they exist):**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --delete --group analytics-team
background: false
```

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --delete --group marketing-team
background: false
```

---

## 2. Creating a Consumer Group

Start a consumer group for processing user events:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group order-processing --property "print.key=true" --property "key.separator=:" --property "print.partition=true" --property "print.offset=true"
background: false
```

**In another terminal**, check the consumer group details:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing
background: false
```

**🔍 Key information:**
- **CONSUMER-ID** - Unique identifier for each consumer
- **HOST** - Where the consumer is running
- **CLIENT-ID** - Application identifier
- **#PARTITIONS** - How many partitions this consumer handles

---

## 3. Multiple Consumers in Same Group

Start a second consumer in the same group (new terminal):

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group order-processing --property "print.key=true" --property "key.separator=:" --property "print.partition=true"
background: false
```

**Watch the rebalancing happen:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing
background: false
```

**🔄 Consumer Rebalancing:**
- Partitions automatically redistribute
- Each partition assigned to exactly ONE consumer
- Load balances across available consumers

---

## 4. Demonstrating Load Balancing

Send messages and observe which consumer receives them:

```terminal:execute
command: docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9092 --topic user-events --property "parse.key=true" --property "key.separator=:"
background: false
```

**Send test messages:**
```
load-test-1:Message 1 for load balancing
load-test-2:Message 2 for load balancing
load-test-3:Message 3 for load balancing
load-test-4:Message 4 for load balancing
load-test-5:Message 5 for load balancing
```

**🎯 Observe:** Each message goes to only ONE consumer in the group, but different consumers handle different partitions.

---

## 5. Consumer Lag Analysis

Generate some consumer lag by sending many messages quickly:

```terminal:execute
command: docker exec kafka bash -c 'for i in {1..50}; do echo "batch-user-$i:High volume message $i"; done | kafka-console-producer --bootstrap-server localhost:9092 --topic user-events --property "parse.key=true" --property "key.separator=:"'
background: false
```

**Check consumer lag immediately:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing
background: false
```

**📊 Understanding lag metrics:**
- **CURRENT-OFFSET** - Last message this consumer processed
- **LOG-END-OFFSET** - Latest message available in partition
- **LAG** - How many messages behind (LOG-END - CURRENT)

---

## 6. Multiple Consumer Groups

Create a second consumer group for analytics:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group analytics-team --from-beginning --property "print.key=true" --property "key.separator=:" | head -10
background: false
```

**Compare the two groups:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing
background: false
```

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group analytics-team
background: false
```

**🔍 Key insight:** Each consumer group maintains its own independent offset position!

---

## 7. Offset Reset Strategies

Stop all consumers (Ctrl+C) and demonstrate different reset strategies.

**Reset to earliest (beginning):**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group order-processing --reset-offsets --to-earliest --topic user-events --execute
background: false
```

**Verify the reset:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing
background: false
```

**Start consumer to see it reads from beginning:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group order-processing --max-messages 5 --property "print.offset=true"
background: false
```

---

## 8. Advanced Offset Reset Options

**Reset to latest (skip old messages):**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group analytics-team --reset-offsets --to-latest --topic user-events --execute
background: false
```

**Reset to specific offset:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group order-processing --reset-offsets --to-offset 10 --topic user-events --execute
background: false
```

**Reset by time (1 hour ago):**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group analytics-team --reset-offsets --to-datetime 2024-01-15T09:00:00.000 --topic user-events --execute
background: false
```

---

## 9. Partition-Specific Operations

Get detailed partition information:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing --members --verbose
background: false
```

**Check specific partition assignments:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing --state
background: false
```

**Reset only specific partitions:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group order-processing --reset-offsets --to-earliest --topic user-events:0,1 --execute
background: false
```

---

## 10. Consumer Group Coordination Protocol

Create a topic to demonstrate partition assignment strategies:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic coordination-demo --partitions 6 --replication-factor 1
background: false
```

**Start consumers one by one and watch rebalancing:**

**Consumer 1:**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic coordination-demo --group coordination-group --property "print.partition=true" &
background: false
```

**Check assignment:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group coordination-group
background: false
```

**Consumer 2 (causes rebalance):**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic coordination-demo --group coordination-group --property "print.partition=true" &
background: false
```

**Check new assignment:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group coordination-group
background: false
```

---

## 11. Lag Monitoring and Alerting

Create a monitoring script to check consumer lag:

**Check total lag across all partitions:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing | awk 'NR>1 {sum += $5} END {print "Total lag:", sum}'
background: false
```

**Generate high lag scenario:**

```terminal:execute
command: docker exec kafka bash -c 'for i in {1..100}; do echo "high-load-$i:Processing message $i"; done | kafka-console-producer --bootstrap-server localhost:9092 --topic user-events --property "parse.key=true" --property "key.separator=:"'
background: false
```

**Monitor lag in real-time:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group order-processing
background: false
```

---

## 12. Consumer Group State Management

Check all possible consumer group states:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --all-groups --state
background: false
```

**Consumer group states:**
- **Empty** - No active consumers
- **PreparingRebalance** - Consumers joining/leaving
- **CompletingRebalance** - Partition assignment in progress
- **Stable** - All consumers active and assigned

**Force a consumer group deletion:**

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --delete --group coordination-group
background: false
```

---

## 13. Offset Storage and Management

**Check where offsets are stored:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list | grep __consumer
background: false
```

**Describe the consumer offsets topic:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic __consumer_offsets
background: false
```

**Read offset commit messages (advanced):**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic __consumer_offsets --formatter "kafka.coordinator.group.GroupMetadataManager\$OffsetsMessageFormatter" --max-messages 10
background: false
```

---

## 14. Production Consumer Patterns

**Pattern 1: Graceful shutdown consumer**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group production-processors --property "enable.auto.commit=false" --property "print.offset=true" --max-messages 5
background: false
```

**Pattern 2: High-performance batch processing**

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --group batch-processors --property "fetch.min.bytes=1024" --property "fetch.max.wait.ms=500" --max-messages 10
background: false
```

---

## 15. Visual Consumer Group Analysis

Switch to **Dashboard** tab and explore:

1. **Consumer Groups** section
2. **Click on any active group** (e.g., `order-processing`)
3. **View partition assignments** and consumer details
4. **Check lag metrics** visually

**Compare CLI vs UI consumer group monitoring** - both provide valuable operational insights!

---

## Key Consumer Group Commands

**Essential Operations:**
```bash
# List all consumer groups
kafka-consumer-groups --bootstrap-server localhost:9092 --list

# Describe specific group
kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group GROUP_NAME

# Check group state and members
kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group GROUP_NAME --members --verbose

# Reset offsets to beginning
kafka-consumer-groups --bootstrap-server localhost:9092 --group GROUP_NAME --reset-offsets --to-earliest --topic TOPIC --execute

# Reset to specific offset
kafka-consumer-groups --bootstrap-server localhost:9092 --group GROUP_NAME --reset-offsets --to-offset N --topic TOPIC --execute

# Delete consumer group
kafka-consumer-groups --bootstrap-server localhost:9092 --delete --group GROUP_NAME
```

---

## Consumer Group Best Practices

**🎯 Operational Guidelines:**

1. **Monitoring:**
   - Watch consumer lag consistently
   - Alert on high lag values
   - Monitor rebalancing frequency

2. **Performance:**
   - Match consumer count to partition count
   - Use appropriate fetch sizes
   - Enable/disable auto-commit based on needs

3. **Reliability:**
   - Handle rebalancing gracefully
   - Implement proper error handling
   - Use meaningful consumer group names

4. **Scaling:**
   - Add consumers to reduce lag
   - Consider partition count limits
   - Plan for peak load scenarios

---

## Offset Management Strategies

**When to reset offsets:**

1. **New application version** - Reset to latest
2. **Bug fix replay** - Reset to specific time/offset
3. **Data reprocessing** - Reset to earliest
4. **Consumer group migration** - Copy offsets from old group

**Offset reset safety checklist:**
- ✅ Stop all consumers in the group first
- ✅ Verify the reset command with `--dry-run`
- ✅ Execute reset with `--execute`
- ✅ Start consumers and verify processing

---

## Current Consumer Group Status

Check our current state:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --list
background: false
```

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --all-groups
background: false
```

**Consumer groups created:**
- `order-processing` - Multi-partition processing
- `analytics-team` - Independent analytics processing
- `production-processors` - Production pattern demo
- `batch-processors` - Batch processing demo

**🚀 Ready for Level 5!**

Next: **Topic Configuration & Retention** - Deep dive into topic lifecycle management and data retention policies.

**🔗 Essential References:**
- [Consumer Group Protocol](https://kafka.apache.org/documentation/#consumerconfigs)
- [Offset Management](https://kafka.apache.org/documentation/#impl_offsettracking)
- [Consumer Rebalancing](https://kafka.apache.org/documentation/#impl_coordinatordetails)