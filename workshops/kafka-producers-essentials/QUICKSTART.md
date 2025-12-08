# Kafka Producers Essentials - Quick Start

Get up and running with the workshop in 5 minutes!

## Prerequisites

- Java 21 installed
- Maven 3.9+
- Docker and Docker Compose
- Git (to clone the repository)

## Quick Setup

```bash
# Navigate to workshop directory
cd workshops/kafka-producers-essentials

# Start Kafka environment
docker compose up -d

# Wait ~20 seconds for services to start
docker compose ps

# Create topic
docker exec kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic humidity_readings --partitions 3 --replication-factor 1

# Build all producers
./build-apps.sh
```

## Run the Producers

### Basic Producer (Fire-and-Forget)
```bash
./run-producer-basic.sh
```
- Fastest throughput
- No error visibility
- Fire-and-forget pattern

### Callback Producer (Production-Ready)
```bash
./run-producer-callback.sh
```
- Async with error handling
- Shows partition, offset, timestamp
- **Recommended for production**

### Sync Producer (Blocking)
```bash
./run-producer-sync.sh
```
- Waits for confirmation
- Shows latency
- Slowest (demo only)

Press `Ctrl+C` to stop any producer.

## Verify Messages

### Console Consumer
```bash
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic humidity_readings \
  --from-beginning \
  --property print.key=true \
  --property print.partition=true \
  --max-messages 10
```

### Kafka UI
Open browser: http://localhost:8080
- Navigate to **Topics** → **humidity_readings**
- View messages, partitions, and keys

## Workshop Modules

1. **Quick Start** (8 min) - Environment setup
2. **ProducerRecord** (8 min) - Understanding components
3. **Keys & Partitioning** (12 min) - Ordering guarantees
4. **Async vs Sync** (10 min) - Send modes comparison
5. **Error Handling** (7 min) - Production patterns
6. **Wrap-Up** (5 min) - Best practices

## Key Concepts Preview

**ProducerRecord:**
```java
new ProducerRecord<>(topic, key, value)
```

**Same key → Same partition → Ordering:**
```
sensor-1 → partition 0 (all messages ordered)
sensor-2 → partition 1 (all messages ordered)
sensor-3 → partition 2 (all messages ordered)
```

**Async with Callback (Best Practice):**
```java
producer.send(record, (metadata, exception) -> {
    if (exception != null) {
        // Handle error
    } else {
        // Success - log metadata
    }
});
```

## Clean Up

```bash
# Stop services
docker compose down

# Remove volumes (optional)
docker compose down -v
```

## Troubleshooting

**Kafka won't start:**
```bash
# Check logs
docker compose logs kafka

# Restart services
docker compose restart
```

**Build fails:**
```bash
# Clean and rebuild
cd kafka-apps/producer-basic
mvn clean package
```

**Port conflicts:**
```bash
# Check if ports 9092 or 8080 are in use
netstat -an | grep 9092
netstat -an | grep 8080
```

## Next Steps

After completing this workshop:
1. Try the **kafka-consumers-essentials** workshop
2. Explore Kafka Streams
3. Learn about Schema Registry (Avro/Protobuf)
4. Study Kafka Connect for integrations

---

**Ready? Start with Module 1: Quick Start!** 🚀

