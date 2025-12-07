# Kafka Consumers Workshop - Quick Start

## Prerequisites

- Docker and Docker Compose installed
- Java JDK 21 installed
- Maven 3.6+ installed
- Git (to clone if needed)

## Quick Start (5 minutes)

### 1. Navigate to Workshop Directory

```bash
cd workshops/kafka-consumers
```

### 2. Start Kafka Services

```bash
docker compose up -d
```

Wait for services to be healthy (~30 seconds):

```bash
docker compose ps
```

### 3. Create Topic

```bash
docker exec kafka kafka-topics \
  --bootstrap-server localhost:9092 \
  --create --topic humidity_readings \
  --partitions 3 --replication-factor 1
```

### 4. Build Applications

```bash
./build-apps.sh
```

### 5. Start Producer

```bash
./run-producer.sh &
```

### 6. Run a Consumer

Choose one:

```bash
# Basic consumer (auto-commit)
./run-consumer-basic.sh

# Manual commit consumer
./run-consumer-manual.sh

# Multithreaded consumer
./run-consumer-multithreaded.sh
```

### 7. Access Kafka UI

Open browser: http://localhost:8080

## What You'll See

**Producer Output:**
```
📨 [1] Sensor 2 (bedroom): 54% humidity → partition 1, offset 0
📨 [2] Sensor 1 (kitchen): 68% humidity → partition 0, offset 0
📨 [3] Sensor 3 (outside): 42% humidity → partition 2, offset 0
```

**Consumer Output:**
```
🌡️  Reading #1:
   📍 Location: kitchen (Sensor 1)
   💧 Humidity: 65%
   ⏰ Timestamp: 2025-12-07T14:30:15Z
   📊 Kafka Metadata:
      - Key: sensor-1
      - Partition: 0
      - Offset: 0
```

## Workshop Flow

1. **Environment Setup** (Module 01) - You just did this!
2. **Consumer Basics** (Module 02) - Run basic consumer
3. **ConsumerRecords** (Module 03) - Understand message structure
4. **Manual Offset Management** (Module 04) - Control commits
5. **Rebalancing Demo** (Module 05) - See partition reassignment
6. **Configuration** (Module 06) - Tune performance
7. **Multithreaded Consumer** (Module 07) - Scale processing
8. **Error Handling** (Module 08) - Build robust consumers
9. **Kafka UI** (Module 09) - Visual monitoring
10. **Summary** (Module 10) - Best practices

## Useful Commands

### Check Topic Messages

```bash
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic humidity_readings \
  --from-beginning --max-messages 10
```

### View Consumer Groups

```bash
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --list
```

### Describe Consumer Group

```bash
docker exec kafka kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --describe --group humidity-monitor-group
```

### Stop Everything

```bash
# Stop consumers
pkill -f "java.*HumidityConsumer"

# Stop producer
pkill -f "java.*HumidityProducer"

# Stop Kafka
docker compose down
```

## Troubleshooting

### Kafka won't start

```bash
# Check if port 9092 is in use
lsof -i :9092

# Check Docker logs
docker compose logs kafka
```

### Consumer not receiving messages

```bash
# Verify producer is running
ps aux | grep HumidityProducer

# Check topic has messages
docker exec kafka kafka-run-class kafka.tools.GetOffsetShell \
  --broker-list localhost:9092 --topic humidity_readings
```

### Build fails

```bash
# Clean Maven cache
rm -rf ~/.m2/repository/org/apache/kafka
rm -rf ~/.m2/repository/com/fasterxml/jackson

# Rebuild
./build-apps.sh
```

## Next Steps

- Open `WORKSHOP_GUIDE.md` for detailed module descriptions
- Follow workshop content in `workshop/content/` directory
- Experiment with different consumer configurations
- Try all three consumer implementations

## Workshop Duration

**Total:** 2.5 - 3 hours
- Setup: 15 min
- Core modules: 2 hours
- Advanced topics: 45 min
- Summary: 15 min

## Support

- Check `README.md` for workshop overview
- Read `WORKSHOP_GUIDE.md` for detailed instructions
- Review module content in `workshop/content/`
- Consult [Apache Kafka Documentation](https://kafka.apache.org/documentation/)

---

**Ready to start?** Open Module 01: `workshop/content/01-environment-setup.md`

🚀 Happy Learning!

