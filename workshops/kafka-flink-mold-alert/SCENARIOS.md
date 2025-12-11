# Workshop Scenarios - Implementation Status

This document shows how the created workshop maps to your original three scenarios and provides guidance for implementing the other two.

---

## ✅ Implemented: Scenario #1 - "The Mold Alert" (Filtering)

### Original Specification

**Scenario:** Mold grows when humidity exceeds 70%. We only care about sensors reporting dangerous levels.

**Logic:** IF humidity > 70 THEN Keep

**Output:** A stream of "Alert" events

### Implementation Status: ✅ COMPLETE

**Workshop:** `kafka-flink-mold-alert`

**Implementation Details:**
- ✅ Filter logic: `humidity > 70`
- ✅ Alert enrichment: Adds `status` and `alert_time` fields
- ✅ Input topic: `raw_sensors` (all sensor data)
- ✅ Output topic: `critical_sensors` (filtered alerts only)
- ✅ Data generator: Produces humidity readings 30-95%
- ✅ Real-time monitoring: Kafka UI and Flink UI
- ✅ Hands-on experimentation: Modify threshold, add location filtering, severity levels

**Code Implementation:**

```java
DataStream<String> criticalStream = sensorStream
    .filter(jsonString -> {
        JsonNode node = mapper.readTree(jsonString);
        int humidity = node.get("humidity").asInt();
        return humidity > HUMIDITY_THRESHOLD; // 70
    })
    .map(jsonString -> {
        ObjectNode node = (ObjectNode) mapper.readTree(jsonString);
        node.put("status", "CRITICAL_MOLD_RISK");
        node.put("alert_time", System.currentTimeMillis());
        return node.toString();
    });
```

**Files:** 19 files, 2,593 lines of code/documentation

---

## 📋 Not Yet Implemented: Scenario #2 - "The Unit Converter" (Map/Transformation)

### Original Specification

**Scenario:** Some legacy sensors send data in 0.0-1.0 format (e.g., 0.55), while new sensors send 0-100% (e.g., 55%).

**Logic:** IF value < 1.0 THEN value * 100 ELSE value

**Output:** A standardized stream where all sensors report 0-100

### Implementation Roadmap

**Suggested Workshop Name:** `kafka-flink-unit-converter`

**Estimated Creation Time:** 30-40 minutes (using existing workshop as template)

**Key Changes Needed:**

1. **Data Generator Schema:**
```json
{
  "sensor_id": "sensor-01",
  "humidity": 0.55,  // Mix of 0-1 and 0-100 formats
  "format": "decimal" // or "percentage"
}
```

2. **Flink Job Logic:**
```java
DataStream<String> normalizedStream = sensorStream
    .map(jsonString -> {
        ObjectNode node = (ObjectNode) mapper.readTree(jsonString);
        double humidity = node.get("humidity").asDouble();
        
        // THE CORE LOGIC: Normalize to 0-100 format
        double normalized = (humidity <= 1.0) ? humidity * 100 : humidity;
        
        node.put("humidity", normalized);
        node.put("normalized", true);
        return node.toString();
    });
```

3. **Topics:**
   - Input: `raw_sensor_readings` (mixed formats)
   - Output: `normalized_readings` (all 0-100 format)

4. **Workshop Focus:**
   - Data normalization patterns
   - Handling legacy vs modern formats
   - Stateless transformations
   - Data quality improvement

**Experiments:**
- Add more format types (percentages, fractions, ratios)
- Implement validation (reject out-of-range values)
- Add metadata about transformation applied

---

## 📋 Not Yet Implemented: Scenario #3 - "The Sensor Router" (Branching)

### Original Specification

**Scenario:** You have "Indoor" sensors and "Outdoor" sensors mixed in one topic. The "Indoor" team only wants to see their data.

**Logic:** Split the stream based on `sensor_location`

**Output:** Two topics: `indoor_humidity` and `outdoor_humidity`

### Implementation Roadmap

**Suggested Workshop Name:** `kafka-flink-sensor-router`

**Estimated Creation Time:** 35-45 minutes

**Key Changes Needed:**

1. **Data Generator Schema:**
```json
{
  "sensor_id": "sensor-01",
  "humidity": 65,
  "location_type": "indoor", // or "outdoor"
  "room": "kitchen" // specific location
}
```

2. **Flink Job Logic (Approach 1 - Multiple Sinks):**
```java
DataStream<String> allSensors = env.fromSource(source, ...);

// Split into two streams
DataStream<String> indoorStream = allSensors
    .filter(msg -> parseLocationType(msg).equals("indoor"));

DataStream<String> outdoorStream = allSensors
    .filter(msg -> parseLocationType(msg).equals("outdoor"));

// Route to different topics
indoorStream.sinkTo(createKafkaSink("indoor_humidity"));
outdoorStream.sinkTo(createKafkaSink("outdoor_humidity"));
```

3. **Flink Job Logic (Approach 2 - Side Outputs - More Advanced):**
```java
OutputTag<String> outdoorTag = new OutputTag<>("outdoor"){};

SingleOutputStreamOperator<String> mainStream = allSensors
    .process(new ProcessFunction<String, String>() {
        @Override
        public void processElement(String value, Context ctx, Collector<String> out) {
            String locationType = parseLocationType(value);
            if (locationType.equals("outdoor")) {
                ctx.output(outdoorTag, value); // Side output
            } else {
                out.collect(value); // Main output
            }
        }
    });

// Main output = indoor
mainStream.sinkTo(createKafkaSink("indoor_humidity"));

// Side output = outdoor
mainStream.getSideOutput(outdoorTag)
    .sinkTo(createKafkaSink("outdoor_humidity"));
```

4. **Topics:**
   - Input: `all_sensors` (mixed indoor/outdoor)
   - Output 1: `indoor_humidity` (indoor only)
   - Output 2: `outdoor_humidity` (outdoor only)

5. **Workshop Focus:**
   - Stream branching patterns
   - Side outputs in Flink
   - Multi-sink architectures
   - Data routing strategies

**Experiments:**
- Add a third category (e.g., "garage" or "unknown")
- Implement priority routing (critical vs normal)
- Add location-based aggregations

---

## 🎯 Recommended Implementation Order

If you want to create all three workshops:

### Priority 1: ✅ Mold Alert (DONE)
- **Reason:** Most common pattern in production
- **Status:** Complete and ready
- **Use cases:** Alerting, anomaly detection, quality control

### Priority 2: 📋 Sensor Router (TODO)
- **Reason:** Very common in multi-tenant systems
- **Complexity:** Medium (introduces side outputs)
- **Use cases:** Tenant isolation, priority queues, data routing
- **Estimated time:** 40 minutes to create

### Priority 3: 📋 Unit Converter (TODO)
- **Reason:** Simpler pattern, niche use case
- **Complexity:** Low (simple map transformation)
- **Use cases:** Data normalization, ETL, migration
- **Estimated time:** 30 minutes to create

---

## 🚀 Quick Start Guide for Creating Workshops #2 and #3

### Step 1: Copy Template

```bash
# For Unit Converter
cp -r kafka-flink-mold-alert kafka-flink-unit-converter

# For Sensor Router
cp -r kafka-flink-mold-alert kafka-flink-sensor-router
```

### Step 2: Modify Key Files

**For each new workshop, update:**

1. **Workshop metadata:**
   - `workshop/config.yaml` - Change name
   - `resources/workshop.yaml` - Update title, description, metadata

2. **Data generator:**
   - `schemas/datagen-connector.json` - Adjust schema
   - `start-datagen.sh` - Update topic name

3. **Flink job:**
   - `flink-app/src/main/java/com/workshop/MoldAlertJob.java`
     - Rename class (e.g., `UnitConverterJob`, `SensorRouterJob`)
     - Implement new logic
   - `flink-app/pom.xml` - Update artifact name

4. **Documentation:**
   - `README.md` - Update use case description
   - `workshop/content/*.md` - Adjust for new scenario
   - `docker-compose.yml` - No changes needed (reuse)

### Step 3: Test Locally

```bash
cd kafka-flink-unit-converter  # or sensor-router
./scripts/verify-setup.sh
./build-flink-job.sh
./submit-flink-job.sh
```

---

## 📊 Feature Comparison Matrix

| Feature | Mold Alert (✅) | Unit Converter (📋) | Sensor Router (📋) |
|---------|----------------|--------------------|--------------------|
| Pattern | Filter | Map | Branch |
| Complexity | Low | Low | Medium |
| Flink Features | Filter, Map | Map | Side Outputs |
| Topics | 2 | 2 | 3 |
| Business Logic | Threshold check | Format conversion | Location routing |
| Real-world use | IoT alerting | Data migration | Multi-tenancy |
| Experimentation | Thresholds, locations | Format types | Routing rules |
| Production relevance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🎓 Complete Workshop Series

If all three were created, you'd have a comprehensive **"Flink Fundamentals"** series:

### Workshop 1: Filtering (Mold Alert) ✅
**Pattern:** Filter unwanted events  
**Duration:** 60 minutes  
**Key Learning:** Conditional logic, alerting systems

### Workshop 2: Transformation (Unit Converter) 📋
**Pattern:** Transform data structure  
**Duration:** 45 minutes  
**Key Learning:** Data normalization, format conversion

### Workshop 3: Routing (Sensor Router) 📋
**Pattern:** Route to multiple destinations  
**Duration:** 60 minutes  
**Key Learning:** Side outputs, multi-sink architectures

### Combined Learning Path (165 minutes total)

After completing all three, participants would master:
- ✅ All basic Flink transformation types
- ✅ Kafka source and sink configuration
- ✅ Real-world stream processing patterns
- ✅ Production deployment and monitoring
- ✅ Debugging and troubleshooting

---

## 💡 Suggested "Mega Workshop" Option

Alternatively, combine all three into a single comprehensive workshop:

**Name:** "Flink Stream Processing Patterns: Filter, Transform, Route"

**Duration:** 90 minutes

**Structure:**
1. Setup (10 min) - Same infrastructure for all
2. Pattern 1: Filter (20 min) - Mold alert
3. Pattern 2: Transform (20 min) - Unit converter
4. Pattern 3: Route (25 min) - Sensor router
5. Integration (10 min) - Combine all patterns
6. Wrap-up (5 min)

**Benefit:** Shows pattern progression in single session

---

## ✅ Summary

- **Implemented:** 1 of 3 scenarios (Mold Alert - Filter pattern)
- **Status:** Production-ready, fully documented, 2,593 lines
- **Remaining:** 2 scenarios can be created in ~70 minutes using existing template
- **Recommendation:** Use Mold Alert workshop immediately; create others based on demand

---

**Created:** December 10, 2025  
**Next Action:** Deploy `kafka-flink-mold-alert` to Educates platform for testing

