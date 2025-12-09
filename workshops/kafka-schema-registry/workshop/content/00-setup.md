# Setup: Getting Started with Schema Registry

Welcome to the Kafka Schema Registry workshop! In this setup module, you'll start the environment and verify everything is ready.

## Workshop Environment

Your Educates environment includes:
- ☕ **Java 21** - For running Kafka applications
- 🐳 **Docker** - For Kafka, Schema Registry, and Kafka UI
- 📦 **Maven** - For building Java applications
- 🛠️ **Helper scripts** - For schema management

## Starting the Environment

### Step 1: Make Scripts Executable

First, let's make all shell scripts executable:

```terminal:execute
command: chmod +x build-apps.sh run-producer.sh run-consumer.sh verify-setup.sh scripts/*.sh
session: 1
```

This ensures all helper scripts can be run throughout the workshop.

### Step 2: Start All Services

Let's start Kafka, Schema Registry, and Kafka UI using Docker Compose:

```terminal:execute
command: docker compose up -d
session: 1
```

This will start three containers:
- **kafka** - Apache Kafka broker (port 9092)
- **schema-registry** - Confluent Schema Registry (port 8081)
- **kafka-ui** - Web-based management UI (port 8080)

While services are starting (~60 seconds), let's inspect the Docker Compose configuration:

```editor:open-file
file: docker-compose.yml
```

This file defines:
- **Kafka broker** on port 9092
- **Schema Registry** on port 8081
- **Kafka UI** on port 8080
- Health checks and dependencies between services

### Step 3: Wait for Services to Start

It takes about 60 seconds for all services to become healthy. Check the status:

```terminal:execute
command: docker compose ps
session: 1
```

You should see all three services with status `healthy`.

If services aren't ready yet, wait a moment and check again:

```terminal:execute
command: sleep 30 && docker compose ps
session: 1
```

### Step 4: Verify Kafka

Check that Kafka is accepting connections:

```terminal:execute
command: docker exec -it kafka kafka-broker-api-versions --bootstrap-server localhost:9092
session: 1
```

You should see a list of API versions - this means Kafka is ready!

### Step 5: Verify Schema Registry

Check that Schema Registry is running and accessible:

```terminal:execute
command: curl http://localhost:8081/subjects
session: 1
```

**Expected output:** `[]` (empty list - no schemas registered yet)

This empty list is normal - we haven't registered any schemas yet!

### Step 6: Open Kafka UI

Kafka UI provides a web interface to explore Kafka topics, messages, and schemas.

Switch to the Kafka UI dashboard:

```dashboard:open-dashboard
name: Kafka UI
```

You should see:
- 📊 Cluster overview
- 📝 Topics (currently empty)
- 🔍 Schema Registry (no schemas yet)

## Build Workshop Applications

Now let's build the producer and consumer applications that we'll use throughout the workshop.

### Build All Applications

Run the build script to compile both producer and consumer:

```terminal:execute
command: ./build-apps.sh
session: 1
```

**What's happening:**
1. 🔧 Maven Avro Plugin reads `schemas/order-v1.avsc`
2. 🏗️ Generates Java classes from Avro schema (`OrderCreated.java`)
3. ⚙️ Compiles producer application
4. ⚙️ Compiles consumer application
5. 📦 Creates executable JAR files

**Build time:** ~2 minutes (first build downloads dependencies)

**Expected output:**
```
Building producer-avro...
[INFO] BUILD SUCCESS
Building consumer-avro...
[INFO] BUILD SUCCESS
✅ Build complete!
```

## Quick Test: Your First Schema-Validated Messages

Let's do a quick end-to-end test to verify everything works!

### Terminal 1: Start the Producer

In this terminal, start the producer that will send order events:

```terminal:execute
command: ./run-producer.sh
session: 1
```

**What you'll see:**
```
🛒 Starting Order Producer with Avro Schema Registry
📊 Topic: orders
🔗 Schema Registry: http://localhost:8081

✅ Order sent: ORD-A3F2 | Customer: CUST-002 | Product: LAPTOP-PRO | Qty: 2 | $2599.98
   📍 Partition: 0 | Offset: 0
✅ Order sent: ORD-B7E1 | Customer: CUST-001 | Product: WIRELESS-MOUSE | Qty: 1 | $29.99
   📍 Partition: 0 | Offset: 1
```

**Behind the scenes:**
1. Producer registers Avro schema with Schema Registry → gets schema ID `1`
2. Producer serializes order data using Avro format
3. Message sent to Kafka with schema ID embedded: `[0x00][ID=1][Avro data]`

**Let it run** - we'll consume these messages in the next step.

### Terminal 2: Start the Consumer

Open a second terminal and start the consumer:

```terminal:execute
command: ./run-consumer.sh
session: 2
```

**What you'll see:**
```
🛒 Starting Order Consumer with Avro Schema Registry
📊 Topic: orders
👥 Group: order-processor-group

═══════════════════════════════════════════════
📦 Order Received #1
───────────────────────────────────────────────
   Order ID:    ORD-A3F2
   Customer:    CUST-002
   Product:     LAPTOP-PRO
   Quantity:    2
   Total Price: $2599.98
═══════════════════════════════════════════════
```

**Behind the scenes:**
1. Consumer reads message from Kafka
2. Extracts schema ID from message (first 5 bytes)
3. Fetches schema from Registry using that ID
4. Deserializes Avro data into Java object
5. Displays order details

### Verify Schema Registration

Check that the schema was automatically registered:

```terminal:execute
command: curl http://localhost:8081/subjects
session: 1
```

**Expected output:** `["orders-value"]`

Get schema details:

```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions/latest | jq .
session: 1
```

You'll see:
- **subject:** `orders-value` (Kafka topic + `-value` suffix)
- **version:** `1` (first version)
- **id:** `1` (globally unique schema ID)
- **schema:** The full Avro schema JSON

### Stop the Applications

Stop the producer and consumer when ready (Ctrl+C in each terminal).

## What Just Happened?

🎉 **Congratulations!** You just experienced schema-based data governance in action:

1. ✅ **Producer** registered an Avro schema → Schema Registry assigned ID `1`
2. ✅ **Messages** were serialized with schema ID embedded
3. ✅ **Consumer** automatically discovered and fetched the schema
4. ✅ **Type safety** ensured - only valid data was accepted
5. ✅ **No manual coordination** needed between producer and consumer!

### The Magic of Schema Registry

Without Schema Registry:
```
Producer → JSON → Kafka → Consumer
                    ↓
              Hope consumer knows the format! 🤞
              Hope field names match! 🤞
              Hope types are correct! 🤞
```

With Schema Registry:
```
Producer → Register Schema → Get ID → Avro → Kafka
                    ↓                          ↓
            Schema Registry ← Fetch Schema ← Consumer
                    ↓
              Guaranteed compatibility! ✅
              Automatic schema discovery! ✅
              Type safety enforced! ✅
```

## Environment Overview

You now have a fully functional Kafka Schema Registry environment:

| Service | Port | Purpose |
|---------|------|---------|
| Kafka | 9092 | Message broker |
| Schema Registry | 8081 | Schema management & validation |
| Kafka UI | 8080 | Web-based management console |

**Total memory used:** ~1.7GB (optimized for workshops)

## Common Issues & Solutions

### Port Already in Use

If you see port conflicts:

```terminal:execute
command: docker compose down && docker compose up -d
session: 1
```

### Schema Registry Not Starting

Check the logs:

```terminal:execute
command: docker logs schema-registry
session: 1
```

Common issue: Kafka not ready yet. Wait 30 seconds and check again.

### Build Failures

Clean and rebuild:

```terminal:execute
command: cd kafka-apps/producer-avro && mvn clean install -U
session: 1
```

## Ready to Learn!

✅ Environment running  
✅ Applications built  
✅ Quick test successful  
✅ Ready for the workshop!

### What's Next?

In the following modules, you'll learn:

- **Module 1:** Why data governance matters (real-world examples)
- **Module 2:** Register schemas and produce messages
- **Module 3:** Consume with automatic schema resolution
- **Module 4:** Schema evolution and compatibility modes
- **Module 5:** Governance in action (prevent breaking changes)

### Workshop Duration

⏱️ **Estimated time:** 90 minutes total

Let's get started! 🚀

---

**💡 Tip:** Keep the Kafka UI dashboard open in a separate tab to visualize what's happening as you progress through the workshop.

**🔍 Troubleshooting:** If anything goes wrong, check `docker compose ps` and `docker logs <container-name>` for diagnostics.

