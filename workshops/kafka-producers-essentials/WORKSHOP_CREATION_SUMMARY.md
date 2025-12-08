# Kafka Producers Essentials Workshop - Creation Summary

## Overview
Created a complete 45-minute hands-on workshop focused on Kafka producer fundamentals, following the same pattern as the kafka-consumers-essentials workshop, using the humidity sensor domain.

## Workshop Structure

### 📁 Directory Layout
```
kafka-producers-essentials/
├── README.md                        # Workshop overview
├── QUICKSTART.md                    # 5-minute quick start guide
├── docker-compose.yml               # Kafka + Kafka UI services
├── build-apps.sh                    # Build script for all producers
├── run-producer-basic.sh            # Run basic (fire-and-forget) producer
├── run-producer-callback.sh         # Run callback producer
├── run-producer-sync.sh             # Run synchronous producer
├── resources/
│   └── workshop.yaml                # Educates workshop definition
├── workshop/
│   ├── config.yaml                  # Workshop configuration
│   └── content/
│       ├── 01-quick-start.md        # Module 1: Setup (8 min)
│       ├── 02-producer-record.md    # Module 2: ProducerRecord (8 min)
│       ├── 03-keys-partitioning.md  # Module 3: Keys & Partitioning (12 min)
│       ├── 04-async-vs-sync.md      # Module 4: Async vs Sync (10 min)
│       ├── 05-error-handling.md     # Module 5: Error Handling (7 min)
│       └── 99-wrap-up.md            # Module 6: Wrap-Up (5 min)
└── kafka-apps/
    ├── producer-basic/              # Fire-and-forget producer
    │   ├── pom.xml
    │   └── src/main/java/com/example/
    │       └── HumidityProducerBasic.java
    ├── producer-callback/           # Production-ready with callbacks
    │   ├── pom.xml
    │   └── src/main/java/com/example/
    │       └── HumidityProducerCallback.java
    └── producer-sync/               # Synchronous blocking mode
        ├── pom.xml
        └── src/main/java/com/example/
            └── HumidityProducerSync.java
```

## Workshop Modules (45 Minutes Total)

### Module 1: Quick Start (8 min)
- Start Kafka and Kafka UI
- Create `humidity_readings` topic (3 partitions)
- Build all three producer applications
- Overview of producer variants

### Module 2: ProducerRecord Essentials (8 min)
- Components: topic, key, value, headers
- Understanding keys and their role
- Running basic producer
- Viewing messages in Kafka UI

### Module 3: Keys → Partitioning → Ordering (12 min)
- Partitioning rules and strategies
- How keys determine partition (`hash(key) % partitions`)
- Ordering guarantees within partitions
- Sticky partitioner for keyless messages
- Hands-on demos proving key-based partitioning

### Module 4: Async vs Sync Send (10 min)
- Fire-and-forget (async, no callback)
- Async with callbacks (production pattern)
- Synchronous blocking send
- Performance comparison
- When to use each mode

### Module 5: Error Handling & Flushing (7 min)
- Common producer errors (serialization, timeout, etc.)
- Idempotent producer configuration
- Error handling via callbacks
- When to flush (and when NOT to)
- Graceful shutdown patterns

### Module 6: Wrap-Up (5 min)
- Key concepts review
- Production checklist
- Best practices and common pitfalls
- Performance tuning tips
- Next steps and resources

## Domain: Humidity Sensors

### Three Sensors
- **Sensor 1 - Kitchen**: 60-75% humidity range
- **Sensor 2 - Bedroom**: 45-60% humidity range  
- **Sensor 3 - Outside**: 25-85% humidity range

### Message Format
```json
{
  "sensor_id": 1,
  "location": "kitchen",
  "humidity": 65,
  "read_at": 1733584800
}
```

### Keys
- `sensor-1` → Always partition 0
- `sensor-2` → Always partition 1
- `sensor-3` → Always partition 2

This demonstrates key-based partitioning and ordering!

## Three Producer Implementations

### 1. HumidityProducerBasic (Fire-and-Forget)
**Purpose:** Show simplest async send pattern

**Characteristics:**
- Calls `producer.send(record)` without callback
- Highest throughput
- No error visibility
- Simple output showing messages sent

**Use case:** Understanding basic async pattern (not production-ready)

### 2. HumidityProducerCallback (Production-Ready)
**Purpose:** Demonstrate production-ready async with error handling

**Characteristics:**
- Uses callbacks for error handling
- Shows partition, offset, timestamp metadata
- Proper error logging
- **Recommended pattern for production**

**Output shows:**
```
✅ SUCCESS: sensor-1 | kitchen | 68%
   → Partition: 0 | Offset: 42 | Timestamp: 1733584800
```

### 3. HumidityProducerSync (Blocking Mode)
**Purpose:** Show blocking send for comparison

**Characteristics:**
- Calls `producer.send(record).get()` - blocks!
- Shows latency per message
- Much slower than async
- Use only for demos/low-frequency sends

**Output shows:**
```
⏳ SYNC: sensor-1 | kitchen | 68%
   → partition 0, offset 1 (latency: 25ms)
```

## Technical Stack

- **Apache Kafka**: 7.7.1 (KRaft mode - no Zookeeper)
- **Java**: 21 (with records feature)
- **Maven**: 3.x
- **Kafka Clients**: 3.8.0
- **Jackson**: 2.18.1 (JSON serialization)
- **Kafka UI**: 0.7.2 (visualization)
- **Docker Compose**: For container orchestration

## Key Learning Outcomes

After completing this workshop, participants will:

✅ Understand ProducerRecord components (topic, key, value, headers)
✅ Know how keys determine partitioning and ordering
✅ Master the difference between async and sync send modes
✅ Implement production-ready error handling with callbacks
✅ Configure idempotent producers to prevent duplicates
✅ Know when to flush (and when NOT to flush)
✅ Apply best practices for high-performance producers

## Producer Configuration Highlights

### All Producers Use:
```java
props.put(ProducerConfig.ACKS_CONFIG, "all");
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy");
```

This ensures:
- **Durability**: All replicas acknowledge
- **Exactly-once**: Idempotence prevents duplicates on retry
- **Efficiency**: Compression reduces network/storage

## Pattern Consistency with Consumer Workshop

This workshop follows the same successful pattern as `kafka-consumers-essentials`:

✅ **Same domain**: Humidity sensors  
✅ **Same message format**: JSON sensor readings  
✅ **Same topic**: `humidity_readings` (3 partitions)  
✅ **Same structure**: Progressive modules with hands-on exercises  
✅ **Same environment**: Docker Compose + Kafka UI  
✅ **Same duration approach**: Condensed essentials (45 min vs 45 min)  

**Together they form a complete producer-consumer learning path!**

## Hands-On Exercises

### Exercise 1: Observe Key-Based Partitioning
- Run producer and observe messages in Kafka UI
- Verify same key always goes to same partition
- See ordering within partitions

### Exercise 2: Compare Send Modes
- Run basic producer (fire-and-forget)
- Run callback producer (see metadata)
- Run sync producer (observe latency)
- Compare throughput

### Exercise 3: Error Visibility
- Compare error handling between basic and callback modes
- See how callbacks provide visibility

### Exercise 4: Kafka UI Exploration
- View messages by partition
- Inspect keys and offsets
- Understand partition distribution

## Production Best Practices Covered

1. **Always use callbacks** for error visibility
2. **Enable idempotence** to prevent duplicates
3. **Use keys** when ordering matters
4. **Avoid flushing** in hot paths (kills performance)
5. **Implement graceful shutdown** with flush on exit
6. **Use compression** (snappy recommended)
7. **Monitor metrics** (success rate, latency, throughput)
8. **Keep callbacks lightweight** (runs on I/O thread)

## Quick Start Commands

```bash
# Setup
cd workshops/kafka-producers-essentials
docker compose up -d
./build-apps.sh

# Create topic
docker exec kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic humidity_readings --partitions 3 --replication-factor 1

# Run producers (in separate terminals)
./run-producer-basic.sh      # Fire-and-forget
./run-producer-callback.sh   # Production-ready
./run-producer-sync.sh       # Blocking mode

# Verify messages
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic humidity_readings \
  --from-beginning \
  --property print.key=true \
  --property print.partition=true \
  --max-messages 10

# Access Kafka UI
# http://localhost:8080

# Cleanup
docker compose down
```

## Files Created

**Documentation:**
- README.md (workshop overview)
- QUICKSTART.md (quick start guide)
- This summary document

**Infrastructure:**
- docker-compose.yml (Kafka + Kafka UI)
- build-apps.sh (build all producers)
- run-producer-basic.sh
- run-producer-callback.sh
- run-producer-sync.sh

**Workshop Content:**
- 6 markdown modules (01 through 99)
- config.yaml
- workshop.yaml (Educates definition)

**Java Applications:**
- 3 producer implementations (basic, callback, sync)
- 3 pom.xml files (one per producer)
- All using Java 21 with records

**Total:** 20+ files creating a complete, production-ready workshop!

## Success Criteria

✅ Workshop follows same pattern as kafka-consumers-essentials  
✅ Uses same domain (humidity sensors)  
✅ Covers all requested topics from the agenda  
✅ Three producer implementations demonstrate different patterns  
✅ Hands-on exercises in each module  
✅ Production-ready best practices throughout  
✅ Complete in 45 minutes  
✅ All files created and organized  

## Next Steps for Users

After this workshop, participants should explore:
1. **kafka-consumers-essentials** - Complete the producer-consumer cycle
2. **Kafka Streams** - Stream processing
3. **Schema Registry** - Avro/Protobuf schemas
4. **Kafka Connect** - Integration with external systems
5. **Transactional Producers** - Exactly-once semantics across topics

---

**Workshop is complete and ready to use!** 🎉

