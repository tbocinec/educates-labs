---
title: Replication Management
---

# 🎯 Kafka Replication Management

V tejto lekcii sa naučíš používať `kafka-leader-election.sh` a `kafka-replica-verification.sh` - nástroje na správu replikácie.

## Čo je Replication Management?

Tieto nástroje umožňujú:
- ✅ Manuálna leader election (rebalancing leaders)
- ✅ Verifikácia data integrity (replica consistency)
- ✅ Detekcia out-of-sync replicas
- ✅ Performance optimization (leader distribution)

**Kedy použiť:**
- Unbalanced leader distribution
- Post-broker restart rebalancing
- Data integrity audit
- Performance troubleshooting
- Planned maintenance

---

## Leader Election

### Čo je Leader?

V Kafka má každá partícia:
- **1 Leader** - obsluhuje všetky reads/writes
- **N-1 Followers** - repliky, ktoré synchronizujú dáta

**Problem:** Po broker reštarte môžu byť leaders unbalanced!

---

## Help & Syntax - Leader Election

```terminal:execute
command: docker exec kafka-1 kafka-leader-election.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address (povinné)
- `--election-type` - Typ election (`PREFERRED`, `UNCLEAN`)
- `--all-topic-partitions` - Všetky partície
- `--topic` - Konkrétna téma
- `--partition` - Konkrétna partícia

---

## 1️⃣ Check Current Leaders

Najprv sa pozrieme, kde sú leaders:

**Vytvoríme tému s 12 partíciami:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic leader-demo --partitions 12 --replication-factor 3 --if-not-exists
```

**Describe - vidíme leaders:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic leader-demo
```

Output:
```
Partition: 0  Leader: 1  Replicas: 1,2,3  Isr: 1,2,3
Partition: 1  Leader: 2  Replicas: 2,3,1  Isr: 2,3,1
Partition: 2  Leader: 3  Replicas: 3,1,2  Isr: 3,1,2
...
```

**Počet leaders per broker:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic leader-demo | grep "Leader:" | awk '{print $4}' | sort | uniq -c
```

Output (should be balanced):
```
  4 1
  4 2
  4 3
```

---

## 2️⃣ Preferred Leader Election

**Preferred leader** = prvá replika v zozname.

**Trigger preferred leader election:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-leader-election.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --election-type PREFERRED \
    --all-topic-partitions
```

Output:
```
Successfully completed leader election for partitions ...
```

**Verify - leaders sú teraz preferred (balanced):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic leader-demo | grep "Leader:" | awk '{print $4}' | sort | uniq -c
```

💡 **Preferred leader election zabezpečí balanced load!**

---

## 3️⃣ Leader Election for Specific Topic

Rebalance len jednu tému:

**Vytvoríme ďalšiu tému:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic critical-topic --partitions 6 --replication-factor 3 --if-not-exists
```

**Preferred election len pre critical-topic:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-leader-election.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --election-type PREFERRED \
    --topic critical-topic
```

**Verify:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic critical-topic
```

---

## 4️⃣ Unclean Leader Election

**DANGEROUS!** Unclean election volí non-ISR repliku (risk of data loss).

**Scenario:** Všetky ISR repliky sú down, cluster je stuck.

⚠️ **Nepoužívaj bez dobrého dôvodu!**

**Simulácia (nebudeme vykonávať v demo):**
```bash
# ONLY in emergency (all ISR replicas down)
kafka-leader-election.sh \
  --bootstrap-server kafka-1:9092 \
  --election-type UNCLEAN \
  --topic stuck-topic \
  --partition 0
```

💀 **Data loss risk! Use only as last resort.**

---

## 5️⃣ Leader Distribution Analysis

Analyzujeme leader distribution across brokers:

**Create helper script:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/analyze-leaders.sh <<EOF
#!/bin/bash
echo "Leader distribution across brokers:"
kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --describe | grep "Leader:" | awk "{print \\\$4}" | sort | uniq -c | awk "{print \"Broker\", \\\$2, \"has\", \\\$1, \"leaders\"}"
EOF
chmod +x /tmp/analyze-leaders.sh'
```

**Run analysis:**
```terminal:execute
command: docker exec kafka-1 /tmp/analyze-leaders.sh
```

**Ideal:** Leaders evenly distributed (±1 difference).

---

## Replica Verification

### Čo je Replica Verification?

Verifikuje, že **všetky repliky majú rovnaké dáta** (consistency check).

---

## Help & Syntax - Replica Verification

```terminal:execute
command: docker exec kafka-1 kafka-replica-verification.sh --help
```

**Dôležité parametre:**
- `--broker-list` - Broker addresses (povinné)
- `--topic-white-list` - Regex pre témy
- `--report-interval-ms` - Ako často reportovať

---

## 6️⃣ Basic Replica Verification

Verifikácia všetkých tém:

**Pošleme dáta do tém najprv:**
```terminal:execute
command: |
  for i in {1..100}; do
    echo "Verification test message $i"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic leader-demo
```

**Run replica verification (beží 10 sekúnd):**
```terminal:execute
command: |
  timeout 10 docker exec kafka-1 kafka-replica-verification.sh \
    --broker-list kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic-white-list '.*' \
    --report-interval-ms 5000 || true
```

Output:
```
max lag is 0 for partition [leader-demo,0] at offset 10 among 3 replicas
max lag is 0 for partition [leader-demo,1] at offset 12 among 3 replicas
...
```

💡 **max lag = 0 → všetky repliky sú in-sync!**

---

## 7️⃣ Verification for Specific Topic

Verify len jednu tému:

```terminal:execute
command: |
  timeout 10 docker exec kafka-1 kafka-replica-verification.sh \
    --broker-list kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic-white-list 'leader-demo' \
    --report-interval-ms 3000 || true
```

**Ak je lag > 0:**
```
max lag is 150 for partition [leader-demo,5] ...
WARNING: Replica is lagging behind!
```

---

## 8️⃣ Detect Out-of-Sync Replicas

**Vytvoríme scenario s lag (simulácia):**

```terminal:execute
command: |
  # Burst traffic - pošleme veľa dát rýchlo
  for i in {1..1000}; do
    echo "Burst message $i: $(head -c 200 /dev/zero | tr '\0' 'X')"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic leader-demo &
  
  # Immediate verification (replicas might lag)
  sleep 2
  timeout 5 docker exec kafka-1 kafka-replica-verification.sh \
    --broker-list kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic-white-list 'leader-demo' \
    --report-interval-ms 2000 || true
```

**Môžeš vidieť temporary lag počas burst!**

---

## 9️⃣ ISR vs. Non-ISR

**In-Sync Replicas (ISR)** = repliky, ktoré sú caught up.

**Check ISR:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic leader-demo | grep "Isr:"
```

Output:
```
Isr: 1,2,3  ← All replicas in-sync
Isr: 1,2    ← Replica 3 is lagging!
```

**Ak Isr < Replicas → problem!**

---

## 🔟 Monitoring Leader Changes

Sleduj leader changes (manual monitoring):

**Before preferred election:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic leader-demo | grep "Leader:" | head -5
```

**Trigger election:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-leader-election.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --election-type PREFERRED \
    --topic leader-demo
```

**After preferred election:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe \
    --topic leader-demo | grep "Leader:" | head -5
```

**Compare leaders - should match preferred (first replica)!**

---

## 🎯 Use Cases

### 1. Post-Broker Restart Rebalancing
**Scenario:** Broker 2 reštartoval, teraz má málo leaders:

```terminal:execute
command: |
  echo "Leaders before rebalance:"
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | grep "Leader:" | awk '{print $4}' | sort | uniq -c
```

```terminal:execute
command: |
  docker exec kafka-1 kafka-leader-election.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --election-type PREFERRED \
    --all-topic-partitions
```

```terminal:execute
command: |
  echo "Leaders after rebalance:"
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | grep "Leader:" | awk '{print $4}' | sort | uniq -c
```

### 2. Performance Optimization
**Scenario:** Broker 1 je slow, presun leaders:

```bash
# Manual reassignment potrebný (kafka-reassign-partitions.sh)
# + potom preferred leader election
```

### 3. Data Integrity Audit
**Scenario:** Quarterly audit - over, že repliky sú consistent:

```terminal:execute
command: |
  echo "=== Quarterly Replication Audit ==="
  timeout 15 docker exec kafka-1 kafka-replica-verification.sh \
    --broker-list kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic-white-list '.*' \
    --report-interval-ms 5000 2>&1 | tee /tmp/audit-report.log || true
  
  echo "Audit complete. Check for max lag > 0."
```

### 4. Planned Maintenance
**Scenario:** Pred maintenance over ISR status:

```terminal:execute
command: |
  echo "Pre-maintenance ISR check:"
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --describe | grep -v "Isr:.*1,2,3" | grep "Isr:" || echo "All partitions have full ISR - safe for maintenance!"
```

---

## 🔍 Kafka UI Verification

Otvor Kafka UI:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Čo kontrolovať:**
- Brokers → Broker 1, 2, 3 → Leader Count (should be balanced)
- Topics → `leader-demo` → Partitions tab → Leader column
- Topics → `leader-demo` → Partitions tab → ISR column (all replicas?)

---

## ⚠️ Common Errors

### 1. "Preferred leader not available"
```
ERROR Preferred replica is not available
```
**Riešenie:**
- Preferred leader (prvá replika) nie je alive
- Počkaj, kým broker reštartuje
- Alebo use reassignment pre zmenu preferred

### 2. "Replication lag detected"
```
max lag is 500 for partition ...
```
**Riešenie:**
- Normálne počas high traffic
- Ak persistent → check broker performance
- Možno slow disk, network issues

### 3. "Unclean election unavailable"
```
ERROR Unclean leader election is disabled
```
**Riešenie:**
- Broker config: `unclean.leader.election.enable=false` (default)
- Good! Unclean election = data loss risk

### 4. "Not enough ISR replicas"
```
ERROR Number of insync replicas is below min.insync.replicas
```
**Riešenie:**
- Over `min.insync.replicas` config
- Zabezpeč, že aspoň N brokers sú alive

---

## 🎓 Best Practices

✅ **DO:**
- Pravidelne trigger **preferred leader election** (cron job, napr. weekly)
- Monitoruj ISR status (alerting ak replicas out-of-sync)
- Run **replica verification** pred major changes
- Dokumentuj leader distribution (should be balanced)
- Používaj `auto.leader.rebalance.enable=true` v produkcii

❌ **DON'T:**
- **NIKDY** nepoužívaj unclean election bez absolútnej nevyhnutnosti
- Neignoruj replication lag warnings
- Netriggeruj leader election počas high traffic (performance impact)
- Nezabudni na `min.insync.replicas` pri acks=all

---

## 📊 Leader Election Types

| Election Type | Use Case | Data Loss Risk |
|---------------|----------|----------------|
| **PREFERRED** | Rebalancing, post-restart | ❌ None (safe) |
| **UNCLEAN** | Emergency (all ISR down) | ⚠️ HIGH - last resort only |

---

## 🎯 Summary

Naučili sme sa:
- ✅ Trigger preferred leader election (`--election-type PREFERRED`)
- ✅ Leader distribution analysis
- ✅ Replica verification pomocou `kafka-replica-verification.sh`
- ✅ Detect out-of-sync replicas (lag detection)
- ✅ ISR monitoring
- ✅ Real-world use cases (post-restart, performance, audit, maintenance)
- ✅ Unclean election (avoid!)

**Next Level:** Naučíme sa advanced tools: `kafka-dump-log.sh`, `kafka-delete-records.sh`, `kafka-get-offsets.sh`! 🚀
