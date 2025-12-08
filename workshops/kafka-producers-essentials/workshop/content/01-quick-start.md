# Quick Start - Setup Environment

Welcome! In this workshop, you'll learn Kafka producer essentials through hands-on practice.

---

## 🎯 What You'll Learn

1. **Quick Start** (8 min) - Get Kafka running
2. **ProducerRecord** (8 min) - Understanding components
3. **Keys & Partitioning** (12 min) - Ordering guarantees
4. **Async vs Sync** (10 min) - Send modes
5. **Error Handling** (7 min) - Production patterns
6. **Wrap-Up** (5 min) - Best practices

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

Create the `humidity_readings` topic with 3 partitions:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic humidity_readings --partitions 3 --replication-factor 1 --if-not-exists
background: false
```

**Why 3 partitions?**
- Demonstrates key-based partitioning
- Shows how keys determine partition
- Enables parallel consumer processing

---

## Build Producer Applications

Build all three producer variants:

```terminal:execute
command: ./build-apps.sh
background: false
```

This compiles:
- ✅ Basic async producer
- ✅ Producer with callbacks
- ✅ Synchronous producer

Takes about 30 seconds...

---

## Producer Variants Overview

We have 3 producer implementations to explore:

**1. Basic Async Producer**
- Fire-and-forget pattern
- Highest throughput
- Minimal error visibility

**2. Callback Producer**
- Async with error handling
- Production-ready pattern
- Best balance of performance and safety

**3. Sync Producer**
- Blocking calls
- Guaranteed delivery confirmation
- Lowest throughput (demo only)

---

## Verify Kafka is Ready

Check that the topic exists:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list
background: false
```

You should see `humidity_readings` in the list.

---

## Access Kafka UI

Switch to tab **Kafka UI** to visualize the cluster:

You can explore:
- Topics and partitions
- Messages in real-time
- Partition distribution

---

## Environment Ready! ✅

You now have:
- ✅ Kafka running (KRaft mode)
- ✅ Topic created (3 partitions)
- ✅ Three producer applications built
- ✅ Kafka UI accessible

**Time used:** ~8 minutes  
**Next:** Learn ProducerRecord essentials! →

