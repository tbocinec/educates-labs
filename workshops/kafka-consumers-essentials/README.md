# Kafka Consumers Essentials

A condensed 45-minute hands-on workshop covering the core concepts of Apache Kafka consumers using humidity sensor data.

## Workshop Overview

**Duration:** 45 minutes  
**Level:** Beginner to Intermediate  
**Focus:** Core consumer concepts with hands-on practice

## What You'll Learn

In 45 minutes, you'll master the essentials:

✅ **Consumer Basics** - Groups, partitions, and the poll loop  
✅ **Offset Management** - Auto-commit vs manual commit  
✅ **Message Processing** - Reading and parsing Kafka messages  
✅ **Monitoring** - Using Kafka UI to monitor consumers  

## Workshop Modules

### Module 1: Quick Start (10 min)
- Start Kafka environment
- Create topic and start producer
- Build consumer application

### Module 2: Your First Consumer (15 min)
- Consumer groups and partition assignment
- The poll loop in action
- Auto-commit offset management
- Monitoring consumer lag

### Module 3: Manual Offset Control (15 min)
- Why manual commit matters
- Implementing at-least-once processing
- Handling message reprocessing

### Module 4: Wrap-Up (5 min)
- Key concepts review
- Production best practices
- Next steps

## Domain: Humidity Sensors

Three sensors monitoring humidity levels:
- **Kitchen** (Sensor 1) - 60-75% range
- **Bedroom** (Sensor 2) - 45-60% range
- **Outside** (Sensor 3) - 25-85% range

**Message Format:**
```json
{
  "sensor_id": 1,
  "location": "kitchen",
  "humidity": 65,
  "read_at": 1764636954
}
```

## Technical Stack

- **Apache Kafka 7.7.1** (KRaft mode)
- **Java 21**
- **Maven**
- **Docker Compose**
- **Kafka UI 0.7.2**

## Quick Start

```bash
# Navigate to workshop
cd workshops/kafka-consumers-essentials

# Start services
docker compose up -d

# Build applications
./build-apps.sh

# Start producer
./run-producer.sh &

# Run consumer
./run-consumer.sh
```

## What's Different from Full Workshop?

This essentials workshop:
- ✅ Focuses on core concepts
- ✅ One consumer implementation (covers both auto and manual commit)
- ✅ Streamlined hands-on exercises
- ✅ Perfect for quick introduction or time-constrained sessions

**For deep dive:** See the full `kafka-consumers` workshop (3 hours)

## Prerequisites

- Basic Java knowledge
- Understanding of messaging concepts (helpful)
- Docker installed
- Maven installed

---

Ready to learn Kafka consumers in 45 minutes? Let's go! 🚀

