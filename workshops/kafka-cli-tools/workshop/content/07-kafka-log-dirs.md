# kafka-log-dirs - Disk Usage Analysis

The `kafka-log-dirs` tool analyzes disk usage and helps with capacity planning.

## Use Cases

- **Capacity planning**: Identify storage trends and predict growth
- **Troubleshooting**: Find which topics consume most disk space
- **Performance optimization**: Identify large partitions that slow rebalancing
- **Cost optimization**: Clean up or compact oversized topics
- **Audit**: Track disk usage before/after reassignments

## Basic Syntax

```bash
kafka-log-dirs --bootstrap-server <brokers> --describe [options]
```

## Analyze All Log Directories

Create topics with different sizes to demonstrate:

```terminal:execute
command: |
  # Small topic
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic small-topic \
    --partitions 2 \
    --replication-factor 2 --if-not-exists
  
  # Large topic
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic large-topic \
    --partitions 6 \
    --replication-factor 2 --if-not-exists
session: 1
```

Send data to create size differences:

```terminal:execute
command: |
  # Small topic - 10 messages
  for i in {1..10}; do
    echo "Small message $i"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic small-topic
  
  # Large topic - 1000 messages with padding
  for i in {1..1000}; do
    echo "Message $i: $(head -c 200 /dev/zero | tr '\0' 'X')"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic large-topic
  
  echo "✓ Data sent"
session: 1
```

Analyze log directories:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
session: 1
```

> Output is in JSON format showing sizes for each partition on each broker

## View Disk Usage

View raw disk usage data:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
session: 1
```

## Filter by Topic

Analyze specific topic:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic-list large-topic
session: 1
```

View topic disk usage:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic-list large-topic
session: 1
```

## Filter by Broker

Analyze specific broker's disk usage:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP \
    --describe \
    --broker-list 1
session: 1
```

View broker 1 disk usage:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP \
    --describe \
    --broker-list 1
session: 1
```

## Identify Largest Topics

View all partition sizes:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
session: 1
```

## Compare Broker Disk Usage

Compare disk usage across all brokers:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
session: 1
```

## Partition Count per Broker

View partition distribution:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
session: 1
```

## Real-World Scenarios

### Scenario 1: Find Topics to Clean Up

View all topics and their disk usage:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
session: 1
```

### Scenario 2: Pre-Reassignment Check

Before reassigning partitions, check disk usage:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic-list large-topic
session: 1
```

### Scenario 3: Capacity Planning

Monitor current disk usage:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
  echo ""
  echo "Monitor this output over time to track growth patterns"
session: 1
```

## Monitor Disk Usage

View current disk usage:

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
session: 1
```

## Common Patterns

### Pattern 1: Quick Topic Size Check

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe --topic-list orders
session: 1
```

### Pattern 2: Disk Usage Monitoring

```terminal:execute
command: |
  kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
session: 1
```

## Summary

You now know how to:
- ✅ Analyze disk usage for all topics and brokers
- ✅ Filter by specific topics or brokers
- ✅ Identify largest topics and partitions
- ✅ Compare disk usage across brokers
- ✅ Calculate total cluster storage
- ✅ Monitor disk usage trends
- ✅ Plan capacity and storage needs

## Next Steps

Next, we'll learn **kafka-configs** for dynamic configuration management without broker restarts.
