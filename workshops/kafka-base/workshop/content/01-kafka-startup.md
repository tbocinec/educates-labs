# Kafka Startup

Kafka and Kafka UI have been automatically started in the background when this workshop session began.

**Workshop Environment:**
- ☕ **Java JDK 21** - ready for Kafka development
- 📝 **Text Editor** - accessible via **Editor** tab at the top
- 🐳 **Docker** - for service management

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

## Docker Compose Structure

Our setup contains:

```yaml
services:
  kafka:          # Apache Kafka broker
    ports:
      - "9092:9092"  # Kafka API
  
  kafka-ui:       # Graphical interface
    ports: 
      - "8080:8080"  # Web UI
```

Docker Compose is the simplest way to quickly start Kafka services with automatic networking and dependencies.

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

If you need to troubleshoot, you can check the setup logs:

```terminal:execute
command: cat /tmp/kafka-setup.log
background: false
```

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

**Follow logs in real-time:**

```terminal:execute
command: docker compose logs -f kafka
background: true
```

**Show resource usage:**

```terminal:execute
command: docker stats kafka kafka-ui --no-stream
background: false  
```

**Check network connectivity:**

```terminal:execute
command: docker compose exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092
background: false
```

---

## Troubleshooting

**If Kafka won't start:**
1. Check logs: `docker compose logs kafka`
2. Restart: `docker compose restart kafka`
3. Full restart: `docker compose down && docker compose up -d`

**If Kafka UI is not available:**
1. Verify Kafka is running: `docker compose ps kafka`  
2. Check Kafka UI logs: `docker compose logs kafka-ui`
3. Try refreshing the page

---

✅ **Kafka is now started and ready to use!**

Continue to the next step for Hello World example.