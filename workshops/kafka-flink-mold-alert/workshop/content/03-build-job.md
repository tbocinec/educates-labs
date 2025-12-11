# Build the Flink Job

Now let's examine the Flink code and build the application.

---

## 📝 Examine the Code

Open the main Flink job file:

```editor:open-file
file: flink-app/src/main/java/com/workshop/MoldAlertJob.java
```

Take a moment to review the code structure:

### Key Sections to Notice

1. **Constants** (lines 28-32): Configuration values
   - Kafka connection details
   - Topic names
   - Humidity threshold (70%)

2. **Execution Environment** (lines 42-43):
   - Creates the Flink streaming context
   - Sets parallelism to 1 for simplicity

3. **Kafka Source** (lines 46-52):
   - Configures connection to input topic
   - Uses `earliest` offset (reads from beginning)

4. **Filter Logic** (lines 63-105):
   - Parses JSON messages
   - Checks if humidity > 70
   - Prints console alerts when critical readings detected

5. **Map Transformation** (lines 94-104):
   - Adds `status` field
   - Adds `alert_time` timestamp

6. **Kafka Sink** (lines 108-115):
   - Configures connection to output topic

7. **Execute** (line 117):
   - Starts the job

---

## 🔍 The Core Logic

The most important part is the **filter** operation:

```java
.filter(jsonString -> {
    try {
        JsonNode node = mapper.readTree(jsonString);
        
        if (!node.has("humidity")) {
            return false;  // Skip if no humidity field
        }
        
        int humidity = node.get("humidity").asInt();
        boolean isCritical = humidity > HUMIDITY_THRESHOLD;
        
        if (isCritical) {
            System.out.printf("🚨 ALERT: Sensor %s (%s) - %d%% humidity detected!%n", 
                sensorId, location, humidity);
        }
        
        return isCritical;  // Keep only if critical
        
    } catch (Exception e) {
        return false;  // Drop malformed data
    }
})
```

**What's happening:**
- Parse incoming JSON string
- Extract humidity value
- Return `true` if > 70 (keep message)
- Return `false` otherwise (drop message)

---

## 📦 Examine Maven Configuration

Open the pom.xml to see the dependencies:

```editor:open-file
file: flink-app/pom.xml
```

**Key Dependencies:**
- `flink-streaming-java`: Core Flink API
- `flink-connector-kafka`: Kafka integration
- `jackson-databind`: JSON parsing

**Important Plugin:**
- `maven-shade-plugin`: Creates a fat JAR with all dependencies bundled

---

## 🏗️ Build the Application

Now let's compile the Flink job into a JAR file:

```terminal:execute
command: ./build-flink-job.sh
background: false
session: 1
```

This will:
1. Navigate to `flink-app/` directory
2. Run `mvn clean package`
3. Compile Java code
4. Download dependencies (~2 minutes first time)
5. Create JAR: `flink-app/target/mold-alert-flink-1.0.0.jar`

**Expected output:**
```
🏗️  Building Flink Mold Alert Job...
📦 Running Maven package...
[INFO] Scanning for projects...
[INFO] Building mold-alert-flink 1.0.0
...
[INFO] BUILD SUCCESS
✅ Build successful!
📄 JAR location: flink-app/target/mold-alert-flink-1.0.0.jar
```

---

## ✅ Verify Build

Check that the JAR was created:

```terminal:execute
command: ls -lh flink-app/target/*.jar
background: false
session: 1
```

You should see:
- `mold-alert-flink-1.0.0.jar` (~20 MB)

This JAR contains:
- Your MoldAlertJob class
- Flink Kafka connector
- Jackson JSON library
- All other runtime dependencies

---

## 🧪 What Just Happened?

Maven performed these steps:

1. **Downloaded dependencies** from Maven Central
   - Flink libraries
   - Kafka client
   - Jackson JSON processor

2. **Compiled Java source** to bytecode
   - Used Java 11 compiler

3. **Packaged with shade plugin**
   - Bundled all dependencies into one JAR
   - Excluded Flink core (provided by cluster)
   - Set main class manifest

4. **Created deployable artifact**
   - Ready to submit to Flink JobManager

---

## 🎯 Build Complete!

Your Flink job is now compiled and ready to deploy.

**Next:** We'll submit this JAR to the Flink cluster and watch it process live data!

---

