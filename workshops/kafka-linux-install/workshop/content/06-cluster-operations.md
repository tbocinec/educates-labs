# Testing the Multi-Broker Cluster

Let's test our cluster with replicated topics and verify failover capabilities.

## Understanding Kafka Replication

Before we start testing, let's understand key replication concepts:

### Replication Factor
The **replication factor** determines how many copies of each partition exist across the cluster. For example:
- `replication-factor=1` - No redundancy, single point of failure
- `replication-factor=2` - One leader + one follower replica
- `replication-factor=3` - One leader + two follower replicas (production standard)

### Leader and Followers
Each partition has one **leader** and zero or more **followers**:
- **Leader** - Handles all read and write requests for the partition
- **Followers** - Replicate data from the leader passively
- If the leader fails, one follower is elected as the new leader

### In-Sync Replicas (ISR)
**ISR** is the set of replicas that are fully caught up with the leader:
- Only ISR members can be elected as leaders
- A replica is removed from ISR if it falls too far behind
- **min.insync.replicas** - Minimum ISR count required for writes (prevents data loss)

### Replication Workflow
```
Producer → Leader Partition
            ↓
    Followers fetch data
            ↓
    Acknowledge when in-sync
            ↓
    Producer receives ack
```

When `acks=all`, producers wait for all ISR replicas to confirm before considering a write successful.

## Create a Replicated Topic

Create a topic with replication factor 2:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-topics.sh --create \
    --topic replicated-topic \
    --partitions 3 \
    --replication-factor 2 \
    --bootstrap-server localhost:9092
```

## Describe the Topic

View the topic details to see replica distribution:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-topics.sh --describe \
    --topic replicated-topic \
    --bootstrap-server localhost:9092
```

Notice:
- **Leader** - The broker handling reads/writes for each partition
- **Replicas** - List of brokers storing copies (e.g., "2,3")
- **ISR** - In-Sync Replicas (replicas that are up-to-date)

Each partition should have 2 replicas across different brokers!

### Understanding the Output

Let's break down what you see:

**Partition Distribution Example:**
```
Partition 0: Leader=2, Replicas=[2,3], ISR=[2,3]
Partition 1: Leader=3, Replicas=[3,2], ISR=[3,2]
Partition 2: Leader=2, Replicas=[2,3], ISR=[2,3]
```

This means:
- **Leader=2** - Broker 2 handles requests for this partition
- **Replicas=[2,3]** - Data is stored on both broker 2 and broker 3
- **ISR=[2,3]** - Both replicas are in-sync (healthy state)

If a broker goes down, you'll see:
- ISR list shrinks (e.g., `ISR=[2]` if broker 3 fails)
- Leader may change if the leader broker fails
- Replicas list stays the same (assigned replicas don't change)

## Produce Messages to the Cluster

Send messages to the replicated topic:

```terminal:execute
command: |
  cd /opt/kafka
  echo -e "Cluster message 1\nCluster message 2\nCluster message 3\nCluster message 4\nCluster message 5" | \
    bin/kafka-console-producer.sh \
      --topic replicated-topic \
      --bootstrap-server localhost:9092
```

## Consume Messages

Read messages from the cluster:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-console-consumer.sh \
    --topic replicated-topic \
    --from-beginning \
    --bootstrap-server localhost:9092
```

You should see all the messages! Press `Ctrl+C` to stop.

## Test Cluster Metadata

Get broker information from the cluster:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092 | head -n 20
```

## Test Failover - Simulate Broker Failure

Let's simulate a broker failure and see how Kafka handles it.

First, identify the process ID of broker 2:

```terminal:execute
command: ps aux | grep broker2.properties | grep -v grep
```

Stop broker 2:

```terminal:execute
command: |
  pkill -f broker2.properties
  sleep 3
  echo "Broker 2 stopped"
```

## Check Topic Status After Failure

Describe the topic again:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-topics.sh --describe \
    --topic replicated-topic \
    --bootstrap-server localhost:9092
```

Notice:
- **ISR changed** - Broker 3 removed from ISR for partitions it led
- **Leader election** - New leaders elected for affected partitions
- **Data still available** - Because we have replicas!

## Continue Producing During Failure

Even with one broker down, we can still produce:

```terminal:execute
command: |
  cd /opt/kafka
  echo "Message during broker failure!" | \
    bin/kafka-console-producer.sh \
      --topic replicated-topic \
      --bootstrap-server localhost:9092
```

## Restart Broker 2

Bring broker 2 back online:

```terminal:execute
command: |
  cd /opt/kafka
  mkdir -p logs
  nohup bin/kafka-server-start.sh config/broker2.properties > logs/broker2.log 2>&1 &
  sleep 10
  echo "Broker 2 restarted"
```

## Verify Recovery

Check that broker 2 rejoined the ISR:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-topics.sh --describe \
    --topic replicated-topic \
    --bootstrap-server localhost:9092
```

The ISR should show both brokers again as replicas sync up!

### Replica Synchronization Process

When broker 2 restarts, here's what happens:

1. **Broker rejoins cluster** - Registers with the controller
2. **Fetches metadata** - Gets current partition assignments
3. **Starts replication** - Begins catching up from current leaders
4. **Rejoins ISR** - Once caught up, added back to ISR for each partition
5. **Available for leadership** - Can now be elected as leader if needed

The time to rejoin ISR depends on:
- Amount of data to catch up
- Network bandwidth
- Disk I/O performance

## Performance - Parallel Production

Test cluster throughput by connecting to multiple brokers:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-producer-perf-test.sh \
    --topic replicated-topic \
    --num-records 10000 \
    --record-size 100 \
    --throughput 1000 \
    --producer-props bootstrap.servers=localhost:9092,localhost:9094
```

## Understanding Replication

Key benefits demonstrated:
- **High Availability** - Topics survive broker failures
- **Leader Election** - Automatic failover to replica
- **Data Durability** - Multiple copies prevent data loss
- **Load Distribution** - Requests balanced across brokers

### Advanced Replication Concepts

**Replication Lag**
- Measures how far behind a follower is from the leader
- Monitored via `kafka.server:type=FetcherLagMetrics`
- High lag may cause replica to be removed from ISR

**Unclean Leader Election**
- `unclean.leader.election.enable=false` (default) - Only ISR can become leader
- If set to `true` - Out-of-sync replica can become leader (data loss risk)
- Trade-off: availability vs. consistency

**Preferred Leader**
- Each partition has a "preferred leader" (first replica in assignment)
- Kafka automatically rebalances to preferred leaders
- Ensures even load distribution across brokers

**Producer Acknowledgment Levels**
- `acks=0` - No acknowledgment (fire and forget)
- `acks=1` - Leader acknowledges (default)
- `acks=all` - All ISR members acknowledge (strongest durability)

**min.insync.replicas**
- Minimum number of ISR required for writes
- Example: `replication-factor=3, min.insync.replicas=2`
- If ISR < 2, writes are rejected (prevents data loss)

## Summary

You've successfully tested the multi-broker cluster! You learned how to:
- Create replicated topics
- Test broker failover and recovery
- Verify replica synchronization
- Measure cluster performance
