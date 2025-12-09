---
title: Dynamic Configuration
---

# 🎯 Kafka Dynamic Configuration

V tejto lekcii sa naučíš používať `kafka-configs.sh` - nástroj na správu dynamickej konfigurácie Kafka.

## Čo je kafka-configs?

Tento nástroj umožňuje:
- ✅ Meniť konfiguráciu **bez reštartu** brokerov
- ✅ Topic-level configs (retention, compression, etc.)
- ✅ Broker-level configs (dynamic settings)
- ✅ Client quotas (throttling)
- ✅ User configs

**Kedy použiť:**
- Zmena retention policy pre konkrétnu tému
- Nastavenie compression
- Throttling pre problematic clients
- Hot-fix konfigurácie bez downtime
- Fine-tuning pre specific topics

---

## Help & Syntax

Najprv si pozrieme help:

```terminal:execute
command: docker exec kafka-1 kafka-configs.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address (povinné)
- `--entity-type` - Typ entity (`topics`, `brokers`, `clients`, `users`)
- `--entity-name` - Názov entity (topic name, broker ID, etc.)
- `--describe` - Zobraz konfiguráciu
- `--alter` - Zmeň konfiguráciu
- `--add-config` - Pridaj config properties
- `--delete-config` - Vymaž config properties

---

## 1️⃣ Describe Topic Config

Zistíme aktuálnu konfiguráciu témy:

**Vytvoríme tému:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic config-demo --partitions 3 --replication-factor 2 --if-not-exists
```

**Describe config:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name config-demo \
    --describe
```

Output:
```
Dynamic configs for topic config-demo are:
(empty if no custom configs)
```

💡 **Empty = používa default broker configs!**

---

## 2️⃣ Alter Topic Config - Retention

Zmeníme retention policy:

**Nastavíme retention na 1 hodinu:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name config-demo \
    --alter \
    --add-config retention.ms=3600000
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name config-demo \
    --describe
```

Output:
```
Dynamic configs for topic config-demo are:
  retention.ms=3600000 sensitive=false synonyms={DYNAMIC_TOPIC_CONFIG:retention.ms=3600000}
```

**Pošleme messages:**
```terminal:execute
command: |
  for i in {1..10}; do
    echo "Message $i - timestamp: $(date +%s)"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic config-demo
```

💡 **Po 1 hodine sa messages automaticky vymažú!**

---

## 3️⃣ Compression Type

Nastavíme compression pre tému:

**Vytvoríme tému pre compression:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic compressed-topic --partitions 3 --replication-factor 2 --if-not-exists
```

**Nastavíme GZIP compression:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name compressed-topic \
    --alter \
    --add-config compression.type=gzip
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name compressed-topic \
    --describe
```

**Pošleme veľké messages (compression benefit):**
```terminal:execute
command: |
  for i in {1..100}; do
    echo "Large compressible message $i: $(head -c 500 /dev/zero | tr '\0' 'A')"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic compressed-topic
```

**Over disk size (should be smaller vďaka compression):**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic-list compressed-topic | jq -r ".brokers[].logDirs[].partitions[] | select(.topic == \"compressed-topic\") | \"Partition \(.partition): \(.size) bytes\""' | awk '{sum+=$2} END {print "Total compressed size:", sum, "bytes"}'
```

---

## 4️⃣ Multiple Configs at Once

Nastavíme viacero configs naraz:

**Vytvoríme production-like tému:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic production-topic --partitions 6 --replication-factor 3 --if-not-exists
```

**Nastavíme multiple configs:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name production-topic \
    --alter \
    --add-config retention.ms=86400000,compression.type=lz4,min.insync.replicas=2,max.message.bytes=2097152
```

**Verify all configs:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name production-topic \
    --describe
```

**Configs explained:**
- `retention.ms=86400000` - 24 hours retention
- `compression.type=lz4` - Fast compression
- `min.insync.replicas=2` - At least 2 replicas must ACK
- `max.message.bytes=2097152` - Max message size = 2MB

---

## 5️⃣ Delete Config (Revert to Default)

Vymažeme custom config:

**Delete retention config:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name config-demo \
    --alter \
    --delete-config retention.ms
```

**Verify - teraz používa default:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name config-demo \
    --describe
```

---

## 6️⃣ Broker-Level Configs

Môžeme meniť aj broker konfiguráciu (bez reštartu!):

**Describe broker 1 config:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type brokers \
    --entity-name 1 \
    --describe
```

**Nastavíme max connections pre broker:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type brokers \
    --entity-name 1 \
    --alter \
    --add-config max.connections=1000
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type brokers \
    --entity-name 1 \
    --describe
```

💡 **Broker config change bez reštartu - powerful!**

---

## 7️⃣ Client Quotas

Throttling pre problematic clients:

**Nastavíme producer quota:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type clients \
    --entity-name test-producer \
    --alter \
    --add-config producer_byte_rate=1048576
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type clients \
    --entity-name test-producer \
    --describe
```

**producer_byte_rate=1048576** = 1 MB/s limit

**Nastavíme consumer quota:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type clients \
    --entity-name test-consumer \
    --alter \
    --add-config consumer_byte_rate=2097152
```

---

## 8️⃣ Cleanup Policy

Zmeníme cleanup policy (delete vs. compact):

**Vytvoríme compacted tému:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic compacted-topic --partitions 3 --replication-factor 2 --if-not-exists
```

**Nastavíme compaction:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name compacted-topic \
    --alter \
    --add-config cleanup.policy=compact,min.cleanable.dirty.ratio=0.5,segment.ms=60000
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name compacted-topic \
    --describe
```

**Pošleme messages s rovnakými keys (len posledný zostane):**
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic compacted-topic \
    --property "parse.key=true" \
    --property "key.separator=:" <<EOF
user123:{"name": "John", "version": 1}
user456:{"name": "Jane", "version": 1}
user123:{"name": "John Updated", "version": 2}
user123:{"name": "John Final", "version": 3}
EOF
```

💡 **Po compaction: user123 bude mať len posledný message!**

---

## 9️⃣ Segment Configuration

Fine-tuning segment sizes:

**Vytvoríme tému s custom segment config:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic segment-config --partitions 2 --replication-factor 2 --if-not-exists
```

**Nastavíme malý segment (pre testing):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name segment-config \
    --alter \
    --add-config segment.bytes=1048576,segment.ms=300000
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name segment-config \
    --describe
```

**Configs:**
- `segment.bytes=1048576` - 1MB segment size (default 1GB)
- `segment.ms=300000` - Close segment after 5 minutes (default 7 days)

---

## 🔟 All Topic Configs

List všetkých možných topic configs:

**Najdôležitejšie topic configs:**

| Config | Default | Popis |
|--------|---------|-------|
| `retention.ms` | 168 hours | Ako dlho držať messages |
| `retention.bytes` | -1 (infinite) | Max size per partition |
| `compression.type` | producer | Compression type (gzip, lz4, snappy, zstd) |
| `cleanup.policy` | delete | delete alebo compact |
| `min.insync.replicas` | 1 | Min replicas pre ACK (acks=all) |
| `max.message.bytes` | 1 MB | Max message size |
| `segment.bytes` | 1 GB | Log segment size |
| `segment.ms` | 7 days | Max time before closing segment |
| `min.cleanable.dirty.ratio` | 0.5 | Compaction threshold |

**Describe s ALL synonyms (default values):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name production-topic \
    --describe \
    --all
```

---

## 🎯 Use Cases

### 1. Emergency Retention Reduction
**Scenario**: Disk je plný, zníž retention pre staré témy:
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name config-demo \
    --alter \
    --add-config retention.ms=3600000
```
💡 **1 hour retention = quick cleanup!**

### 2. Enable Compression for Bandwidth
**Scenario**: Network je bottleneck, enable compression:
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name compressed-topic \
    --alter \
    --add-config compression.type=lz4
```

### 3. Increase min.insync.replicas for Critical Data
**Scenario**: Potrebujeme vyššiu durability:
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type topics \
    --entity-name production-topic \
    --alter \
    --add-config min.insync.replicas=2
```

### 4. Throttle Noisy Client
**Scenario**: Jeden client zahlcuje broker:
```terminal:execute
command: |
  docker exec kafka-1 kafka-configs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --entity-type clients \
    --entity-name noisy-client \
    --alter \
    --add-config producer_byte_rate=524288
```
💡 **512 KB/s limit!**

---

## 🔍 Kafka UI Verification

Otvor Kafka UI:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Čo kontrolovať:**
- Topics → `production-topic` → Settings tab → vidíš custom configs?
- Topics → `compressed-topic` → Settings → Compression Type = lz4?
- Topics → `compacted-topic` → Settings → Cleanup Policy = compact?

---

## ⚠️ Common Errors

### 1. "Unknown configuration"
```
ERROR Unknown configuration 'xyz'
```
**Riešenie:**
- Over, že config existuje (case-sensitive!)
- Použi `--describe --all` pre list všetkých configs

### 2. "Invalid value"
```
ERROR Invalid value for configuration retention.ms: -5
```
**Riešenie:**
- Over hodnoty (napr. retention.ms musí byť > 0 alebo -1)
- Použi správne units (ms, bytes, etc.)

### 3. "Cannot alter immutable config"
```
ERROR Cannot alter immutable configuration
```
**Riešenie:**
- Niektoré configs sa nedajú meniť dynamicky
- Musíš reštartovať broker alebo recreate topic

### 4. "Entity does not exist"
```
ERROR Topic 'xyz' does not exist
```
**Riešenie:**
- Over `kafka-topics.sh --list`
- Create topic najprv

---

## 🎓 Best Practices

✅ **DO:**
- Používaj dynamic configs pre runtime changes (avoid reštart)
- Dokumentuj config changes (changelog)
- Testuj na DEV prostredí najprv
- Použi `--describe` pred `--alter` (backup current values)
- Monitoruj impact po config change

❌ **DON'T:**
- Nemení kritické configs bez testing (napr. min.insync.replicas)
- Nenastavuj retention príliš nízko (risk of data loss)
- Nezabudni na disk space pri increase retention
- Nepoužívaj compaction ak nerozumieš, ako funguje

---

## 📊 Config Recommendations

| Topic Type | retention.ms | compression.type | min.insync.replicas | cleanup.policy |
|------------|--------------|------------------|---------------------|----------------|
| **Transient logs** | 1 hour | lz4 | 1 | delete |
| **Audit logs** | 30 days | gzip | 2 | delete |
| **Event sourcing** | Infinite | snappy | 2 | delete |
| **State store** | Infinite | lz4 | 2 | compact |
| **Testing** | 10 min | none | 1 | delete |

---

## 🎯 Summary

Naučili sme sa:
- ✅ Describe a alter topic configs (retention, compression, etc.)
- ✅ Set multiple configs naraz
- ✅ Delete configs (revert to defaults)
- ✅ Broker-level dynamic configs
- ✅ Client quotas (throttling)
- ✅ Cleanup policy (delete vs. compact)
- ✅ Segment configuration
- ✅ Real-world use cases (emergency retention, compression, throttling)

**Next Level:** Workshop summary a cheat sheet! 🚀
