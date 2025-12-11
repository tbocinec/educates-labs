# Understanding the Mold Alert Logic

Before we build our Flink job, let's understand exactly what we're trying to achieve.

---

## 🧫 The Science: Why 70%?

According to environmental health guidelines:
- **Below 60% humidity**: Safe, mold cannot thrive
- **60-70% humidity**: Moderate risk, monitor closely
- **Above 70% humidity**: **Critical** - mold can grow in 24-48 hours

Our system will implement a simple rule:

```
IF humidity > 70 THEN 
    Create Alert 
ELSE 
    Ignore
```

---

## 🔄 The Data Flow

Here's how data moves through our system:

```
┌─────────────────┐
│  Data Generator │  Produces sensor readings every 2s
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  raw_sensors    │  Kafka Topic (all sensor data)
│     (input)     │  
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Flink Job      │  Filters: humidity > 70
│  (Filter &      │  Transforms: adds "CRITICAL_MOLD_RISK" tag
│   Transform)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ critical_sensors│  Kafka Topic (only alerts)
│    (output)     │
└─────────────────┘
```

---

## 📊 Sample Input vs Output

### Input (raw_sensors topic)

```json
{"sensor_id":"sensor-01","location":"basement","humidity":45,"temperature":20,"timestamp":1700000001000}
{"sensor_id":"sensor-02","location":"bathroom","humidity":78,"temperature":24,"timestamp":1700000002000}
{"sensor_id":"sensor-03","location":"kitchen","humidity":52,"temperature":22,"timestamp":1700000003000}
{"sensor_id":"sensor-04","location":"basement","humidity":85,"temperature":19,"timestamp":1700000004000}
{"sensor_id":"sensor-05","location":"bedroom","humidity":55,"temperature":21,"timestamp":1700000005000}
```

### Output (critical_sensors topic)

Only 2 messages make it through (humidity > 70):

```json
{"sensor_id":"sensor-02","location":"bathroom","humidity":78,"temperature":24,"timestamp":1700000002000,"status":"CRITICAL_MOLD_RISK","alert_time":1733850123456}
{"sensor_id":"sensor-04","location":"basement","humidity":85,"temperature":19,"timestamp":1700000004000,"status":"CRITICAL_MOLD_RISK","alert_time":1733850124789}
```

Notice:
- ✅ Only readings with humidity > 70 appear
- ✅ Each message has added fields: `status` and `alert_time`

---

## 🧩 The Flink Job Components

Our Flink job has 3 main parts:

### 1. Source (Kafka Consumer)

```java
KafkaSource<String> source = KafkaSource.<String>builder()
    .setBootstrapServers("kafka:29092")
    .setTopics("raw_sensors")
    .setGroupId("mold-alert-group")
    .setStartingOffsets(OffsetsInitializer.earliest())
    .setValueOnlyDeserializer(new SimpleStringSchema())
    .build();
```

**What it does:** Reads messages from the `raw_sensors` topic.

---

### 2. Transformation (Filter + Map)

```java
DataStream<String> criticalStream = sensorStream
    .filter(jsonString -> {
        JsonNode node = mapper.readTree(jsonString);
        int humidity = node.get("humidity").asInt();
        return humidity > 70;  // THE CORE LOGIC
    })
    .map(jsonString -> {
        ObjectNode node = (ObjectNode) mapper.readTree(jsonString);
        node.put("status", "CRITICAL_MOLD_RISK");
        node.put("alert_time", System.currentTimeMillis());
        return node.toString();
    });
```

**What it does:**
- **Filter:** Keep only messages where humidity > 70
- **Map:** Add alert metadata to each message

---

### 3. Sink (Kafka Producer)

```java
KafkaSink<String> sink = KafkaSink.<String>builder()
    .setBootstrapServers("kafka:29092")
    .setRecordSerializer(KafkaRecordSerializationSchema.builder()
        .setTopic("critical_sensors")
        .setValueSerializationSchema(new SimpleStringSchema())
        .build()
    )
    .build();
```

**What it does:** Writes filtered messages to the `critical_sensors` topic.

---

## 🎯 Success Criteria

Our Flink job is working correctly if:

1. ✅ It reads from `raw_sensors` topic
2. ✅ It filters out messages where humidity ≤ 70
3. ✅ It adds `status` and `alert_time` fields to alerts
4. ✅ It writes only critical alerts to `critical_sensors` topic
5. ✅ It processes messages in real-time (low latency)

---

## 💡 Why This Matters

This simple filter pattern is the foundation of many real-world use cases:

- **IoT Monitoring:** Alert when temperature exceeds threshold
- **Fraud Detection:** Flag suspicious transactions
- **Quality Control:** Detect defective products
- **Network Security:** Identify abnormal traffic patterns

The same logic applies:
1. Read stream
2. Filter based on condition
3. Transform and enrich
4. Route to appropriate destination

---

## Ready to Build?

Now that you understand the logic, let's examine the actual Flink code and build it!

---

