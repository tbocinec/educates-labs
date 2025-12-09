---
title: Partition Reassignment
---

# 🎯 Kafka Partition Reassignment

V tejto lekcii sa naučíš používať `kafka-reassign-partitions.sh` - nástroj na presunovanie partícií medzi brokermi.

## Čo je Partition Reassignment?

Partition reassignment umožňuje:
- ✅ Presunúť partície medzi brokermi (load balancing)
- ✅ Pridať/odobrať repliky
- ✅ Vykonať broker decommissioning
- ✅ Rebalancovať klaster po pridaní nových brokerov

**Kedy použiť:**
- Broker má príliš veľa partícií (unbalanced load)
- Pridávaš nové brokery do klastra
- Vyraďuješ starý broker
- Disk usage je unbalanced
- Performance optimization

---

## Help & Syntax

Najprv si pozrieme help:

```terminal:execute
command: docker exec kafka-1 kafka-reassign-partitions.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address
- `--generate` - Generuje reassignment JSON
- `--execute` - Vykoná reassignment
- `--verify` - Overí status reassignment
- `--reassignment-json-file` - JSON file s plánom
- `--throttle` - Bandwidth throttling (bytes/sec)

---

## 1️⃣ Current Partition Distribution

Najprv sa pozrieme na aktuálne rozloženie partícií:

**Vytvoríme tému s 12 partíciami:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic reassign-demo --partitions 12 --replication-factor 2 --if-not-exists
```

**Describe témy:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic reassign-demo
```

Output:
```
Topic: reassign-demo  Partition: 0  Leader: 1  Replicas: 1,2  Isr: 1,2
Topic: reassign-demo  Partition: 1  Leader: 2  Replicas: 2,3  Isr: 2,3
Topic: reassign-demo  Partition: 2  Leader: 3  Replicas: 3,1  Isr: 3,1
...
```

**Pozri rozloženie:**
- `Leader` - Broker, ktorý obsluhuje reads/writes
- `Replicas` - Brokery, kde sú repliky
- `Isr` - In-Sync Replicas (aktuálne synchronizované)

---

## 2️⃣ Generate Reassignment Plan

Vytvoríme JSON file s témami, ktoré chceme rebalancovať:

**Vytvoríme topics-to-move.json:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/topics-to-move.json <<EOF
{
  "topics": [
    {"topic": "reassign-demo"}
  ],
  "version": 1
}
EOF'
```

**Over file:**
```terminal:execute
command: docker exec kafka-1 cat /tmp/topics-to-move.json
```

**Generate reassignment plan pre všetky 3 brokery:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topics-to-move-json-file /tmp/topics-to-move.json \
    --broker-list "1,2,3" \
    --generate
```

Output má 2 časti:
1. **Current Partition Replica Assignment** - aktuálne rozloženie (backup!)
2. **Proposed Partition Reassignment Configuration** - nový plán

---

## 3️⃣ Execute Reassignment

**Uložíme proposed plan:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/reassignment-plan.json <<EOF
{
  "version": 1,
  "partitions": [
    {"topic": "reassign-demo", "partition": 0, "replicas": [2,3], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 1, "replicas": [3,1], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 2, "replicas": [1,2], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 3, "replicas": [2,3], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 4, "replicas": [3,1], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 5, "replicas": [1,2], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 6, "replicas": [2,3], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 7, "replicas": [3,1], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 8, "replicas": [1,2], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 9, "replicas": [2,3], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 10, "replicas": [3,1], "log_dirs": ["any","any"]},
    {"topic": "reassign-demo", "partition": 11, "replicas": [1,2], "log_dirs": ["any","any"]}
  ]
}
EOF'
```

**Execute reassignment:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/reassignment-plan.json \
    --execute
```

**Verify reassignment progress:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/reassignment-plan.json \
    --verify
```

Output:
```
Status of partition reassignment:
Reassignment of partition reassign-demo-0 is complete.
Reassignment of partition reassign-demo-1 is complete.
...
```

---

## 4️⃣ Throttling Reassignment

Pre produkčné prostredie je dôležité throttlovať bandwidth!

**Vytvoríme veľkú tému s dátami:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic large-topic --partitions 6 --replication-factor 2 --if-not-exists
```

**Pošleme veľa dát (simulácia):**
```terminal:execute
command: |
  for i in {1..1000}; do
    echo "Large message number $i with lots of data padding padding padding padding"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic large-topic
```

**Reassignment s throttling (10 MB/s):**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/large-topic-reassign.json <<EOF
{
  "version": 1,
  "partitions": [
    {"topic": "large-topic", "partition": 0, "replicas": [3,1], "log_dirs": ["any","any"]},
    {"topic": "large-topic", "partition": 1, "replicas": [1,2], "log_dirs": ["any","any"]},
    {"topic": "large-topic", "partition": 2, "replicas": [2,3], "log_dirs": ["any","any"]},
    {"topic": "large-topic", "partition": 3, "replicas": [3,1], "log_dirs": ["any","any"]},
    {"topic": "large-topic", "partition": 4, "replicas": [1,2], "log_dirs": ["any","any"]},
    {"topic": "large-topic", "partition": 5, "replicas": [2,3], "log_dirs": ["any","any"]}
  ]
}
EOF'
```

**Execute s throttle:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/large-topic-reassign.json \
    --execute \
    --throttle 10000000
```

💡 **10000000 bytes/sec = 10 MB/s** - nepreťažíme network!

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/large-topic-reassign.json \
    --verify
```

---

## 5️⃣ Increase Replication Factor

Zmeníme replication factor z 2 na 3:

**Vytvoríme tému s RF=2:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic rf-demo --partitions 3 --replication-factor 2 --if-not-exists
```

**Describe - RF=2:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic rf-demo
```

**Increase RF na 3 (pridáme tretiu repliku):**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/increase-rf.json <<EOF
{
  "version": 1,
  "partitions": [
    {"topic": "rf-demo", "partition": 0, "replicas": [1,2,3], "log_dirs": ["any","any","any"]},
    {"topic": "rf-demo", "partition": 1, "replicas": [2,3,1], "log_dirs": ["any","any","any"]},
    {"topic": "rf-demo", "partition": 2, "replicas": [3,1,2], "log_dirs": ["any","any","any"]}
  ]
}
EOF'
```

**Execute:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/increase-rf.json \
    --execute
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/increase-rf.json \
    --verify
```

**Describe - RF=3 teraz:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic rf-demo
```

---

## 6️⃣ Decrease Replication Factor

Môžeme aj znížiť RF (opatrne!):

**Decrease RF z 3 na 2:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/decrease-rf.json <<EOF
{
  "version": 1,
  "partitions": [
    {"topic": "rf-demo", "partition": 0, "replicas": [1,2], "log_dirs": ["any","any"]},
    {"topic": "rf-demo", "partition": 1, "replicas": [2,3], "log_dirs": ["any","any"]},
    {"topic": "rf-demo", "partition": 2, "replicas": [3,1], "log_dirs": ["any","any"]}
  ]
}
EOF'
```

**Execute:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/decrease-rf.json \
    --execute
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/decrease-rf.json \
    --verify
```

⚠️ **Pozor**: Zníženie RF znižuje durability!

---

## 7️⃣ Broker Decommissioning

Scenario: Vyraďujeme broker 3, presunieme všetky partície na broker 1,2:

**Vytvoríme tému na broker 3:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic broker3-topic --partitions 4 --replication-factor 2 --if-not-exists
```

**Describe - niektoré partície sú na broker 3:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic broker3-topic | grep "Replicas:.*3"
```

**Move všetky partície z broker 3 na 1,2:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/decommission-broker3.json <<EOF
{
  "topics": [
    {"topic": "broker3-topic"}
  ],
  "version": 1
}
EOF'
```

**Generate plan pre brokery 1,2 (bez 3):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topics-to-move-json-file /tmp/decommission-broker3.json \
    --broker-list "1,2" \
    --generate
```

**Skopírujeme Proposed plan a uložíme:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/execute-decommission.json <<EOF
{
  "version": 1,
  "partitions": [
    {"topic": "broker3-topic", "partition": 0, "replicas": [1,2], "log_dirs": ["any","any"]},
    {"topic": "broker3-topic", "partition": 1, "replicas": [2,1], "log_dirs": ["any","any"]},
    {"topic": "broker3-topic", "partition": 2, "replicas": [1,2], "log_dirs": ["any","any"]},
    {"topic": "broker3-topic", "partition": 3, "replicas": [2,1], "log_dirs": ["any","any"]}
  ]
}
EOF'
```

**Execute:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/execute-decommission.json \
    --execute
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --reassignment-json-file /tmp/execute-decommission.json \
    --verify
```

**Describe - broker 3 už nie je v Replicas:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic broker3-topic
```

---

## 🎯 Use Cases

### 1. Rebalancing After Adding New Broker
**Scenario**: Pridali sme nový broker, chceme redistribuovať partície:
```terminal:execute
command: |
  echo "Generate plan with all brokers (1,2,3):"
  docker exec kafka-1 sh -c 'cat > /tmp/rebalance-all.json <<EOF
{
  "topics": [
    {"topic": "reassign-demo"}
  ],
  "version": 1
}
EOF'
```

```terminal:execute
command: |
  docker exec kafka-1 kafka-reassign-partitions.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topics-to-move-json-file /tmp/rebalance-all.json \
    --broker-list "1,2,3" \
    --generate
```

### 2. Disk Space Balancing
**Scenario**: Broker 1 má plný disk, presunieme partície:
```bash
# Over disk usage najprv (další level - kafka-log-dirs)
# Potom reassign partície z broker 1 na 2,3
```

### 3. Performance Optimization
**Scenario**: Leader je na pomalšom brokeri, presunieme:
```bash
# Change leader preference v reassignment JSON
{"topic": "my-topic", "partition": 0, "replicas": [2,1,3]}
# 2 bude nový leader (prvý v zozname)
```

---

## 🔍 Kafka UI Verification

Otvor Kafka UI:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Čo kontrolovať:**
- Brokers → Disk Usage → balancovaný?
- Topics → `reassign-demo` → Partitions tab → vidíš nové Replicas?
- Topics → `rf-demo` → Replication Factor = 3?

---

## ⚠️ Common Errors

### 1. "Replica is not alive"
```
ERROR Replica 3 is not alive for partition [topic,0]
```
**Riešenie:**
- Over, že broker 3 beží: `docker ps | grep kafka-3`
- Použij len live brokery v JSON

### 2. "Reassignment already in progress"
```
ERROR There is an existing assignment running
```
**Riešenie:**
- Počkaj, kým aktuálny reassignment skončí
- Použi `--verify` pre checking progress

### 3. "Invalid JSON format"
```
ERROR Failed to parse JSON
```
**Riešenie:**
- Over JSON syntax (čiarky, zátvorky)
- Použi JSON validator (napr. `jq`)

### 4. "Not enough replicas"
```
ERROR Replication factor 3 larger than available brokers 2
```
**Riešenie:**
- Nemôžeš mať RF > počet brokerov
- Znížiť RF alebo pridať brokery

---

## 🎓 Best Practices

✅ **DO:**
- Vždy backup "Current Partition Replica Assignment" pred reassignment
- Použi `--throttle` v produkcii (napr. 50-100 MB/s)
- Použi `--verify` pravidelne počas reassignment
- Testuj na DEV prostredí najprv
- Monitoruj disk usage a network počas reassignment

❌ **DON'T:**
- Nerob reassignment bez throttle v produkcii (saturuje network)
- Neznižuj RF pod 2 (risk of data loss)
- Nereassignuj všetky témy naraz (postupne)
- Nezabudni na `--verify` - reassignment môže zlyhať v polovici

---

## 📊 Throttling Guidelines

| Environment | Throttle (bytes/sec) | Use Case |
|-------------|----------------------|----------|
| **DEV/TEST** | No throttle / 100MB | Fast testing |
| **STAGING** | 50 MB/s | Realistic testing |
| **PRODUCTION (off-peak)** | 100 MB/s | Faster reassignment |
| **PRODUCTION (peak)** | 20-50 MB/s | Minimálny impact |

---

## 🎯 Summary

Naučili sme sa:
- ✅ Generate reassignment plan pomocou `--generate`
- ✅ Execute reassignment pomocou `--execute`
- ✅ Verify progress pomocou `--verify`
- ✅ Throttling bandwidth pre produkčné prostredie
- ✅ Increase/decrease replication factor
- ✅ Broker decommissioning
- ✅ Real-world use cases (rebalancing, performance)

**Next Level:** Naučíme sa analyzovať disk usage pomocou `kafka-log-dirs.sh`! 🚀
