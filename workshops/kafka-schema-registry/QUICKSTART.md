# Quick Start Guide

Get up and running with the Kafka Schema Registry workshop in 10 minutes!

## Prerequisites

- Docker & Docker Compose installed
- Java 17+ installed
- Maven 3.8+ installed
- curl and jq installed (optional, for scripts)

## Quick Setup (5 minutes)

### 1. Start the Environment

```bash
docker compose up -d
```

Wait for all services to be healthy (~60 seconds):

```bash
docker compose ps
```

You should see:
- ✅ kafka (healthy)
- ✅ schema-registry (healthy)
- ✅ kafka-ui (healthy)

### 2. Verify Services

**Kafka:**
```bash
docker exec -it kafka kafka-broker-api-versions --bootstrap-server localhost:9092
```

**Schema Registry:**
```bash
curl http://localhost:8081/subjects
```

Expected: `[]` (empty list)

**Kafka UI:**
Open http://localhost:8080 in your browser

### 3. Build Applications

```bash
./build-apps.sh
```

This will:
- Generate Java classes from Avro schemas
- Compile producer and consumer applications
- Create executable JAR files

Build time: ~2 minutes

## Quick Demo (5 minutes)

### Terminal 1: Start Producer

```bash
./run-producer.sh
```

You'll see orders being produced:
```
✅ Order sent: ORD-A3F2 | Customer: CUST-002 | Product: LAPTOP-PRO | Qty: 2 | $2599.98
   📍 Partition: 0 | Offset: 0
```

### Terminal 2: Start Consumer

```bash
./run-consumer.sh
```

You'll see orders being consumed:
```
📦 Order Received #1
   Order ID:    ORD-A3F2
   Customer:    CUST-002
   Product:     LAPTOP-PRO
   Total Price: $2599.98
```

### Terminal 3: Explore Schema Registry

List registered schemas:
```bash
curl http://localhost:8081/subjects | jq .
```

Get schema details:
```bash
curl http://localhost:8081/subjects/orders-value/versions/latest | jq .
```

## What Just Happened?

1. **Producer** registered the Avro schema with Schema Registry
2. **Schema Registry** assigned schema ID `1`
3. **Producer** serialized messages with schema ID embedded
4. **Consumer** fetched schema by ID and deserialized messages
5. **Type safety** ensured - invalid data rejected automatically!

## Next Steps

### Follow the Workshop

Start with Module 1:
```bash
cat workshop/content/01-introduction.md
```

Or jump to specific topics:
- Module 2: Register and Produce with Schemas
- Module 3: Consume with Schema Registry
- Module 4: Schema Evolution & Compatibility
- Module 5: Governance in Action

### Experiment with Schema Evolution

Try registering a new schema version:
```bash
cd scripts
./register-schema.sh orders-value ../schemas/order-v2-compatible.avsc
```

Check compatibility first:
```bash
./check-compatibility.sh orders-value ../schemas/order-v2-compatible.avsc
```

### Explore Kafka UI

Visit http://localhost:8080 and explore:
- Topics → orders (see messages)
- Schema Registry (browse schemas)
- Consumer Groups (monitor lag)

## Common Issues

### Port Already in Use

```bash
# Stop services
docker compose down

# Check what's using the port
netstat -ano | findstr :9092
netstat -ano | findstr :8081
netstat -ano | findstr :8080
```

### Schema Registry Not Starting

```bash
# Check logs
docker logs schema-registry

# Common issue: Kafka not ready
# Solution: Wait longer or restart
docker compose restart schema-registry
```

### Build Failures

```bash
# Clean and rebuild
cd kafka-apps/producer-avro
mvn clean install -U

cd ../consumer-avro
mvn clean install -U
```

## Clean Up

Stop all services:
```bash
docker compose down
```

Remove volumes (complete reset):
```bash
docker compose down -v
```

## Ready to Learn?

🎓 **Start the workshop:** `workshop/content/01-introduction.md`

📚 **Full README:** `README.md`

💡 **Scripts:** Check `scripts/` directory for helper tools

---

**Estimated time to complete workshop:** 90 minutes

**Support:** Open an issue or ask in the workshop session!

