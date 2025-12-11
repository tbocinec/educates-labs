# IMMEDIATE FIX: Flink SQL ClassNotFoundException

## 🐛 Current Error

```
[ERROR] Could not execute SQL statement. Reason:
java.lang.ClassNotFoundException: org.apache.flink.connector.kafka.source.KafkaSource
```

---

## ✅ Quick Fix (Do This Now)

### Step 1: Exit SQL Client

If you're in the SQL client, type:
```sql
QUIT;
```

---

### Step 2: Re-run the Updated Setup Script

The script has been updated to download the correct JARs:

```bash
./setup-flink-sql-connectors.sh
```

This will download TWO JARs now:
1. `flink-sql-connector-kafka-3.1.0-1.18.jar` (SQL connector)
2. `flink-connector-kafka-3.1.0-1.18.jar` (base connector with KafkaSource class)

---

### Step 3: Restart Flink

```bash
docker restart flink-jobmanager
```

**Wait 15-20 seconds** for Flink to fully restart.

---

### Step 4: Verify JARs Are Installed

```bash
docker exec flink-jobmanager ls -lh /opt/flink/lib/ | grep kafka
```

**Expected output:**
```
-rw-r--r-- 1 root root  15M Dec 11 10:30 flink-sql-connector-kafka-3.1.0-1.18.jar
-rw-r--r-- 1 root root 950K Dec 11 10:30 flink-connector-kafka-3.1.0-1.18.jar
```

---

### Step 5: Check Flink UI

Open Flink UI at http://localhost:8081

Make sure it's fully loaded and showing "Running" status.

---

### Step 6: Start SQL Client Again

```bash
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh
```

---

### Step 7: Verify Connector is Available

In the SQL client, run:

```sql
SHOW JARS;
```

You should see both Kafka JARs in the list.

---

### Step 8: Try Creating a Table

```sql
CREATE TABLE test_kafka (
    id INT,
    name STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'test',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json'
);
```

**Expected result:**
```
[INFO] Execute statement succeed.
```

If you see this, the fix worked! ✅

---

## 🔍 What Was Wrong?

### Original Problem
- Only downloaded `flink-sql-connector-kafka` JAR
- This JAR has the SQL table factory
- But it doesn't include the actual `KafkaSource` class
- The `KafkaSource` class is in the base `flink-connector-kafka` JAR

### The Fix
- Download BOTH JARs:
  1. **flink-sql-connector-kafka**: SQL Table API integration
  2. **flink-connector-kafka**: Core Kafka source/sink classes

---

## 🎯 Why Two JARs?

Flink's Kafka support is split into layers:

```
┌─────────────────────────────────────┐
│  flink-sql-connector-kafka          │  <- SQL Table Factory
│  (Registers 'kafka' connector)      │
└─────────────────────────────────────┘
                 ↓ depends on
┌─────────────────────────────────────┐
│  flink-connector-kafka               │  <- Core Implementation
│  (KafkaSource, KafkaSink classes)   │
└─────────────────────────────────────┘
```

Both are needed for SQL queries to work!

---

## ✅ Verification Checklist

- [ ] Script ran successfully
- [ ] Two JAR files downloaded
- [ ] JARs copied to `/opt/flink/lib/`
- [ ] Flink restarted
- [ ] Flink UI loads correctly
- [ ] SQL client starts without errors
- [ ] `SHOW JARS;` shows both Kafka JARs
- [ ] CREATE TABLE with Kafka succeeds
- [ ] SELECT queries work

---

## 🚨 If Still Not Working

### Check 1: Verify JAR Sizes

```bash
docker exec flink-jobmanager ls -lh /opt/flink/lib/ | grep kafka
```

- `flink-sql-connector-kafka`: Should be ~15MB
- `flink-connector-kafka`: Should be ~900KB-1MB

If sizes are 0 or very small, the download failed. Delete and re-download.

---

### Check 2: Verify Flink Can Read JARs

```bash
docker exec flink-jobmanager jar -tf /opt/flink/lib/flink-connector-kafka-3.1.0-1.18.jar | grep KafkaSource
```

**Expected:** Should show several lines with `KafkaSource` classes.

---

### Check 3: Check Flink Logs

```bash
docker logs flink-jobmanager | grep -i kafka
```

Look for any errors about loading Kafka classes.

---

## 📝 Updated Files

The setup script (`setup-flink-sql-connectors.sh`) now downloads both JARs automatically.

No manual intervention needed - just run the script!

---

## 🎓 For the Workshop

The workshop content has been updated with:
- ✅ Verification step (`SHOW JARS;`)
- ✅ Longer wait time after restart (15-20 seconds)
- ✅ Flink UI check before SQL client
- ✅ Troubleshooting guidance

---

**Date:** December 11, 2025  
**Status:** ✅ Fixed  
**Action Required:** Re-run setup script and restart Flink

