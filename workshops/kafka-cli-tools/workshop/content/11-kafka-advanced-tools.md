# Advanced Kafka Tools

Low-level tools for debugging, compliance, and operational tasks.

## What are Advanced Tools?

Beyond standard producer/consumer operations, Kafka provides specialized tools for:
- **Debugging**: Inspect raw log segments
- **Compliance**: Delete records for GDPR/data retention
- **Capacity Planning**: Analyze offset growth
- **Upgrades**: Check API version compatibility

## kafka-dump-log - Inspect Log Segments

### Use Cases

- **Corruption investigation**: Examine damaged log files
- **Performance analysis**: Understand compression ratios
- **Message inspection**: View raw binary data
- **Index debugging**: Verify offset index integrity

### Basic Syntax

```bash
kafka-dump-log --files <log-file> [--print-data-log] [--deep-iteration]
```

## Find Log Files

Kafka stores data in `/var/lib/kafka/data` (in container):

```terminal:execute
command: |
  echo "=== Log Directories ==="
  ls -lh /var/lib/kafka/data/
session: 1
```

Create test topic to inspect:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic debug-demo \
    --partitions 1 \
    --replication-factor 1 --if-not-exists
  
  # Produce some messages
  echo -e "msg1\nmsg2\nmsg3" | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic debug-demo
  
  echo "✓ Test data created"
session: 1
```

## Dump Log Metadata

View log segment metadata:

```terminal:execute
command: |
  LOG_FILE=$(ls /var/lib/kafka/data/debug-demo-0/*.log | head -1)
  echo "Inspecting: $LOG_FILE"
  echo "---"
  
  kafka-dump-log --files $LOG_FILE
session: 1
```

**Output shows:**
- Starting offset
- Position in file
- CreateTime timestamp
- Key/value sizes

## Dump with Message Content

Print actual message data:

```terminal:execute
command: |
  LOG_FILE=$(ls /var/lib/kafka/data/debug-demo-0/*.log | head -1)
  
  kafka-dump-log --files $LOG_FILE \
    --print-data-log
session: 1
```

## Deep Iteration Mode

Validate all records and indexes:

```terminal:execute
command: |
  LOG_FILE=$(ls /var/lib/kafka/data/debug-demo-0/*.log | head -1)
  
  kafka-dump-log --files $LOG_FILE \
    --deep-iteration
  
  echo "✓ Deep validation complete"
session: 1
```

**Deep iteration:**
- Reads every byte
- Validates checksums
- Detects corruption early

## Inspect Index Files

View offset index:

```terminal:execute
command: |
  INDEX_FILE=$(ls /var/lib/kafka/data/debug-demo-0/*.index | head -1)
  echo "Offset Index: $INDEX_FILE"
  
  kafka-dump-log --files $INDEX_FILE
session: 1
```

View time index:

```terminal:execute
command: |
  TIME_INDEX=$(ls /var/lib/kafka/data/debug-demo-0/*.timeindex | head -1)
  echo "Time Index: $TIME_INDEX"
  
  kafka-dump-log --files $TIME_INDEX
session: 1
```

## Analyze Compression

Check compression effectiveness:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic compressed-demo \
    --partitions 1 \
    --replication-factor 1 \
    --config compression.type=gzip --if-not-exists
  
  # Produce compressible data
  for i in {1..100}; do
    echo "This is a repeating message number $i"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic compressed-demo
  
  LOG_FILE=$(ls /var/lib/kafka/data/compressed-demo-0/*.log | head -1)
  kafka-dump-log --files $LOG_FILE --print-data-log | grep "compression codec" | head -5
session: 1
```

## kafka-delete-records - GDPR Compliance

### Use Cases

- **GDPR compliance**: Delete personal data on request
- **Data retention**: Remove old records before retention expires
- **Testing**: Clean test data without recreating topics
- **Compliance audits**: Implement right-to-be-forgotten

### Basic Syntax

```bash
kafka-delete-records --bootstrap-server <brokers> --offset-json-file <json>
```

## Create Test Data

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic gdpr-demo \
    --partitions 2 \
    --replication-factor 1 --if-not-exists
  
  # Produce 10 messages
  for i in {1..10}; do
    echo "user-data-$i"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic gdpr-demo
  
  echo "✓ 10 messages produced"
session: 1
```

Verify data:

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic gdpr-demo \
    --from-beginning \
    --max-messages 10 \
    --timeout-ms 3000
session: 1
```

## Delete Records Before Offset

Create deletion specification:

```terminal:execute
command: |
  printf '{"partitions":[{"topic":"gdpr-demo","partition":0,"offset":5},{"topic":"gdpr-demo","partition":1,"offset":5}],"version":1}' > /tmp/delete-records.json
  
  cat /tmp/delete-records.json
session: 1
```

Execute deletion:

```terminal:execute
command: |
  kafka-delete-records --bootstrap-server $BOOTSTRAP \
    --offset-json-file /tmp/delete-records.json
  
  echo "✓ Records deleted"
session: 1
```

Verify deletion (earlier messages gone):

```terminal:execute
command: |
  kafka-console-consumer --bootstrap-server $BOOTSTRAP \
    --topic gdpr-demo \
    --from-beginning \
    --max-messages 10 \
    --timeout-ms 3000
session: 1
```

**Note:** Offsets 0-4 are now inaccessible. Consumer starts from offset 5.

## Delete All Records in Partition

Delete everything by setting offset to -1:

```terminal:execute
command: |
  printf '{"partitions":[{"topic":"gdpr-demo","partition":0,"offset":-1}],"version":1}' > /tmp/delete-all.json
  
  kafka-delete-records --bootstrap-server $BOOTSTRAP \
    --offset-json-file /tmp/delete-all.json
  
  echo "✓ Partition 0 truncated"
session: 1
```

## kafka-get-offsets - Capacity Planning

### Use Cases

- **Capacity planning**: Calculate daily message rates
- **Lag analysis**: Compare consumer position to latest offset
- **Growth monitoring**: Track topic size over time
- **Retention planning**: Estimate storage needs

### Basic Syntax

```bash
kafka-get-offsets --bootstrap-server <brokers> --topic <topic>
```

## Get Latest Offsets

Create topic with known message count:

```terminal:execute
command: |
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic metrics-demo \
    --partitions 3 \
    --replication-factor 1 --if-not-exists
  
  # Produce 30 messages (10 per partition)
  for i in {1..30}; do
    echo "metric-$i"
  done | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic metrics-demo
  
  echo "✓ 30 messages produced"
session: 1
```

Get current end offsets:

```terminal:execute
command: |
  kafka-get-offsets --bootstrap-server $BOOTSTRAP \
    --topic metrics-demo
session: 1
```

**Output format:** `topic:partition:offset`

## Get Earliest Offsets

```terminal:execute
command: |
  kafka-get-offsets --bootstrap-server $BOOTSTRAP \
    --topic metrics-demo \
    --time -2
session: 1
```

**Time values:**
- `-1` = latest (default)
- `-2` = earliest
- Timestamp in milliseconds

## Calculate Message Count

Count messages in topic:

```terminal:execute
command: |
  echo "=== Message Count Analysis ==="
  
  EARLIEST=$(kafka-get-offsets --bootstrap-server $BOOTSTRAP --topic metrics-demo --time -2)
  LATEST=$(kafka-get-offsets --bootstrap-server $BOOTSTRAP --topic metrics-demo --time -1)
  
  echo "Earliest offsets:"
  echo "$EARLIEST"
  echo ""
  echo "Latest offsets:"
  echo "$LATEST"
  
  # Calculate total (manual for demo)
  TOTAL=$(echo "$LATEST" | awk -F':' '{sum+=$3} END {print sum}')
  echo ""
  echo "Total messages: $TOTAL"
session: 1
```

## Get Offsets at Specific Time

Find offset 5 minutes ago:

```terminal:execute
command: |
  # Current time minus 5 minutes (in milliseconds)
  TIMESTAMP=$(($(date +%s) * 1000 - 300000))
  
  echo "Offsets 5 minutes ago:"
  kafka-get-offsets --bootstrap-server $BOOTSTRAP \
    --topic metrics-demo \
    --time $TIMESTAMP
session: 1
```

**Use case:** Compare offset growth over time windows

## Monitor Topic Growth

Create growth monitoring script:

```terminal:execute
command: |
  {
    echo '#!/bin/bash'
    echo 'TOPIC="metrics-demo"'
    echo 'BOOTSTRAP="kafka-1:19092,kafka-2:19092,kafka-3:19092"'
    echo ''
    echo 'echo "=== Topic Growth Monitor ==="'
    echo 'echo "$(date): Starting measurement"'
    echo ''
    echo 'BEFORE=$(kafka-get-offsets --bootstrap-server $BOOTSTRAP --topic $TOPIC | \\'
    echo '  awk -F'\''':'\'''' '\'''{sum+=$3} END {print sum}'\''')'
    echo ''
    echo 'echo "Current total: $BEFORE messages"'
    echo 'echo "Checking again in 5 seconds..."'
    echo ''
    echo 'AFTER=$(kafka-get-offsets --bootstrap-server $BOOTSTRAP --topic $TOPIC | \\'
    echo '  awk -F'\''':'\'''' '\'''{sum+=$3} END {print sum}'\''')'
    echo ''
    echo 'GROWTH=$((AFTER - BEFORE))'
    echo 'RATE=$((GROWTH / 10))'
    echo ''
    echo 'echo "New total: $AFTER messages"'
    echo 'echo "Growth: $GROWTH messages in 10s"'
    echo 'echo "Rate: ~$RATE msg/sec"'
  } > /tmp/monitor-growth.sh
  
  chmod +x /tmp/monitor-growth.sh
session: 1
```

Run growth monitor:

```terminal:execute
command: |
  # Produce messages
  for i in {1..50}; do echo "data-$i"; done | \
    kafka-console-producer --bootstrap-server $BOOTSTRAP --topic metrics-demo
  
  echo "✓ Messages produced"
session: 1
```

## kafka-broker-api-versions - Upgrade Planning

### Use Cases

- **Upgrade compatibility**: Check if clients support new APIs
- **Feature discovery**: Find available broker features
- **Version audit**: Verify cluster API versions
- **Client validation**: Ensure client library compatibility

### Check Broker API Versions

```terminal:execute
command: |
  kafka-broker-api-versions --bootstrap-server $BOOTSTRAP
session: 1
```

**Output shows:**
- API key names (Produce, Fetch, Metadata, etc.)
- Min/Max supported versions
- Broker version compatibility

## Check Specific Broker

```terminal:execute
command: |
  kafka-broker-api-versions --bootstrap-server kafka-1:19092
session: 1
```

## Real-World Scenarios

### Scenario 1: GDPR Data Deletion

User requests deletion of their data:

```terminal:execute
command: |
  # Step 1: Find user's messages (simplified - use consumer to find offsets)
  kafka-topics --bootstrap-server $BOOTSTRAP \
    --create \
    --topic user-events \
    --partitions 1 \
    --replication-factor 1 --if-not-exists
  
  echo -e "user-123-event\nother-event\nuser-123-event" | kafka-console-producer --bootstrap-server $BOOTSTRAP --topic user-events
  
  # Step 2: Delete records up to found offset
  printf '{"partitions":[{"topic":"user-events","partition":0,"offset":2}],"version":1}' > /tmp/gdpr-delete.json
  
  kafka-delete-records --bootstrap-server $BOOTSTRAP \
    --offset-json-file /tmp/gdpr-delete.json
  
  echo "✓ User data deleted per GDPR request"
session: 1
```

### Scenario 2: Capacity Planning

Calculate daily message rate:

```terminal:execute
command: |
  TOPIC="metrics-demo"
  
  # Get current offset
  CURRENT=$(kafka-get-offsets --bootstrap-server $BOOTSTRAP --topic $TOPIC | \
    awk -F':' '{sum+=$3} END {print sum}')
  
  # Get offset 1 hour ago (simulate with current)
  HOUR_AGO=$CURRENT
  
  HOURLY_RATE=$((CURRENT - HOUR_AGO))
  DAILY_ESTIMATE=$((HOURLY_RATE * 24))
  
  echo "=== Capacity Planning ==="
  echo "Current offset: $CURRENT"
  echo "Hourly rate: $HOURLY_RATE msg/hr"
  echo "Daily estimate: $DAILY_ESTIMATE msg/day"
  echo "Monthly estimate: $((DAILY_ESTIMATE * 30)) msg/month"
session: 1
```

### Scenario 3: Log Corruption Investigation

Investigate corrupted log segment:

```terminal:execute
command: |
  # Find largest log file
  LARGEST_LOG=$(ls -lS /var/lib/kafka/data/*/*.log 2>/dev/null | head -2 | tail -1 | awk '{print $NF}')
  
  if [ -n "$LARGEST_LOG" ]; then
    echo "Investigating: $LARGEST_LOG"
    echo "---"
    
    # Deep iteration to check for corruption
    kafka-dump-log --files $LARGEST_LOG \
      --deep-iteration 2>&1 | head -20
    
    echo "✓ Corruption check complete"
  else
    echo "No log files found (normal for new cluster)"
  fi
session: 1
```

## Best Practices

### 1. Backup Before Deletion

Always backup before using kafka-delete-records:
```bash
# Export data first
kafka-console-consumer --topic critical-topic --from-beginning > backup.txt

# Then delete
kafka-delete-records --offset-json-file delete.json
```

### 2. Monitor Offset Growth

Set up automated monitoring:
```bash
# Daily capacity report
kafka-get-offsets --topic important-topic >> /var/log/kafka-capacity.log
```

### 3. Validate Deletions

After deleting records, verify earliest offset:
```bash
kafka-get-offsets --topic gdpr-topic --time -2
```

### 4. Use Deep Iteration for Audits

Periodic corruption checks:
```bash
# Weekly log validation
find /var/lib/kafka/data -name "*.log" -exec kafka-dump-log --deep-iteration --files {} \;
```

## Summary

You now know how to:
- ✅ Inspect raw log segments with kafka-dump-log
- ✅ Validate log integrity with deep iteration
- ✅ Delete records for GDPR compliance
- ✅ Calculate message counts and growth rates
- ✅ Monitor topic capacity with kafka-get-offsets
- ✅ Check API version compatibility
- ✅ Investigate log corruption
- ✅ Plan storage capacity

## Next Steps

Congratulations! You've completed all 11 Kafka CLI tools. Review the workshop summary for a complete overview of everything you've learned.
