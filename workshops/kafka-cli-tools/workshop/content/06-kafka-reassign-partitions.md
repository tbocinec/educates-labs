# kafka-reassign-partitions - Partition Rebalancing

The `kafka-reassign-partitions` tool moves partitions between brokers for load balancing and cluster maintenance.

## Use Cases

- **Load balancing**: Redistribute partitions across brokers
- **Broker decommissioning**: Move partitions off a broker before shutdown
- **New broker integration**: Rebalance after adding brokers to cluster
- **Performance optimization**: Fix uneven partition distribution
- **Increase replication factor**: Add replicas for higher availability

## Basic Syntax

```bash
kafka-reassign-partitions --bootstrap-server <brokers> <action> [options]
```

**Actions:**
- `--generate` - Generate reassignment plan
- `--execute` - Execute reassignment plan
- `--verify` - Check reassignment status

## Current Partition Distribution

First, examine current partition layout:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic reassign-demo \
    --partitions 12 \
    --replication-factor 2 --if-not-exists
session: 1
```

View partition distribution:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic reassign-demo
session: 1
```

**Output shows:**
- `Leader` - Broker handling reads/writes
- `Replicas` - Brokers hosting replicas
- `Isr` - In-Sync Replicas

## Generate Reassignment Plan

Create a JSON file with topics to rebalance:

```terminal:execute
command: |
  printf '{"topics":[{"topic":"reassign-demo"}],"version":1}' > /tmp/topics-to-move.json
  cat /tmp/topics-to-move.json
session: 1
```

Generate reassignment plan across all brokers:

```terminal:execute
command: |
  kafka-reassign-partitions --bootstrap-server $BOOTSTRAP \
    --topics-to-move-json-file /tmp/topics-to-move.json \
    --broker-list "1,2,3" \
    --generate
session: 1
```

**Output contains:**
1. **Current Partition Replica Assignment** - Backup of current state
2. **Proposed Partition Reassignment Configuration** - New distribution plan

> Save the current assignment as backup before executing!

## Execute Reassignment

Create reassignment plan file:

```terminal:execute
command: |
  echo '{"version":1,"partitions":[' > /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":0,"replicas":[2,3],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":1,"replicas":[3,1],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":2,"replicas":[1,2],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":3,"replicas":[2,3],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":4,"replicas":[3,1],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":5,"replicas":[1,2],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":6,"replicas":[2,3],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":7,"replicas":[3,1],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":8,"replicas":[1,2],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":9,"replicas":[2,3],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":10,"replicas":[3,1],"log_dirs":["any","any"]},' >> /tmp/reassignment-plan.json
  echo '{"topic":"reassign-demo","partition":11,"replicas":[1,2],"log_dirs":["any","any"]}]}' >> /tmp/reassignment-plan.json
session: 1
```

Execute the plan:

```terminal:execute
command: |
  kafka-reassign-partitions --bootstrap-server $BOOTSTRAP \
    --reassignment-json-file /tmp/reassignment-plan.json \
    --execute
session: 1
```

Verify reassignment status:

```terminal:execute
command: |
  kafka-reassign-partitions --bootstrap-server $BOOTSTRAP \
    --reassignment-json-file /tmp/reassignment-plan.json \
    --verify
session: 1
```

## Increase Replication Factor

Change replication factor from 2 to 3:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic rf-demo \
    --partitions 3 \
    --replication-factor 2 --if-not-exists
session: 1
```

Check current RF:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic rf-demo | grep ReplicationFactor
session: 1
```

Increase to RF=3:

```terminal:execute
command: |
  echo '{"version":1,"partitions":[' > /tmp/increase-rf.json
  echo '{"topic":"rf-demo","partition":0,"replicas":[1,2,3],"log_dirs":["any","any","any"]},' >> /tmp/increase-rf.json
  echo '{"topic":"rf-demo","partition":1,"replicas":[2,3,1],"log_dirs":["any","any","any"]},' >> /tmp/increase-rf.json
  echo '{"topic":"rf-demo","partition":2,"replicas":[3,1,2],"log_dirs":["any","any","any"]}]}' >> /tmp/increase-rf.json
  
  kafka-reassign-partitions --bootstrap-server $BOOTSTRAP \
    --reassignment-json-file /tmp/increase-rf.json \
    --execute
session: 1
```

Verify new RF:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --describe \
    --topic rf-demo
session: 1
```

## Broker Decommissioning

Move all partitions off broker 3:

```terminal:execute
command: |
  printf '{"topics":[{"topic":"reassign-demo"},{"topic":"large-topic"}],"version":1}' > /tmp/topics-to-move.json
  
  # Generate plan excluding broker 3
  kafka-reassign-partitions --bootstrap-server $BOOTSTRAP \
    --topics-to-move-json-file /tmp/topics-to-move.json \
    --broker-list "1,2" \
    --generate
session: 1
```

> Use the proposed plan to move all partitions to brokers 1 and 2

## Common Errors

### Error: Reassignment Already in Progress

```
ERROR: A reassignment is already in progress
```

**Fix:** Wait for current reassignment to complete, check with `--verify`

### Error: Invalid Broker ID

```
ERROR: Broker 5 does not exist
```

**Fix:** Verify broker IDs with `kafka-broker-api-versions`

### Error: Replication Factor Too High

```
ERROR: Replication factor cannot exceed number of brokers
```

**Fix:** Ensure replica count doesn't exceed available brokers

## Best Practices

### 1. Always Backup Current Assignment

Save the "Current Partition Replica Assignment" from `--generate` output before executing.

### 2. Use Throttling in Production

```bash
--throttle 50000000  # 50 MB/s
```

### 3. Monitor Progress

Regularly run `--verify` to check reassignment status.

### 4. Reassign During Low Traffic

Schedule reassignments during off-peak hours to minimize impact.

### 5. Test on Non-Critical Topics First

Validate your reassignment process on test topics before touching production data.

## Summary

You now know how to:
- ✅ Generate partition reassignment plans
- ✅ Execute reassignments with throttling
- ✅ Verify reassignment progress
- ✅ Increase replication factor
- ✅ Decommission brokers safely
- ✅ Balance partition distribution across cluster

## Next Steps

Next, we'll learn **kafka-log-dirs** to analyze disk usage and plan capacity.
