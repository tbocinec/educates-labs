# Quick Start Guide

Get up and running with the Kafka + Flink Mold Alert workshop in under 5 minutes.

## Prerequisites Check

```bash
# Check Docker
docker --version

# Check Docker Compose
docker compose version

# Check Java
java -version  # Should be 11 or higher

# Check Maven
mvn -version   # Should be 3.6 or higher
```

## 1. Start Infrastructure (2 min)

```bash
# Navigate to workshop directory
cd kafka-flink-mold-alert

# Make scripts executable
chmod +x *.sh scripts/*.sh

# Start all services
docker compose up -d

# Wait for services to be healthy (~60 seconds)
./scripts/verify-setup.sh
```

**Expected Services:**
- ✅ Kafka (port 9092)
- ✅ Kafka UI (port 8080)
- ✅ Kafka Connect (port 8083)
- ✅ Flink JobManager (port 8081)
- ✅ Flink TaskManager

## 2. Create Topics (30 sec)

```bash
# Create input topic
docker exec kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic raw_sensors --partitions 3 --replication-factor 1 --if-not-exists

# Create output topic
docker exec kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic critical_sensors --partitions 1 --replication-factor 1 --if-not-exists
```

## 3. Start Data Generator (30 sec)

```bash
./start-datagen.sh
```

This generates realistic humidity sensor data every 2 seconds.

## 4. Build Flink Job (2 min)

```bash
./build-flink-job.sh
```

**Note:** First build downloads Maven dependencies (~100 MB). Subsequent builds are faster.

## 5. Deploy Flink Job (15 sec)

```bash
./submit-flink-job.sh
```

## 6. Verify It's Working (30 sec)

### Check Flink UI
Open: http://localhost:8081

Should show "Humidity Mold Alert Job" running.

### Check Output Topic

```bash
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic critical_sensors \
  --from-beginning \
  --max-messages 5
```

You should see JSON messages with `humidity > 70` and added `status` field.

### Check Kafka UI
Open: http://localhost:8080

Navigate to Topics → critical_sensors → Messages to see alerts.

## Quick Test

```bash
# Watch input (all sensor data)
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 --topic raw_sensors

# In another terminal, watch output (filtered alerts only)
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 --topic critical_sensors
```

You should notice that `critical_sensors` only shows messages where humidity > 70.

## Troubleshooting

### Services not ready?
```bash
# Check status
docker compose ps

# View logs
docker compose logs -f
```

### Build failed?
```bash
# Clean and retry
cd flink-app && mvn clean && cd ..
./build-flink-job.sh
```

### No data in topics?
```bash
# Verify connector is running
curl http://localhost:8083/connectors/humidity-datagen-source/status

# Restart if needed
curl -X POST http://localhost:8083/connectors/humidity-datagen-source/restart
```

## Next Steps

Once everything is running:
1. Open the workshop content at `workshop/content/01-quick-start.md`
2. Follow the progressive modules
3. Experiment with modifications in module 5

## Cleanup

```bash
# Stop services
docker compose down

# Remove all data
docker compose down -v
```

---

**Total Setup Time:** ~5 minutes (excluding first-time downloads)

**Ready to learn?** Proceed to the full workshop content! 🚀

