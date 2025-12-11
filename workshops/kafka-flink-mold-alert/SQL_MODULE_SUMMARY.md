# Flink SQL Module - Addition Summary

## 🆕 New Module Added: Flink SQL

A new module has been added to the workshop that teaches participants how to solve the same mold alert problem using **Flink SQL** instead of the Java DataStream API.

---

## 📋 Module Overview

**File:** `workshop/content/06-flink-sql.md`  
**Duration:** 15 minutes  
**Difficulty:** Beginner (easier than Java approach)  
**Lines:** 400+ lines of content

---

## 🎯 Learning Objectives

Participants will learn:

1. ✅ **Declarative stream processing** with SQL syntax
2. ✅ **Table definitions** mapping Kafka topics to SQL tables
3. ✅ **Interactive querying** of streaming data
4. ✅ **Continuous queries** as streaming jobs
5. ✅ **SQL aggregations** and windowing functions
6. ✅ **When to use SQL vs Java** for different use cases

---

## 📚 Content Structure

### 1. Introduction (2 min)
- Why Flink SQL?
- Comparison table: DataStream API vs Flink SQL
- When to use each approach

### 2. Setup SQL Client (2 min)
- Cancel the Java job
- Start interactive SQL client
- Introduction to Flink SQL CLI

### 3. Create Table Definitions (3 min)
- Define source table (raw_sensors)
- Define sink table (critical_sensors)
- Understanding table DDL syntax

### 4. Query the Data (2 min)
- SELECT queries to explore data
- Filter high humidity readings
- Interactive exploration

### 5. Deploy Continuous Query (2 min)
- INSERT INTO as streaming job
- The 10-line SQL solution
- Verify in Flink UI

### 6. Advanced SQL Queries (4 min)
- Aggregations: COUNT, AVG, MAX per location
- Windowed aggregations: 5-minute tumbling windows
- Complex filters with CASE statements

### 7. Comparison & Best Practices (2 min)
- Side-by-side comparison: 100 lines Java vs 10 lines SQL
- When to use each approach
- Use case matrix

---

## 💡 Key Code Examples

### The Main SQL Query

Instead of 100 lines of Java:

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

**That's it!** Same functionality in ~10 lines.

---

### Advanced Example: Windowed Aggregation

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

Shows 5-minute alert summaries per location.

---

## 🎓 Pedagogical Benefits

### 1. Multiple Learning Paths
- **Java-first learners:** Start with DataStream API, then see SQL simplification
- **SQL-comfortable learners:** Can jump to SQL module directly
- **Complete picture:** Understand both approaches and trade-offs

### 2. Reinforcement Through Repetition
- Same problem, different solution
- Reinforces core concepts (filtering, transformation, Kafka integration)
- Demonstrates that multiple valid approaches exist

### 3. Real-World Decision Making
- Participants learn WHEN to use each approach
- Not just HOW, but WHY
- Prepares for architecture decisions

### 4. Reduced Barrier to Entry
- SQL is more familiar than Java for many
- Instant gratification with interactive queries
- Encourages experimentation

---

## 🔄 Workshop Flow Update

### Before (60 minutes)
```
1. Quick Start (10 min)
2. Understanding (5 min)
3. Build Java Job (15 min)
4. Deploy & Monitor (15 min)
5. Experimentation (10 min)
6. Wrap-Up (5 min)
```

### After (75 minutes)
```
1. Quick Start (10 min)
2. Understanding (5 min)
3. Build Java Job (15 min)
4. Deploy & Monitor (15 min)
5. Experimentation (10 min)
6. Flink SQL (15 min) 🆕
7. Wrap-Up (5 min)
```

**Bonus Module:** Can be optional for time-constrained sessions.

---

## 🎯 Comparison: Java vs SQL

| Aspect | Java DataStream | Flink SQL |
|--------|----------------|-----------|
| **Lines of Code** | ~100 | ~10 |
| **Build Time** | 2-3 minutes | Instant |
| **Deploy Time** | 30 seconds | Instant |
| **Modify & Test** | Rebuild + redeploy | Change query + run |
| **Learning Curve** | Steep | Gentle |
| **Flexibility** | High | Medium |
| **Best For** | Complex logic | Simple transformations |

---

## 🚀 Hands-On Activities

The module includes these interactive exercises:

### Activity 1: Interactive Exploration
```sql
SELECT * FROM raw_sensors LIMIT 10;
```
Participants see live streaming data in SQL format.

### Activity 2: Filtering
```sql
SELECT sensor_id, location, humidity 
FROM raw_sensors 
WHERE humidity > 70 
LIMIT 10;
```
See only critical readings.

### Activity 3: Continuous Job
```sql
INSERT INTO critical_sensors
SELECT ...
FROM raw_sensors
WHERE humidity > 70;
```
Deploy as running streaming job.

### Activity 4: Aggregations
```sql
SELECT location, COUNT(*), AVG(humidity)
FROM raw_sensors
WHERE humidity > 70
GROUP BY location;
```
Real-time statistics per location.

### Activity 5: Windowing
```sql
SELECT window_start, window_end, location, COUNT(*)
FROM TABLE(TUMBLE(TABLE raw_sensors, DESCRIPTOR(event_time), INTERVAL '5' MINUTES))
WHERE humidity > 70
GROUP BY window_start, window_end, location;
```
Time-based aggregations.

---

## 📊 Expected Outcomes

After completing this module, participants will:

1. ✅ Understand Flink SQL capabilities
2. ✅ Be able to create streaming queries
3. ✅ Know when to choose SQL vs Java
4. ✅ Use SQL for rapid prototyping
5. ✅ Apply windowing and aggregations
6. ✅ Make informed architectural decisions

---

## 🛠️ Technical Requirements

### No Additional Setup Required!

The module uses:
- ✅ Existing Flink cluster (already running)
- ✅ Existing Kafka topics (already created)
- ✅ Existing data generator (already producing)
- ✅ Built-in SQL client (part of Flink image)

**Zero additional infrastructure needed!**

---

## 🎨 Module Features

### Interactive SQL Client
- Full-color ASCII art Flink logo
- Tab completion
- Query history
- Multi-line queries
- Pretty-printed results

### Live Queries
- Real-time data streaming
- Continuous updates
- Ctrl+C to stop

### Multiple Terminal Sessions
- SQL client in session 2
- Verification commands in session 1
- Side-by-side comparison possible

### Dashboard Integration
- Links to Flink UI to see SQL job
- Links to Kafka UI for verification

---

## 💪 Advanced Challenges

The module includes optional challenges:

1. **Severity Routing**
   - Route CRITICAL and HIGH to different topics
   - Use CASE statements

2. **Hourly Statistics**
   - Calculate AVG, MIN, MAX per hour
   - Use TUMBLE windows

3. **Rapid Increase Detection**
   - Find sensors with >15% jump in 5 minutes
   - Use LAG function

4. **Metadata Joins**
   - Enrich with sensor owner info
   - Use JOIN with lookup table

---

## 📖 Documentation Updates

All documentation has been updated:

- ✅ `README.md` - Added SQL module section
- ✅ `01-quick-start.md` - Updated module list
- ✅ `05-experimentation.md` - Added pointer to SQL module
- ✅ `resources/workshop.yaml` - Updated duration to 75m
- ✅ New file: `06-flink-sql.md` (400+ lines)

---

## 🎓 Educational Value

### Before SQL Module
Participants learned:
- Stream processing with Java
- One approach (programmatic)
- Detailed implementation

### After SQL Module
Participants learn:
- Stream processing with Java **AND** SQL
- Two approaches (programmatic + declarative)
- How to choose the right tool
- **More complete picture of Flink ecosystem**

---

## 🌟 Why This Addition Matters

1. **Accessibility:** SQL is more familiar than Java for many participants
2. **Productivity:** Shows how to achieve results in minutes vs hours
3. **Completeness:** Covers both major Flink APIs
4. **Real-world:** Reflects actual decision-making in production
5. **Flexibility:** Module can be optional or mandatory depending on audience

---

## 🎯 Success Metrics

The module is successful if participants can:

1. ✅ Start the SQL client
2. ✅ Create table definitions
3. ✅ Write SELECT queries
4. ✅ Deploy continuous INSERT queries
5. ✅ Verify results in output topic
6. ✅ Explain when to use SQL vs Java

---

## 🔄 Integration with Existing Content

The SQL module:
- ✅ **Builds on** existing infrastructure (no new setup)
- ✅ **Reinforces** core concepts (filtering, transformation)
- ✅ **Extends** learning (adds new approach)
- ✅ **Complements** Java module (comparison, not replacement)
- ✅ **Optional** (can be skipped if time is limited)

---

## 📈 Impact on Workshop

### Time
- Added 15 minutes (60m → 75m)
- Can be skipped for 60-minute sessions
- Provides depth for longer workshops

### Complexity
- **Reduces** perceived complexity (SQL is simpler)
- **Increases** understanding (multiple approaches)
- **Maintains** hands-on nature

### Value
- **Higher** for SQL-comfortable audiences
- **Educational** for all audiences (comparison)
- **Practical** for rapid prototyping scenarios

---

## ✅ Module Status

- ✅ **Content Complete:** 400+ lines of educational material
- ✅ **Code Examples:** 5+ SQL queries provided
- ✅ **Hands-On Activities:** 5 interactive exercises
- ✅ **Documentation Updated:** All references updated
- ✅ **Integration Complete:** Flows naturally from experimentation
- ✅ **No Additional Setup:** Uses existing infrastructure

**Status:** Ready for immediate use!

---

## 🚀 Quick Start for SQL Module

```bash
# After completing the Java modules, jump to SQL:

# 1. Cancel Java job (via Flink UI)

# 2. Start SQL client
docker exec -it flink-jobmanager /opt/flink/bin/sql-client.sh

# 3. Create tables (copy from module content)

# 4. Run the query
INSERT INTO critical_sensors
SELECT sensor_id, location, humidity, temperature, `timestamp`,
       'CRITICAL_MOLD_RISK' AS status,
       UNIX_TIMESTAMP() * 1000 AS alert_time
FROM raw_sensors
WHERE humidity > 70;

# 5. Verify results
docker exec kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic critical_sensors --from-beginning --max-messages 5
```

---

**Module Added:** December 10, 2025  
**File:** `06-flink-sql.md`  
**Lines:** 400+  
**Status:** ✅ Production Ready

