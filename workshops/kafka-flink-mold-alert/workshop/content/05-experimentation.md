# Experimentation and Customization

Now that you have a working Flink job, let's experiment with modifications!

---

## 🧪 Experiment 1: Change the Threshold

Let's make the alert system more sensitive by lowering the humidity threshold.

### Step 1: Stop the Current Job

First, we need to cancel the running job. Switch to the Flink UI:

```dashboard:open-dashboard
name: Flink UI
```

- Click on "Running Jobs"
- Click on "Humidity Mold Alert Job"
- Click the **Cancel** button (🗑️ icon)
- Confirm the cancellation

Wait a few seconds until status shows "CANCELED".

---

### Step 2: Modify the Threshold

Open the Java source file:

```editor:open-file
file: flink-app/src/main/java/com/workshop/MoldAlertJob.java
line: 32
```

Find line 32 where the threshold is defined:

```java
private static final int HUMIDITY_THRESHOLD = 70;
```

**Change it to a lower value (e.g., 60):**

```java
private static final int HUMIDITY_THRESHOLD = 60;
```

This will make the system alert on moderate humidity levels (60-70%) as well.

**Save the file** (Ctrl+S or Cmd+S).

---

### Step 3: Rebuild the Job

Rebuild the application with the new threshold:

```terminal:execute
command: ./build-flink-job.sh
background: false
session: 1
```

Wait for the build to complete (~30 seconds, faster than the first build).

---

### Step 4: Redeploy

Submit the updated job:

```terminal:execute
command: ./submit-flink-job.sh
background: false
session: 1
```

---

### Step 5: Observe the Difference

Check the output topic to see more alerts:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic critical_sensors --from-beginning --max-messages 10
background: false
session: 1
```

**Expected Result:** You should now see more messages in the output topic because messages with humidity between 60-70 are now included!

---

## 🧪 Experiment 2: Add Location-Based Filtering

Let's make the system smarter by only alerting for specific high-risk locations.

### The Goal

Alert only when:
- Humidity > 70 **AND**
- Location is "basement" or "bathroom" (high-risk areas)

---

### Step 1: Cancel the Running Job

Return to Flink UI and cancel the current job (same as before).

---

### Step 2: Modify the Filter Logic

Open the source file:

```editor:open-file
file: flink-app/src/main/java/com/workshop/MoldAlertJob.java
line: 65
```

Find the filter logic around line 73. Modify it to include location check:

**Original:**
```java
int humidity = node.get("humidity").asInt();
boolean isCritical = humidity > HUMIDITY_THRESHOLD;
```

**New Version:**
```java
int humidity = node.get("humidity").asInt();
String location = node.has("location") ? 
    node.get("location").asText() : "unknown";

// Alert only if high humidity in high-risk locations
boolean isHighRisk = location.equals("basement") || location.equals("bathroom");
boolean isCritical = humidity > HUMIDITY_THRESHOLD && isHighRisk;
```

**Save the file**.

---

### Step 3: Rebuild and Redeploy

```terminal:execute
command: ./build-flink-job.sh
background: false
session: 1
```

```terminal:execute
command: ./submit-flink-job.sh
background: false
session: 1
```

---

### Step 4: Test the New Logic

Watch the output:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic critical_sensors
background: false
session: 2
```

**Expected Result:** You should now ONLY see alerts for basement and bathroom locations, even if other locations have high humidity!

**Press Ctrl+C** to stop.

---

## 🧪 Experiment 3: Add Severity Levels

Let's categorize alerts by severity.

### The Goal

Add a `severity` field:
- **MODERATE**: 60-75% humidity
- **HIGH**: 75-85% humidity
- **CRITICAL**: 85%+ humidity

---

### Step 1: Cancel Current Job

Cancel via Flink UI.

---

### Step 2: Modify the Map Function

Open the source file:

```editor:open-file
file: flink-app/src/main/java/com/workshop/MoldAlertJob.java
line: 85
```

Find the map transformation around line 85-95. Modify it to add severity:

**Original:**
```java
.map(jsonString -> {
    try {
        ObjectNode node = (ObjectNode) mapper.readTree(jsonString);
        node.put("status", "CRITICAL_MOLD_RISK");
        node.put("alert_time", System.currentTimeMillis());
        return mapper.writeValueAsString(node);
    } catch (Exception e) {
        return jsonString;
    }
})
```

**New Version:**
```java
.map(jsonString -> {
    try {
        ObjectNode node = (ObjectNode) mapper.readTree(jsonString);
        int humidity = node.get("humidity").asInt();
        
        // Determine severity level
        String severity;
        if (humidity >= 85) {
            severity = "CRITICAL";
        } else if (humidity >= 75) {
            severity = "HIGH";
        } else {
            severity = "MODERATE";
        }
        
        node.put("status", "MOLD_RISK");
        node.put("severity", severity);
        node.put("alert_time", System.currentTimeMillis());
        return mapper.writeValueAsString(node);
    } catch (Exception e) {
        return jsonString;
    }
})
```

**Save the file**.

---

### Step 3: Rebuild and Redeploy

```terminal:execute
command: ./build-flink-job.sh
background: false
session: 1
```

```terminal:execute
command: ./submit-flink-job.sh
background: false
session: 1
```

---

### Step 4: Verify Severity Levels

Check the output:

```terminal:execute
command: docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic critical_sensors --from-beginning --max-messages 10
background: false
session: 1
```

**Expected Result:** Messages now include `"severity":"MODERATE"` or `"severity":"HIGH"` or `"severity":"CRITICAL"`.

---

## 🎯 Challenge: Create a Topic Router

Can you modify the code to route alerts to different topics based on severity?

**Goal:**
- MODERATE alerts → `moderate_alerts` topic
- HIGH/CRITICAL alerts → `critical_sensors` topic

**Hint:** You'll need to use Flink's `SideOutputs` or create separate sinks for each severity level.

---

## 💡 Key Takeaways

Through these experiments, you learned:

1. ✅ **Stateless transformations** are easy to modify
2. ✅ **Filter + Map patterns** are composable
3. ✅ **Rebuilding and redeploying** is fast with hot deployments
4. ✅ **Business logic** can be adjusted without changing infrastructure
5. ✅ **Testing in production** is safe with Kafka's offset management

---

## 🔄 Reset to Original

Want to restore the original version? 

Change the threshold back to 70 and remove custom logic:

```java
private static final int HUMIDITY_THRESHOLD = 70;
```

Rebuild and redeploy:

```terminal:execute
command: ./build-flink-job.sh && ./submit-flink-job.sh
background: false
session: 1
```

---

**Next:** Want to see a completely different approach? Try the same problem using **Flink SQL** in the next module!

---

