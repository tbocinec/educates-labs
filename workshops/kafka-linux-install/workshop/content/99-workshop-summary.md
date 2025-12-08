# Workshop Summary

Congratulations! You've successfully completed the Apache Kafka on Linux workshop.

## What You Learned

### 1. Kafka Installation
- ✅ Downloaded and installed Apache Kafka binaries
- ✅ Set up environment variables
- ✅ Understood Kafka directory structure

### 2. KRaft Mode
- ✅ Learned about KRaft (Kafka without Zookeeper)
- ✅ Generated cluster IDs
- ✅ Formatted storage directories
- ✅ Started Kafka in KRaft mode

### 3. Single Broker Operations
- ✅ Started a single Kafka broker
- ✅ Created topics with partitions
- ✅ Produced messages using console producer
- ✅ Consumed messages using console consumer
- ✅ Worked with consumer groups

### 4. Multi-Broker Cluster
- ✅ Configured a 3-node cluster (1 controller + 2 brokers)
- ✅ Created replicated topics
- ✅ Tested broker failover
- ✅ Verified replica synchronization
- ✅ Monitored cluster health

## Key Concepts Mastered

### KRaft Architecture
- **No Zookeeper dependency** - Simplified deployment
- **Metadata quorum** - Built-in consensus protocol
- **Faster failover** - Improved reliability

### Replication
- **High availability** - Data survives broker failures
- **In-Sync Replicas (ISR)** - Ensures data consistency
- **Leader election** - Automatic failover

### Cluster Management
- **Node roles** - Controllers vs Brokers
- **Partition distribution** - Load balancing
- **Configuration management** - Multiple properties files

## Architecture Overview

```
┌─────────────────────────────────────────┐
│         KRaft Cluster                    │
│                                          │
│  ┌──────────────┐                       │
│  │ Controller   │  (Manages metadata)   │
│  │   Node 1     │                       │
│  │ Port: 9093   │                       │
│  └──────────────┘                       │
│         │                                │
│    ┌────┴────┐                          │
│    │         │                          │
│ ┌──▼────┐ ┌──▼────┐                    │
│ │Broker │ │Broker │  (Handle data)     │
│ │Node 2 │ │Node 3 │                    │
│ │  9092 │ │  9094 │                    │
│ └───────┘ └───────┘                    │
│                                          │
│  Topics with replication factor 2       │
│  spread across both brokers             │
└─────────────────────────────────────────┘
```

## Common Commands Reference

### Cluster Management
```bash
# Start controller
kafka-server-start.sh config/controller.properties

# Start broker
kafka-server-start.sh config/broker1.properties

# Stop all Kafka processes
pkill -f kafka.Kafka
```

### Topic Operations
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

# Delete topic
kafka-topics.sh --delete --topic my-topic \
  --bootstrap-server localhost:9092
```

### Producer/Consumer
```bash
# Console producer
kafka-console-producer.sh --topic my-topic \
  --bootstrap-server localhost:9092

# Console consumer
kafka-console-consumer.sh --topic my-topic \
  --from-beginning --bootstrap-server localhost:9092

# Consumer group details
kafka-consumer-groups.sh --describe \
  --group my-group --bootstrap-server localhost:9092
```

## Production Best Practices

### Cluster Sizing
- Minimum 3 controllers for production
- Add brokers based on throughput requirements
- Separate controller and broker roles in large clusters

### Replication
- Use replication factor ≥ 3 for critical data
- Set min.insync.replicas = 2 for durability
- Monitor ISR health regularly

### Configuration
- Tune `num.partitions` for parallelism
- Configure `log.retention.hours` based on storage
- Set appropriate `socket.buffer` sizes for network

### Monitoring
- Track broker CPU/memory/disk usage
- Monitor under-replicated partitions
- Watch consumer lag
- Use Kafka UI or JMX metrics

## Next Steps

Now that you know Kafka basics, explore:

1. **Kafka Connect** - Integration with external systems
2. **Kafka Streams** - Stream processing applications
3. **Schema Registry** - Manage Avro/JSON schemas
4. **Security** - SSL/SASL authentication, ACLs
5. **Performance Tuning** - Optimize throughput and latency

## Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [KRaft Mode Guide](https://kafka.apache.org/documentation/#kraft)
- [Kafka Operations Guide](https://kafka.apache.org/documentation/#operations)

## Thank You!

Great job completing this workshop! You now have the skills to:
- Install and configure Kafka in KRaft mode
- Manage multi-broker clusters
- Handle topic operations and replication
- Troubleshoot common issues

Happy streaming! 🚀
