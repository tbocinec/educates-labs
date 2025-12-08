# CLI-Based Monitoring

Learn to monitor Kafka using built-in command-line tools - the foundation of Kafka observability.

## Topic Monitoring

### List All Topics

```terminal:execute
command: |
  docker exec kafka kafka-topics --list \
    --bootstrap-server localhost:9092
session: 1
```

### Describe Topic Details

Get detailed information about a topic:

```terminal:execute
command: |
  docker exec kafka kafka-topics --describe \
    --topic monitoring-demo \
    --bootstrap-server localhost:9092
session: 1
```

This shows:
- **Partition count** - Number of partitions
- **Replication factor** - Number of replicas per partition
- **Leader** - Which broker leads each partition
- **Replicas** - Where data is stored
- **ISR** - In-Sync Replicas (healthy replicas)

### Check Topic Configuration

```terminal:execute
command: |
  docker exec kafka kafka-configs --describe \
    --entity-type topics \
    --entity-name monitoring-demo \
    --bootstrap-server localhost:9092
session: 1
```

## Partition Monitoring

### Get Partition Offsets

Check the current offsets for each partition:

```terminal:execute
command: |
  docker exec kafka kafka-get-offsets --topic monitoring-demo \
    --bootstrap-server localhost:9092
session: 1
```

This shows:
- **Partition ID** - Partition number
- **Offset** - Latest offset (total messages written)

### Calculate Messages per Partition

```terminal:execute
command: |
  echo "Messages per partition in monitoring-demo:"
  docker exec kafka kafka-get-offsets --topic monitoring-demo \
    --bootstrap-server localhost:9092 | \
  awk -F: '{print "Partition " $2 ": " $3 " messages"}'
session: 1
```

## Consumer Group Monitoring

### List All Consumer Groups

```terminal:execute
command: |
  docker exec kafka kafka-consumer-groups --list \
    --bootstrap-server localhost:9092
session: 1
```

### Create a Test Consumer Group

Start a consumer in a group:

```terminal:execute
command: |
  docker exec -d kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic monitoring-demo \
    --group test-monitoring-group \
    --from-beginning > /dev/null 2>&1
  echo "Consumer group 'test-monitoring-group' created"
session: 1
```

### Describe Consumer Group

Get detailed consumer group information:

```terminal:execute
command: |
  docker exec kafka kafka-consumer-groups --describe \
    --group test-monitoring-group \
    --bootstrap-server localhost:9092
session: 1
```

Key metrics:
- **CURRENT-OFFSET** - Consumer's current position
- **LOG-END-OFFSET** - Latest message in partition
- **LAG** - Messages behind (LOG-END - CURRENT)
- **CONSUMER-ID** - Which consumer owns the partition
- **HOST** - Where consumer is running

### Monitor Consumer Lag

Consumer lag is critical - it shows if consumers are keeping up:

```terminal:execute
command: |
  echo "=== Consumer Lag Summary ==="
  docker exec kafka kafka-consumer-groups --describe \
    --group test-monitoring-group \
    --bootstrap-server localhost:9092 | \
  grep -v TOPIC | awk 'NR>1 {sum+=$5} END {print "Total lag: " sum " messages"}'
session: 1
```

## Broker Monitoring

### Check Broker API Versions

```terminal:execute
command: |
  docker exec kafka kafka-broker-api-versions \
    --bootstrap-server localhost:9092 | head -n 20
session: 1
```

### Get Broker Metadata

```terminal:execute
command: |
  docker exec kafka kafka-metadata --bootstrap-server localhost:9092 \
    --describe --topic monitoring-demo
session: 1
```

## Performance Testing

### Measure Producer Performance

```terminal:execute
command: |
  docker exec kafka kafka-producer-perf-test \
    --topic monitoring-demo \
    --num-records 10000 \
    --record-size 100 \
    --throughput 1000 \
    --producer-props bootstrap.servers=localhost:9092
session: 1
```

Key metrics:
- **Records/sec** - Throughput
- **MB/sec** - Data rate
- **Avg latency** - Time to acknowledge
- **Max latency** - Worst case latency

### Measure Consumer Performance

```terminal:execute
command: |
  docker exec kafka kafka-consumer-perf-test \
    --bootstrap-server localhost:9092 \
    --topic monitoring-demo \
    --messages 10000 \
    --threads 1 \
    --show-detailed-stats
session: 1
```

## Simulating Consumer Lag

Let's create a scenario with consumer lag using our slow consumer generator:

```terminal:execute
command: |
  # Start slow consumer (processes 1 msg/sec while producer sends 5 msg/sec)
  nohup ./generators/slow-consumer.sh monitoring-demo slow-lag-group 1000 > slow-consumer.log 2>&1 &
  echo "Slow consumer started"
session: 2
```

Check the lag:

```terminal:execute
command: |
  echo "=== Checking consumer lag ==="
  docker exec kafka kafka-consumer-groups --describe \
    --group slow-lag-group \
    --bootstrap-server localhost:9092
session: 1
```

Notice the **LAG** column growing! This shows the consumer falling behind.

## CLI Monitoring Best Practices

### Regular Health Checks

1. **Check ISR status** - All replicas should be in-sync
2. **Monitor consumer lag** - Should be near zero for real-time apps
3. **Track partition distribution** - Ensure balanced load
4. **Verify broker availability** - All brokers responding

### Useful Monitoring Scripts

Create a simple monitoring script:

```editor:append-lines-to-file
file: ~/monitor-kafka.sh
text: |
  #!/bin/bash
  echo "=== Kafka Health Check ==="
  echo ""
  echo "Topics:"
  docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
  echo ""
  echo "Consumer Groups:"
  docker exec kafka kafka-consumer-groups --list --bootstrap-server localhost:9092
  echo ""
  echo "Consumer Lag:"
  for group in $(docker exec kafka kafka-consumer-groups --list --bootstrap-server localhost:9092); do
    echo "Group: $group"
    docker exec kafka kafka-consumer-groups --describe --group $group --bootstrap-server localhost:9092 | grep -v TOPIC
    echo ""
  done
```

Make it executable and run:

```terminal:execute
command: |
  chmod +x ~/monitor-kafka.sh
  ~/monitor-kafka.sh
session: 1
```

## Summary

CLI tools provide:
- ✅ **Quick diagnostics** - Fast problem identification
- ✅ **No dependencies** - Works anywhere Kafka runs
- ✅ **Scriptable** - Easy to automate
- ✅ **Real-time** - Immediate feedback

Next, we'll explore JMX metrics for deeper insights!
