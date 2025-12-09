# 🎯 Kafka CLI Tools - Workshop Summary

Congratulations! You've successfully completed the Kafka CLI Tools Mastery workshop! 🎉

---

## ✅ What You've Learned

### 1️⃣ CLI Introduction
- Where Kafka CLI tools are located
- How to use `--help` for each tool
- Environment setup (aliases, bootstrap-server)
- Testing cluster connectivity
- **Key Concept**: Docker container access pattern - connect once, stay inside

### 2️⃣ kafka-topics
- `--create` - Creating topics with partitions and replication factor
- `--list` - List all topics
- `--describe` - Topic details (partitions, replicas, ISR, leader)
- `--alter` - Change partitions and configs
- `--delete` - Delete topics
- **Use Cases**: DLQ topics, high-throughput topics, testing topics

### 3️⃣ kafka-console-producer
- Basic message sending
- Sending with keys (`--property parse.key=true`)
- Custom partitioning (`--partition`)
- Producer properties (acks, compression, batch.size)
- JSON messages
- Performance testing
- **Use Cases**: Testing, manual data injection, debugging

### 4️⃣ kafka-console-consumer
- Reading from beginning vs. latest
- Consumer groups (`--group`)
- Formatting output (keys, timestamps, partitions, offsets)
- Reading specific partition and offset
- Consumer properties (auto-commit, fetch sizes)
- Filtering and grepping
- **Use Cases**: Debugging, monitoring, testing

### 5️⃣ kafka-consumer-groups
- `--list` - List consumer groups
- `--describe` - LAG monitoring (critical!)
- `--reset-offsets` - Replay messages (to-earliest, to-latest, by-duration, shift-by)
- `--delete` - Delete inactive groups
- Group states and members
- **Use Cases**: Lag monitoring, replay after bug fix, skip corrupted messages

### 6️⃣ kafka-reassign-partitions
- `--generate` - Generate reassignment plan
- `--execute` - Execute reassignment
- `--verify` - Verify progress
- `--throttle` - Bandwidth throttling (production!)
- Increase/decrease replication factor
- Broker decommissioning
- **Use Cases**: Rebalancing, adding new brokers, disk balancing

### 7️⃣ kafka-log-dirs
- Analyze disk usage per broker
- Identify largest topics and partitions
- Offset lag detection (replicas out of sync)
- Capacity planning
- **Use Cases**: Disk full alerts, pre-reassignment audit, skewed partitions

### 8️⃣ kafka-configs
- `--describe` - Display configuration
- `--alter --add-config` - Change configs (retention, compression, min.insync.replicas)
- `--delete-config` - Revert to defaults
- Broker-level configs (dynamic, without restart!)
- Client quotas (throttling)
- Cleanup policy (delete vs. compact)
- **Use Cases**: Emergency retention reduction, enable compression, throttle noisy clients

### 9️⃣ kafka-acls
- `--add` - Grant permissions (Read, Write, Create, Delete)
- `--remove` - Remove ACLs
- `--list` - List all ACLs
- Topic, group, and cluster ACLs
- Wildcard patterns, deny rules
- **Use Cases**: Multi-tenant setup, GDPR compliance, read-only access, security audit

### 🔟 kafka-leader-election & kafka-replica-verification
- `--election-type PREFERRED` - Leader rebalancing
- Replica verification (data integrity)
- ISR monitoring (in-sync replicas)
- Leader distribution analysis
- **Use Cases**: Post-restart rebalancing, performance optimization, data integrity audit

### 1️⃣1️⃣ Advanced Tools (dump-log, delete-records, get-offsets)
- `kafka-dump-log` - Raw log inspection, corruption detection
- `kafka-delete-records` - Permanent deletion (GDPR)
- `kafka-get-offsets` - Offset queries, capacity planning
- `kafka-broker-api-versions` - API compatibility checking
- **Use Cases**: Deep debugging, GDPR compliance, upgrade planning

---

## 🎓 Best Practices Summary

### ✅ Production Recommendations

**Topic Configuration:**
- `replication.factor >= 2` (ideally 3)
- `min.insync.replicas = 2` (with acks=all)
- `compression.type = lz4` (fast) or `gzip` (high compression)
- `retention.ms` based on business needs (default 7 days)

**Consumer Groups:**
- Monitor LAG regularly (alerting!)
- Use descriptive group IDs (`service-name-env`)
- Test offset resets on DEV environment first
- Delete inactive groups (cleanup)

**Disk Management:**
- Alert on disk usage > 80%
- Retention policies for cleanup
- Rebalance after adding brokers
- Monitor growth rate

**Partition Reassignment:**
- Always use `--throttle` (50-100 MB/s)
- Backup current assignment before reassignment
- Use `--verify` regularly
- Reassign gradually (not everything at once)

**Security:**
- Enable ACLs for multi-tenant clusters
- Use principle of least privilege
- Regular ACL audits
- Wildcard patterns for scalability

---

## 📊 CLI Cheat Sheet

### Quick Reference

```bash
# TOPICS
kafka-topics --bootstrap-server $BOOTSTRAP --list
kafka-topics --bootstrap-server $BOOTSTRAP --create --topic <name> --partitions <N> --replication-factor <RF>
kafka-topics --bootstrap-server $BOOTSTRAP --describe --topic <name>
kafka-topics --bootstrap-server $BOOTSTRAP --delete --topic <name>

# PRODUCER
kafka-console-producer --bootstrap-server $BOOTSTRAP --topic <name>
# With keys:
--property "parse.key=true" --property "key.separator=:"

# CONSUMER
kafka-console-consumer --bootstrap-server $BOOTSTRAP --topic <name> --from-beginning
kafka-console-consumer --bootstrap-server $BOOTSTRAP --topic <name> --group <group-id>
# With formatting:
--property print.key=true --property print.timestamp=true --property print.partition=true

# CONSUMER GROUPS
kafka-consumer-groups --bootstrap-server $BOOTSTRAP --list
kafka-consumer-groups --bootstrap-server $BOOTSTRAP --group <name> --describe
kafka-consumer-groups --bootstrap-server $BOOTSTRAP --group <name> --reset-offsets --topic <topic> --to-earliest --execute
kafka-consumer-groups --bootstrap-server $BOOTSTRAP --group <name> --delete

# REASSIGNMENT
kafka-reassign-partitions --bootstrap-server $BOOTSTRAP --topics-to-move-json-file <file> --broker-list "1,2,3" --generate
kafka-reassign-partitions --bootstrap-server $BOOTSTRAP --reassignment-json-file <file> --execute --throttle 100000000
kafka-reassign-partitions --bootstrap-server $BOOTSTRAP --reassignment-json-file <file> --verify

# LOG DIRS
kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe
kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe --topic-list <topic>
kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe --broker-list <broker-id>

# CONFIGS
kafka-configs --bootstrap-server $BOOTSTRAP --entity-type topics --entity-name <topic> --describe
kafka-configs --bootstrap-server $BOOTSTRAP --entity-type topics --entity-name <topic> --alter --add-config <key>=<value>
kafka-configs --bootstrap-server $BOOTSTRAP --entity-type topics --entity-name <topic> --alter --delete-config <key>

# ACLS
kafka-acls --bootstrap-server $BOOTSTRAP --list
kafka-acls --bootstrap-server $BOOTSTRAP --add --allow-principal User:<user> --operation <op> --topic <topic>
kafka-acls --bootstrap-server $BOOTSTRAP --remove --allow-principal User:<user> --operation <op> --topic <topic> --force

# LEADER ELECTION
kafka-leader-election --bootstrap-server $BOOTSTRAP --election-type PREFERRED --all-topic-partitions

# REPLICA VERIFICATION
kafka-replica-verification --bootstrap-server $BOOTSTRAP --topic-white-list '.*' --report-interval-ms 5000

# ADVANCED TOOLS
kafka-dump-log --files <log-file> --print-data-log --deep-iteration
kafka-delete-records --bootstrap-server $BOOTSTRAP --offset-json-file <file>
kafka-get-offsets --bootstrap-server $BOOTSTRAP --topic <topic> --time -1
kafka-broker-api-versions --bootstrap-server $BOOTSTRAP
```

---

## 🚀 Next Steps

### Continue Your Learning:

1. **Kafka Streams API** - Stream processing
2. **Kafka Connect** - Integration with external systems
3. **Schema Registry** - Avro, Protobuf, JSON schema management
4. **ksqlDB** - SQL queries on Kafka streams
5. **Kafka Security** - SSL, SASL, ACLs deep dive
6. **Monitoring & Alerting** - Prometheus, Grafana, JMX metrics

### Recommended Resources:

- 📚 **Kafka: The Definitive Guide** (book)
- 🎥 **Confluent YouTube Channel** (tutorials)
- 🌐 **Apache Kafka Documentation** - kafka.apache.org/documentation
- 💬 **Kafka Community** - Slack, Reddit, Stack Overflow

---

## 🎯 Real-World Scenarios Recap

### Scenario 1: Disk Full Emergency
```bash
# 1. Identify largest topics
kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe

# 2. Reduce retention for old topics
kafka-configs --bootstrap-server $BOOTSTRAP --entity-type topics --entity-name old-topic \
  --alter --add-config retention.ms=3600000

# 3. Monitor cleanup
kafka-log-dirs --bootstrap-server $BOOTSTRAP --describe --topic-list old-topic
```

### Scenario 2: Consumer Lag Alert
```bash
# 1. Check lag
kafka-consumer-groups --bootstrap-server $BOOTSTRAP --group my-app --describe

# 2. Investigate (slow consumer? Too many messages?)
kafka-topics --bootstrap-server $BOOTSTRAP --describe --topic my-topic

# 3. Scale consumers or optimize
```

### Scenario 3: Bug Fix Replay
```bash
# 1. Stop consumers
# 2. Reset offsets to 1 hour ago
kafka-consumer-groups --bootstrap-server $BOOTSTRAP --group my-app \
  --topic my-topic --reset-offsets --by-duration PT1H --execute

# 3. Restart consumers (reprocess last hour)
```

### Scenario 4: Adding New Broker
```bash
# 1. Generate rebalance plan
kafka-reassign-partitions --bootstrap-server $BOOTSTRAP \
  --topics-to-move-json-file topics.json --broker-list "1,2,3,4" --generate

# 2. Execute with throttle
kafka-reassign-partitions --bootstrap-server $BOOTSTRAP \
  --reassignment-json-file plan.json --execute --throttle 100000000

# 3. Verify progress
kafka-reassign-partitions --bootstrap-server $BOOTSTRAP \
  --reassignment-json-file plan.json --verify
```

---

## 📈 Performance Tips

### Optimizing Throughput:
- Increase partitions (parallel processing)
- Enable compression (`lz4` for speed, `gzip` for ratio)
- Batch size tuning (`batch.size`, `linger.ms`)
- Multiple consumer instances

### Optimizing Latency:
- Fewer partitions (less coordination)
- `acks=1` (instead of `all`)
- No compression
- `linger.ms=0`

### Balancing Durability:
- `acks=all` + `min.insync.replicas=2`
- `replication.factor=3`
- `unclean.leader.election.enable=false`

---

## 🔍 Troubleshooting Guide

| Problem | Check | Solution |
|---------|-------|----------|
| **High LAG** | `kafka-consumer-groups --describe` | Scale consumers, optimize processing |
| **Disk Full** | `kafka-log-dirs --describe` | Reduce retention, delete old topics |
| **Unbalanced Brokers** | `kafka-log-dirs` per broker | Reassign partitions |
| **Messages Not Appearing** | Producer errors, topic exists? | Check producer logs, verify topic |
| **Consumer Not Reading** | Offset position? | Reset offset to `--to-earliest` |
| **Reassignment Slow** | No throttle? | Add `--throttle` parameter |
| **Out-of-Sync Replicas** | `kafka-topics --describe` ISR | Check network, increase ISR timeout |
| **Unbalanced Leaders** | Leader distribution | Run preferred leader election |

---

## 🎉 Final Words

You've mastered **11 essential Kafka CLI tools**! You now know how to:

- ✅ Manage topics (create, describe, alter, delete)
- ✅ Send and read messages (producer, consumer)
- ✅ Monitor consumer lag and reset offsets
- ✅ Rebalance partitions across brokers
- ✅ Analyze disk usage
- ✅ Dynamically change configuration
- ✅ Manage security and ACLs
- ✅ Rebalance leaders and verify replicas
- ✅ Use advanced tools (dump-log, delete-records, get-offsets)

**Kafka CLI tools are essential for:**
- Debugging production issues
- Automation scripts
- Monitoring and alerting
- Capacity planning
- Performance tuning
- Security & compliance (ACLs, GDPR)

---

## 🌟 Thank You!

Workshop created by: **Educates Kafka Team**

**Feedback?** Let us know how we can improve the workshop!

**Need help?**
- 📧 Email support
- 💬 Slack channel
- 🐛 GitHub issues

---

## 🎯 Workshop Statistics

For your reference:

```
✅ Topics Created: 25+
✅ Messages Produced: 3500+
✅ Consumer Groups: 20+
✅ Partition Reassignments: 8+
✅ Config Changes: 30+
✅ ACLs Created: 15+
✅ CLI Commands Executed: 150+
```

**Total Time:** ~150-180 minutes  
**Level:** Beginner → Intermediate → Advanced  
**3-node Kafka Cluster:** ✅ kafka-1, kafka-2, kafka-3  
**CLI Tools Covered:** 11 tools

---

## 📝 Certification Challenge (Optional)

Want to verify your knowledge?

**Mini Challenges:**

1. Create a topic with RF=3, min.insync.replicas=2, compression=lz4, retention=2 hours
2. Send 100 messages with keys (user1-user10)
3. Reset consumer group offset by 30 minutes
4. Reassign all partitions to brokers 1,2 (decommission broker 3)
5. Find which topic uses the most disk space
6. Change retention to 10 minutes for the largest topic
7. Grant read-only access to a user for a specific topic
8. Verify all replicas are in-sync across the cluster

**Complete all challenges = Kafka CLI Master! 🏆**

---

## 🚀 Keep Learning!

Kafka is a powerful platform - this workshop is just the beginning!

**Happy Kafkaing!** ☕🎯

```
  _  __       __ _         
 | |/ /__ _  / _| | ____ _ 
 | ' // _` || |_| |/ / _` |
 | . \ (_| ||  _|   < (_| |
 |_|\_\__,_||_| |_|\_\__,_|
                            
 CLI TOOLS MASTERY ✅
```
