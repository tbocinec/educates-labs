# Kafka CLI Tools Workshop

Master essential Kafka command-line tools through hands-on practice with a live 3-node cluster.

## What You'll Learn

This workshop covers **8 essential Kafka CLI tools** with practical scenarios:

### 🎯 Core Topics

1. **kafka-topics** - Topic lifecycle management
2. **kafka-console-producer** - Publishing messages from command line
3. **kafka-console-consumer** - Consuming and filtering messages
4. **kafka-consumer-groups** - Consumer group management and lag monitoring
5. **kafka-reassign-partitions** - Partition rebalancing across brokers
6. **kafka-log-dirs** - Disk usage analysis and capacity planning
7. **kafka-configs** - Dynamic broker and topic configuration

### 💡 Why CLI Tools?

- ⚡ **Instant troubleshooting** - No GUI dependencies in production
- 🔧 **Automation-ready** - Script DevOps workflows and CI/CD pipelines
- 🎓 **Deep understanding** - See exactly what Kafka is doing
- 🐛 **Production debugging** - Essential for incident response
- 📊 **Real-time monitoring** - Live cluster health checks

### 🖥️ Lab Environment

**3-Node Kafka Cluster** (KRaft mode):
- `kafka-1`, `kafka-2`, `kafka-3` - Brokers with IDs 1, 2, 3
- **Replication Factor**: 3 (high availability)
- **Min ISR**: 2 (data durability)
- **Kafka UI**: Available on port 8080 for visualization

### 📚 Workshop Structure

Each level focuses on one tool with:
1. **Syntax & Options** - Core commands and parameters
2. **Use Cases** - Real-world scenarios
3. **Hands-on Practice** - Click-to-execute examples
4. **Best Practices** - Production recommendations
5. **Common Pitfalls** - Error handling

### ⏱️ Duration

**90 minutes** - Each level takes 10-15 minutes

### 🚀 Who Should Attend

**Ideal for:**
- Kafka administrators and operators
- DevOps/SRE engineers
- Backend developers using Kafka
- Data engineers building pipelines
- Anyone managing Kafka in production

**Prerequisites:**
- Basic understanding of Kafka concepts (topics, partitions, consumers)
- Familiarity with command line
- No prior CLI tools experience needed

### 🎓 Learning Outcomes

After completing this workshop, you'll be able to:
- ✅ Manage Kafka topics without a GUI
- ✅ Debug consumer lag and offset issues
- ✅ Rebalance partitions for performance optimization
- ✅ Monitor disk usage and plan capacity
- ✅ Configure brokers and topics dynamically
- ✅ Automate Kafka operations with scripts

### 🛠️ Learning Approach

**Hands-on first** - Learn by doing, not just reading. All commands are ready to execute.

Every command is **clickable** (`terminal:execute`), so:
- ❌ No copying/pasting needed
- ✅ Just click and see results
- ✅ Focus on understanding, not syntax

## Lesson Structure

### Level 1: CLI Introduction
Environment setup and cluster connectivity

### Level 2: kafka-topics
Creating, describing, and managing topics

### Level 3: kafka-console-producer  
Sending messages with keys and properties

### Level 4: kafka-console-consumer
Reading messages, filtering, and consuming from specific offsets

### Level 5: kafka-consumer-groups
Managing consumer groups, lag monitoring, and offset resets

### Level 6: kafka-reassign-partitions
Rebalancing partitions across brokers

### Level 7: kafka-log-dirs
Analyzing disk usage and broker storage

### Level 8: kafka-configs
Dynamic broker and topic configuration

## Why a 3-node cluster?

A single-node cluster cannot demonstrate:
- ❌ Replication
- ❌ Partition reassignment
- ❌ Leader election
- ❌ Rack awareness
- ❌ ISR (In-Sync Replicas)

**3-node cluster** = Production-like environment!

## Ready to start?

Click **Continue** and let's set up the environment! 🚀

### Useful Information

**Bootstrap Servers:**
```
From host: localhost:9092,localhost:9093,localhost:9094
Inside container: kafka-1:19092,kafka-2:19092,kafka-3:19092
```

**Kafka UI:**
```
http://localhost:8080
```

**Command Help:**
Every Kafka CLI tool has `--help`:
```bash
kafka-topics --help
kafka-console-producer --help
# etc.
```

---

**Tip:** Keep terminals and Kafka UI open side-by-side - you'll see CLI changes instantly in the GUI! 🎯
