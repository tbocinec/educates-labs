# Kafka Producers Essentials

A condensed 45-minute hands-on workshop covering the core concepts of Apache Kafka producers using humidity sensor data.

## Workshop Overview

**Duration:** 45 minutes  
**Level:** Beginner to Intermediate  
**Focus:** Core producer concepts with hands-on practice

## What You'll Learn

In 45 minutes, you'll master the essentials:

✅ **Producer Basics** - ProducerRecord and its components  
✅ **Keys & Partitioning** - How keys determine ordering  
✅ **Async vs Sync** - Send modes and callbacks  
✅ **Error Handling** - Production-ready patterns  

## Workshop Modules

### Module 1: Quick Start (8 min)
- Start Kafka environment
- Create topic with multiple partitions
- Build producer application

### Module 2: ProducerRecord Essentials (8 min)
- Understanding ProducerRecord components
- Keys, values, and headers
- Key role in ordering

### Module 3: Keys → Partitioning → Ordering (12 min)
- Partitioning rules and strategies
- How keys guarantee ordering
- Sticky partitioner for keyless messages

### Module 4: Async vs Sync Send (10 min)
- Async send (default and preferred)
- Callbacks for error handling
- Sync send and when to use it

### Module 5: Error Handling & Flushing (7 min)
- Common producer errors
- Proper error handling with callbacks
- When to flush (and when NOT to)

### Module 6: Wrap-Up (5 min)
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
cd workshops/kafka-producers-essentials

# Start services
docker compose up -d

# Build applications
./build-apps.sh

# Run producer (basic mode)
./run-producer-basic.sh

# Run producer (with callbacks)
./run-producer-callback.sh

# Run producer (sync mode)
./run-producer-sync.sh
```

## What's Different from Consumer Workshop?

This producers workshop:
- ✅ Focuses on producer-specific concepts
- ✅ Three producer implementations (basic, callback, sync)
- ✅ Hands-on partitioning and ordering exercises
- ✅ Perfect for understanding producer patterns

**Companion workshop:** See `kafka-consumers-essentials` for the consumer side

## Prerequisites

- Basic Java knowledge
- Understanding of messaging concepts (helpful)
- Docker installed
- Maven installed

---

Ready to learn Kafka producers in 45 minutes? Let's go! 🚀

