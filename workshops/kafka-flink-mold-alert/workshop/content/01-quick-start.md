# Quick Start - Setup Environment

Welcome! In this workshop, you'll learn how to use Apache Flink to process streaming data from Kafka.

---

## 🎯 What You'll Learn

In this hands-on workshop, you will:

1. **Quick Start** (10 min) - Set up Kafka, Flink, and data generators
2. **Understanding the Problem** (5 min) - Learn about mold detection
3. **Build Flink Job** (15 min) - Create a stream processing job with Java
4. **Deploy & Monitor** (15 min) - Run the job and see results
5. **Experimentation** (10 min) - Modify and extend the logic
6. **Flink SQL** (15 min) - Solve the same problem with SQL (declarative approach)
7. **Wrap-Up** (5 min) - Best practices and next steps

**Total Duration:** ~75 minutes (60 min core + 15 min SQL bonus)

---

## 🧪 The Use Case: Mold Alert System

**The Problem:** Mold grows when humidity exceeds 70%. We need to monitor multiple humidity sensors and alert when dangerous levels are detected.

**The Solution:** Use Flink to:
- Filter sensor readings for humidity > 70%
- Tag critical readings with alert status
- Route alerts to a separate Kafka topic

**Why Flink?**
- Real-time processing (sub-second latency)
- Fault-tolerant and scalable
- Easy integration with Kafka

---
Prerequisite for excercises Flink SQL connectors
```terminal:execute
command: mkdir flink-connectors
background: false
session: 1
```

## Make Scripts Executable

First, let's make all shell scripts executable:

```terminal:execute
command: chmod +x build-flink-job.sh submit-flink-job.sh start-datagen.sh setup-flink-sql-connectors.sh scripts/verify-setup.sh
background: false
session: 1
```

This ensures all helper scripts can be run throughout the workshop.

---

## Start Infrastructure Services

Start Kafka, Flink, Kafka Connect, and Kafka UI:

```terminal:execute
command: cd /home/eduk8s && docker compose up -d
background: false
session: 1
```

This will start:
- **Kafka broker** (port 9092)
- **Kafka UI** (port 8080)
- **Kafka Connect** with Datagen (port 8083)
- **Flink JobManager** (port 8081)
- **Flink TaskManager**

While services are starting (~60 seconds), let's inspect the Docker Compose configuration:

```editor:open-file
file: docker-compose.yml
```

This file defines all infrastructure components with health checks and resource limits optimized for the workshop environment.

---

## Verify Services

Check that all services are healthy:

```terminal:execute
command: ./scripts/verify-setup.sh
background: false
session: 1
```

All checks should show ✅. If any service is not ready, wait 30 seconds and run the verification again.

---

## Create Kafka Topics

Create the input and output topics:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic raw_sensors --partitions 3 --replication-factor 1 --if-not-exists
background: false
session: 1
```

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic critical_sensors --partitions 1 --replication-factor 1 --if-not-exists
background: false
session: 1
```

**Topic Architecture:**
- `raw_sensors`: Receives all sensor data (3 partitions for parallelism)
- `critical_sensors`: Contains only high-humidity alerts (1 partition)

---

## Access Dashboards

Now let's explore the running services:

### Kafka UI

Switch to the Kafka UI dashboard to visualize the cluster:

```dashboard:open-dashboard
name: Kafka UI
```

You should see:
- Both topics we just created
- No messages yet (we haven't started the data generator)

### Flink Dashboard

Switch to the Flink dashboard:

```dashboard:open-dashboard
name: Flink UI
```

You should see:
- JobManager status: Running
- TaskManager: 1 available with 2 task slots
- No jobs running yet

---

## Start Data Generator

Now let's generate some realistic sensor data using Kafka Connect Datagen:

```terminal:execute
command: ./start-datagen.sh
background: false
session: 1
```

This registers a connector that generates random humidity sensor readings with:
- **sensor_id**: sensor-01 through sensor-05
- **location**: basement, bathroom, kitchen, bedroom, living-room, garage
- **humidity**: Random values between 30% and 95%
- **temperature**: Random values between 15°C and 30°C
- **timestamp**: Current time

The generator produces one message every 2 seconds.

---

## Verify Data Flow

Let's peek at the incoming sensor data:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic raw_sensors --from-beginning --max-messages 5
background: false
session: 2
```

You should see JSON messages like:

```json
{"sensor_id":"sensor-03","location":"bathroom","humidity":78,"temperature":24,"timestamp":1700000003000}
{"sensor_id":"sensor-01","location":"basement","humidity":85,"temperature":19,"timestamp":1700000004000}
{"sensor_id":"sensor-02","location":"kitchen","humidity":52,"temperature":22,"timestamp":1700000005000}
```

Notice that humidity values vary. Some are above 70% (mold risk), others are safe.

---

## Quick Start Complete! ✅

You now have:
- ✅ Kafka running with 2 topics created
- ✅ Flink cluster ready (JobManager + TaskManager)
- ✅ Data generator producing sensor readings
- ✅ Kafka UI and Flink UI accessible

**Next:** We'll build and deploy a Flink job to filter and alert on dangerous humidity levels.

---

