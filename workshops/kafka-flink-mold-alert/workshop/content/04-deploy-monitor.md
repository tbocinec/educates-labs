# Deploy and Monitor

Time to deploy your Flink job and see it in action!

---

## 🚀 Submit Job to Flink

Deploy the job to the Flink cluster:

```terminal:execute
command: ./submit-flink-job.sh
background: false
session: 1
```

This script will:
1. Copy the JAR to the Flink JobManager container
2. Submit the job using `flink run -d`
3. Return immediately (detached mode)

**Expected output:**
```
🚀 Deploying Mold Alert Job to Flink...
📤 Copying JAR to Flink JobManager...
🎯 Submitting job to Flink...
Job has been submitted with JobID xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
✅ Job submitted successfully!
🌐 View job status at: http://localhost:8081
```

---

## 📊 View Job in Flink UI

Switch to the Flink dashboard to see your running job:

```dashboard:open-dashboard
name: Flink UI
```

In the Flink UI, you should see:

### Running Jobs Tab
- **Job Name**: "Humidity Mold Alert Job"
- **Status**: RUNNING
- **Start Time**: Just now
- **Duration**: Increasing

Click on the job to see details:

### Job Details
- **Job Graph**: Visual representation
  - Humidity Sensor Source → Mold Alert Filter & Transform → Critical Sensors Sink

### Task Managers
- Shows resource utilization
- Number of task slots in use

### Configuration
- Parallelism: 1
- Checkpoint interval: (not configured for this simple job)

---

## 🔍 Monitor Job Logs

Let's see the console output from the running Flink job:

```terminal:execute
command: docker logs -f flink-taskmanager --tail 50
background: false
session: 2
```

You should see alert messages when high humidity is detected:

```
🚨 ALERT: Sensor sensor-02 (bathroom) - 78% humidity detected!
🚨 ALERT: Sensor sensor-04 (basement) - 85% humidity detected!
🚨 ALERT: Sensor sensor-01 (basement) - 73% humidity detected!
```

**Press Ctrl+C** in session 2 to stop following logs (the job keeps running).

---

## 📥 Check Output Topic

Now let's verify that alerts are being written to the output topic:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic critical_sensors --from-beginning --max-messages 5
background: false
session: 1
```

You should see JSON messages with the added fields:

```json
{"sensor_id":"sensor-02","location":"bathroom","humidity":78,"temperature":24,"timestamp":1700000002000,"status":"CRITICAL_MOLD_RISK","alert_time":1733850123456}
{"sensor_id":"sensor-04","location":"basement","humidity":85,"temperature":19,"timestamp":1700000004000,"status":"CRITICAL_MOLD_RISK","alert_time":1733850124789}
```

Notice:
- ✅ Only messages with humidity > 70
- ✅ Added `status` field
- ✅ Added `alert_time` field

---

## 📈 View in Kafka UI

Let's visualize the data flow in Kafka UI:

```dashboard:open-dashboard
name: Kafka UI
```

### Check the Topics

1. **raw_sensors topic**:
   - Click on "Topics" → "raw_sensors"
   - Click "Messages" tab
   - See ALL sensor readings (high and low humidity)
   - Message rate: ~0.5 messages/second

2. **critical_sensors topic**:
   - Click on "Topics" → "critical_sensors"
   - Click "Messages" tab
   - See ONLY critical alerts (humidity > 70)
   - Message rate: Lower (only ~30-40% of input messages)

---

## 📊 Compare Input vs Output Rate

Let's measure the filtering effect by visualizing the message counts in Kafka UI.

### View Message Counts in Kafka UI

Switch to the Kafka UI dashboard:

```dashboard:open-dashboard
name: Kafka UI
```

In Kafka UI, compare the two topics:

1. **Navigate to Topics**
   - Click on "Topics" in the left menu

2. **Check raw_sensors topic**
   - Find "raw_sensors" in the list
   - Look at the "Messages" column - shows total count
   - Note the partition offsets (e.g., 125 + 130 + 128 = 383 total)

3. **Check critical_sensors topic**
   - Find "critical_sensors" in the list
   - Look at the "Messages" column - shows total count
   - Note the partition offsets (e.g., 145 total)

**Compare the numbers:** The `critical_sensors` topic should have significantly fewer messages than `raw_sensors`, proving the filter is working!

**Expected ratio:** Since humidity > 70 occurs in roughly 30-40% of readings (range is 30-95%), you should see approximately 30-40% of messages making it through the filter.

### Alternative: View Message Details in Kafka UI

You can also click into each topic in Kafka UI to see more details:

**For raw_sensors:**
1. Click on "raw_sensors" topic
2. Go to "Messages" tab
3. Scroll to see recent messages
4. The partition dropdown shows offset ranges per partition

**For critical_sensors:**
1. Click on "critical_sensors" topic
2. Go to "Messages" tab
3. Compare the total message count with raw_sensors
4. Notice only high-humidity readings appear

The visual comparison in Kafka UI is the most reliable way to verify the filtering is working correctly.


---

## 🎯 Real-Time Streaming Demo

Let's watch data flow in real-time. Open two terminal sessions side by side:

### Terminal 1: Watch Input Topic

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic raw_sensors
background: false
session: 1
```

### Terminal 2: Watch Output Topic

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic critical_sensors
background: false
session: 2
```

**Observe:**
- Session 2 shows ALL messages
- Session 3 shows ONLY critical alerts
- Notice which sensor IDs and locations trigger alerts

**Press Ctrl+C** in both sessions when done observing.

---

## 🧪 Test Scenario

Let's verify the logic with a specific example:

### Expected Behavior

Given this input message:
```json
{"sensor_id":"sensor-01","location":"basement","humidity":85,"temperature":19,"timestamp":1700000010000}
```

**Question:** Will this message appear in `critical_sensors`?

**Answer:** ✅ YES, because 85 > 70

Expected output:
```json
{"sensor_id":"sensor-01","location":"basement","humidity":85,"temperature":19,"timestamp":1700000010000,"status":"CRITICAL_MOLD_RISK","alert_time":1733850999999}
```

Given this input message:
```json
{"sensor_id":"sensor-02","location":"bedroom","humidity":55,"temperature":21,"timestamp":1700000011000}
```

**Question:** Will this message appear in `critical_sensors`?

**Answer:** ❌ NO, because 55 ≤ 70 (filtered out)

---

## 🎉 Success!

Your Flink job is now:
- ✅ Reading from `raw_sensors` topic
- ✅ Filtering humidity > 70
- ✅ Adding alert metadata
- ✅ Writing to `critical_sensors` topic
- ✅ Processing in real-time with low latency

**Next:** Let's experiment by modifying the threshold and redeploying!

---

