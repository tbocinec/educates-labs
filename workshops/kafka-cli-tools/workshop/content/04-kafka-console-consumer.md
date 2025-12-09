# kafka-console-consumer - Reading Messages

The `kafka-console-consumer` tool reads messages from Kafka topics for testing, debugging, and monitoring.

## Use Cases

- **Verification**: Confirm producers are writing messages correctly
- **Debugging**: Inspect message content and formatting
- **Monitoring**: Watch live data flow through topics
- **Testing**: Validate consumer configurations

## Basic Syntax

```bash
kafka-console-consumer --bootstrap-server <brokers> --topic <topic-name> [options]
```

**Key Parameters:**
- `--from-beginning` - Read from oldest offset (default: only new messages)
- `--max-messages` - Limit number of messages to consume
- `--partition` - Read from specific partition
- `--offset` - Start from specific offset
- `--group` - Consumer group ID
- `--timeout-ms` - Auto-exit after timeout with no messages

## Read from Beginning

Read all existing messages:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic messages \
    --from-beginning \
    --max-messages 10 \
    --timeout-ms 5000
session: 1
```

> Without `--from-beginning`, you'll only see new messages published after the consumer starts.

## Read Only New Messages

Start a consumer that waits for new messages:

```terminal:execute
command: |
  # This will timeout after 5 seconds if no new messages arrive
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic messages \
    --max-messages 3 \
    --timeout-ms 5000
session: 1
```

Now publish new messages in another terminal and the consumer will catch them.

## Reading with Keys

Display message keys along with values:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --from-beginning \
    --property print.key=true \
    --property key.separator=" => " \
    --timeout-ms 5000
session: 1
```

Output format:
```
user123 => login
user456 => signup
user123 => page_view
```

## Display Timestamps

Show when each message was created:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --from-beginning \
    --property print.timestamp=true \
    --property print.key=true \
    --property key.separator=" => " \
    --max-messages 5 \
    --timeout-ms 5000
session: 1
```

Output format:
```
CreateTime:1702131200000   user123 => login
CreateTime:1702131201000   user456 => signup
```

## Display Partition and Offset

See which partition and offset each message came from:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --from-beginning \
    --property print.partition=true \
    --property print.offset=true \
    --property print.key=true \
    --max-messages 5 \
    --timeout-ms 5000
session: 1
```

Output format:
```
Partition:0 Offset:15 user123 => login
Partition:1 Offset:8  user456 => signup
Partition:0 Offset:16 user123 => page_view
```

## Read Specific Partition

Read only from partition 0:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --partition 0 \
    --from-beginning \
    --timeout-ms 5000
session: 1
```

**Use case:** Debugging partition-specific issues or verifying key-based routing

## Read from Specific Offset

Start reading from offset 10 in partition 0:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --partition 0 \
    --offset 10 \
    --max-messages 5
session: 1
```

## Consumer Groups

Create a consumer group to track reading progress:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic messages \
    --group my-consumer-group \
    --from-beginning \
    --max-messages 20 \
    --timeout-ms 5000
session: 1
```

Check the consumer group's progress:

```terminal:execute
command: |
  kafka-consumer-groups --bootstrap-server $BOOTSTRAP \
    --group my-consumer-group \
    --describe
session: 1
```

> Consumer groups automatically track offsets. Restarting the consumer with the same group ID will continue from where it left off.

## Filtering with grep

Combine with shell tools for filtering:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic orders \
    --from-beginning \
    --timeout-ms 5000 | grep "pending"
session: 1
```

Count messages:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic messages \
    --from-beginning \
    --timeout-ms 3000 | wc -l
session: 1
```

## JSON Message Inspection

Read JSON messages:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic orders \
    --from-beginning \
    --max-messages 3 \
    --timeout-ms 3000
session: 1
```

## Performance: Fetch Size

For high-throughput topics, increase fetch size:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic load-test \
    --from-beginning \
    --max-messages 100 \
    --timeout-ms 5000 \
    --property fetch.min.bytes=1048576
session: 1
```

**Properties:**
- `fetch.min.bytes` - Minimum data per fetch (default: 1 byte)
- `fetch.max.wait.ms` - Max wait time for fetch.min.bytes (default: 500ms)
- `max.partition.fetch.bytes` - Max data per partition (default: 1MB)

## Common Errors

### Error: Offset Out of Range

```
ERROR: Offset out of range
```

**Cause:** Requested offset was deleted due to retention policy

**Fix:** Use `--from-beginning` or valid offset range

### Error: Unknown Topic

```
ERROR: Topic 'xyz' does not exist
```

**Fix:** Verify topic name and create if needed

### Error: Authorization Failed

```
ERROR: Not authorized to access topic
```

**Fix:** Check ACLs (covered in Level 9)

## Real-World Scenarios

### Monitor Production Traffic

Watch live messages (Ctrl+C to stop):

```terminal:execute
command: |
  timeout 10 kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic user-events \
    --property print.timestamp=true \
    --property print.key=true || echo "Stopped monitoring"
session: 1
```

### Verify Producer Changes

After deploying producer changes, verify message format:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic orders \
    --max-messages 1 \
    --timeout-ms 3000
session: 1
```

### Count Messages in Topic

```terminal:execute
command: |
  echo "Counting messages in topic..."
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic messages \
    --from-beginning \
    --timeout-ms 5000 2>/dev/null | wc -l
session: 1
```

## Consumer Properties Comparison

| Use Case | Properties |
|----------|-----------|
| **Quick inspection** | `--from-beginning --max-messages 10` |
| **Live monitoring** | No `--from-beginning`, no `--max-messages` |
| **Debugging specific partition** | `--partition 0 --from-beginning` |
| **High throughput** | `--property fetch.min.bytes=1048576` |
| **Offset tracking** | `--group <group-id>` |

## Summary

You now know how to:
- ✅ Read messages from beginning or only new ones
- ✅ Display keys, timestamps, partitions, and offsets
- ✅ Read from specific partitions or offsets
- ✅ Use consumer groups to track progress
- ✅ Filter and process messages with shell tools
- ✅ Monitor live traffic

## Next Steps

Next, we'll learn **kafka-consumer-groups** to manage consumer group offsets and monitor lag.
