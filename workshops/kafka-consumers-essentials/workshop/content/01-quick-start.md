# Quick Start - Setup Environment
Welcome! In this workshop, you'll learn Kafka consumer essentials through hands-on practice.
---
## 🎯 What You'll Learn
1. **Quick Start** (10 min) - Get Kafka running
2. **First Consumer** (15 min) - Consumer basics
3. **Manual Commit** (15 min) - Control offsets
4. **Wrap-Up** (5 min) - Best practices
---
## Start Kafka Services
Start Kafka and Kafka UI:
```terminal:execute
command: cd /home/eduk8s && docker compose up -d
background: false
```
Wait ~20 seconds for services to be healthy:
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
command: ./run-producer.sh
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
```
You should see JSON messages like:
```json
{"sensor_id":1,"location":"kitchen","humidity":65,"read_at":1733584800}
```
---
## Access Kafka UI
Open Kafka UI to visualize the cluster:
**URL:** http://localhost:8080
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
