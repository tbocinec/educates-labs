# Your First Consumer
Learn the core concepts by running a Kafka consumer in AUTO-COMMIT mode.
---
## Learning Goals (15 minutes)
* Understand consumer groups  
* See the poll loop in action  
* Learn auto-commit behavior  
* Monitor consumer lag  
---
## Consumer Architecture
Consumer groups enable parallel processing!
---
## Run Consumer (Auto-Commit Mode)
Our consumer starts in AUTO-COMMIT mode by default.
```terminal:execute
command: ./run-consumer.sh
background: false
```
**Let it run for 30-60 seconds** to see multiple readings.
Press Ctrl+C when done observing.
---
## Understanding the Output
Each message shows:
- **Location & Humidity** - Sensor data
- **Key** - Message key (sensor-1, sensor-2, sensor-3)
- **Partition** - Which partition (0, 1, or 2)
- **Offset** - Position in partition
**Notice:** Same sensor always goes to same partition! (Key-based partitioning)
---
## The Poll Loop
The heart of every consumer - must keep polling or be considered dead.
---
## Consumer Groups
Check your consumer group:
```terminal:execute
command: docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group humidity-monitor
background: false
```
---
## Auto-Commit Behavior
With auto-commit enabled:
- Offsets saved every 5 seconds automatically
- Happens in background during poll()
- Simple but has risks!
This is **AT-MOST-ONCE** delivery.
---
## Check Consumer Lag in Kafka UI
Open Kafka UI: http://localhost:8080
1. Navigate to **Consumer Groups**
2. Find **humidity-monitor** group
3. View **Offsets** tab
**Healthy consumer:** Lag is low and stable
---
## Key Concepts Review
**Consumer Group:** Consumers with same group.id share partitions  
**Poll Loop:** Heart of the consumer  
**Auto-Commit:** Commits every 5 seconds automatically  
**Lag:** Difference between latest message and consumed position  
---
## Time Check
**Time used:** ~15 minutes  
**Next:** Learn manual offset control for safer processing!
