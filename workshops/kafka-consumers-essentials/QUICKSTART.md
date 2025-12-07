# Quick Start - Kafka Consumers Workshop

## Prerequisites

- Docker and Docker Compose
- Java JDK 21
- Maven 3.6+

## 5-Minute Setup

### 1. Navigate to Workshop

```bash
cd workshops/kafka-consumers-essentials
```

### 2. Start Services

```bash
docker compose up -d
```

Wait for healthy status (~20 seconds):

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

### 6. Run Consumer

```bash
./run-consumer.sh
```

## What You'll See

**Producer:**
```
📨 Sensor 1 (kitchen): 67% → partition 0
📨 Sensor 2 (bedroom): 54% → partition 1
📨 Sensor 3 (outside): 42% → partition 2
```

**Consumer (Auto-Commit):**
```
🌡️  [1] kitchen: 67%
    Key: sensor-1 | Partition: 0 | Offset: 0
    --------------------------------------------------
```

## Switch to Manual Commit

Edit `kafka-apps/consumer/src/main/java/com/example/HumidityConsumer.java`:

Change:
```java
private static final boolean USE_MANUAL_COMMIT = false;
```

To:
```java
private static final boolean USE_MANUAL_COMMIT = true;
```

Rebuild and run:
```bash
cd kafka-apps/consumer && mvn clean package -q && cd ../..
./run-consumer.sh
```

## Access Kafka UI

Open: http://localhost:8080

Explore:
- Topics → humidity_readings
- Consumer Groups → humidity-monitor

## Cleanup

```bash
pkill -f "java.*Humidity"
docker compose down
```

## Workshop Modules

1. **Quick Start** (10 min) - Setup complete!
2. **First Consumer** (15 min) - Auto-commit mode
3. **Manual Commit** (15 min) - At-least-once processing
4. **Wrap-Up** (5 min) - Best practices

**Total: 45 minutes**

## Next Steps

- Follow workshop content in `workshop/content/`
- For deep dive: See `kafka-consumers` workshop (3 hours)

Ready? Open Module 01! 🚀

