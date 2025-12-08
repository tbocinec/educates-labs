# Apache Kafka on Linux - KRaft Mode Installation Workshop

This workshop teaches you how to install and configure Apache Kafka in KRaft mode on Ubuntu Linux, progressing from a single broker to a multi-broker cluster.

## Workshop Overview

### What You'll Learn

- Install Apache Kafka binaries on Linux
- Configure Kafka in KRaft mode (without Zookeeper)
- Start and manage a single Kafka broker
- Create topics and produce/consume messages
- Scale to a multi-broker cluster with replication
- Test failover and high availability
- Monitor Kafka with Kafka UI

### Prerequisites

- Basic Linux command line knowledge
- Understanding of distributed systems concepts
- Familiarity with Kafka fundamentals (topics, producers, consumers)

### Duration

Approximately 2 hours

## Workshop Structure

### Level 1: Installation & Setup
- Download and install Kafka binaries
- Understand directory structure
- Set environment variables

### Level 2: Single Broker
- Configure KRaft mode
- Start a Kafka broker
- Verify broker is running

### Level 3: Basic Operations
- Create topics with partitions
- Produce messages using console producer
- Consume messages using console consumer
- Work with consumer groups

### Level 4: Multi-Broker Cluster
- Configure 3-node cluster (1 controller + 2 brokers)
- Format storage for each node
- Start the cluster
- Verify cluster health

### Level 5: Cluster Operations
- Create replicated topics
- Test broker failover
- Verify replica synchronization
- Monitor cluster with Kafka UI

## Architecture

The workshop demonstrates two architectures:

### Single Broker (Level 1-3)
```
┌────────────────┐
│  Kafka Broker  │
│  (KRaft Mode)  │
│   Port: 9092   │
└────────────────┘
```

### Multi-Broker Cluster (Level 4-5)
```
┌─────────────────────────────────────────┐
│         KRaft Cluster                    │
│                                          │
│  ┌──────────────┐                       │
│  │ Controller   │  (Metadata)           │
│  │   Node 1     │                       │
│  │ Port: 9093   │                       │
│  └──────────────┘                       │
│         │                                │
│    ┌────┴────┐                          │
│    │         │                          │
│ ┌──▼────┐ ┌──▼────┐                    │
│ │Broker │ │Broker │  (Data)            │
│ │Node 2 │ │Node 3 │                    │
│ │  9092 │ │  9094 │                    │
│ └───────┘ └───────┘                    │
└─────────────────────────────────────────┘
```

## Key Concepts Covered

### KRaft Mode
- Kafka without Zookeeper
- Built-in metadata quorum using Raft consensus
- Simplified deployment and operations
- Better scalability and performance

### Cluster Management
- Node roles (controller vs broker)
- Cluster ID generation
- Storage formatting
- Configuration management

### Replication & High Availability
- Replication factor
- In-Sync Replicas (ISR)
- Leader election
- Failover testing

## Files Included

### Workshop Content
- `workshop/content/` - Step-by-step instructions in Markdown
- `workshop/config.yaml` - Workshop configuration

### Configuration Files
- `resources/workshop.yaml` - Educates workshop definition

### Helper Scripts
- `scripts/kafka-helper.sh` - Utility script for common operations
- `docker-compose.yml` - Kafka UI setup

## Helper Script Usage

The workshop includes a helper script for common operations:

```bash
# Interactive mode
./scripts/kafka-helper.sh

# Command mode
./scripts/kafka-helper.sh start-ui      # Start Kafka UI
./scripts/kafka-helper.sh stop-ui       # Stop Kafka UI
./scripts/kafka-helper.sh stop-all      # Stop all Kafka processes
./scripts/kafka-helper.sh status        # Check cluster status
./scripts/kafka-helper.sh logs broker1  # View broker logs
./scripts/kafka-helper.sh cleanup       # Clean up data
```

## Kafka UI

The workshop includes Kafka UI for visual monitoring:

- **URL**: http://localhost:8080
- **Features**:
  - Topic management
  - Message browser
  - Consumer group monitoring
  - Broker statistics
  - Cluster overview

Start Kafka UI:
```bash
docker-compose up -d
```

## Common Commands Reference

### Topic Management
```bash
# Create topic
kafka-topics.sh --create --topic my-topic \
  --partitions 3 --replication-factor 2 \
  --bootstrap-server localhost:9092

# List topics
kafka-topics.sh --list --bootstrap-server localhost:9092

# Describe topic
kafka-topics.sh --describe --topic my-topic \
  --bootstrap-server localhost:9092
```

### Producer/Consumer
```bash
# Console producer
kafka-console-producer.sh --topic my-topic \
  --bootstrap-server localhost:9092

# Console consumer from beginning
kafka-console-consumer.sh --topic my-topic \
  --from-beginning --bootstrap-server localhost:9092

# Consumer group info
kafka-consumer-groups.sh --describe \
  --group my-group --bootstrap-server localhost:9092
```

### Cluster Management
```bash
# Start controller
kafka-server-start.sh config/controller.properties

# Start broker
kafka-server-start.sh config/broker1.properties

# Stop all
pkill -f kafka.Kafka
```

## Troubleshooting

### Broker Won't Start
- Check Java version: `java -version` (need Java 11+)
- Verify storage is formatted: `kafka-storage.sh format ...`
- Check logs: `tail -f ~/kafka/logs/kafka.log`
- Ensure port 9092 is available: `netstat -tlnp | grep 9092`

### Topics Not Creating
- Verify broker is running: `ps aux | grep kafka.Kafka`
- Check connectivity: `telnet localhost 9092`
- Review broker logs for errors

### Cluster Issues
- Ensure all nodes have same cluster ID
- Verify controller.quorum.voters is correct
- Check network listeners in configuration
- Confirm storage formatted for each node

## Production Considerations

This workshop uses simplified configurations suitable for learning. For production:

1. **Security**: Enable SSL/SASL authentication
2. **Replication**: Use RF ≥ 3 for critical topics
3. **Resources**: Allocate adequate CPU, memory, disk
4. **Monitoring**: Set up comprehensive monitoring (JMX, metrics)
5. **Backup**: Regular data backups
6. **Separation**: Run controllers on separate hardware

## Next Steps After Workshop

- Explore Kafka Connect for data integration
- Learn Kafka Streams for stream processing
- Study Schema Registry for schema management
- Implement security (SSL, ACLs)
- Performance tuning and optimization

## Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [KRaft Mode Guide](https://kafka.apache.org/documentation/#kraft)
- [Kafka Operations](https://kafka.apache.org/documentation/#operations)

## License

This workshop is provided for educational purposes.

## Author

Educates Workshop Team

---

**Happy Learning!** 🚀
