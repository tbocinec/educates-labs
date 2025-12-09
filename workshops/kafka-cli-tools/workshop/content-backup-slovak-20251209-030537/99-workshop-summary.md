---
title: Workshop Summary
---

# 🎯 Kafka CLI Tools - Workshop Summary

Gratulujeme! Úspešne si dokončil workshop Kafka CLI Tools Mastery! 🎉

---

## ✅ Čo si sa naučil

### 1️⃣ CLI Introduction
- Kde sa nachádzajú Kafka CLI tools
- Ako používať `--help` pre každý nástroj
- Environment setup (aliases, bootstrap-server)
- Testing cluster connectivity

### 2️⃣ kafka-topics.sh
- `--create` - Vytváranie tém s partíciami a replication factor
- `--list` - Zoznam všetkých tém
- `--describe` - Detail témy (partície, repliky, ISR, leader)
- `--alter` - Zmena partícií a configs
- `--delete` - Vymazanie témy
- **Use cases**: DLQ, high-throughput topics, testing topics

### 3️⃣ kafka-console-producer.sh
- Basic message sending
- Posielanie s kľúčmi (`--property parse.key=true`)
- Custom partitioning (`--partition`)
- Producer properties (acks, compression, batch.size)
- JSON messages
- Performance testing
- **Use cases**: Testing, manual data injection, debugging

### 4️⃣ kafka-console-consumer.sh
- Reading from beginning vs. latest
- Consumer groups (`--group`)
- Formatting output (keys, timestamps, partitions, offsets)
- Reading specific partition a offset
- Consumer properties (auto-commit, fetch sizes)
- Filtering a grepping
- **Use cases**: Debugging, monitoring, testing

### 5️⃣ kafka-consumer-groups.sh
- `--list` - Zoznam consumer groups
- `--describe` - LAG monitoring (critical!)
- `--reset-offsets` - Replay messages (to-earliest, to-latest, by-duration, shift-by)
- `--delete` - Vymazanie inactive groups
- Group states a members
- **Use cases**: Lag monitoring, replay after bug fix, skip corrupted messages

### 6️⃣ kafka-reassign-partitions.sh
- `--generate` - Generovanie reassignment plánu
- `--execute` - Vykonanie reassignment
- `--verify` - Overenie progress
- `--throttle` - Bandwidth throttling (production!)
- Increase/decrease replication factor
- Broker decommissioning
- **Use cases**: Rebalancing, adding new brokers, disk balancing

### 7️⃣ kafka-log-dirs.sh
- Analyze disk usage per broker
- Identify largest topics a partitions
- Offset lag detection (replicas out of sync)
- Capacity planning
- **Use cases**: Disk full alerts, pre-reassignment audit, skewed partitions

### 8️⃣ kafka-configs.sh
- `--describe` - Zobrazenie konfigurácie
- `--alter --add-config` - Zmena configs (retention, compression, min.insync.replicas)
- `--delete-config` - Revert to defaults
- Broker-level configs (dynamic, bez reštartu!)
- Client quotas (throttling)
- Cleanup policy (delete vs. compact)
- **Use cases**: Emergency retention reduction, enable compression, throttle noisy clients

### 9️⃣ kafka-acls.sh
- `--add` - Grant permissions (Read, Write, Create, Delete)
- `--remove` - Remove ACLs
- `--list` - Zoznam všetkých ACLs
- Topic, group a cluster ACLs
- Wildcard patterns, deny rules
- **Use cases**: Multi-tenant setup, GDPR compliance, read-only access, security audit

### 🔟 kafka-leader-election.sh & kafka-replica-verification.sh
- `--election-type PREFERRED` - Leader rebalancing
- Replica verification (data integrity)
- ISR monitoring (in-sync replicas)
- Leader distribution analysis
- **Use cases**: Post-restart rebalancing, performance optimization, data integrity audit

### 1️⃣1️⃣ Advanced Tools (dump-log, delete-records, get-offsets)
- `kafka-dump-log.sh` - Raw log inspection, corruption detection
- `kafka-delete-records.sh` - Permanent deletion (GDPR)
- `kafka-get-offsets.sh` - Offset queries, capacity planning
- `kafka-broker-api-versions.sh` - API compatibility checking
- **Use cases**: Deep debugging, GDPR compliance, upgrade planning

---

## 🎓 Best Practices Summary

### ✅ Production Recommendations

**Topic Configuration:**
- `replication.factor >= 2` (ideally 3)
- `min.insync.replicas = 2` (with acks=all)
- `compression.type = lz4` (fast) or `gzip` (high compression)
- `retention.ms` based on business needs (default 7 days)

**Consumer Groups:**
- Monitoruj LAG pravidelne (alerting!)
- Používaj descriptive group IDs (`service-name-env`)
- Testuj offset resets na DEV prostredí najprv
- Delete inactive groups (cleanup)

**Disk Management:**
- Alerting na disk usage > 80%
- Retention policies pre cleanup
- Rebalancing po pridaní brokerov
- Monitoruj growth rate

**Partition Reassignment:**
- Vždy používaj `--throttle` (50-100 MB/s)
- Backup current assignment pred reassignment
- Použi `--verify` pravidelne
- Postupne reassignuj (nie všetko naraz)

---

## 📊 CLI Cheat Sheet

### Quick Reference

```bash
# TOPICS
kafka-topics.sh --bootstrap-server <broker> --list
kafka-topics.sh --bootstrap-server <broker> --create --topic <name> --partitions <N> --replication-factor <RF>
kafka-topics.sh --bootstrap-server <broker> --describe --topic <name>
kafka-topics.sh --bootstrap-server <broker> --delete --topic <name>

# PRODUCER
kafka-console-producer.sh --bootstrap-server <broker> --topic <name>
# With keys:
--property "parse.key=true" --property "key.separator=:"

# CONSUMER
kafka-console-consumer.sh --bootstrap-server <broker> --topic <name> --from-beginning
kafka-console-consumer.sh --bootstrap-server <broker> --topic <name> --group <group-id>
# With formatting:
--property print.key=true --property print.timestamp=true --property print.partition=true

# CONSUMER GROUPS
kafka-consumer-groups.sh --bootstrap-server <broker> --list
kafka-consumer-groups.sh --bootstrap-server <broker> --group <name> --describe
kafka-consumer-groups.sh --bootstrap-server <broker> --group <name> --reset-offsets --topic <topic> --to-earliest --execute
kafka-consumer-groups.sh --bootstrap-server <broker> --group <name> --delete

# REASSIGNMENT
kafka-reassign-partitions.sh --bootstrap-server <broker> --topics-to-move-json-file <file> --broker-list "1,2,3" --generate
kafka-reassign-partitions.sh --bootstrap-server <broker> --reassignment-json-file <file> --execute --throttle 100000000
kafka-reassign-partitions.sh --bootstrap-server <broker> --reassignment-json-file <file> --verify

# LOG DIRS
kafka-log-dirs.sh --bootstrap-server <broker> --describe
kafka-log-dirs.sh --bootstrap-server <broker> --describe --topic-list <topic>
kafka-log-dirs.sh --bootstrap-server <broker> --describe --broker-list <broker-id>

# CONFIGS
kafka-configs.sh --bootstrap-server <broker> --entity-type topics --entity-name <topic> --describe
kafka-configs.sh --bootstrap-server <broker> --entity-type topics --entity-name <topic> --alter --add-config <key>=<value>
kafka-configs.sh --bootstrap-server <broker> --entity-type topics --entity-name <topic> --alter --delete-config <key>

# ACLS
kafka-acls.sh --bootstrap-server <broker> --list
kafka-acls.sh --bootstrap-server <broker> --add --allow-principal User:<user> --operation <op> --topic <topic>
kafka-acls.sh --bootstrap-server <broker> --remove --allow-principal User:<user> --operation <op> --topic <topic> --force

# LEADER ELECTION
kafka-leader-election.sh --bootstrap-server <broker> --election-type PREFERRED --all-topic-partitions

# REPLICA VERIFICATION
kafka-replica-verification.sh --broker-list <brokers> --topic-white-list '.*' --report-interval-ms 5000

# ADVANCED TOOLS
kafka-dump-log.sh --files <log-file> --print-data-log --deep-iteration
kafka-delete-records.sh --bootstrap-server <broker> --offset-json-file <file>
kafka-run-class.sh kafka.tools.GetOffsetShell --bootstrap-server <broker> --topic <topic> --time -1
kafka-broker-api-versions.sh --bootstrap-server <broker>
```

---

## 🚀 Next Steps

### Ďalšie učenie:

1. **Kafka Streams API** - Stream processing
2. **Kafka Connect** - Integration s externými systémami
3. **Schema Registry** - Avro, Protobuf, JSON schema management
4. **ksqlDB** - SQL queries na Kafka streams
5. **Kafka Security** - SSL, SASL, ACLs
6. **Monitoring & Alerting** - Prometheus, Grafana, JMX metrics

### Recommended Resources:

- 📚 **Kafka: The Definitive Guide** (kniha)
- 🎥 **Confluent YouTube Channel** (tutoriály)
- 🌐 **Apache Kafka Documentation** - kafka.apache.org/documentation
- 💬 **Kafka Community** - Slack, Reddit, Stack Overflow

---

## 🎯 Real-World Scenarios Recap

### Scenario 1: Disk Full Emergency
```bash
# 1. Identify largest topics
kafka-log-dirs.sh --bootstrap-server <broker> --describe | jq ...

# 2. Reduce retention for old topics
kafka-configs.sh --bootstrap-server <broker> --entity-type topics --entity-name old-topic \
  --alter --add-config retention.ms=3600000

# 3. Monitor cleanup
kafka-log-dirs.sh --bootstrap-server <broker> --describe --topic-list old-topic
```

### Scenario 2: Consumer Lag Alert
```bash
# 1. Check lag
kafka-consumer-groups.sh --bootstrap-server <broker> --group my-app --describe

# 2. Investigate (slow consumer? Too many messages?)
kafka-topics.sh --bootstrap-server <broker> --describe --topic my-topic

# 3. Scale consumers or optimize
```

### Scenario 3: Bug Fix Replay
```bash
# 1. Stop consumers
# 2. Reset offsets to 1 hour ago
kafka-consumer-groups.sh --bootstrap-server <broker> --group my-app \
  --topic my-topic --reset-offsets --by-duration PT1H --execute

# 3. Restart consumers (reprocess last hour)
```

### Scenario 4: Adding New Broker
```bash
# 1. Generate rebalance plan
kafka-reassign-partitions.sh --bootstrap-server <broker> \
  --topics-to-move-json-file topics.json --broker-list "1,2,3,4" --generate

# 2. Execute with throttle
kafka-reassign-partitions.sh --bootstrap-server <broker> \
  --reassignment-json-file plan.json --execute --throttle 100000000

# 3. Verify progress
kafka-reassign-partitions.sh --bootstrap-server <broker> \
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
| **High LAG** | `kafka-consumer-groups.sh --describe` | Scale consumers, optimize processing |
| **Disk Full** | `kafka-log-dirs.sh --describe` | Reduce retention, delete old topics |
| **Unbalanced Brokers** | `kafka-log-dirs.sh` per broker | Reassign partitions |
| **Messages Not Appearing** | Producer errors, topic exists? | Check producer logs, verify topic |
| **Consumer Not Reading** | Offset position? | Reset offset to `--to-earliest` |
| **Reassignment Slow** | No throttle? | Add `--throttle` parameter |

---

## 🎉 Záverečné slová

Zvládol si **8 najdôležitejších Kafka CLI nástrojov**! Teraz vieš:

- ✅ Spravovať témy (create, describe, alter, delete)
- ✅ Posielať a čítať messages (producer, consumer)
- ✅ Monitorovať consumer lag a resetovať offsety
- ✅ Rebalancovať partície medzi brokermi
- ✅ Analyzovať disk usage
- ✅ Dynamicky meniť konfiguráciu
- ✅ Spravovať security a ACLs
- ✅ Rebalancovať leaders a verifikovať repliky
- ✅ Používať advanced tools (dump-log, delete-records, get-offsets)

**Kafka CLI tools sú základ pre:**
- Debugging production issues
- Automation scripts
- Monitoring a alerting
- Capacity planning
- Performance tuning
- Security & compliance (ACLs, GDPR)

---

## 🌟 Thank You!

Workshop vytvoril: **Educates Kafka Team**

**Feedback?** Daj nám vedieť, ako môžeme workshop zlepšiť!

**Potrebuješ pomoc?**
- 📧 Email support
- 💬 Slack channel
- 🐛 GitHub issues

---

## 🎯 Workshop Statistics

Pre tvoju referenciu:

```
✅ Topics Created: 20+
✅ Messages Produced: 3000+
✅ Consumer Groups: 15+
✅ Partition Reassignments: 5+
✅ Config Changes: 25+
✅ ACLs Created: 10+
✅ CLI Commands Executed: 150+
```

**Celkový čas:** ~120-150 minút  
**Úroveň:** Beginner → Intermediate → Advanced  
**3-node Kafka Cluster:** ✅ kafka-1, kafka-2, kafka-3
**CLI Tools Covered:** 11 nástrojov

---

## 📝 Certification (Optional)

Chceš si overiť znalosti?

**Mini Challenges:**

1. Vytvor tému s RF=3, min.insync.replicas=2, compression=lz4, retention=2 hours
2. Pošli 100 messages s kľúčmi (user1-user10)
3. Reset consumer group offset o 30 minút dozadu
4. Reassign všetky partície na broker 1,2 (vyraď broker 3)
5. Zisti, ktorá téma zabiera najviac disku
6. Zmeň retention na 10 minút pre tému s najväčším diskom

**Riešenie challenges = Kafka CLI Master! 🏆**

---

## 🚀 Keep Learning!

Kafka je powerful platform - tento workshop je len začiatok!

**Happy Kafkaing!** ☕🎯

```
  _  __       __ _         
 | |/ /__ _  / _| | ____ _ 
 | ' // _` || |_| |/ / _` |
 | . \ (_| ||  _|   < (_| |
 |_|\_\__,_||_| |_|\_\__,_|
                            
 CLI TOOLS MASTERY ✅
```
