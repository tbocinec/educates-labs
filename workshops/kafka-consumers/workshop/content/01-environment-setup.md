# Environment Setup and Producer

Welcome to the **Kafka Consumers Deep Dive** workshop! In this comprehensive session, you'll master Kafka consumer patterns using real-world humidity sensor data.

## 🌡️ Workshop Scenario

You're building a **humidity monitoring system** with three sensors:
- **Kitchen** (Sensor 1) - High moisture area from cooking
- **Bedroom** (Sensor 2) - Climate-controlled indoor space  
- **Outside** (Sensor 3) - Variable outdoor weather conditions

Each sensor continuously sends humidity readings to Kafka, and you'll build consumers to process this data in various ways.

---

## Workshop Environment

Your environment includes:
- ☕ **Java JDK 21** - Modern Java development
- 🐳 **Docker Compose** - Kafka and Kafka UI services
- 🔨 **Maven** - Java build tool
- 📝 **Multiple Consumer Apps** - Ready to build and run

---

## Start Kafka Services

First, let's start Kafka and Kafka UI using Docker Compose:

```terminal:execute
command: cd /home/eduk8s && docker compose up -d
background: false
```

**What this starts:**
- **Kafka broker** with KRaft mode (port 9092)
- **Kafka UI** web interface (port 8080)

---

## Verify Services

Check that services are running:

```terminal:execute
command: docker compose ps
background: false
```

You should see both services as **healthy**.

---

## Create Topic

Create the `humidity_readings` topic with 3 partitions:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic humidity_readings --partitions 3 --replication-factor 1 --if-not-exists
background: false
```

**Why 3 partitions?**
- Enables parallel processing by multiple consumers
- Each sensor's messages go to same partition (via key)
- Demonstrates consumer group behavior

Verify the topic was created:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic humidity_readings
background: false
```

---

## Build Applications

Build all Java applications (producer and consumers):

```terminal:execute
command: ./build-apps.sh
background: false
```

This compiles:
- ✅ Humidity sensor producer
- ✅ Basic consumer (auto-commit)
- ✅ Manual commit consumer
- ✅ Multithreaded consumer

---

## Start the Producer

Start the humidity sensor data producer in the background:

```terminal:execute
command: ./run-producer.sh
background: true
```

The producer will continuously generate sensor readings every 2-5 seconds.

**Sample output:**
```
📨 [1] Sensor 2 (bedroom): 54% humidity → partition 1, offset 0
📨 [2] Sensor 1 (kitchen): 68% humidity → partition 0, offset 0
📨 [3] Sensor 3 (outside): 42% humidity → partition 2, offset 0
```

---

## Check Messages in Kafka

Verify messages are being produced:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic humidity_readings --from-beginning --max-messages 5
background: false
```

You should see JSON messages like:
```json
{"sensor_id":1,"location":"kitchen","humidity":65,"read_at":1764636954}
```

---

## Access Kafka UI

Open Kafka UI in your browser to visualize the data:

- **URL:** http://localhost:8080
- Navigate to **Topics** → **humidity_readings**
- See messages, partitions, and consumer groups

---

## Key Concepts Introduced

✅ **Topic with multiple partitions** - Enables parallel processing  
✅ **Message keys** - `sensor-{id}` ensures order per sensor  
✅ **Continuous producer** - Simulates real-time data stream  
✅ **JSON payload** - Structured sensor data

---

## Next Steps

Now that your environment is ready and data is flowing, you'll build your first consumer! 🚀

