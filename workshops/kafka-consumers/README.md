# Kafka Consumers Deep Dive

Advanced workshop exploring Apache Kafka consumer patterns using humidity sensor data. Master consumer groups, offset management, rebalancing, and multithreading with real Java applications.

## Workshop Features

- 🌡️ **Real-World Domain** - Humidity sensor readings from kitchen, bedroom, and outdoor locations
- ☕ **Java JDK 21** - Modern Java with latest features
- 🔨 **Multiple Consumer Patterns** - Basic, manual commit, and multithreaded implementations
- 🐳 **Docker Compose** - Kafka with KRaft mode (no Zookeeper needed)
- 📊 **Kafka UI** - Visual monitoring and message exploration
- 🚀 **Automatic Setup** - Services and topics start automatically

## What You'll Learn

### 🎯 **Core Consumer Concepts**
- Consumer groups and partition assignment
- Poll loop mechanics and timeout handling
- ConsumerRecord structure and metadata
- Offset management strategies
- Rebalancing behavior and triggers

### 📝 **Offset Management**
- Auto-commit vs manual commit patterns
- Commit timing and delivery semantics
- At-least-once vs at-most-once processing
- Handling duplicates and processing failures

### ⚙️ **Consumer Configuration**
- Essential reliability settings
- Performance tuning parameters
- Session timeouts and heartbeats
- Max poll interval configuration

### 🔄 **Advanced Patterns**
- Partition rebalancing strategies
- Multithreaded consumer patterns
- Error handling and retry logic
- Backpressure management

## Workshop Steps

1. **Environment Setup** - Verify Kafka and sensor data producer
2. **Consumer Basics** - Build and run your first consumer
3. **Understanding ConsumerRecords** - Explore message structure and metadata
4. **Manual Offset Management** - Implement manual commit patterns
5. **Rebalancing in Action** - Observe partition reassignment
6. **Consumer Configuration** - Tune performance and reliability
7. **Multithreaded Consumer** - Implement worker pool pattern
8. **Error Handling** - Handle failures and implement retry logic
9. **Kafka UI Exploration** - Visual analysis and monitoring
10. **Summary** - Best practices and production considerations

## Domain Model

### 🌡️ Humidity Sensor Data

Topic: `humidity_readings`

```json
{
  "sensor_id": 1,
  "location": "kitchen",
  "humidity": 65,
  "read_at": 1764636954
}
```

**Sensor Locations:**
- **Kitchen** (sensor_id: 1) - Indoor high-moisture area
- **Bedroom** (sensor_id: 2) - Indoor climate-controlled space
- **Outside** (sensor_id: 3) - Outdoor weather monitoring

**Message Key:** `sensor-{sensor_id}` (ensures readings from same sensor go to same partition)

## Technical Stack

- **Apache Kafka 7.7.1** with KRaft mode
- **Java 21** with Maven build system
- **Kafka UI 0.7.2** for visual management
- **Docker Compose** for service orchestration
- **Jackson** for JSON serialization/deserialization

## Prerequisites

Basic Java knowledge helpful. No prior Kafka experience required - we'll cover everything from fundamentals to advanced patterns.

## Duration

Approximately 2-3 hours including hands-on exercises, experimentation, and discussion.

---

Ready to master Kafka consumers? Let's dive in! 🚀

