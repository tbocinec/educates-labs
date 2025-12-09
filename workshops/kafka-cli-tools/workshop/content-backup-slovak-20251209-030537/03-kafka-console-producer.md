---
title: Kafka Console Producer
---

# 🎯 Kafka Console Producer

V tejto lekcii sa naučíš používať `kafka-console-producer.sh` - nástroj na posielanie správ do Kafka tém.

## Čo je Console Producer?

Console Producer je command-line nástroj, ktorý:
- ✅ Posiela správy do Kafka tém z príkazového riadku
- ✅ Používa sa na testovanie, debugging, manuálne vkladanie dát
- ✅ Podporuje keys, headers, custom partitioners
- ✅ Môže čítať zo stdin alebo z file

**Kedy použiť:**
- Testing topic connectivity
- Generovanie test dát
- Manual data injection
- Debugging producer issues
- Quick prototyping

---

## Help & Syntax

Najprv si pozrieme help:

```terminal:execute
command: docker exec kafka-1 kafka-console-producer.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address (povinné)
- `--topic` - Názov témy (povinné)
- `--property` - Producer properties (key.serializer, acks, compression, etc.)
- `--producer-property` - Alias pre --property
- `--timeout` - Timeout v ms (default: 1000)

---

## 1️⃣ Basic Message Sending

Najjednoduchší príklad - posielame správy do témy `messages`:

**Vytvoríme tému:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic messages --partitions 3 --replication-factor 2
```

**Interaktívne posielanie:**
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages <<EOF
  Hello Kafka!
  This is message number 1
  This is message number 2
  EOF
```

**Verifikácia - prečítame správy:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages \
    --from-beginning \
    --max-messages 3 \
    --timeout-ms 5000
```

---

## 2️⃣ Sending with Keys

Keys sú dôležité pre:
- **Partitioning** - messages s rovnakým kľúčom idú do rovnakej partície
- **Compaction** - len najnovšia správa pre každý kľúč sa zachová
- **Ordering** - správy s rovnakým kľúčom sú ordered

**Vytvoríme tému pre key-value páry:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic user-events --partitions 3 --replication-factor 2
```

**Posielame s kľúčmi (separator je tab):**
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --property "parse.key=true" \
    --property "key.separator=:" <<EOF
  user123:login_event
  user123:page_view
  user456:login_event
  user123:logout_event
  user789:signup_event
  user456:purchase_event
  EOF
```

**Čítame s kľúčmi:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --from-beginning \
    --property print.key=true \
    --property key.separator=" => " \
    --timeout-ms 5000
```

💡 **Poznámka**: Všetky správy pre `user123` pôjdu do rovnakej partície!

---

## 3️⃣ Custom Partitioning

Môžeme vybrať konkrétnu partíciu:

**Posielame do partície 0:**
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --property "parse.key=true" \
    --property "key.separator=:" \
    --partition 0 <<EOF
  forced_key:This message goes to partition 0
  EOF
```

**Verifikujeme partitioning:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --partition 0 \
    --from-beginning \
    --timeout-ms 5000
```

---

## 4️⃣ Producer Properties

Môžeme nastaviť rôzne producer properties:

**Vytvoríme tému pre high-throughput:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic high-throughput --partitions 12 --replication-factor 2
```

**Posielame s compression a custom acks:**
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic high-throughput \
    --property compression.type=gzip \
    --property acks=all \
    --property batch.size=16384 <<EOF
  Large message 1 with compression enabled
  Large message 2 with compression enabled
  Large message 3 with compression enabled
  Large message 4 with compression enabled
  Large message 5 with compression enabled
  EOF
```

**Dôležité properties:**

| Property | Hodnota | Účel |
|----------|---------|------|
| `acks` | `0`, `1`, `all` | Delivery guarantee (all = najspoľahlivejšie) |
| `compression.type` | `gzip`, `snappy`, `lz4`, `zstd` | Komprimovanie správ |
| `batch.size` | bytes | Veľkosť batch pre posielanie |
| `linger.ms` | ms | Čakanie pred odoslaním (vyššie = lepší throughput) |
| `retries` | number | Počet retry pri zlyhaniach |

---

## 5️⃣ Timeout & Error Handling

**Posielame s custom timeout:**
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages \
    --timeout 5000 \
    --property request.timeout.ms=10000 <<EOF
  Message with custom timeout
  EOF
```

**Čo sa stane pri chybe?**

Skúsime poslať do neexistujúcej témy (ak je `auto.create.topics.enable=false`):

```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic non-existent-topic \
    --timeout 2000 <<EOF
  This might fail if auto-create is disabled
  EOF
```

💡 **V produkčnom prostredí**:
- Používaj `acks=all` pre critical data
- Nastav `retries` dostatočne vysoko (napr. 10)
- Používaj `compression.type` pre úsporu bandwidth

---

## 6️⃣ JSON Messages

Pre JSON messages (častý use case):

**Vytvoríme tému pre JSON events:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic json-events --partitions 3 --replication-factor 2
```

**Posielame JSON správy:**
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic json-events <<EOF
  {"user_id": "user123", "event": "login", "timestamp": "2024-01-15T10:00:00Z"}
  {"user_id": "user456", "event": "purchase", "amount": 99.99, "timestamp": "2024-01-15T10:05:00Z"}
  {"user_id": "user789", "event": "signup", "email": "user789@example.com", "timestamp": "2024-01-15T10:10:00Z"}
  EOF
```

**Čítame JSON:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic json-events \
    --from-beginning \
    --timeout-ms 5000
```

---

## 7️⃣ Performance Testing

Pre bulk testing môžeme generovať veľa správ:

**Vytvoríme tému pre load testing:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic load-test --partitions 12 --replication-factor 2
```

**Generujeme 100 správ:**
```terminal:execute
command: |
  for i in {1..100}; do
    echo "Message number $i - $(date +%s)"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic load-test \
    --property compression.type=lz4 \
    --property batch.size=32768
```

**Počet správ v téme:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic load-test \
    --time -1 | awk -F: '{sum += $3} END {print "Total messages:", sum}'
```

---

## 🎯 Use Cases

### 1. Testing Topic Setup
Po vytvorení novej témy rýchlo otestuj connectivity:
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages <<EOF
  Test message
  EOF
```

### 2. Manual Data Injection
Ručne vlož správu do DLQ (Dead Letter Queue):
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic dlq-topic --partitions 1 --replication-factor 2 --if-not-exists
```

```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic dlq-topic \
    --property "parse.key=true" \
    --property "key.separator=:" <<EOF
  error123:{"original_topic": "orders", "error": "serialization_error", "data": "corrupted_payload"}
  EOF
```

### 3. Debugging Consumer Issues
Simuluj konkrétne správy pre debugging:
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic debug-topic --partitions 1 --replication-factor 1 --if-not-exists
```

```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic debug-topic <<EOF
  EDGE_CASE_1
  NULL_VALUE
  SPECIAL_CHARS_!@#$%
  EOF
```

---

## 🔍 Kafka UI Verification

Otvor Kafka UI a over:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Čo kontrolovať:**
- Topics → `messages` → Messages tab → vidíš svoje správy?
- Topics → `user-events` → Messages tab → vidíš keys?
- Topics → `load-test` → Overview → koľko messages?

---

## ⚠️ Common Errors

### 1. "Topic does not exist"
```
ERROR Error when sending message ... Topic 'xyz' not found
```
**Riešenie:**
- Buď vytvor tému manuálne (`kafka-topics.sh --create`)
- Alebo povoľ auto-creation (nie odporúčané v produkcii)

### 2. "Connection refused"
```
ERROR Error when sending message ... Connection to kafka-1:9092 refused
```
**Riešenie:**
- Over, že broker beží: `docker ps | grep kafka`
- Over bootstrap-server syntax (čiarkou oddelené)

### 3. "Message too large"
```
ERROR The message is ... bytes when serialized which is larger than max.request.size
```
**Riešenie:**
```bash
--property max.request.size=2097152  # 2MB
```

### 4. "Not enough in-sync replicas"
```
ERROR Number of insync replicas for partition [topic,0] is [1], below required minimum [2]
```
**Riešenie:**
- Over `min.insync.replicas` pre tému
- Zabezpeč, že aspoň 2 brokery sú alive

---

## 🎓 Best Practices

✅ **DO:**
- Používaj `acks=all` pre critical data
- Nastav `compression.type` pre veľké messages (gzip, lz4, zstd)
- Používaj keys pre ordering a compaction
- Testuj vždy s malým počtom messages najprv

❌ **DON'T:**
- Nepoužívaj console producer v produkcii (len testing/debugging)
- Nedávaj --partition bez dobrého dôvodu (nechaj default partitioning)
- Nezabudni na timeout pri scriptovaní (`--timeout`)

---

## 📊 Porovnanie Properties

| Use Case | acks | compression | batch.size | linger.ms |
|----------|------|-------------|------------|-----------|
| **Fast testing** | 0 | none | default | 0 |
| **High throughput** | 1 | lz4 | 32768 | 10 |
| **Critical data** | all | gzip | 16384 | 5 |
| **Low latency** | 1 | none | 1024 | 0 |

---

## 🎯 Summary

Naučili sme sa:
- ✅ Posielať basic messages do Kafka
- ✅ Používať keys pre partitioning
- ✅ Nastavovať producer properties (acks, compression)
- ✅ Testovať s JSON messages
- ✅ Debugging a error handling
- ✅ Performance testing s bulk messages

**Next Level:** Naučíme sa čítať správy pomocou `kafka-console-consumer.sh`! 🚀
