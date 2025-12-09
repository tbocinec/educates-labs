---
title: Kafka Console Consumer
---

# 🎯 Kafka Console Consumer

V tejto lekcii sa naučíš používať `kafka-console-consumer.sh` - nástroj na čítanie správ z Kafka tém.

## Čo je Console Consumer?

Console Consumer je command-line nástroj, ktorý:
- ✅ Číta správy z Kafka tém
- ✅ Podporuje rôzne offsety (beginning, latest, specific)
- ✅ Môže formatovať output (keys, timestamps, headers)
- ✅ Používa sa na debugging, monitoring, testing

**Kedy použiť:**
- Verifikácia, že producer posiela správy
- Debugging consumer group issues
- Monitoring data flow
- Quick data inspection
- Testing topic content

---

## Help & Syntax

Najprv si pozrieme help:

```terminal:execute
command: docker exec kafka-1 kafka-console-consumer.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address (povinné)
- `--topic` - Názov témy (povinné)
- `--from-beginning` - Číta od začiatku (inak len nové správy)
- `--max-messages` - Maximálny počet správ (inak infinite)
- `--partition` - Konkrétna partícia
- `--offset` - Konkrétny offset
- `--group` - Consumer group ID
- `--property` - Consumer properties

---

## 1️⃣ Basic Reading

Najjednoduchší príklad - čítame z témy `messages`:

**Ak téma neexistuje, vytvoríme ju a pošleme messages:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic messages --partitions 3 --replication-factor 2 --if-not-exists
```

```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages <<EOF
  Hello from console consumer lesson!
  Message 1
  Message 2
  Message 3
  EOF
```

**Čítame od začiatku:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages \
    --from-beginning \
    --max-messages 10 \
    --timeout-ms 5000
```

💡 **Poznámka**: Bez `--from-beginning` by sme čítali len nové správy!

---

## 2️⃣ Reading Only New Messages

**Spustíme consumer, ktorý čaká na nové messages (v pozadí):**

Najprv otvoríme consumer v samostatnom termináli:
```terminal:execute
command: |
  echo "Starting consumer in background..."
  docker exec kafka-1 sh -c 'kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages \
    --max-messages 3 \
    --timeout-ms 10000 &'
```

**Teraz pošleme nové messages:**
```terminal:execute
command: |
  sleep 2
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages <<EOF
  New message 1 after consumer start
  New message 2 after consumer start
  New message 3 after consumer start
  EOF
```

Bez `--from-beginning` consumer vidí len messages poslané **po jeho štarte**!

---

## 3️⃣ Reading with Keys

Pre key-value páry:

**Vytvoríme tému s kľúčmi (ak neexistuje):**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic user-events --partitions 3 --replication-factor 2 --if-not-exists
```

**Pošleme messages s kľúčmi:**
```terminal:execute
command: |
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --property "parse.key=true" \
    --property "key.separator=:" <<EOF
  user123:login_event
  user456:page_view_home
  user123:page_view_products
  user789:signup_event
  user123:logout_event
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

Output bude:
```
user123 => login_event
user456 => page_view_home
user123 => page_view_products
...
```

---

## 4️⃣ Reading with Timestamps

Vidieť timestamp každej správy:

```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --from-beginning \
    --property print.timestamp=true \
    --property print.key=true \
    --property key.separator=" => " \
    --timeout-ms 5000
```

Output bude:
```
CreateTime:1705315200000   user123 => login_event
CreateTime:1705315201000   user456 => page_view_home
...
```

---

## 5️⃣ Reading Specific Partition

Čítame len z partície 0:

**Najprv zistíme, v ktorej partícii sú naše messages:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --from-beginning \
    --property print.partition=true \
    --property print.key=true \
    --timeout-ms 5000
```

**Teraz čítame len partition 0:**
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

## 6️⃣ Reading from Specific Offset

Čítame od konkrétneho offsetu:

**Zistíme latest offset:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --time -1
```

Output ukáže offsety pre každú partíciu:
```
user-events:0:5
user-events:1:3
user-events:2:2
```

**Čítame partition 0 od offsetu 2:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --partition 0 \
    --offset 2 \
    --timeout-ms 5000
```

---

## 7️⃣ Consumer Groups

Consumer groups umožňujú parallel processing a offset tracking.

**Vytvoríme tému pre group testing:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic group-test --partitions 6 --replication-factor 2 --if-not-exists
```

**Pošleme 20 messages:**
```terminal:execute
command: |
  for i in {1..20}; do
    echo "Message number $i"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic group-test
```

**Čítame s consumer group:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic group-test \
    --group my-test-group \
    --from-beginning \
    --max-messages 10 \
    --timeout-ms 5000
```

**Druhé spustenie s rovnakou group prečíta ďalších 10:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic group-test \
    --group my-test-group \
    --max-messages 10 \
    --timeout-ms 5000
```

💡 **Consumer group si pamätá offset!** Druhé spustenie neprekrýva prvé 10 správ.

---

## 8️⃣ Formatting Output

Môžeme formatovať output rôznymi spôsobmi:

**Vytvoríme tému pre JSON messages:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic json-events --partitions 3 --replication-factor 2 --if-not-exists
```

**Pošleme JSON messages:**
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

**Čítame s detailným formátom:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic json-events \
    --from-beginning \
    --property print.timestamp=true \
    --property print.partition=true \
    --property print.offset=true \
    --property print.headers=true \
    --timeout-ms 5000
```

Output bude:
```
CreateTime:1705315200000 Partition:0 Offset:0 Headers:NO_HEADERS {"user_id": "user123", ...}
CreateTime:1705315300000 Partition:1 Offset:0 Headers:NO_HEADERS {"user_id": "user456", ...}
...
```

---

## 9️⃣ Filtering & Grepping

Môžeme kombinovať s grep pre filtering:

**Čítame len login events:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic json-events \
    --from-beginning \
    --timeout-ms 5000 | grep login
```

**Počet messages v téme:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic json-events \
    --from-beginning \
    --timeout-ms 5000 | wc -l
```

---

## 🔟 Consumer Properties

Môžeme nastaviť rôzne consumer properties:

**Auto-commit disabled (manual offset management):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic group-test \
    --group manual-commit-group \
    --property enable.auto.commit=false \
    --max-messages 5 \
    --timeout-ms 5000
```

**Fetch size optimization:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic group-test \
    --property fetch.min.bytes=1024 \
    --property fetch.max.wait.ms=500 \
    --max-messages 5 \
    --timeout-ms 5000
```

**Dôležité properties:**

| Property | Hodnota | Účel |
|----------|---------|------|
| `enable.auto.commit` | `true`/`false` | Automatic offset commit |
| `auto.offset.reset` | `earliest`/`latest` | Začiatok čítania pri novej group |
| `fetch.min.bytes` | bytes | Minimálne dáta pre fetch |
| `fetch.max.wait.ms` | ms | Maximálne čakanie na fetch |
| `max.poll.records` | number | Max records per poll |

---

## 🎯 Use Cases

### 1. Debugging Producer Issues
Overiť, že producer píše správne:
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages \
    --property print.timestamp=true \
    --property print.partition=true \
    --max-messages 5 \
    --timeout-ms 3000
```

### 2. Monitoring Data Flow
Real-time sledovanie messages (simulácia):
```terminal:execute
command: |
  # Pošleme messages v pozadí
  for i in {1..5}; do
    echo "Real-time message $i"
    sleep 1
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages &
  
  # Čítame real-time
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic messages \
    --max-messages 5 \
    --timeout-ms 10000
```

### 3. Testing Consumer Group Behavior
Overiť, že consumer group správne distribuuje partície:
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic group-test \
    --group test-distribution-group \
    --property print.partition=true \
    --max-messages 10 \
    --timeout-ms 5000
```

### 4. Inspecting Specific Messages
Nájsť messages v konkrétnej partícii a offsete:
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --partition 0 \
    --offset 0 \
    --max-messages 3 \
    --timeout-ms 3000
```

---

## 🔍 Kafka UI Verification

Otvor Kafka UI a over:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Čo kontrolovať:**
- Topics → `group-test` → Consumer Groups → `my-test-group` → vidíš lag?
- Topics → `messages` → Messages tab → vidíš messages, partition assignment?
- Topics → `json-events` → Messages tab → formátovanie JSON?

---

## ⚠️ Common Errors

### 1. "No messages received"
```
Processed a total of 0 messages
```
**Možné príčiny:**
- Téma je prázdna → over `kafka-topics.sh --describe`
- Offset je na konci → použi `--from-beginning`
- Timeout je príliš krátky → zvýš `--timeout-ms`

### 2. "Group rebalancing"
```
WARN [Consumer clientId=console-consumer] Resetting offset for partition
```
**Riešenie:**
- To je normálne pri prvom spustení consumer group
- Alebo iný consumer v rovnakej group sa pripojil/odpojil

### 3. "Connection timeout"
```
ERROR Error processing message, terminating consumer ...
```
**Riešenie:**
- Over bootstrap-server: `docker ps | grep kafka`
- Over network connectivity
- Zvýš `--timeout-ms`

### 4. "Offset out of range"
```
ERROR Offset out of range for partition
```
**Riešenie:**
```bash
--property auto.offset.reset=earliest
```
Alebo reset consumer group offsetu (ďalší level).

---

## 🎓 Best Practices

✅ **DO:**
- Použi `--from-beginning` pri debugovaní
- Použi `--max-messages` a `--timeout-ms` pri scriptovaní
- Použi consumer groups pre tracking pozície
- Formátuj output (`print.key`, `print.timestamp`) pre lepší prehľad

❌ **DON'T:**
- Nespúšťaj console consumer v produkcii (len testing/debugging)
- Nepoužívaj rovnaké consumer group ID pre rôzne účely
- Nezabúdaj na timeout (inak consumer beží donekonečna)

---

## 📊 Porovnanie Modes

| Mode | Use Case | Command |
|------|----------|---------|
| **From beginning** | Debugging, full scan | `--from-beginning` |
| **Latest only** | Real-time monitoring | (default, bez --from-beginning) |
| **Specific offset** | Replay specific range | `--partition X --offset Y` |
| **Consumer group** | Tracking progress | `--group my-group` |

---

## 🎯 Summary

Naučili sme sa:
- ✅ Čítať messages od začiatku vs. latest
- ✅ Používať consumer groups pre offset tracking
- ✅ Formatovať output (keys, timestamps, partitions, offsets)
- ✅ Čítať z konkrétnej partície a offsetu
- ✅ Filtering a grepping messages
- ✅ Consumer properties (auto-commit, fetch sizes)

**Next Level:** Naučíme sa spravovať consumer groups pomocou `kafka-consumer-groups.sh`! 🚀
