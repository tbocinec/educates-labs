---
title: Advanced CLI Tools
---

# 🎯 Advanced Kafka CLI Tools

V tejto lekcii sa naučíš používať pokročilé Kafka CLI nástroje pre deep debugging a maintenance.

## Nástroje v tejto lekcii

- ✅ **kafka-dump-log.sh** - Raw log inspection
- ✅ **kafka-get-offsets.sh** - Offset queries
- ✅ **kafka-delete-records.sh** - Manual cleanup
- ✅ **kafka-broker-api-versions.sh** - API compatibility

**Kedy použiť:**
- Deep debugging (corruption, offset issues)
- GDPR compliance (delete specific records)
- Capacity planning (offset analysis)
- Upgrade planning (API compatibility)

---

## 1️⃣ kafka-dump-log.sh

### Čo je dump-log?

Umožňuje čítať **raw log segments** priamo z disku.

**Use cases:**
- Inspect log file structure
- Debug corruption
- Analyze offset gaps
- Low-level troubleshooting

---

### Help

```terminal:execute
command: docker exec kafka-1 kafka-dump-log.sh --help
```

**Dôležité parametre:**
- `--files` - Cesta k log file (povinné)
- `--print-data-log` - Vypíš messages
- `--deep-iteration` - Deep scan (slower, thorough)
- `--offsets-decoder` - Decode offset metadata

---

### Find Log Files

Log files sú v `/var/lib/kafka/data`:

**Vytvoríme tému pre dump demo:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic dump-demo --partitions 2 --replication-factor 2 --if-not-exists
```

**Pošleme messages:**
```terminal:execute
command: |
  for i in {1..20}; do
    echo "Dump test message $i"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic dump-demo
```

**Find log directory:**
```terminal:execute
command: |
  docker exec kafka-1 find /var/lib/kafka/data -name "dump-demo-*" -type d
```

Output:
```
/var/lib/kafka/data/dump-demo-0
/var/lib/kafka/data/dump-demo-1
```

**List log files:**
```terminal:execute
command: |
  docker exec kafka-1 ls -lh /var/lib/kafka/data/dump-demo-0/
```

Output:
```
00000000000000000000.log      ← Active log segment
00000000000000000000.index    ← Offset index
00000000000000000000.timeindex ← Timestamp index
```

---

### Dump Log Metadata

**Dump log file metadata (NO messages):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-dump-log.sh \
    --files /var/lib/kafka/data/dump-demo-0/00000000000000000000.log | head -30
```

Output:
```
Dumping /var/lib/kafka/data/dump-demo-0/00000000000000000000.log
Starting offset: 0
baseOffset: 0 lastOffset: 9 count: 10 baseSequence: 0 ...
```

---

### Dump with Messages

**Dump s messages (print data):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-dump-log.sh \
    --files /var/lib/kafka/data/dump-demo-0/00000000000000000000.log \
    --print-data-log | head -50
```

Output:
```
offset: 0 position: 0 CreateTime: 1702124000000 size: 25 magic: 2 payload: Dump test message 1
offset: 1 position: 25 CreateTime: 1702124001000 size: 25 magic: 2 payload: Dump test message 2
...
```

**Dôležité fields:**
- `offset` - Logical offset
- `position` - Physical position v file
- `CreateTime` - Message timestamp
- `size` - Message size v bytes
- `payload` - Actual message

---

### Deep Iteration

**Thorough scan (slower, detects corruption):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-dump-log.sh \
    --files /var/lib/kafka/data/dump-demo-0/00000000000000000000.log \
    --deep-iteration \
    --print-data-log | tail -20
```

💡 **Deep iteration overuje checksumy - detects corruption!**

---

## 2️⃣ kafka-get-offsets.sh

### Čo je get-offsets?

Zisťuje offsety pre témy (earliest, latest, timestamp-based).

**Use cases:**
- Capacity calculation (koľko messages?)
- Timestamp-based offset lookup
- Monitoring offset growth

---

### Help

```terminal:execute
command: docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address
- `--topic` - Topic name
- `--time` - Timestamp (-1 = latest, -2 = earliest)

---

### Get Latest Offsets

**Latest offset pre dump-demo:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic dump-demo \
    --time -1
```

Output:
```
dump-demo:0:10
dump-demo:1:10
```

Format: `topic:partition:offset`

---

### Get Earliest Offsets

**Earliest offset:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic dump-demo \
    --time -2
```

Output:
```
dump-demo:0:0
dump-demo:1:0
```

---

### Calculate Total Messages

**Total messages v téme:**
```terminal:execute
command: |
  echo "Calculating total messages in dump-demo..."
  docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic dump-demo \
    --time -1 | awk -F: '{sum += $3} END {print "Total messages:", sum}'
```

---

### Timestamp-Based Offset

**Find offset for specific timestamp:**

```terminal:execute
command: |
  # Current timestamp - 5 minutes
  TIMESTAMP=$(($(date +%s) * 1000 - 300000))
  echo "Looking for offset at timestamp: $TIMESTAMP"
  
  docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic dump-demo \
    --time $TIMESTAMP
```

💡 **Timestamp v milliseconds!**

---

## 3️⃣ kafka-delete-records.sh

### Čo je delete-records?

Vymaže records **pred konkrétnym offsetom** (permanent!).

**Use cases:**
- GDPR compliance (delete user data)
- Free up space quickly
- Remove corrupted messages
- Manual cleanup pred retention

⚠️ **PERMANENT DELETION - use with caution!**

---

### Help

```terminal:execute
command: docker exec kafka-1 kafka-delete-records.sh --help
```

**Dôležité parametre:**
- `--bootstrap-server` - Kafka broker address
- `--offset-json-file` - JSON file s offsetmi

---

### Delete Records Example

**Vytvoríme tému pre delete demo:**
```terminal:execute
command: docker exec kafka-1 kafka-topics.sh --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 --create --topic delete-demo --partitions 2 --replication-factor 2 --if-not-exists
```

**Pošleme 50 messages:**
```terminal:execute
command: |
  for i in {1..50}; do
    echo "Delete demo message $i"
  done | docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic delete-demo
```

**Check messages (should be 50):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic delete-demo \
    --time -1 | awk -F: '{sum += $3} END {print "Messages before delete:", sum}'
```

---

### Create Delete JSON

**Vytvoríme JSON file - delete prvých 20 messages z každej partície:**
```terminal:execute
command: |
  docker exec kafka-1 sh -c 'cat > /tmp/delete-offsets.json <<EOF
{
  "partitions": [
    {
      "topic": "delete-demo",
      "partition": 0,
      "offset": 20
    },
    {
      "topic": "delete-demo",
      "partition": 1,
      "offset": 20
    }
  ],
  "version": 1
}
EOF'
```

**Verify JSON:**
```terminal:execute
command: docker exec kafka-1 cat /tmp/delete-offsets.json
```

---

### Execute Delete

**DELETE RECORDS (permanent!):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-delete-records.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --offset-json-file /tmp/delete-offsets.json
```

Output:
```
Deleting records for partition delete-demo-0 with offset 20
Deleting records for partition delete-demo-1 with offset 20
Records deleted successfully.
```

---

### Verify Deletion

**Check earliest offset (should be 20 now):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic delete-demo \
    --time -2
```

Output:
```
delete-demo:0:20  ← Was 0, now 20!
delete-demo:1:20  ← Was 0, now 20!
```

**Try to read deleted messages (should fail):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic delete-demo \
    --partition 0 \
    --offset 0 \
    --max-messages 1 \
    --timeout-ms 3000 || echo "Cannot read offset 0 - deleted!"
```

**Read from offset 20 (works):**
```terminal:execute
command: |
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic delete-demo \
    --partition 0 \
    --offset 20 \
    --max-messages 5 \
    --timeout-ms 3000
```

💀 **Messages 0-19 sú PERMANENTLY deleted!**

---

## 4️⃣ kafka-broker-api-versions.sh

### Čo je broker-api-versions?

Zisťuje **API versions** podporované brokerom.

**Use cases:**
- Upgrade planning (client compatibility)
- Debugging version mismatches
- Feature detection

---

### Check API Versions

**Query broker API versions:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-broker-api-versions.sh \
    --bootstrap-server kafka-1:9092 | head -30
```

Output:
```
kafka-1:9092 (id: 1 rack: null) -> (
  Produce(0): 0 to 9 [usable: 9],
  Fetch(1): 0 to 13 [usable: 13],
  ListOffsets(2): 0 to 7 [usable: 7],
  Metadata(3): 0 to 12 [usable: 12],
  ...
)
```

**Dôležité:**
- `usable: 9` = broker podporuje API version 9
- Client musí používať version <= 9

---

### Specific API Check

**Find Produce API versions:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-broker-api-versions.sh \
    --bootstrap-server kafka-1:9092 | grep "Produce"
```

**Find Consumer API versions:**
```terminal:execute
command: |
  docker exec kafka-1 kafka-broker-api-versions.sh \
    --bootstrap-server kafka-1:9092 | grep "Fetch"
```

---

## 🎯 Use Cases

### 1. GDPR - Delete User Data
**Scenario:** User requested data deletion:

```terminal:execute
command: |
  # Create GDPR demo topic
  docker exec kafka-1 kafka-topics.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --create --topic user-events --partitions 1 --replication-factor 2 --if-not-exists
```

```terminal:execute
command: |
  # Send user events
  docker exec -i kafka-1 kafka-console-producer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --property "parse.key=true" \
    --property "key.separator=:" <<EOF
user123:signup_event
user456:login_event
user123:purchase_event
user789:page_view
user123:logout_event
EOF
```

```terminal:execute
command: |
  # User123 requested deletion
  # Find offset range for user123 (manual inspection)
  docker exec kafka-1 kafka-console-consumer.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic user-events \
    --from-beginning \
    --property print.key=true \
    --property print.offset=true \
    --timeout-ms 3000
```

```terminal:execute
command: |
  # Delete records up to offset 5 (includes user123 data)
  docker exec kafka-1 sh -c 'cat > /tmp/gdpr-delete.json <<EOF
{
  "partitions": [{"topic": "user-events", "partition": 0, "offset": 5}],
  "version": 1
}
EOF'
  
  docker exec kafka-1 kafka-delete-records.sh \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --offset-json-file /tmp/gdpr-delete.json
```

💡 **GDPR compliance achieved!**

---

### 2. Debug Corrupted Segment
**Scenario:** Consumer reports deserialization errors:

```terminal:execute
command: |
  # Inspect raw log file
  docker exec kafka-1 sh -c '
    LOG_FILE=$(find /var/lib/kafka/data/dump-demo-0 -name "*.log" | head -1)
    kafka-dump-log.sh --files $LOG_FILE --deep-iteration --print-data-log | tail -20
  '
```

---

### 3. Capacity Planning
**Scenario:** Plánujeme retention policy:

```terminal:execute
command: |
  echo "=== Capacity Analysis ==="
  
  # Messages per day (example)
  MESSAGES_PER_DAY=1000000
  
  # Current total messages
  CURRENT=$(docker exec kafka-1 kafka-run-class.sh kafka.tools.GetOffsetShell \
    --bootstrap-server kafka-1:9092,kafka-2:9093,kafka-3:9094 \
    --topic dump-demo \
    --time -1 | awk -F: '{sum += $3} END {print sum}')
  
  echo "Current messages: $CURRENT"
  echo "Messages per day: $MESSAGES_PER_DAY"
  echo "With 7-day retention: $((MESSAGES_PER_DAY * 7)) messages"
```

---

### 4. Upgrade Compatibility Check
**Scenario:** Upgrade Kafka - over client compatibility:

```terminal:execute
command: |
  echo "=== Pre-Upgrade API Check ==="
  docker exec kafka-1 kafka-broker-api-versions.sh \
    --bootstrap-server kafka-1:9092 | grep -E "Produce|Fetch|ApiVersions"
```

---

## 🔍 Kafka UI Verification

Otvor Kafka UI:

```dashboard:open-dashboard
name: Kafka UI
url: {{ ingress_protocol }}://{{ session_namespace }}-kafka-ui.{{ ingress_domain }}
```

**Čo kontrolovať:**
- Topics → `delete-demo` → Messages tab → First offset = 20 (deleted 0-19!)
- Topics → `dump-demo` → Overview → Segment files
- Brokers → API versions (if supported by UI)

---

## ⚠️ Common Errors

### 1. "File not found" (dump-log)
```
ERROR Log file not found
```
**Riešenie:**
- Over path: `find /var/lib/kafka/data -name "*.log"`
- Log files sú len na brokerovi, kde je replika

### 2. "Offset out of range" (delete-records)
```
ERROR Offset 100 is out of range
```
**Riešenie:**
- Over latest offset: `kafka-get-offsets.sh --time -1`
- Offset v JSON musí byť <= latest

### 3. "Cannot delete records in future"
```
ERROR Cannot delete future records
```
**Riešenie:**
- Offset v JSON je vyšší než current latest
- Použi `--time -1` pre zistenie latest

### 4. "Corrupted log segment"
```
ERROR Corrupted record at offset 123
```
**Riešenie:**
- Use `--deep-iteration` pre full scan
- Možno treba delete segment a recover z repliky

---

## 🎓 Best Practices

✅ **DO:**
- **Backup** pred `kafka-delete-records.sh` (permanent!)
- Používaj `dump-log.sh` s `--deep-iteration` pre thorough audit
- Dokumentuj GDPR deletions (audit trail)
- Test delete operations na DEV najprv
- Monitoruj API versions pri upgrade

❌ **DON'T:**
- **NEVER** delete records v produkcii bez approval
- Nedump logs počas high traffic (disk I/O impact)
- Nezabudni na repliky - delete len na leader nestačí
- Nepoužívaj wildcard offsets (must be specific)

---

## 📊 Tools Comparison

| Tool | Use Case | Danger Level |
|------|----------|--------------|
| **dump-log** | Debugging, inspection | ✅ Safe (read-only) |
| **get-offsets** | Capacity, monitoring | ✅ Safe (read-only) |
| **delete-records** | GDPR, cleanup | ⚠️ HIGH (permanent delete) |
| **broker-api-versions** | Compatibility | ✅ Safe (read-only) |

---

## 🎯 Summary

Naučili sme sa:
- ✅ `kafka-dump-log.sh` - Raw log inspection, corruption detection
- ✅ `kafka-get-offsets.sh` - Offset queries (earliest, latest, timestamp)
- ✅ `kafka-delete-records.sh` - Permanent record deletion (GDPR)
- ✅ `kafka-broker-api-versions.sh` - API compatibility checking
- ✅ Real-world use cases (GDPR, debugging, capacity planning, upgrades)

**Next:** Workshop summary a final review! 🚀
