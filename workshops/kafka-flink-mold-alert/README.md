# Kafka + Flink: Real-Time Mold Alert System

A hands-on workshop demonstrating stream processing with Apache Flink and Kafka through a practical IoT use case.

## 🎯 Workshop Overview

**Duration:** 75 minutes (60 min core + 15 min SQL bonus)  
**Difficulty:** Beginner  
**Prerequisites:** Basic understanding of Java and event-driven systems (SQL knowledge helpful but not required)

### What You'll Build

A real-time humidity monitoring system that:
- Ingests sensor data from multiple locations
- Filters readings exceeding mold-risk threshold (>70% humidity)
- Enriches alerts with status and severity metadata
- Routes critical events to a separate Kafka topic

### The Use Case: Mold Detection

Mold growth is a serious health and property concern. It thrives when humidity exceeds 70%. This workshop simulates a network of humidity sensors in different locations (basement, bathroom, kitchen, etc.) and demonstrates how to build a real-time alerting system using stream processing.

## 🏗️ Architecture

```
┌──────────────────┐
│ Kafka Connect    │  Datagen Connector
│ (Data Generator) │  Simulates 5 sensors
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  raw_sensors     │  Input Topic
│  (Kafka Topic)   │  All sensor readings
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Flink Job       │  Stream Processing
│  • Filter        │  humidity > 70
│  • Transform     │  Add alert metadata
│  • Enrich        │  Severity levels
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ critical_sensors │  Output Topic
│  (Kafka Topic)   │  Only alerts
└──────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Java 11 or higher
- Maven 3.6+
- Basic command-line knowledge

### Start the Environment

```bash
# Make scripts executable
chmod +x *.sh scripts/*.sh

# Start infrastructure
docker compose up -d

# Verify services
./scripts/verify-setup.sh
```

### Create Topics

```bash
# Input topic (all sensor data)
docker exec kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic raw_sensors --partitions 3 --replication-factor 1

# Output topic (alerts only)
docker exec kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic critical_sensors --partitions 1 --replication-factor 1
```

### Start Data Generator

```bash
./start-datagen.sh
```

This registers a Kafka Connect Datagen connector that produces realistic sensor data:
- **sensor_id**: sensor-01 through sensor-05
- **location**: basement, bathroom, kitchen, bedroom, living-room, garage
- **humidity**: 30-95% (random)
- **temperature**: 15-30°C (random)
- **timestamp**: Current time
- **Interval**: Every 2 seconds

### Build and Deploy Flink Job

```bash
# Build the Flink application
./build-flink-job.sh

# Submit to Flink cluster
./submit-flink-job.sh
```

### (Optional) Setup Flink SQL

If you want to try the Flink SQL module:

```bash
# Install Kafka connector for SQL client
./setup-flink-sql-connectors.sh

# Restart Flink to load the connector
docker restart flink-jobmanager

# Wait ~10 seconds, then start SQL client
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh
```

### Monitor the Pipeline

**Flink Dashboard:** http://localhost:8081
- View running jobs
- Monitor task execution
- Check metrics and logs

**Kafka UI:** http://localhost:8080
- Browse topics and messages
- Compare input vs output rates
- Visualize data flow

**Console Consumer:**
```bash
# Watch alerts in real-time
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic critical_sensors \
  --from-beginning
```

## 📚 Workshop Contents

The workshop is structured in progressive modules:

### 1. Quick Start (10 min)
- Set up Kafka, Flink, and Kafka Connect
- Create topics and start data generation
- Verify infrastructure with dashboards

### 2. Understanding the Logic (5 min)
- Learn about the mold detection problem
- Understand the data flow architecture
- Review input vs output examples

### 3. Build the Flink Job (15 min)
- Examine the Java source code
- Understand Source → Transform → Sink pattern
- Build the application with Maven

### 4. Deploy and Monitor (15 min)
- Submit job to Flink cluster
- Monitor execution in real-time
- Verify filtering and transformation logic
- Compare input/output message rates

### 5. Experimentation (10 min)
- Modify the humidity threshold
- Add location-based filtering
- Implement severity levels (MODERATE, HIGH, CRITICAL)
- Rebuild and redeploy

### 6. Wrap-Up (5 min)
- Review key concepts and patterns
- Best practices for production
- Next steps and advanced topics

## 🧪 Key Learning Objectives

### Stream Processing Fundamentals
- ✅ Source → Transform → Sink pattern
- ✅ Stateless transformations (filter, map)
- ✅ Real-time event processing
- ✅ Kafka integration with Flink

### Practical Skills
- ✅ Configure Flink Kafka sources and sinks
- ✅ Implement filtering logic
- ✅ Transform and enrich events
- ✅ Deploy and monitor Flink jobs
- ✅ Build fat JARs with Maven Shade plugin

### Patterns and Use Cases
- ✅ The Filter Pattern (anomaly detection, alerting)
- ✅ The Enrichment Pattern (metadata, calculated fields)
- ✅ The Router Pattern (conditional routing, priorities)
- ✅ Real-world IoT monitoring scenarios

## 🛠️ Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| Apache Kafka | 7.7.1 (Confluent) | Message broker |
| Apache Flink | 1.18 | Stream processing engine |
| Kafka Connect | 7.5.0 | Data integration |
| Datagen Connector | 0.6.2 | Test data generation |
| Kafka UI | 0.7.2 | Web-based Kafka viewer |
| Java | 11 | Application runtime |
| Maven | 3.x | Build tool |
| Jackson | 2.15.3 | JSON processing |

## 📁 Project Structure

```
kafka-flink-mold-alert/
├── docker-compose.yml              # Infrastructure definition
├── build-flink-job.sh              # Build script
├── submit-flink-job.sh             # Deployment script
├── start-datagen.sh                # Data generator setup
├── flink-app/
│   ├── pom.xml                     # Maven configuration
│   └── src/main/java/com/workshop/
│       └── MoldAlertJob.java       # Main Flink application
├── schemas/
│   └── datagen-connector.json      # Connector configuration
├── scripts/
│   └── verify-setup.sh             # Environment verification
├── workshop/
│   ├── config.yaml                 # Workshop metadata
│   └── content/
│       ├── 01-quick-start.md
│       ├── 02-understanding-logic.md
│       ├── 03-build-job.md
│       ├── 04-deploy-monitor.md
│       ├── 05-experimentation.md
│       └── 99-wrap-up.md
└── resources/
    └── workshop.yaml               # Educates configuration
```

## 🔍 Code Highlights

### Filter Logic

```java
DataStream<String> criticalStream = sensorStream
    .filter(jsonString -> {
        JsonNode node = mapper.readTree(jsonString);
        int humidity = node.get("humidity").asInt();
        return humidity > HUMIDITY_THRESHOLD; // Core logic
    });
```

### Transform and Enrich

```java
.map(jsonString -> {
    ObjectNode node = (ObjectNode) mapper.readTree(jsonString);
    node.put("status", "CRITICAL_MOLD_RISK");
    node.put("alert_time", System.currentTimeMillis());
    return node.toString();
});
```

### Kafka Source Configuration

```java
KafkaSource<String> source = KafkaSource.<String>builder()
    .setBootstrapServers("kafka:29092")
    .setTopics("raw_sensors")
    .setGroupId("mold-alert-group")
    .setStartingOffsets(OffsetsInitializer.earliest())
    .setValueOnlyDeserializer(new SimpleStringSchema())
    .build();
```

### Kafka Sink Configuration

```java
KafkaSink<String> sink = KafkaSink.<String>builder()
    .setBootstrapServers("kafka:29092")
    .setRecordSerializer(
        KafkaRecordSerializationSchema.builder()
            .setTopic("critical_sensors")
            .setValueSerializationSchema(new SimpleStringSchema())
            .build()
    )
    .build();
```

## 🧩 Extending the Workshop

### Challenge Ideas

1. **Windowed Aggregations**
   - Calculate 5-minute average humidity per sensor
   - Alert when average exceeds threshold

2. **Stateful Processing**
   - Track consecutive high readings
   - Alert only after 3+ consecutive violations

3. **Complex Event Processing**
   - Detect rapid humidity increases (>10% in 5 minutes)
   - Pattern matching with Flink CEP

4. **Multi-Topic Routing**
   - Route MODERATE alerts to one topic
   - Route CRITICAL alerts to another
   - Use side outputs

5. **External Enrichment**
   - Look up sensor metadata from external database
   - Add weather data from REST API

## 📊 Sample Data

### Input Message (raw_sensors)

```json
{
  "sensor_id": "sensor-02",
  "location": "bathroom",
  "humidity": 78,
  "temperature": 24,
  "timestamp": 1700000002000
}
```

### Output Message (critical_sensors)

```json
{
  "sensor_id": "sensor-02",
  "location": "bathroom",
  "humidity": 78,
  "temperature": 24,
  "timestamp": 1700000002000,
  "status": "CRITICAL_MOLD_RISK",
  "alert_time": 1733850123456
}
```

## 🐛 Troubleshooting

### Services Not Starting

```bash
# Check service status
docker compose ps

# View logs
docker compose logs kafka
docker compose logs jobmanager

# Restart services
docker compose restart
```

### Build Failures

```bash
# Clean Maven cache
cd flink-app && mvn clean

# Rebuild with debug info
mvn package -X
```

### Job Not Processing Data

```bash
# Check Flink job status
docker exec flink-jobmanager flink list

# View job logs
docker logs flink-taskmanager

# Verify Kafka topics have data
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic raw_sensors --from-beginning --max-messages 5
```

### Connector Issues

```bash
# Check connector status
curl http://localhost:8083/connectors/humidity-datagen-source/status

# Restart connector
curl -X POST http://localhost:8083/connectors/humidity-datagen-source/restart
```

## 🧹 Cleanup

### Stop Services

```bash
docker compose down
```

### Remove All Data

```bash
docker compose down -v
```

## 📖 Additional Resources

### Official Documentation
- [Apache Flink Documentation](https://flink.apache.org/docs/)
- [Flink Kafka Connector](https://nightlies.apache.org/flink/flink-docs-stable/docs/connectors/datastream/kafka/)
- [Kafka Documentation](https://kafka.apache.org/documentation/)

### Learning Resources
- [Flink Forward Conference](https://www.flink-forward.org/)
- [Ververica Blog](https://www.ververica.com/blog)
- [Confluent Kafka Tutorials](https://kafka-tutorials.confluent.io/)

### Community
- [Apache Flink Slack](https://flink.apache.org/community.html)
- [Stack Overflow - apache-flink](https://stackoverflow.com/questions/tagged/apache-flink)

## 📝 License

This workshop is provided for educational purposes.

## 🤝 Contributing

Feedback and contributions are welcome! Please open an issue or submit a pull request.

## 👥 Authors

Kafka Flink Workshop Team

---

**Happy Stream Processing!** 🚀

