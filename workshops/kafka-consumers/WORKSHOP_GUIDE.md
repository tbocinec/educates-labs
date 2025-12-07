# Kafka Consumers Workshop - Complete Guide

## Overview

This workshop provides a comprehensive deep dive into Apache Kafka consumers, covering everything from basic concepts to advanced production patterns. Using a real-world humidity sensor monitoring scenario, participants will build multiple consumer implementations and master key concepts.

## Workshop Structure

### Duration
**2.5 - 3 hours** (including hands-on exercises and experimentation)

### Target Audience
- Developers with basic Java knowledge
- Engineers working with event streaming platforms
- Teams implementing Kafka-based systems
- Anyone wanting to master Kafka consumer patterns

### Prerequisites
- Basic understanding of messaging systems (helpful but not required)
- Familiarity with Java programming
- Understanding of JSON format
- Command-line experience

## Domain Model: Humidity Sensor Monitoring

### Scenario
You're building a **humidity monitoring system** with three sensors continuously sending readings to Kafka:

1. **Kitchen Sensor** (ID: 1) - High moisture area from cooking
2. **Bedroom Sensor** (ID: 2) - Climate-controlled indoor space
3. **Outside Sensor** (ID: 3) - Variable outdoor weather conditions

### Message Format

**Topic:** `humidity_readings`

**Message Structure:**
```json
{
  "sensor_id": 1,
  "location": "kitchen",
  "humidity": 65,
  "read_at": 1764636954
}
```

**Message Key:** `sensor-{sensor_id}` (ensures readings from same sensor go to same partition)

**Partitions:** 3 (enables parallel processing)

## Workshop Modules

### Module 1: Environment Setup (15 min)
**File:** `01-environment-setup.md`

**Topics:**
- Starting Kafka and Kafka UI with Docker Compose
- Creating the humidity_readings topic
- Building Java applications with Maven
- Starting the humidity sensor producer
- Verifying message flow

**Hands-on:**
- Start Docker services
- Create topic with 3 partitions
- Build all consumer applications
- Start producer generating sensor data
- View messages via console consumer

### Module 2: Consumer Basics (25 min)
**File:** `02-consumer-basics.md`

**Topics:**
- Consumer architecture and components
- Consumer groups and partition assignment
- Poll loop mechanics
- Auto-commit offset management
- ConsumerRecord structure

**Hands-on:**
- Run basic consumer with auto-commit
- Observe partition assignment
- Monitor consumer group status
- Check offset storage
- Understand delivery semantics

**Code:** `consumer-basic/src/main/java/com/example/HumidityConsumerBasic.java`

### Module 3: Understanding ConsumerRecords (20 min)
**File:** `03-consumer-records.md`

**Topics:**
- ConsumerRecord structure deep dive
- Metadata fields (topic, partition, offset, timestamp)
- Message keys vs values
- Headers usage
- Offset semantics and gaps

**Hands-on:**
- Inspect message metadata
- Analyze partition distribution
- Verify key-based partitioning
- Examine offset patterns
- Check message sizes

### Module 4: Manual Offset Management (30 min)
**File:** `04-manual-offset-management.md`

**Topics:**
- Auto-commit vs manual commit
- At-least-once delivery semantics
- Synchronous vs asynchronous commits
- Per-partition offset tracking
- Handling duplicates

**Hands-on:**
- Run manual commit consumer
- Observe batch processing
- Test message reprocessing
- Reset consumer offsets
- Compare with auto-commit behavior

**Code:** `consumer-manual/src/main/java/com/example/HumidityConsumerManual.java`

### Module 5: Partition Rebalancing (25 min)
**File:** `05-rebalancing-demo.md`

**Topics:**
- What triggers rebalancing
- Partition reassignment process
- Assignment strategies (Range, RoundRobin, CooperativeSticky)
- Rebalance listeners
- Timeout configurations

**Hands-on:**
- Observe single consumer with all partitions
- Add second consumer and trigger rebalance
- Remove consumer and observe reassignment
- Monitor partition movement
- Experiment with rebalance listeners

### Module 6: Consumer Configuration (25 min)
**File:** `06-consumer-configuration.md`

**Topics:**
- Essential reliability configurations
- Performance tuning parameters
- Timeout settings (session, heartbeat, poll interval)
- Configuration profiles for different use cases
- Memory considerations

**Hands-on:**
- Review configuration templates
- Tune max.poll.records
- Experiment with fetch parameters
- Test different profiles
- Monitor configuration impact

### Module 7: Multithreaded Consumer (30 min)
**File:** `07-multithreaded-consumer.md`

**Topics:**
- Thread-safety constraints
- Single consumer + worker pool pattern
- Backpressure handling
- Offset commit coordination
- Performance optimization

**Hands-on:**
- Run multithreaded consumer
- Observe parallel processing
- Monitor worker thread activity
- Compare with single-threaded throughput
- Test backpressure handling

**Code:** `consumer-multithreaded/src/main/java/com/example/HumidityConsumerMultithreaded.java`

### Module 8: Error Handling (25 min)
**File:** `08-error-handling.md`

**Topics:**
- Common error scenarios
- Retry strategies (exponential backoff, fibonacci, jittered)
- Dead Letter Queue (DLQ) pattern
- Circuit breaker implementation
- Poison pill handling

**Hands-on:**
- Create DLQ topic
- Implement retry logic
- Test error scenarios
- Monitor DLQ messages
- Circuit breaker demonstration

### Module 9: Kafka UI Exploration (20 min)
**File:** `09-kafka-ui-exploration.md`

**Topics:**
- Navigating Kafka UI
- Monitoring consumer groups and lag
- Inspecting messages and partitions
- Troubleshooting common issues
- Topic and configuration management

**Hands-on:**
- Explore topic details
- Monitor consumer lag
- Inspect individual messages
- Debug stuck consumers
- Use UI for troubleshooting

### Module 10: Summary and Best Practices (15 min)
**File:** `99-summary.md`

**Topics:**
- Production deployment patterns
- Monitoring and alerting strategies
- Security best practices
- Performance optimization tips
- Common pitfalls to avoid

**Review:**
- Configuration checklist
- Error handling template
- Graceful shutdown pattern
- Monitoring metrics
- Testing strategies

## Technical Components

### Applications

#### 1. Humidity Producer
**Location:** `kafka-apps/producer/`

**Purpose:** Simulates three humidity sensors continuously sending readings

**Features:**
- Generates readings every 2-5 seconds
- Randomized humidity values per sensor range
- JSON serialization with Jackson
- Proper key-based partitioning
- Production-ready error handling

**Run:** `./run-producer.sh`

#### 2. Basic Consumer (Auto-commit)
**Location:** `kafka-apps/consumer-basic/`

**Purpose:** Demonstrates simplest consumer pattern with auto-commit

**Features:**
- Auto-commit offset management
- Simple poll loop
- JSON deserialization
- Formatted output display
- Graceful shutdown

**Run:** `./run-consumer-basic.sh`

#### 3. Manual Commit Consumer
**Location:** `kafka-apps/consumer-manual/`

**Purpose:** Shows manual offset management for at-least-once semantics

**Features:**
- Manual synchronous commits
- Batch processing
- Per-partition offset tracking
- Alert detection (high/low humidity)
- Proper error handling

**Run:** `./run-consumer-manual.sh`

#### 4. Multithreaded Consumer
**Location:** `kafka-apps/consumer-multithreaded/`

**Purpose:** Implements worker pool pattern for higher throughput

**Features:**
- ThreadPoolExecutor with bounded queue
- Parallel message processing
- Backpressure handling (CallerRunsPolicy)
- Wait-for-completion before commit
- Processing metrics (success/failure counters)
- Humidity analysis logic

**Run:** `./run-consumer-multithreaded.sh`

### Infrastructure

#### Docker Compose Services

**Kafka Broker:**
- Image: `confluentinc/cp-kafka:7.7.1`
- Mode: KRaft (no Zookeeper)
- Port: 9092
- Optimized for workshop environment

**Kafka UI:**
- Image: `provectuslabs/kafka-ui:v0.7.2`
- Port: 8080
- Full cluster visualization

### Build System

**Maven:**
- Java 21 target
- Kafka Clients 3.8.0
- Jackson 2.18.1 for JSON
- SLF4J for logging
- Exec Maven Plugin for easy running

## Learning Outcomes

By completing this workshop, participants will:

### Fundamental Understanding
✅ Understand consumer groups and how partitions are assigned  
✅ Master the poll loop and its critical role  
✅ Know when to use auto-commit vs manual commit  
✅ Understand offset semantics and storage  

### Configuration Mastery
✅ Configure consumers for different use cases  
✅ Tune performance parameters appropriately  
✅ Set timeouts correctly to avoid rebalancing  
✅ Choose the right assignment strategy  

### Advanced Patterns
✅ Implement multithreaded consumers safely  
✅ Handle errors with retries and DLQ  
✅ Manage backpressure with bounded queues  
✅ Coordinate offset commits with async processing  

### Operational Skills
✅ Monitor consumer lag and health  
✅ Troubleshoot common consumer issues  
✅ Use Kafka UI for debugging  
✅ Deploy consumers in production  

## File Structure

```
kafka-consumers/
├── README.md                           # Workshop overview
├── docker-compose.yml                  # Infrastructure setup
├── build-apps.sh                       # Build all Java apps
├── run-producer.sh                     # Start producer
├── run-consumer-basic.sh              # Start basic consumer
├── run-consumer-manual.sh             # Start manual consumer
├── run-consumer-multithreaded.sh      # Start multithreaded consumer
│
├── kafka-apps/                        # Java applications
│   ├── producer/                      # Humidity sensor producer
│   │   ├── pom.xml
│   │   └── src/main/java/com/example/
│   │       └── HumidityProducer.java
│   │
│   ├── consumer-basic/                # Basic auto-commit consumer
│   │   ├── pom.xml
│   │   └── src/main/java/com/example/
│   │       └── HumidityConsumerBasic.java
│   │
│   ├── consumer-manual/               # Manual commit consumer
│   │   ├── pom.xml
│   │   └── src/main/java/com/example/
│   │       └── HumidityConsumerManual.java
│   │
│   └── consumer-multithreaded/        # Worker pool consumer
│       ├── pom.xml
│       └── src/main/java/com/example/
│           └── HumidityConsumerMultithreaded.java
│
├── resources/                         # Educates resources
│   └── workshop.yaml                  # Workshop definition
│
└── workshop/                          # Workshop content
    ├── config.yaml                    # Content structure
    └── content/                       # Markdown modules
        ├── 01-environment-setup.md
        ├── 02-consumer-basics.md
        ├── 03-consumer-records.md
        ├── 04-manual-offset-management.md
        ├── 05-rebalancing-demo.md
        ├── 06-consumer-configuration.md
        ├── 07-multithreaded-consumer.md
        ├── 08-error-handling.md
        ├── 09-kafka-ui-exploration.md
        └── 99-summary.md
```

## Key Concepts Covered

### Consumer Fundamentals
- Consumer groups and partition assignment
- Poll loop mechanics
- Offset management (auto vs manual)
- ConsumerRecord structure
- Rebalancing triggers and behavior

### Delivery Semantics
- At-most-once (auto-commit)
- At-least-once (manual commit)
- Exactly-once (transactional)
- Idempotent processing

### Configuration Categories
- Connection and security
- Group management
- Offset behavior
- Performance tuning
- Reliability and timeouts

### Design Patterns
- Single consumer per thread
- Consumer + worker pool
- Dead Letter Queue (DLQ)
- Circuit breaker
- Retry with exponential backoff

### Operational Concerns
- Monitoring consumer lag
- Troubleshooting rebalancing
- Handling errors gracefully
- Graceful shutdown
- Production deployment

## Instructor Notes

### Setup Before Workshop
1. Ensure Docker and Docker Compose are installed
2. Test that Kafka starts successfully
3. Verify Java 21 is available
4. Confirm Maven can download dependencies
5. Test all shell scripts work

### Common Issues and Solutions

**Issue:** Kafka won't start  
**Solution:** Check port 9092 not in use, increase Docker memory

**Issue:** Maven build fails  
**Solution:** Clear ~/.m2 cache, check internet connection

**Issue:** Consumer can't connect  
**Solution:** Verify Kafka is healthy, check bootstrap.servers config

**Issue:** Rebalancing constantly  
**Solution:** Increase session.timeout.ms and max.poll.interval.ms

### Timing Recommendations
- Don't rush through configuration section - it's critical
- Allow time for experimentation in multithreaded module
- Rebalancing demo needs patience to observe
- Let participants explore Kafka UI independently

### Extension Activities
1. Implement custom deserializer with schema registry
2. Add metrics collection with Prometheus
3. Implement exactly-once processing with transactions
4. Create custom partition assignor
5. Build consumer application with Kafka Streams

## Best Practices Demonstrated

✅ Manual commit for critical data  
✅ Bounded queues for backpressure  
✅ Graceful shutdown handling  
✅ Comprehensive error handling  
✅ Dead Letter Queue for failed messages  
✅ Monitoring and observability  
✅ Production-ready configuration  
✅ Thread-safe consumer usage  

## Additional Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Confluent Developer Resources](https://developer.confluent.io/)
- [Kafka: The Definitive Guide (Book)](https://www.confluent.io/resources/kafka-the-definitive-guide/)

## Support and Feedback

For questions or issues with this workshop:
- Check the troubleshooting section in each module
- Review common pitfalls in the summary
- Consult Apache Kafka documentation
- Ask in community forums

---

**Version:** 1.0  
**Last Updated:** December 7, 2025  
**Kafka Version:** 3.8.0  
**Java Version:** 21

