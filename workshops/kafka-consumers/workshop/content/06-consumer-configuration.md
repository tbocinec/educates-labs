# Consumer Configuration Deep Dive

Master the essential consumer configurations for reliability, performance, and operational excellence.

---

## 🎯 What You'll Learn

- Essential reliability configurations
- Performance tuning parameters
- Trade-offs and best practices
- Production-ready configuration templates

---

## Configuration Categories

Consumer configs fall into these categories:

1. **Connection** - Bootstrap servers, security
2. **Group Management** - Group ID, assignment strategy
3. **Offset Management** - Auto-commit, reset behavior
4. **Performance** - Fetch sizes, poll records
5. **Reliability** - Timeouts, retries, heartbeats

---

## Essential Reliability Configs

### group.id (Required)

```java
props.put(ConsumerConfig.GROUP_ID_CONFIG, "humidity-processors");
```

**Purpose:** Identifies the consumer group  
**Impact:** Consumers with same group.id share partition assignment  
**Tip:** Use descriptive names (e.g., `analytics-pipeline`, `alerts-service`)

### enable.auto.commit

```java
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
```

**Values:** true (default) | false  
**Purpose:** Controls automatic offset commits  
**Recommendation:** Use `false` for critical data (at-least-once)

### auto.offset.reset

```java
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
```

**Values:**
- `earliest` - Start from beginning (oldest message)
- `latest` - Start from end (new messages only)
- `none` - Throw exception if no offset found

**Recommendation:** Use `earliest` for data pipelines, `latest` for real-time monitoring

---

## Performance Tuning Configs

### max.poll.records

```java
props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 500);
```

**Purpose:** Maximum records returned per poll()  
**Default:** 500  
**Impact:**
- Higher = Fewer polls, better throughput
- Lower = Smaller batches, faster processing

**Tuning:**
- Fast processing → increase (1000-5000)
- Slow processing → decrease (50-200)
- Must process within max.poll.interval.ms

### fetch.min.bytes

```java
props.put(ConsumerConfig.FETCH_MIN_BYTES_CONFIG, 50000);
```

**Purpose:** Minimum data broker must have before responding  
**Default:** 1 byte  
**Impact:**
- Higher = Fewer requests, better batching
- Lower = Lower latency

**Recommendation:** 50KB-100KB for throughput, 1KB for latency

### fetch.max.wait.ms

```java
props.put(ConsumerConfig.FETCH_MAX_WAIT_MS_CONFIG, 500);
```

**Purpose:** Maximum time broker waits to accumulate fetch.min.bytes  
**Default:** 500ms  
**Impact:** Balances latency vs batching  
**Recommendation:** 100-500ms

### max.partition.fetch.bytes

```java
props.put(ConsumerConfig.MAX_PARTITION_FETCH_BYTES_CONFIG, 1048576);
```

**Purpose:** Maximum data per partition per fetch  
**Default:** 1MB  
**Impact:** Limits memory usage per partition  
**Recommendation:** 1MB-10MB depending on message size

---

## Timeout Configurations

### session.timeout.ms

```java
props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 30000);
```

**Purpose:** Max time between heartbeats before consumer kicked out  
**Default:** 10 seconds  
**Range:** 6-300 seconds  
**Recommendation:** 30 seconds (production)

### heartbeat.interval.ms

```java
props.put(ConsumerConfig.HEARTBEAT_INTERVAL_MS_CONFIG, 3000);
```

**Purpose:** Frequency of heartbeat signals  
**Default:** 3 seconds  
**Rule:** Must be < session.timeout.ms / 3  
**Recommendation:** session.timeout.ms / 3

### max.poll.interval.ms

```java
props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 300000);
```

**Purpose:** Max time between poll() calls  
**Default:** 5 minutes  
**Impact:** Prevents stuck consumers from holding partitions  
**Recommendation:**
- Fast processing: 300000 (5 min)
- Slow processing: 600000-1800000 (10-30 min)
- Must be > max batch processing time

---

## Configuration Profiles

### Profile 1: Low Latency (Real-time Alerts)

```java
Properties props = new Properties();
// Connection
props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(ConsumerConfig.GROUP_ID_CONFIG, "realtime-alerts");

// Serialization
props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);

// Offset management
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest");

// Performance - optimized for latency
props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 100);  // Small batches
props.put(ConsumerConfig.FETCH_MIN_BYTES_CONFIG, 1);     // Don't wait
props.put(ConsumerConfig.FETCH_MAX_WAIT_MS_CONFIG, 100); // Low wait

// Reliability
props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 10000);
props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 60000);
```

**Use case:** Immediate alerts, real-time dashboards

### Profile 2: High Throughput (Data Pipeline)

```java
Properties props = new Properties();
// Connection
props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(ConsumerConfig.GROUP_ID_CONFIG, "data-pipeline");

// Serialization
props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);

// Offset management
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

// Performance - optimized for throughput
props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 5000);    // Large batches
props.put(ConsumerConfig.FETCH_MIN_BYTES_CONFIG, 100000);   // Wait for data
props.put(ConsumerConfig.FETCH_MAX_WAIT_MS_CONFIG, 500);    // Reasonable wait
props.put(ConsumerConfig.MAX_PARTITION_FETCH_BYTES_CONFIG, 5242880); // 5MB

// Reliability - allow more time for batch processing
props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 30000);
props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 600000); // 10 minutes
```

**Use case:** Batch ETL, analytics pipelines

### Profile 3: Reliable Processing (Critical Data)

```java
Properties props = new Properties();
// Connection
props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(ConsumerConfig.GROUP_ID_CONFIG, "critical-processor");

// Serialization
props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);

// Offset management - manual control
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

// Performance - balanced
props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 500);
props.put(ConsumerConfig.FETCH_MIN_BYTES_CONFIG, 50000);
props.put(ConsumerConfig.FETCH_MAX_WAIT_MS_CONFIG, 500);

// Reliability - conservative timeouts
props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 30000);
props.put(ConsumerConfig.HEARTBEAT_INTERVAL_MS_CONFIG, 10000);
props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 900000); // 15 minutes

// Advanced
props.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG, 
    "org.apache.kafka.clients.consumer.CooperativeStickyAssignor");
```

**Use case:** Financial transactions, order processing

---

## Experiment: Tuning max.poll.records

Let's see the impact of `max.poll.records`. View current setting:

```terminal:execute
command: grep -A 60 "createConsumer" kafka-apps/consumer-manual/src/main/java/com/example/HumidityConsumerManual.java | grep MAX_POLL_RECORDS
background: false
```

Current value: 50

Start the consumer and observe batch sizes:

```terminal:execute
command: ./run-consumer-manual.sh
background: true
```

Watch the output - batches will be small (likely 1-10 messages per batch).

Stop it:

```terminal:interrupt
session: 1
```

---

## Memory Considerations

Consumer memory usage depends on:

```
Memory ≈ max.poll.records × avg_message_size × num_partitions
```

**Example:**
- 1000 max.poll.records
- 5KB average message
- 10 partitions assigned

```
Memory = 1000 × 5KB × 10 = 50MB per poll
```

**Recommendations:**
- Monitor heap usage
- Set appropriate JVM heap size
- Use max.partition.fetch.bytes to limit per-partition data

---

## Security Configurations

For production with SSL/SASL:

```java
// SSL
props.put("security.protocol", "SSL");
props.put("ssl.truststore.location", "/path/to/truststore.jks");
props.put("ssl.truststore.password", "password");

// SASL
props.put("security.protocol", "SASL_SSL");
props.put("sasl.mechanism", "PLAIN");
props.put("sasl.jaas.config", 
    "org.apache.kafka.common.security.plain.PlainLoginModule required " +
    "username=\"user\" password=\"password\";");
```

---

## Isolation Level

For transactional producers:

```java
props.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");
```

**Values:**
- `read_uncommitted` (default) - See all messages
- `read_committed` - Only see committed transactions

---

## Static Group Membership

Prevents rebalance on consumer restart:

```java
props.put(ConsumerConfig.GROUP_INSTANCE_ID_CONFIG, "consumer-1");
props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 300000); // 5 minutes
```

**Use case:** Stateful consumers, large state stores

---

## Configuration Validation

Check current consumer configuration:

```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-processor-group --members --verbose
background: false
```

---

## Best Practices Checklist

✅ **Always set group.id** explicitly  
✅ **Use manual commit** for critical data  
✅ **Set max.poll.interval.ms** > max processing time  
✅ **Keep heartbeat.interval.ms** < session.timeout.ms / 3  
✅ **Tune max.poll.records** based on processing speed  
✅ **Use CooperativeStickyAssignor** to minimize rebalancing  
✅ **Set auto.offset.reset** explicitly (don't rely on default)  
✅ **Monitor lag** and adjust fetch parameters  

---

## Common Pitfalls

❌ **Auto-commit with slow processing** → message loss  
❌ **max.poll.interval.ms too low** → constant rebalancing  
❌ **max.poll.records too high** → timeout issues  
❌ **No error handling on commit** → silent failures  
❌ **Ignoring consumer lag** → growing backlog  

---

## Key Takeaways

✅ **Configuration is critical** for performance and reliability  
✅ **No one-size-fits-all** - tune for your use case  
✅ **Timeouts control** failure detection speed  
✅ **Fetch parameters** balance latency vs throughput  
✅ **Test configurations** under realistic load  

---

## Next Steps

You now understand consumer configuration! Next, we'll implement a **multithreaded consumer** for better throughput with slower processing.

