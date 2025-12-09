# kafka-leader-election & kafka-replica-verification

Tools for managing partition leaders and verifying replication integrity.

## What is Replication Management?

Kafka maintains multiple replicas of each partition:
- **1 Leader** - Handles all reads and writes
- **N-1 Followers** - Replicate data from leader
- **ISR (In-Sync Replicas)** - Replicas caught up with leader

**Common issues:**
- Unbalanced leader distribution after broker restarts
- Out-of-sync replicas
- Performance degradation from poor leader placement

## Leader Election Tool

### Use Cases

- **Post-restart rebalancing**: Redistribute leaders after broker restart
- **Performance optimization**: Balance load across brokers
- **Planned maintenance**: Rebalance before taking broker offline

### Basic Syntax

```bash
kafka-leader-election --bootstrap-server <brokers> --election-type <type> [options]
```

**Election Types:**
- `PREFERRED` - Elect preferred (first in replica list)
- `UNCLEAN` - Allow non-ISR replica (data loss risk!)

## Check Current Leader Distribution

Create test topic:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic leader-demo \
    --partitions 12 \
    --replication-factor 3 --if-not-exists
session: 1
```

View leader distribution:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic leader-demo | grep "Leader:"
session: 1
```

Count leaders per broker:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic leader-demo | \
    grep "Leader:" | awk '{print $4}' | sort | uniq -c
session: 1
```

**Ideal:** Leaders evenly distributed (4 per broker for 12 partitions / 3 brokers)

## Preferred Leader Election

Elect preferred leaders to rebalance:

```terminal:execute
command: |
  kafka-leader-election --bootstrap-server $BOOTSTRAP \
    --election-type PREFERRED \
    --all-topic-partitions
  
  echo "✓ Leader election complete"
session: 1
```

Verify rebalancing:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic leader-demo | \
    grep "Leader:" | awk '{print $4}' | sort | uniq -c
session: 1
```

## Election for Specific Topic

Rebalance only one topic:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic critical-topic \
    --partitions 6 \
    --replication-factor 3 --if-not-exists
  
  kafka-leader-election --bootstrap-server $BOOTSTRAP \
    --election-type PREFERRED \
    --topic critical-topic
  
  echo "✓ critical-topic leaders rebalanced"
session: 1
```

## Analyze Leader Distribution

Create analysis script:

```terminal:execute
command: |
  {
    echo '#!/bin/bash'
    echo 'echo "=== Leader Distribution Analysis ==="'
    echo 'kafka-topics --bootstrap-server kafka-1:19092,kafka-2:19092,kafka-3:19092 --describe | \\'
    echo '  grep "Leader:" | awk '\'''{print $4}'\''' | sort | uniq -c | \\'
    echo '  awk '\'''{print "Broker", $2, "has", $1, "leaders"}'\'''
  } > /tmp/analyze-leaders.sh
  
  chmod +x /tmp/analyze-leaders.sh
  bash /tmp/analyze-leaders.sh
session: 1
```

## Unclean Leader Election

> **WARNING:** Only use in emergency! Risk of data loss!

**Scenario:** All ISR replicas are down, cluster is stuck

**DO NOT run this in demo:**
```bash
# EMERGENCY ONLY - when all ISR replicas are unavailable
kafka-leader-election --bootstrap-server $BOOTSTRAP \
  --election-type UNCLEAN \
  --topic stuck-topic \
  --partition 0
```

**Risks:**
- Data loss (non-ISR replica may be behind)
- Message duplication possible
- Violates durability guarantees

**Use only when:**
- All ISR replicas are permanently lost
- Availability is more critical than consistency
- You accept potential data loss

## Replica Verification

### kafka-replica-verification Tool

Verifies data integrity across replicas.

### Use Cases

- **Data integrity audit**: Ensure replicas are identical
- **Post-failure check**: Verify recovery after broker failure
- **Performance troubleshooting**: Identify lagging replicas

### Run Replica Verification

```terminal:execute
command: |
  kafka-replica-verification --bootstrap-server $BOOTSTRAP \
    --topic-white-list 'leader-demo' \
    --report-interval-ms 5000
  
  echo "✓ Verification complete"
session: 1
```

> Ctrl+C to stop after a few seconds

**Output shows:**
- Max lag across replicas
- Number of partitions with lag
- Specific partition issues

## Verify Specific Topic

```terminal:execute
command: |
  timeout 10 kafka-replica-verification --bootstrap-server $BOOTSTRAP \
    --topic-white-list 'critical-topic' \
    --report-interval-ms 3000 || echo "✓ Verification completed"
session: 1
```

## Monitor ISR Status

Check which replicas are in-sync:

```terminal:execute
command: |
  echo "=== ISR Status ==="
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic leader-demo | \
    awk '/Partition:/ {print "Partition", $2, "- Replicas:", $6, "ISR:", $8}'
session: 1
```

**Healthy:** Replicas == ISR  
**Problem:** ISR < Replicas (some replicas out of sync)

## Detect Out-of-Sync Replicas

Find partitions with ISR problems:

```terminal:execute
command: |
  echo "=== Checking for out-of-sync replicas ==="
  kafka-topics --bootstrap-server $BOOTSTRAP --describe | \
    awk '/Partition:/ {
      replicas = split($6, r, ",");
      isr = split($8, i, ",");
      if (replicas != isr) {
        print "⚠️  Topic:",$4, "Partition:",$2, "- OSR detected!";
        print "   Replicas:", $6, "ISR:", $8
      }
    }' || echo "✓ All replicas in sync"
session: 1
```

## Real-World Scenarios

### Scenario 1: Post-Restart Rebalancing

After broker restart, rebalance leaders:

```terminal:execute
command: |
  echo "Simulating post-restart rebalancing..."
  
  # Check current distribution
  echo "Before:"
  kafka-topics --bootstrap-server $BOOTSTRAP --describe --topic leader-demo | \
    grep "Leader:" | awk '{print $4}' | sort | uniq -c
  
  # Rebalance
  kafka-leader-election --bootstrap-server $BOOTSTRAP \
    --election-type PREFERRED \
    --all-topic-partitions
  
  # Check new distribution
  echo "After:"
  kafka-topics --bootstrap-server $BOOTSTRAP --describe --topic leader-demo | \
    grep "Leader:" | awk '{print $4}' | sort | uniq -c
session: 1
```

### Scenario 2: Performance Optimization

Identify and fix unbalanced leaders:

```terminal:execute
command: |
  echo "=== Leader Balance Check ==="
  kafka-topics --bootstrap-server $BOOTSTRAP --describe | \
    grep "Leader:" | awk '{print $4}' | sort | uniq -c | \
    awk '{
      if ($1 > threshold) print "⚠️  Broker", $2, "has", $1, "leaders (high)";
      else if ($1 < threshold) print "⚠️  Broker", $2, "has", $1, "leaders (low)";
      else print "✓ Broker", $2, "has", $1, "leaders (balanced)";
    }' threshold=4
session: 1
```

### Scenario 3: Monitoring Leader Changes

Track leader election events:

```terminal:execute
command: |
  echo "Before election:"
  kafka-topics --bootstrap-server $BOOTSTRAP --describe --topic critical-topic | \
    grep "Leader:" > /tmp/leaders-before.txt
  
  kafka-leader-election --bootstrap-server $BOOTSTRAP \
    --election-type PREFERRED \
    --topic critical-topic
  
  echo "After election:"
  kafka-topics --bootstrap-server $BOOTSTRAP --describe --topic critical-topic | \
    grep "Leader:" > /tmp/leaders-after.txt
  
  echo "Changes:"
  diff /tmp/leaders-before.txt /tmp/leaders-after.txt || echo "No leader changes"
session: 1
```

## Best Practices

### 1. Regular Leader Rebalancing

Schedule preferred leader election during maintenance windows:
```bash
# Cron job example
0 2 * * 0 kafka-leader-election --bootstrap-server $BOOTSTRAP --election-type PREFERRED --all-topic-partitions
```

### 2. Monitor ISR

Set up alerts when replicas fall out of ISR:
```bash
# Check for OSR (Out-of-Sync Replicas)
if [ $(kafka-topics --describe | grep "Isr: " | wc -l) -gt 0 ]; then
  alert "OSR detected!"
fi
```

### 3. Avoid Unclean Elections

Configure brokers to prevent unclean elections:
```properties
unclean.leader.election.enable=false
```

### 4. Verify After Changes

Always run replica verification after major changes:
```bash
kafka-replica-verification --topic-white-list '.*'
```

## Summary

You now know how to:
- ✅ Check and analyze leader distribution
- ✅ Perform preferred leader elections
- ✅ Verify replica consistency
- ✅ Monitor ISR status
- ✅ Detect out-of-sync replicas
- ✅ Rebalance leaders for performance
- ✅ Understand unclean election risks

## Next Steps

Next, we'll learn **advanced debugging tools** like kafka-dump-log, kafka-get-offsets, and kafka-delete-records.
