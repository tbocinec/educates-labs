# kafka-consumer-groups - Consumer Group Management

The `kafka-consumer-groups` tool manages consumer groups, monitors lag, and resets offsets.

## What are Consumer Groups?

Consumer groups enable:
- **Parallel processing**: Multiple consumers process partitions simultaneously
- **Load balancing**: Partitions automatically distributed across consumers
- **Fault tolerance**: Automatic rebalancing when consumers join/leave
- **Progress tracking**: Committed offsets track processing state

## Use Cases

- **Lag monitoring**: Identify slow consumers falling behind
- **Offset reset**: Replay messages or skip ahead
- **Debugging**: Investigate consumer issues
- **Cleanup**: Remove inactive consumer groups

## Basic Syntax

```bash
kafka-consumer-groups --bootstrap-server <brokers> <action> [options]
```

## List Consumer Groups

Show all consumer groups in the cluster:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP --list
session: 1
```

## Describe Consumer Group

View detailed information about a specific group:

First, create a demo scenario:

```terminal:execute
command: |
  # Create topic
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic consumer-demo \
    --partitions 6 \
    --replication-factor 2 --if-not-exists
  
  # Send 50 messages
  for i in {1..50}; do
    echo "Message $i - $(date +%s)"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic consumer-demo
  
  echo "✓ Sent 50 messages"
session: 1
```

Start a consumer that reads only 30 messages:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic consumer-demo \
    --group demo-group \
    --from-beginning \
    --max-messages 30 \
    --timeout-ms 5000
session: 1
```

Now describe the consumer group to see lag:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --describe
session: 1
```

**Output columns:**
- `CURRENT-OFFSET` - Last offset committed by consumer
- `LOG-END-OFFSET` - Latest offset in partition
- `LAG` - Number of messages behind (LOG-END - CURRENT)
- `CONSUMER-ID` - Active consumer instance (if any)
- `HOST` - Consumer host
- `CLIENT-ID` - Consumer client identifier

## Monitor Consumer Lag

Lag is critical for identifying performance issues:

```terminal:execute
command: |
  # Send more messages to create lag
  for i in {51..150}; do
    echo "Backlog message $i"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic consumer-demo
  
  echo "✓ Sent 100 more messages. Group should now have significant lag."
session: 1
```

Check total lag across all partitions:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --describe | awk 'NR>1 {sum+=$5} END {print "Total LAG:", sum, "messages"}'
session: 1
```

## Consumer Group States

View the state of a consumer group:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --describe \
    --state
session: 1
```

**States:**
- `Empty` - Group exists but has no members
- `Stable` - Group has active consumers, all partitions assigned
- `PreparingRebalance` - Consumer joining/leaving
- `CompletingRebalance` - Rebalance in progress
- `Dead` - No members and metadata expired

## View Group Members

See active consumers in a group:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --describe \
    --members
session: 1
```

If group is Empty, you'll see:
```
Consumer group 'demo-group' has no active members.
```

## Reset Offsets

Resetting offsets allows you to replay or skip messages.

### Reset to Beginning

Replay all messages from the start:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --to-earliest \
    --topic consumer-demo \
    --execute
session: 1
```

> **Important:** Consumer group must be inactive (no running consumers) to reset offsets.

Verify the reset:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --describe
session: 1
```

### Reset to Latest

Skip all existing messages:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --to-latest \
    --topic consumer-demo \
    --execute
session: 1
```

### Reset to Specific Offset

Jump to a specific offset:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --to-offset 10 \
    --topic consumer-demo:0 \
    --execute
session: 1
```

> Format: `topic:partition` to target specific partition

### Shift Offsets Forward/Backward

Move offsets by a relative amount:

```terminal:execute
command: |
  # Shift forward by 5 (skip 5 messages)
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --shift-by 5 \
    --topic consumer-demo \
    --execute
session: 1
```

Shift backward to reprocess:

```terminal:execute
command: |
  # Shift backward by 10 (reprocess last 10 per partition)
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --shift-by -10 \
    --topic consumer-demo \
    --execute
session: 1
```

### Reset by Timestamp

Reset to messages from a specific time:

```terminal:execute
command: |
  # Reset to messages from 5 minutes ago
  TIMESTAMP=$(date -d '5 minutes ago' +%s)000
  
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --to-datetime ${TIMESTAMP} \
    --topic consumer-demo \
    --execute
session: 1
```

### Dry Run

Preview offset reset without applying:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --to-earliest \
    --topic consumer-demo \
    --dry-run
session: 1
```

> Always use `--dry-run` first to verify the reset plan!

## Delete Consumer Group

Remove an inactive consumer group:

```terminal:execute
command: |
  # Create a temporary group
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic consumer-demo \
    --group temp-group \
    --from-beginning \
    --max-messages 5 \
    --timeout-ms 3000
session: 1
```

Delete it:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group temp-group \
    --delete
session: 1
```

> Consumer group must be Empty (no active members) to delete.

## Real-World Scenarios

### Scenario 1: Recover from Poison Message

If a bad message causes consumer to crash:

```terminal:execute
command: |
  # Skip the problematic message by shifting forward
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --shift-by 1 \
    --topic consumer-demo:0 \
    --execute
session: 1
```

### Scenario 2: Reprocess Last Hour

Replay messages from the last hour:

```terminal:execute
command: |
  TIMESTAMP=$(date -d '1 hour ago' +%s)000
  
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --reset-offsets \
    --to-datetime ${TIMESTAMP} \
    --topic consumer-demo \
    --dry-run
session: 1
```

### Scenario 3: Monitor Multiple Groups

Check lag for all groups:

```terminal:execute
command: |
  echo "=== Consumer Group Lag Summary ==="
  for group in $(kafka-consumer-groups --bootstrap-server $BOOTSTRAP --list); do
    echo "Group: $group"
    kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
      --group $group \
      --describe 2>/dev/null | awk 'NR>1 {sum+=$5} END {if (sum>0) print "  Total Lag:", sum}'
  done
session: 1
```

## Lag Alerting

Create a simple lag checker:

```terminal:execute
command: |
  LAG_THRESHOLD=20
  
  TOTAL_LAG=$(kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group demo-group \
    --describe 2>/dev/null | awk 'NR>1 {sum+=$5} END {print sum}')
  
  if [ "$TOTAL_LAG" -gt "$LAG_THRESHOLD" ]; then
    echo "⚠️  ALERT: Consumer group 'demo-group' has lag of $TOTAL_LAG (threshold: $LAG_THRESHOLD)"
  else
    echo "✓ Consumer group 'demo-group' lag is acceptable: $TOTAL_LAG"
  fi
session: 1
```

## Common Errors

### Error: Group is Not Empty

```
Error: Assignments can only be reset if the group 'demo-group' is inactive
```

**Fix:** Stop all consumers in the group before resetting offsets

### Error: Group Does Not Exist

```
Error: Consumer group 'unknown-group' does not exist
```

**Fix:** Verify group name with `--list` command

### Error: Offset Out of Range

After reset, if offset doesn't exist:

**Fix:** Use `--to-earliest` or `--to-latest` to ensure valid offset

## Best Practices

### 1. Always Use Dry-Run First

```bash
--reset-offsets --to-earliest --dry-run
```

### 2. Monitor Lag Regularly

Set up automated lag monitoring and alerting for production consumer groups.

### 3. Document Offset Resets

Log all offset reset operations for audit trail:

```bash
echo "$(date): Reset demo-group to earliest" >> /tmp/offset-resets.log
```

### 4. Stop Consumers Before Reset

Ensure no active consumers before resetting offsets to avoid conflicts.

## Summary

You now know how to:
- ✅ List and describe consumer groups
- ✅ Monitor consumer lag across partitions
- ✅ Check consumer group state and members
- ✅ Reset offsets (earliest, latest, specific, by timestamp)
- ✅ Delete inactive consumer groups
- ✅ Implement lag monitoring and alerting
- ✅ Handle common offset management scenarios

## Next Steps

Next, we'll learn **kafka-reassign-partitions** for rebalancing partitions across brokers.
