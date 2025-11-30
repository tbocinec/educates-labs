# Build Java Applications

In this step, we'll build the pre-prepared Java applications that will interact with Kafka.

---

## Project Structure

The workshop includes two Java Maven projects:

```
kafka-apps/
├── producer/          # Kafka message producer
│   ├── pom.xml
│   └── src/main/java/com/example/
│       └── KafkaProducer.java
└── consumer/          # Kafka message consumer
    ├── pom.xml
    └── src/main/java/com/example/
        └── KafkaConsumer.java
```

---

## Explore the Producer Code

Examine the producer application code:

**📁 File location:** `kafka-apps/producer/src/main/java/com/example/KafkaProducer.java`

💡 **View the code in the Editor tab** at the top of this workshop interface.

**Key features:**
- **Sends 50 numbered messages** with timestamps
- **1 second delay** between messages
- **Async sending** with callbacks
- **Proper error handling** and logging

---

## Explore the Consumer Code

Examine the consumer application:

**📁 File location:** `kafka-apps/consumer/src/main/java/com/example/KafkaConsumer.java`

💡 **View the code in the Editor tab** at the top of this workshop interface.

**Key features:**
- **Subscribes to test-messages topic**
- **Consumer group**: `test-consumer-group`
- **Auto-commit** enabled
- **Displays message details** on console

---

## Check Maven Configuration

Examine the Maven dependencies:

**📁 File location:** `kafka-apps/producer/pom.xml` (or consumer/pom.xml)

💡 **View the configuration in the Editor tab** at the top of this workshop interface.

**Dependencies include:**
- **Kafka Clients** (3.8.0) - Core Kafka library
- **SLF4J Simple** - Logging framework
- **Java 21** target

---

## Build Applications

Now let's build both applications:

```terminal:execute
command: chmod +x build-apps.sh && ./build-apps.sh
background: false
```

This script:
1. **Compiles the Producer** application
2. **Compiles the Consumer** application
3. **Downloads dependencies** from Maven Central

---

## Verify Build Success

Check if the build created the necessary class files:

```terminal:execute
command: find kafka-apps -name "*.class" -type f
background: false
```

You should see compiled `.class` files for both applications.

---

## Make Scripts Executable

Ensure our run scripts are executable:

```terminal:execute
command: chmod +x run-producer.sh run-consumer.sh
background: false
```

---

## What's Next?

With applications built, we can now:
1. **Run the Producer** to send messages to Kafka
2. **Run the Consumer** to read and display messages
3. **Monitor activity** in Kafka UI

The Java applications are now ready to demonstrate Kafka messaging! 🚀