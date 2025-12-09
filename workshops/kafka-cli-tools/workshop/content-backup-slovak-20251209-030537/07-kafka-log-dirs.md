---
title: Log Directories Analysis
---

# 🎯 Kafka Log Directories Analysis

V tejto lekcii sa naučíš používať `kafka-log-dirs.sh` - nástroj na analýzu disk usage a log directories.

## Čo je kafka-log-dirs?

Tento nástroj umožňuje:
- ✅ Analyzovať disk usage per broker
- ✅ Zistiť veľkosť každej partície/repliky
- ✅ Identifikovať najväčšie témy
- ✅ Sledovať log segment sizes
- ✅ Plánovať disk capacity

**Kedy použiť:**
- Disk je plný - zistiť ktorá téma zaberie najviac miesta
- Capacity planning
- Debugging storage issues
- Performance optimization (veľké partície = slow rebalancing)
- Audit pred reassignment

---

## Help & Syntax

Najprv si pozrieme help:

```terminal:execute
command: docker exec kafka-1 kafka-log-dirs.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address (povinné)
- `--describe` - Describe log directories
- `--topic-list` - Filter pre konkrétne témy
- `--broker-list` - Filter pre konkrétne brokery

---

## 1️⃣ Basic Log Dirs Analysis

Najprv vytvoríme témy s rôznymi veľkosťami:

**Vytvoríme malú tému:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic small-topic --partitions 2 --replication-factor 2 --if-not-exists
```

**Vytvoríme veľkú tému:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic large-topic --partitions 6 --replication-factor 2 --if-not-exists
```

**Pošleme pár messages do small-topic:**
```terminal:execute
command: |
  for i in {1..10}; do
    echo "Small message $i"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic small-topic
```

**Pošleme veľa messages do large-topic:**
```terminal:execute
command: |
  for i in {1..1000}; do
    echo "Large message $i with extra padding to increase size: $(head -c 100 /dev/zero | tr '\0' 'X')"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic large-topic
```

**Analyze log directories:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe
```

Output je JSON formát - uvidíme sizes pre každú partíciu!

---

## 2️⃣ Parse JSON Output

Output je JSON - môžeme použiť `jq` pre parsing:

**Install jq v containeri:**
```terminal:execute
command: docker exec kafka-1 sh -c 'which jq || (apt-get update > /dev/null 2>&1 && apt-get install -y jq > /dev/null 2>&1 && echo "jq installed")'
```

**Parse output - celkový size per broker:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[] | \"Broker \(.broker): \(.logDirs[].partitions | map(.size) | add) bytes\""'
```

**Parse output - size per partition:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[].logDirs[].partitions[] | \"\(.topic)-\(.partition): \(.size) bytes\""' | head -20
```

---

## 3️⃣ Filter by Topic

Analyzujeme len konkrétnu tému:

**Log dirs pre large-topic:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic-list large-topic
```

**Celková veľkosť large-topic:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic-list large-topic | jq ".brokers[].logDirs[].partitions[] | select(.topic == \"large-topic\") | .size" | awk "{sum+=\$1} END {print \"Total size:\", sum, \"bytes (\", sum/1024/1024, \"MB)\"}"'
```

---

## 4️⃣ Filter by Broker

Analyzujeme len konkrétny broker:

**Log dirs pre broker 1:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --broker-list 1
```

**Celková veľkosť na broker 1:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --broker-list 1 | jq ".brokers[] | select(.broker == 1) | .logDirs[].partitions | map(.size) | add"'
```

---

## 5️⃣ Identify Largest Topics

Zistíme, ktorá téma zaberie najviac miesta:

**Top 10 najväčších partícií:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[].logDirs[].partitions[] | \"\(.size) \(.topic)-\(.partition)\""' | sort -rn | head -10
```

**Sumarizácia per topic:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[].logDirs[].partitions[] | \"\(.topic) \(.size)\""' | awk '{topic_sizes[$1]+=$2} END {for (topic in topic_sizes) print topic, topic_sizes[topic]}' | sort -k2 -rn
```

---

## 6️⃣ Disk Usage per Broker

Porovnanie disk usage medzi brokermi:

**Celkový size per broker:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[] | {broker: .broker, total: (.logDirs[].partitions | map(.size) | add)} | \"Broker \(.broker): \(.total) bytes (\(.total/1024/1024) MB)\""'
```

**Identifikuj unbalanced brokers:**
```terminal:execute
command: |
  echo "Disk usage comparison:"
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[] | {broker: .broker, total_mb: ((.logDirs[].partitions | map(.size) | add) / 1024 / 1024)} | \"Broker \(.broker): \(.total_mb | floor) MB\""'
```

💡 **Ak je rozdiel > 20%, zvážiť reassignment!**

---

## 7️⃣ Log Segment Sizes

Každá partícia sa skladá z log segmentov:

**Vytvoríme tému s custom segment size:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic segment-demo --partitions 3 --replication-factor 2 --config segment.bytes=10485760 --if-not-exists
```

**Pošleme dáta:**
```terminal:execute
command: |
  for i in {1..500}; do
    echo "Segment test message $i with padding: $(head -c 200 /dev/zero | tr '\0' 'Y')"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic segment-demo
```

**Analyze segment-demo:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic-list segment-demo | jq -r ".brokers[].logDirs[].partitions[] | select(.topic == \"segment-demo\") | \"\(.topic)-\(.partition) on broker \(.broker): \(.size) bytes, offset lag: \(.offsetLag)\""'
```

**OffsetLag:**
- `offsetLag` = koľko messages ešte treba replikovať
- `offsetLag = 0` = replika je in-sync

---

## 8️⃣ Identify Replicas Out of Sync

**Offset lag detection:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[].logDirs[].partitions[] | select(.offsetLag > 0) | \"WARNING: \(.topic)-\(.partition) on broker \(.broker) has lag: \(.offsetLag)\""' || echo "All replicas in sync!"
```

---

## 9️⃣ Capacity Planning

Zistíme growth rate:

**Aktuálny total disk usage:**
```terminal:execute
command: |
  CURRENT_SIZE=$(docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq ".brokers[].logDirs[].partitions | map(.size) | add"' | awk '{sum+=$1} END {print sum}')
  echo "Current total disk usage: $CURRENT_SIZE bytes ($((CURRENT_SIZE / 1024 / 1024)) MB)"
```

**Simulácia growth (pridáme viac dát):**
```terminal:execute
command: |
  for i in {1..200}; do
    echo "Growth test message $i: $(head -c 300 /dev/zero | tr '\0' 'Z')"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic large-topic
```

**Nový total disk usage:**
```terminal:execute
command: |
  NEW_SIZE=$(docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq ".brokers[].logDirs[].partitions | map(.size) | add"' | awk '{sum+=$1} END {print sum}')
  echo "New total disk usage: $NEW_SIZE bytes ($((NEW_SIZE / 1024 / 1024)) MB)"
```

---

## 🔟 Compare with Topic Describe

Porovnáme s `kafka-topics.sh --describe`:

**Topic describe:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic large-topic
```

**Log dirs pre large-topic:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic-list large-topic | jq -r ".brokers[].logDirs[].partitions[] | select(.topic == \"large-topic\") | \"Partition \(.partition) on broker \(.broker): \(.size) bytes, isFuture: \(.isFuture)\""'
```

**isFuture flag:**
- `isFuture: true` - replica sa práve presúva (reassignment)
- `isFuture: false` - normálna replika

---

## 🎯 Use Cases

### 1. Disk Full Alert - Find Culprit
**Scenario**: Disk je plný, zisti ktorá téma:
```terminal:execute
command: |
  echo "Top 5 largest topics:"
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[].logDirs[].partitions[] | \"\(.topic) \(.size)\""' | awk '{topic_sizes[$1]+=$2} END {for (topic in topic_sizes) print topic, topic_sizes[topic], "bytes"}' | sort -k2 -rn | head -5
```

### 2. Pre-Reassignment Audit
**Scenario**: Pred reassignment over sizes:
```terminal:execute
command: |
  echo "Broker disk usage before reassignment:"
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | jq -r ".brokers[] | \"Broker \(.broker): \((.logDirs[].partitions | map(.size) | add) / 1024 / 1024 | floor) MB\""'
```

### 3. Identify Skewed Partitions
**Scenario**: Jedna partícia je oveľa väčšia (skewed keys):
```terminal:execute
command: |
  echo "Partition sizes for large-topic:"
  docker exec kafka-1 sh -c 'kafka-log-dirs.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic-list large-topic | jq -r ".brokers[].logDirs[].partitions[] | select(.topic == \"large-topic\") | \"Partition \(.partition): \(.size) bytes\""' | awk '{partitions[$2]+=$3} END {for (p in partitions) print p, partitions[p]}' | sort -k2 -rn
```

### 4. Retention Policy Verification
**Scenario**: Over, že retention funguje (staré dáta sa mažú):
```bash
# Poznač size teraz
# Počkaj na retention window
# Over size znova - mal by klesnúť
```

---

## 🔍 Kafka UI Verification

Otvor Kafka UI:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Čo kontrolovať:**
- Brokers → Disk Usage graph → vidíš distribution?
- Topics → `large-topic` → Overview → Size on Disk
- Topics → Partitions tab → Size per partition

---

## ⚠️ Common Errors

### 1. "jq: command not found"
```
sh: jq: not found
```
**Riešenie:**
```terminal:execute
command: docker exec kafka-1 sh -c 'apt-get update && apt-get install -y jq'
```

### 2. "Empty output"
```
Output is empty or minimal
```
**Riešenie:**
- Over, že témy existujú a majú dáta
- Pošli messages do tém najprv

### 3. "Broker not responding"
```
ERROR Broker 3 is not available
```
**Riešenie:**
- Over `docker ps | grep kafka-3`
- Použi `--broker-list` pre live brokery len

---

## 🎓 Best Practices

✅ **DO:**
- Pravidelne monitoruj disk usage (daily/weekly)
- Nastavuj alerts na disk usage thresholds (napr. > 80%)
- Používaj retention policies pre cleanup
- Identifikuj najväčšie témy a optimalizuj
- Compare disk usage medzi brokermi (rebalance ak unbalanced)

❌ **DON'T:**
- Neignoruj disk warnings - Kafka zlyhá ak disk full
- Nepoužívaj infinite retention bez monitoringu
- Nezabudni na replicas - each partition má N copies
- Nečakaj kým je disk 100% plný

---

## 📊 Disk Usage Alerts

| Threshold | Action |
|-----------|--------|
| **< 60%** | OK - normálna prevádzka |
| **60-70%** | INFO - monitoruj growth rate |
| **70-80%** | WARNING - plánuj cleanup alebo scale up |
| **80-90%** | CRITICAL - okamžitá akcia (delete old topics, increase retention) |
| **> 90%** | EMERGENCY - Kafka môže zlyhať, immediate action |

---

## 🎯 Summary

Naučili sme sa:
- ✅ Analyze log directories pomocou `kafka-log-dirs.sh`
- ✅ Parse JSON output pomocou `jq`
- ✅ Filter by topic a broker
- ✅ Identify largest topics a partitions
- ✅ Compare disk usage medzi brokermi
- ✅ Detect replicas out of sync (offsetLag)
- ✅ Capacity planning a growth rate analysis
- ✅ Real-world use cases (disk full alerts, pre-reassignment audit)

**Next Level:** Naučíme sa spravovať konfiguráciu pomocou `kafka-configs.sh`! 🚀
