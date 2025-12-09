---
title: Kafka Consumer Groups
---

# 🎯 Kafka Consumer Groups

V tejto lekcii sa naučíš používať `kafka-consumer-groups.sh` - nástroj na správu consumer groups.

## Čo sú Consumer Groups?

Consumer groups sú kľúčový koncept v Kafka:
- ✅ Umožňujú parallel processing (multiple consumers)
- ✅ Sledujú offsety (tracking progress)
- ✅ Load balancing medzi consumers
- ✅ Fault tolerance (rebalancing)

**Kedy použiť:**
- Monitoring consumer lag
- Resetting offsets (replay messages)
- Debugging consumer issues
- Deleting inactive groups
- Lag analysis a alerting

---

## Help & Syntax

Najprv si pozrieme help:

```terminal:execute
command: docker exec kafka-1 kafka-consumer-groups.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address (povinné)
- `--list` - Zoznam všetkých consumer groups
- `--describe` - Detail pre konkrétnu group
- `--group` - Consumer group ID
- `--reset-offsets` - Reset offsetov
- `--delete` - Vymazanie consumer group

---

## 1️⃣ List Consumer Groups

Zoznam všetkých consumer groups v klastri:

```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list
```

Output:
```
my-test-group
manual-commit-group
test-distribution-group
...
```

💡 **Poznámka**: Groups vytvorené v predchádzajúcich leveloch!

---

## 2️⃣ Describe Consumer Group

Detail pre konkrétnu group:

**Najprv vytvoríme tému a consumer group:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic consumer-group-demo --partitions 6 --replication-factor 2 --if-not-exists
```

**Pošleme 30 messages:**
```terminal:execute
command: |
  for i in {1..30}; do
    echo "Message number $i - $(date +%s)"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic consumer-group-demo
```

**Spustíme consumer (prečíta len 20 z 30):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic consumer-group-demo \
    --group demo-group \
    --from-beginning \
    --max-messages 20 \
    --timeout-ms 5000
```

**Describe group - vidíme LAG!**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group demo-group \
    --describe
```

Output:
```
GROUP           TOPIC                PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG
demo-group      consumer-group-demo  0          4               5               1
demo-group      consumer-group-demo  1          3               5               2
demo-group      consumer-group-demo  2          3               5               2
...
```

**Dôležité stĺpce:**
- `CURRENT-OFFSET` - Kde je consumer (naposledy prečítaný offset)
- `LOG-END-OFFSET` - Kde končí log (najnovší offset)
- `LAG` - Rozdiel (koľko messages consumer zaostáva)

---

## 3️⃣ Monitoring Lag

Lag je kritická metrika pre monitoring!

**Vytvoríme scenario s veľkým lagom:**
```terminal:execute
command: |
  # Pošleme veľa messages
  for i in {1..100}; do
    echo "Backlog message $i"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic consumer-group-demo
```

**Spustíme consumer, ktorý prečíta len 10:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic consumer-group-demo \
    --group demo-group \
    --max-messages 10 \
    --timeout-ms 5000
```

**Teraz má group významný LAG:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group demo-group \
    --describe
```

**Celkový LAG pre všetky partície:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group demo-group \
    --describe | awk '{sum+=$6} END {print "Total LAG:", sum}'
```

---

## 4️⃣ Group State

Consumer groups majú rôzne stavy:

```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group demo-group \
    --describe \
    --state
```

Output:
```
GROUP       COORDINATOR (ID)    ASSIGNMENT-STRATEGY  STATE       #MEMBERS
demo-group  kafka-2 (2)         range                Stable      0
```

**Stavy:**
- `Empty` - Group existuje, ale nemá members
- `Stable` - Group má active consumers, všetko funguje
- `PreparingRebalance` - Nový consumer sa pridáva/odstraňuje
- `CompletingRebalance` - Rebalancing prebieha
- `Dead` - Group nemá members a metadata sú vypršané

---

## 5️⃣ Group Members

Ak má group active consumers, vidíme members:

**Spustíme consumer v pozadí (simulácia):**
```terminal:execute
command: |
  echo "Starting long-running consumer in background..."
  docker exec kafka-1 sh -c 'kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic consumer-group-demo \
    --group active-demo-group \
    --timeout-ms 30000 > /dev/null 2>&1 &'
  sleep 2
```

**Describe members:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group active-demo-group \
    --describe \
    --members
```

Output ukáže:
- `CONSUMER-ID` - Unique ID consumera
- `HOST` - Kde beží consumer
- `CLIENT-ID` - Client identifier
- `#PARTITIONS` - Koľko partícií má assigned

---

## 6️⃣ Reset Offsets - To Earliest

Reset offsetov je powerful operácia - **REPLAY messages**!

**Vytvoríme novú tému pre reset demo:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic reset-demo --partitions 3 --replication-factor 2 --if-not-exists
```

**Pošleme 20 messages:**
```terminal:execute
command: |
  for i in {1..20}; do
    echo "Reset demo message $i"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic reset-demo
```

**Consumer prečíta všetky messages:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic reset-demo \
    --group reset-demo-group \
    --from-beginning \
    --timeout-ms 5000
```

**Teraz LAG je 0:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --describe
```

**Reset offsetov na EARLIEST (začiatok):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --to-earliest \
    --execute
```

**Over - LAG je teraz 20!**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --describe
```

**Consumer znovu prečíta všetky messages:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic reset-demo \
    --group reset-demo-group \
    --max-messages 20 \
    --timeout-ms 5000
```

💡 **REPLAY successful!** Všetky messages prečítané znovu.

---

## 7️⃣ Reset Offsets - To Latest

Reset na LATEST = preskočíme všetky messages:

**Pošleme ďalších 10 messages:**
```terminal:execute
command: |
  for i in {21..30}; do
    echo "Additional message $i"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic reset-demo
```

**Reset offsetov na LATEST:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --to-latest \
    --execute
```

**LAG je teraz 0 - všetky messages preskočené:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --describe
```

---

## 8️⃣ Reset Offsets - By Duration

Reset na konkrétny čas v minulosti (napr. 2 minúty dozadu):

**Reset o 2 minúty dozadu:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --by-duration PT2M \
    --execute
```

**Reset o 1 hodinu dozadu:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --by-duration PT1H \
    --execute
```

**Duration formát:**
- `PT2M` - 2 minúty
- `PT1H` - 1 hodina
- `PT30M` - 30 minút
- `P1D` - 1 deň

---

## 9️⃣ Reset Offsets - Shift By

Posunúť offsety o konkrétny počet messages:

**Shift o -5 (5 messages dozadu):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --shift-by -5 \
    --execute
```

**Shift o +3 (3 messages dopredu - preskočíme):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --shift-by 3 \
    --execute
```

**Over výsledok:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --describe
```

---

## 🔟 Delete Consumer Group

Vymazanie consumer group (musí byť inactive!):

**Vytvoríme novú group:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic reset-demo \
    --group temp-group \
    --from-beginning \
    --max-messages 5 \
    --timeout-ms 3000
```

**Describe:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group temp-group \
    --describe
```

**Delete group:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group temp-group \
    --delete
```

**Overíme - group je preč:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --list | grep temp-group || echo "Group 'temp-group' successfully deleted!"
```

⚠️ **Pozor**: Group musí byť INACTIVE (žiadni active consumers)!

---

## 🎯 Use Cases

### 1. Monitoring Consumer Lag
**Production scenario - alerting na high lag:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group demo-group \
    --describe | awk '$6 > 10 {print "ALERT: Partition", $3, "has lag", $6}'
```

### 2. Replay Messages After Bug Fix
**Developer fixed bug, need to reprocess last hour:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --by-duration PT1H \
    --execute
```

### 3. Skip Corrupted Messages
**Producer sent bad data, skip forward:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --shift-by 10 \
    --execute
```

### 4. Testing Consumer Behavior
**Reset to earliest for full reprocessing test:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-consumer-groups.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --group reset-demo-group \
    --topic reset-demo \
    --reset-offsets \
    --to-earliest \
    --execute
```

---

## 🔍 Kafka UI Verification

Otvor Kafka UI a over:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Čo kontrolovať:**
- Consumers → `demo-group` → vidíš LAG pre každú partíciu?
- Consumers → `demo-group` → Members tab → active consumers?
- Topics → `consumer-group-demo` → Consumer Groups tab → LAG graph

---

## ⚠️ Common Errors

### 1. "Group is not empty"
```
ERROR Group 'xxx' is not empty (has active consumers)
```
**Riešenie:**
- Stop all consumers in the group
- Počkaj pár sekúnd (group coordinator needs time)
- Skús znovu

### 2. "Group does not exist"
```
ERROR Consumer group 'xxx' does not exist
```
**Riešenie:**
- Over `--list` či group existuje
- Group sa vytvorí až keď prvý consumer sa pripojí

### 3. "Reset offsets failed"
```
ERROR Error resetting offsets for group 'xxx'
```
**Riešenie:**
- Group musí byť INACTIVE (žiadni active consumers)
- Použi `--dry-run` najprv pre testing:
```bash
--reset-offsets --to-earliest --dry-run
```

### 4. "Invalid duration format"
```
ERROR Invalid duration format
```
**Riešenie:**
- Používaj ISO-8601 duration: `PT2M`, `PT1H`, `P1D`
- Nie: `2m`, `1h`, `1d`

---

## 🎓 Best Practices

✅ **DO:**
- Monitoruj LAG pravidelne (alerting)
- Používaj `--dry-run` pred `--execute` pri reset offsetov
- Dokumentuj consumer group naming convention (napr. `service-name-env`)
- Delete inactive groups pravidelne (cleanup)

❌ **DON'T:**
- Nereset offsety bez porozumenia impact (môže spôsobiť duplicate processing)
- Nepoužívaj rovnaké group ID pre rôzne aplikácie
- Nedelete group s active consumers (zlyhá)
- Neignoruj LAG - môže signalizovať performance issues

---

## 📊 Reset Offsets Comparison

| Method | Use Case | Command Example |
|--------|----------|-----------------|
| **To Earliest** | Full replay | `--reset-offsets --to-earliest` |
| **To Latest** | Skip all backlog | `--reset-offsets --to-latest` |
| **By Duration** | Replay last N hours | `--reset-offsets --by-duration PT1H` |
| **Shift By** | Skip/replay N messages | `--reset-offsets --shift-by -10` |
| **To Datetime** | Reset to specific time | `--reset-offsets --to-datetime 2024-01-15T10:00:00` |

---

## 🎯 Summary

Naučili sme sa:
- ✅ Zoznam a describe consumer groups
- ✅ Monitoring lag (kritická metrika!)
- ✅ Reset offsetov (to-earliest, to-latest, by-duration, shift-by)
- ✅ Group states a members
- ✅ Delete consumer groups
- ✅ Real-world use cases (replay, skip, monitoring)

**Next Level:** Naučíme sa presúvať partície pomocou `kafka-reassign-partitions.sh`! 🚀
