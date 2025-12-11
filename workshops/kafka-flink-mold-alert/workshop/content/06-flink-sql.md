# Flink SQL - Declarative Stream Processing (BROKEN EXERCISE - loading kafka connector)

Now let's solve the same mold alert problem using **Flink SQL** instead of the Java DataStream API!

---

## 🎯 Why Flink SQL?

Flink SQL provides a **declarative approach** to stream processing:

| Aspect | DataStream API (Java) | Flink SQL |
|--------|----------------------|-----------|
| **Language** | Java/Scala | SQL |
| **Complexity** | ~100 lines of code | ~10 lines of SQL |
| **Learning Curve** | Steep (requires Java knowledge) | Gentle (SQL is familiar) |
| **Use Case** | Complex stateful logic | Filtering, joins, aggregations |
| **Deployment** | Compile → JAR → Submit | Interactive or script |

**When to use Flink SQL:**
- Simple filters and transformations
- Analytics and reporting queries
- Rapid prototyping
- Business analysts can write queries

**When to use DataStream API:**
- Complex stateful processing
- Custom windowing logic
- Advanced CEP patterns
- Performance optimization needed

---

## 📊 The Same Problem in SQL

Remember our Java filter logic?

```java
stream.filter(msg -> parseHumidity(msg) > 70)
      .map(msg -> addAlertStatus(msg))
```

In Flink SQL, this becomes:

```sql
INSERT INTO critical_sensors
SELECT 
    sensor_id,
    location,
    humidity,
    temperature,
    timestamp,
    'CRITICAL_MOLD_RISK' AS status,
    UNIX_TIMESTAMP() * 1000 AS alert_time
FROM raw_sensors
WHERE humidity > 70;
```

**That's it!** Much simpler, right?

---

## 🚀 Setup Flink SQL Client

First, let's prepare the environment for Flink SQL.

### Cancel Java Job

Switch to Flink UI:

```dashboard:open-dashboard
name: Flink UI
```

- Click on "Running Jobs"
- Click on "Humidity Mold Alert Job"
- Click the **Cancel** button
- Wait for status to show "CANCELED"

---

### Prepare Docker Environment

First, we need to restart docker-compose to apply proper user permissions for the volume mount:

```terminal:execute
command: export UID=$(id -u) GID=$(id -g) && docker compose down && docker compose up -d
background: false
session: 1
```

This restarts all containers with proper user/group IDs, preventing permission issues.

Wait ~30 seconds for all services to start, then verify:

```terminal:execute
command: docker ps | grep -E "kafka|flink"
background: false
session: 1
```

All containers should show "Up" status.

---

### Download Kafka Connectors

The Flink SQL client needs the Kafka connector libraries. Let's download them:

```terminal:execute
command: chmod +x setup-flink-sql-connectors.sh && ./setup-flink-sql-connectors.sh
background: false
session: 1
```

This script will:
1. Create `flink-connectors` directory
2. Download the Flink Kafka SQL connector JARs
3. JARs are automatically loaded via `FLINK_CLASSPATH` environment variable

Wait for the "✅ Setup complete!" message.

**Note:** The connectors are loaded via the `FLINK_CLASSPATH=/opt/flink/connectors/*` environment variable configured in docker-compose.yml. No symlinks or complex setup needed!

---

### Restart Flink JobManager

Restart the JobManager to load the new connectors:

```terminal:execute
command: docker restart flink-jobmanager
background: false
session: 1
```

**Wait for Flink to fully restart** (~15-20 seconds). Check the status:

```terminal:execute
command: docker ps --filter name=flink-jobmanager --format "{{.Status}}"
background: false
session: 1
```

Wait until it shows "Up X seconds" (not "Restarting").

Verify Flink is ready by checking the dashboard:

```dashboard:open-dashboard
name: Flink UI
```

The dashboard should load and show "Running" status. If you see connection errors, wait a few more seconds and refresh.

---

### Start SQL Client

Now let's start an interactive Flink SQL session:

```terminal:execute
command: docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh
background: false
session: 2
```

You should see the Flink SQL CLI:

```
                                   ▒▓██▓██▒
                               ▓████▒▒█▓▒▓███▓▒
                            ▓███▓░░        ▒▒▒▓██▒  ▒
                          ░██▒   ▒▒▓▓█▓▓▒░      ▒████
                          ██▒         ░▒▓███▒    ▒█▒█▒
                            ░▓█            ███   ▓░▒██
                              ▓█       ▒▒▒▒▒▓██▓░▒░▓▓█
                            █░ █   ▒▒░       ███▓▓█ ▒█▒▒▒
                            ████░   ▒▓█▓      ██▒▒▒ ▓███▒
                         ░▒█▓▓██       ▓█▒    ▓█▒▓██▓ ░█░
                   ▓░▒▓████▒ ██         ▒█    █▓░▒█▒░▒█▒
                  ███▓░██▓  ▓█           █   █▓ ▒▓█▓▓█▒
                ░██▓  ░█░            █  █▒ ▒█████▓▒ ██▓░▒
               ███░ ░ █░          ▓ ░█ █████▒░░    ░█░▓  ▓░
              ██▓█ ▒▒▓▒          ▓███████▓░       ▒█▒ ▒▓ ▓██▓
           ▒██▓ ▓█ █▓█       ░▒█████▓▓▒░         ██▒▒  █ ▒  ▓█▒
           ▓█▓  ▓█ ██▓ ░▓▓▓▓▓▓▓▒              ▒██▓           ░█▒
           ▓█    █ ▓███▓▒░              ░▓▓▓███▓          ░▒░ ▓█
           ██▓    ██▒    ░▒▓▓███▓▓▓▓▓██████▓▒            ▓███  █
          ▓███▒ ███   ░▓▓▒░░   ░▓████▓░                  ░▒▓▒  █▓
          █▓▒▒▓▓██  ░▒▒░░░▒▒▒▒▓██▓░                            █▓
          ██ ▓░▒█   ▓▓▓▓▒░░  ▒█▓       ▒▓▓██▓    ▓▒          ▒▒▓
          ▓█▓ ▓▒█  █▓░  ░▒▓▓██▒            ░▓█▒   ▒▒▒░▒▒▓█████▒
           ██░ ▓█▒█▒  ▒▓▓▒  ▓█                █░      ░░░░   ░█▒
           ▓█   ▒█▓   ░     █░                ▒█              █▓
            █▓   ██         █░                 ▓▓        ▒█▓▓▓▒█░
             █▓ ░▓██░       ▓▒                  ▓█▓▒░░░▒▓█░    ▒█
              ██   ▓█▓░      ▒                    ░▒█▒██▒      ▓▓
               ▓█▒   ▒█▓▒░                         ▒▒ █▒█▓▒▒░░▒██
                ░██▒    ▒▓▓▒                     ▓██▓▒█▒ ░▓▓▓▓▒█▓
                  ░▓██▒                          ▓░  ▒█▓█  ░░▒▒▒
                      ▒▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▓▓  ▓░▒█░

    ______ _ _       _       _____  ____  _         _____ _ _            _  BETA
   |  ____| (_)     | |     / ____|/ __ \| |       / ____| (_)          | |
   | |__  | |_ _ __ | | __ | (___ | |  | | |      | |    | |_  ___ _ __ | |_
   |  __| | | | '_ \| |/ /  \___ \| |  | | |      | |    | | |/ _ \ '_ \| __|
   | |    | | | | | |   <   ____) | |__| | |____  | |____| | |  __/ | | | |_
   |_|    |_|_|_| |_|_|\_\ |_____/ \___\_\______|  \_____|_|_|\___|_| |_|\__|

        Welcome! Enter 'HELP;' to list all available commands. 'QUIT;' to exit.

Flink SQL>
```

**✅ You're now in the Flink SQL interactive client!**

---

### 🔍 Verify Kafka Connector is Available

Before creating tables, let's verify the Kafka connector is properly loaded.

In the SQL client, run:

```sql
SHOW JARS;
```

You should see JARs including `flink-sql-connector-kafka` and `flink-connector-kafka` in the list. If you don't see them, exit the SQL client (type `QUIT;`) and:

1. Verify the JARs are in the container:
   ```bash
   docker exec flink-jobmanager ls -lh /opt/flink/lib/ | grep kafka
   ```

2. If not present, re-run the setup script and restart

---

## 📝 Create Table Definitions

In Flink SQL, we need to define "tables" that map to our Kafka topics.

### Define Source Table (raw_sensors)

Copy and paste this into the SQL client:

```sql
CREATE TABLE raw_sensors (
    sensor_id STRING,
    location STRING,
    humidity INT,
    temperature INT,
    `timestamp` BIGINT,
    event_time AS TO_TIMESTAMP_LTZ(`timestamp`, 3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'raw_sensors',
    'properties.bootstrap.servers' = 'kafka:29092',
    'properties.group.id' = 'flink-sql-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.fail-on-missing-field' = 'false',
    'json.ignore-parse-errors' = 'true'
);
```

**Press Enter** to execute.

You should see: `[INFO] Execute statement succeed.`

---

### Define Sink Table (critical_sensors)

Now define the output table:

```sql
CREATE TABLE critical_sensors (
    sensor_id STRING,
    location STRING,
    humidity INT,
    temperature INT,
    `timestamp` BIGINT,
    status STRING,
    alert_time BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'critical_sensors',
    'properties.bootstrap.servers' = 'kafka:29092',
    'format' = 'json'
);
```

**Press Enter** to execute.

---

## 🔍 Query the Data

Before creating the continuous query, let's explore the data.

### View Sample Data

```sql
SELECT * FROM raw_sensors LIMIT 10;
```

You should see sensor readings flowing in real-time!

```
+-------------+-------------+----------+-------------+-----------+
| sensor_id   | location    | humidity | temperature | timestamp |
+-------------+-------------+----------+-------------+-----------+
| sensor-02   | bathroom    | 78       | 24          | 170000... |
| sensor-01   | basement    | 45       | 20          | 170000... |
| sensor-03   | kitchen     | 52       | 22          | 170000... |
...
```

Press **Ctrl+C** to stop the query.

---

### Filter High Humidity

Let's see only the high humidity readings:

```sql
SELECT sensor_id, location, humidity 
FROM raw_sensors 
WHERE humidity > 70 
LIMIT 10;
```

You should see only critical readings!

Press **Ctrl+C** when done.

---

## 🚀 Deploy the Continuous Query

Now let's create the **streaming job** that continuously filters and writes to the output topic:

```sql
INSERT INTO critical_sensors
SELECT 
    sensor_id,
    location,
    humidity,
    temperature,
    `timestamp`,
    'CRITICAL_MOLD_RISK' AS status,
    UNIX_TIMESTAMP() * 1000 AS alert_time
FROM raw_sensors
WHERE humidity > 70;
```

**Press Enter** to submit the job.

You should see:
```
[INFO] Submitting SQL update statement to the cluster...
[INFO] SQL update statement has been successfully submitted to the cluster:
Job ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

The query is now running continuously in the background!

---

## 📊 Verify the SQL Job

### Check Flink UI

Switch to the Flink dashboard:

```dashboard:open-dashboard
name: Flink UI
```

You should see a new job:
- **Job Name**: "insert-into_default_catalog.default_database.critical_sensors"
- **Status**: RUNNING

---

### Check Output Topic

In a different terminal session, verify alerts are being written:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic critical_sensors --from-beginning --max-messages 5
background: false
session: 1
```

You should see the same filtered messages as before!

```json
{"sensor_id":"sensor-02","location":"bathroom","humidity":78,"temperature":24,"timestamp":1700000002000,"status":"CRITICAL_MOLD_RISK","alert_time":1733850123456}
```

---

## 🧪 Advanced SQL Queries

Let's explore more powerful SQL features!

### Aggregation: Count Alerts per Location

Go back to the SQL client (session 2) and run:

```sql
SELECT 
    location,
    COUNT(*) as alert_count,
    AVG(humidity) as avg_humidity,
    MAX(humidity) as max_humidity
FROM raw_sensors
WHERE humidity > 70
GROUP BY location;
```

This continuously updates the counts per location!

Press **Ctrl+C** to stop.

---

### Windowed Aggregation: 5-Minute Alert Summary

```sql
SELECT 
    window_start,
    window_end,
    location,
    COUNT(*) as alert_count,
    AVG(CAST(humidity AS DOUBLE)) as avg_humidity
FROM TABLE(
    TUMBLE(TABLE raw_sensors, DESCRIPTOR(event_time), INTERVAL '5' MINUTES)
)
WHERE humidity > 70
GROUP BY window_start, window_end, location;
```

This groups alerts into 5-minute windows!

---

### Complex Filter: Multiple Conditions

```sql
SELECT 
    sensor_id,
    location,
    humidity,
    temperature,
    CASE 
        WHEN humidity >= 85 THEN 'CRITICAL'
        WHEN humidity >= 75 THEN 'HIGH'
        ELSE 'MODERATE'
    END as severity
FROM raw_sensors
WHERE humidity > 70 
  AND location IN ('basement', 'bathroom')
LIMIT 20;
```

This adds severity levels and filters by location!

---

## 🔄 Comparison: Java vs SQL

Let's compare both approaches:

### Java DataStream API

**Pros:**
- ✅ Full control over processing logic
- ✅ Advanced stateful operations
- ✅ Custom serialization
- ✅ Performance optimization
- ✅ Complex CEP patterns

**Cons:**
- ❌ Requires Java knowledge
- ❌ More code to write (~100 lines)
- ❌ Compile and rebuild for changes
- ❌ Longer development cycle

**Lines of Code:** ~100 lines

---

### Flink SQL

**Pros:**
- ✅ Familiar SQL syntax
- ✅ Rapid development (minutes)
- ✅ Interactive exploration
- ✅ Business analysts can use it
- ✅ Built-in functions (aggregations, windows)

**Cons:**
- ❌ Limited to SQL capabilities
- ❌ Less control over low-level details
- ❌ Not suitable for complex stateful logic

**Lines of Code:** ~10 lines

---

## 🎯 When to Use Each Approach

| Use Case | Best Choice |
|----------|-------------|
| Simple filtering and routing | **Flink SQL** ⭐ |
| Aggregations and analytics | **Flink SQL** ⭐ |
| Joins between streams | **Flink SQL** ⭐ |
| Rapid prototyping | **Flink SQL** ⭐ |
| Complex stateful processing | **DataStream API** ⭐ |
| Custom windowing logic | **DataStream API** ⭐ |
| CEP (Complex Event Processing) | **DataStream API** ⭐ |
| Performance-critical paths | **DataStream API** ⭐ |

---

## 🧹 Cleanup SQL Session

When you're done experimenting:

### Stop the SQL Job

In the SQL client:

```sql
SHOW JOBS;
```

This shows the running job ID. Then:

```sql
STOP JOB '<job-id>';
```

Replace `<job-id>` with the actual ID shown.

---

### Exit SQL Client

```sql
QUIT;
```

This exits the SQL CLI.

---

## 💡 Key Takeaways

1. ✅ **Flink SQL is declarative** - Focus on WHAT, not HOW
2. ✅ **Much less code** - ~90% reduction for simple use cases
3. ✅ **Interactive development** - Test queries immediately
4. ✅ **Familiar syntax** - SQL is widely known
5. ✅ **Powerful features** - Windows, aggregations, joins built-in
6. ✅ **Both APIs work together** - You can mix SQL and Java in same application

---

## 🚀 What We Learned

In this module, you:

- ✅ Defined Kafka topics as SQL tables
- ✅ Queried streaming data with SELECT statements
- ✅ Created continuous INSERT queries (streaming jobs)
- ✅ Used aggregations and windowing in SQL
- ✅ Compared SQL vs Java DataStream approaches
- ✅ Understood when to use each method

**The same mold alert logic, 10 lines vs 100 lines!**

---

## 📚 Further SQL Exploration

Try these challenges on your own:

1. **Create severity routing**
   ```sql
   -- Route CRITICAL and HIGH alerts to different topics
   ```

2. **Calculate hourly statistics**
   ```sql
   -- AVG, MIN, MAX humidity per location per hour
   ```

3. **Detect rapid increases**
   ```sql
   -- Find sensors where humidity jumped >15% in 5 minutes
   ```

4. **Join with sensor metadata**
   ```sql
   -- Enrich alerts with sensor owner information
   ```

---

**Next:** Return to the main workshop to continue or explore more experiments!

---

