# Quick Start - Setup Environment
Welcome! In this workshop, you'll learn Kafka consumer essentials through hands-on practice.
---
## 🎯 What You'll Learn
1. **Quick Start** (10 min) - Get Kafka running
2. **First Consumer** (15 min) - Consumer basics
3. **Manual Commit** (15 min) - Control offsets
4. **Wrap-Up** (5 min) - Best practices
---
---

## Make Scripts Executable

First, let's make all shell scripts executable:

```terminal:execute
command: chmod +x build-apps.sh run-producer.sh run-consumer.sh
background: false
session: 1
```

This ensures all helper scripts can be run throughout the workshop.

---

## Start Kafka Services
Start Kafka and Kafka UI:
```terminal:execute
command: cd /home/eduk8s && docker compose up -d
background: false
```

While services are starting (~20 seconds), let's inspect the Docker Compose configuration:

```editor:open-file
file: docker-compose.yml
```

This file defines:
- **Kafka broker** on port 9092
- **Kafka UI** on port 8080
- Health checks and dependencies

Check that services are healthy:
```terminal:execute
command: docker compose ps
background: false
```
Both services should show "healthy" status.
---
## Create Topic
Create the `humidity_readings` topic:
```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic humidity_readings --partitions 3 --replication-factor 1 --if-not-exists
background: false
```
**Why 3 partitions?**
- Enables parallel processing
- Demonstrates consumer groups
- Key-based partitioning (sensor-1, sensor-2, sensor-3)
---
## Build Applications
Build the producer and consumer:
```terminal:execute
command: ./build-apps.sh
background: false
```
This compiles:
- ✅ Humidity sensor producer
- ✅ Consumer (supports both auto and manual commit)
Takes about 30 seconds...
---
## Start Producer
Start the producer in background:
```terminal:execute
command: ./run-producer.sh > /dev/null 2>&1 &
background: true
```
The producer generates humidity readings every 3 seconds from 3 sensors:
- **Kitchen** (60-75%)
- **Bedroom** (45-60%)
- **Outside** (25-85%)
---
## Verify Messages
Check that messages are flowing:
```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic humidity_readings --from-beginning --max-messages 3
background: false
session: 2
```
You should see JSON messages like:
```json
{"sensor_id":1,"location":"kitchen","humidity":65,"read_at":1733584800}
```
---
## Access Kafka UI

Switch to the Kafka UI dashboard to visualize the cluster:

```dashboard:open-dashboard
name: Kafka UI
```

You can explore:
- Topics and partitions
- Messages
- Consumer groups
---
## Environment Ready! ✅
You now have:
- ✅ Kafka running
- ✅ Topic created (3 partitions)
- ✅ Producer generating data
- ✅ Consumer application built
**Time used:** ~10 minutes  
**Next:** Build your first consumer! →
