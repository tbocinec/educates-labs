# Kafka UI Exploration

Master visual monitoring, troubleshooting, and management using Kafka UI.

---

## 🎯 What You'll Learn

- Navigate Kafka UI interface
- Monitor consumer groups and lag
- Inspect messages and partitions
- Troubleshoot common issues
- Manage topics and configurations

---

## Access Kafka UI

Open Kafka UI in your browser:

**URL:** http://localhost:8080

```dashboard:create-dashboard
name: Kafka UI
url: http://localhost:8080
```

You should see the Kafka UI dashboard with cluster overview.

---

## Dashboard Overview

The main dashboard shows:

- **Cluster Health** - Broker status, uptime
- **Topics** - Total topics and partitions
- **Consumer Groups** - Active groups
- **Messages** - Total message count
- **Disk Usage** - Storage utilization

---

## Exploring Topics

### 1. Navigate to Topics

Click **Topics** in the left sidebar.

You should see:
- `humidity_readings` - Main topic (3 partitions)
- `humidity_readings_dlq` - Dead letter queue
- `__consumer_offsets` - Internal offset storage

### 2. Topic Details

Click on **humidity_readings** topic.

**Overview tab** shows:
- Partition count: 3
- Replication factor: 1
- Total messages
- Size on disk
- Configuration

**Partitions tab** shows:
- Per-partition details
- Leader broker
- Offset range (start → end)
- Size per partition

### 3. Message Distribution

Check how messages are distributed:
- Click **Messages** tab
- Observe partition distribution
- Notice key → partition mapping

---

## Inspecting Messages

### View Messages

In the **Messages** tab:

1. Click **Add Filter**
2. Leave default (all partitions)
3. Click **Submit**

**You'll see:**
- Message key (sensor-1, sensor-2, sensor-3)
- Message value (JSON payload)
- Partition number
- Offset
- Timestamp
- Headers (if any)

### Search by Offset

To view a specific message:
1. Select partition
2. Enter offset number
3. Click **Jump to Offset**

### Filter by Key

To see all messages from sensor 1:
1. Click **Add Filter**
2. Select **Key**
3. Enter: `sensor-1`
4. Submit

All kitchen sensor readings will be shown!

---

## Monitor Consumer Groups

### 1. Navigate to Consumer Groups

Click **Consumer Groups** in left sidebar.

You should see:
- `humidity-monitor-group` (basic consumer)
- `humidity-processor-group` (manual commit consumer)
- `humidity-analytics-group` (multithreaded consumer)

### 2. Consumer Group Details

Click on **humidity-processor-group**.

**Members tab** shows:
- Consumer ID
- Client ID
- Host
- Assigned partitions

**Offsets tab** shows:
- Current offset per partition
- Log end offset
- **Lag** - unconsumed messages
- Last commit timestamp

### 3. Understanding Lag

**Lag** = Log End Offset - Current Offset

```
Example:
Partition 0:
  Log End Offset: 1000  (latest message)
  Current Offset: 950   (consumer position)
  Lag: 50              (unconsumed messages)
```

**Healthy consumer:** Lag should be low and stable  
**Problem:** Growing lag indicates consumer can't keep up

---

## Visualizing Consumer Lag

### Check Current Lag

In Kafka UI:
1. Go to **Consumer Groups**
2. Select **humidity-processor-group**
3. Click **Offsets** tab
4. Observe lag per partition

### Simulate Lag

Stop all consumers:

```terminal:execute
command: pkill -f "java.*HumidityConsumer" || true
background: false
```

Let producer run for 30 seconds (lag accumulates):

```terminal:execute
command: sleep 30
background: false
```

Now check lag again in Kafka UI - it should be growing!

### Resume Consumption

Start consumer and watch lag decrease:

```terminal:execute
command: ./run-consumer-manual.sh
background: true
```

Refresh Kafka UI every few seconds - lag should go down!

---

## Topic Configuration

### View Topic Config

In topic **humidity_readings**:
1. Click **Config** tab

Important settings:
- `retention.ms` - How long to keep messages
- `segment.ms` - Log segment roll time
- `compression.type` - Compression algorithm
- `max.message.bytes` - Max message size

### Update Configuration

You can update config via UI:
1. Click **Edit Config**
2. Modify settings
3. Save

Example: Increase retention to 7 days:
```
retention.ms = 604800000
```

---

## Partition Details

### Partition Leader and Replicas

In **Partitions** tab of topic:

For each partition, you see:
- **Leader** - Broker handling reads/writes
- **Replicas** - Broker IDs with copies (none in our single-broker setup)
- **In-Sync Replicas (ISR)** - Up-to-date replicas

### Partition Size

Check storage per partition:
- Different sizes indicate uneven key distribution
- If one partition is much larger, key distribution may be skewed

---

## Creating Topics via UI

### Create a Test Topic

1. Click **Topics** → **Add Topic**
2. Enter name: `test-topic`
3. Set partitions: 3
4. Set replication factor: 1
5. Click **Create**

### Delete Topic

1. Go to topic detail page
2. Click **Delete Topic**
3. Confirm

---

## Message Production via UI

### Send Test Messages

1. Navigate to **humidity_readings** topic
2. Click **Produce Message** tab
3. Enter key: `sensor-1`
4. Enter value (JSON):
```json
{
  "sensor_id": 1,
  "location": "kitchen",
  "humidity": 75,
  "read_at": 1733584800
}
```
5. Click **Produce Message**

The message will be consumed by any active consumer!

---

## Consumer Group Management

### Reset Offsets

To reprocess messages:

1. Go to **Consumer Groups** → **humidity-processor-group**
2. Click **Reset Offsets** (if available)
3. Select strategy:
   - **To Beginning** - Reprocess all messages
   - **To End** - Skip to latest
   - **To Timestamp** - Start from specific time
   - **By Offset** - Jump to specific offset

**⚠️ Warning:** Stop consumers before resetting offsets!

---

## Troubleshooting Scenarios

### Scenario 1: Consumer Not Consuming

**Symptoms in UI:**
- Consumer group exists
- No members shown
- Lag increasing

**Diagnosis:**
- Consumer crashed
- Consumer can't connect to Kafka
- Consumer not subscribed correctly

**Action:**
- Check consumer logs
- Verify network connectivity
- Restart consumer

### Scenario 2: Uneven Partition Assignment

**Symptoms:**
- Some consumers have many partitions
- Others have few/none

**Diagnosis:**
- More consumers than partitions (some idle)
- Using Range assignor with uneven distribution

**Action:**
- Adjust consumer count
- Switch to RoundRobin or CooperativeSticky assignor

### Scenario 3: Growing Lag

**Symptoms:**
- Lag constantly increasing
- Consumer can't keep up with producer

**Diagnosis:**
- Consumer too slow
- Not enough consumers
- Processing bottleneck

**Action:**
- Add more consumers to group
- Optimize processing code
- Use multithreaded pattern
- Increase partition count (requires topic recreation)

---

## Monitoring Broker Health

### Broker Details

Click **Brokers** in sidebar:

Shows:
- Broker ID
- Host and port
- Number of partitions
- Leader partitions
- Disk usage
- Uptime

### Broker Logs

Check broker logs if issues:

```terminal:execute
command: docker compose logs kafka --tail 50
background: false
```

---

## Message Headers Inspection

### View Headers

In **Messages** tab, expand a message to see:
- Standard fields (key, value, timestamp)
- Custom headers (if any)

Our producer doesn't add headers, but you can send a message with headers via UI:

1. **Produce Message** tab
2. Click **Add Header**
3. Key: `trace-id`
4. Value: `abc-123`
5. Produce message

Now view it - headers are visible!

---

## Cluster Configuration

### View Cluster Configs

Click **Cluster** → **Configuration**

Shows broker-level settings:
- Log retention defaults
- Compression settings
- Network configs
- Security settings

---

## Performance Metrics

### Topic Metrics

For **humidity_readings**:
- Messages in/sec
- Bytes in/sec
- Request rate

### Consumer Metrics

For consumer groups:
- Lag trend
- Commit rate
- Rebalance frequency

---

## Practical Exercise: Debug Stuck Consumer

Let's simulate and debug a common issue.

### 1. Create the Problem

Stop all consumers:

```terminal:execute
command: pkill -f "java.*HumidityConsumer" || true
background: false
```

### 2. Observe in UI

In Kafka UI:
- Go to **Consumer Groups**
- See groups have no active members
- Watch lag growing

### 3. Diagnose

Questions to answer using UI:
- Which partitions have highest lag?
- When was last offset committed?
- How many messages behind?

### 4. Fix

Start consumer:

```terminal:execute
command: ./run-consumer-manual.sh
background: true
```

### 5. Verify

Watch in UI:
- Member appears in group
- Lag starts decreasing
- Offsets advancing

---

## Key Takeaways

✅ **Kafka UI provides visual monitoring** of entire cluster  
✅ **Consumer lag is key metric** for consumer health  
✅ **Message inspection** helps debug data issues  
✅ **Topic configuration** viewable and editable  
✅ **Consumer group details** show assignment and progress  
✅ **Use UI for troubleshooting** - faster than CLI  

---

## Next Steps

You've mastered Kafka UI! Let's wrap up with a **summary of best practices** and production considerations.

