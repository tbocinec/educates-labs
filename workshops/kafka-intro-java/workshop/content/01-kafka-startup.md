# Kafka Startup and Environment

Kafka and Kafka UI have been automatically started in the background when this workshop session began. A test topic `test-messages` has also been created for you.

**Workshop Environment:**
- ☕ **Java JDK 21** - ready for Kafka development
- 📝 **Text Editor** - accessible via **Editor** tab at the top
- 🐳 **Docker** - for service management
- 🔨 **Maven** - for building Java applications

---

## What is Apache Kafka?

**Apache Kafka** is an open-source distributed streaming platform designed for:
- **High-throughput** real-time message processing
- **Fault-tolerance** - resilience to failures
- **Scalability** - horizontal scaling

**Key components:**
- **Broker** - Server that stores and processes messages
- **Topic** - Channel for messages (like conversation topic)  
- **Producer** - Application that sends messages
- **Consumer** - Application that reads messages

---

## Docker Compose Setup

We use Docker Compose as the simplest way to quickly start Kafka services:

```yaml
services:
  kafka:          # Apache Kafka broker with KRaft mode
    ports:
      - "9092:9092"  # Kafka API
  
  kafka-ui:       # Graphical interface
    ports: 
      - "8080:8080"  # Web UI
```

Docker Compose automatically handles service orchestration, networking, and dependencies.

---

## Verifying Services

To verify that Kafka is running, use:

```terminal:execute
command: docker compose ps
background: false
```

**Expected output:**
- ✅ `kafka` - (healthy)  
- ✅ `kafka-ui` - (healthy)

---

## Check Created Topic

Verify that the test topic was created automatically:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list
background: false
```

You should see the `test-messages` topic in the output.

---

## Accessing Kafka UI

Once services are running, you can access the Kafka UI dashboard:

- **URL:** http://localhost:8080
- **Dashboard** tab at the top of the workshop

**In Kafka UI you can:**
- 📊 Monitor Kafka cluster status
- 📝 Create and manage topics
- 💬 Send and read messages
- 🔍 Monitor metrics

---

## Useful Commands

**View service logs:**

```terminal:execute
command: docker compose logs kafka
background: false
```

**View all logs:**

```terminal:execute
command: docker compose logs
background: false
```

**Restart services if needed:**

```terminal:execute  
command: docker compose restart
background: false
```