# Topic Management Fundamentals

Topics are the heart of Kafka - named feeds that organize your data streams. Master these essential operations! 📁

---

## What is a Kafka Topic?

**📋 Topic Definition:**
A **topic** is a named stream of records (messages) that serves as a category or feed name to which data is published and from which data is consumed.

**🔍 Key Concepts:**
- **Named channel** - Like a folder or category for messages
- **Append-only log** - New messages are always added to the end
- **Partitioned** - Divided into partitions for scalability and parallelism
- **Persistent** - Messages are stored on disk (configurable retention)
- **Ordered** - Messages within a partition maintain strict ordering

**🎯 Real-world Analogy:**
Think of a topic like a **newspaper section**:
- `sports` topic = Sports section (all sports news goes here)
- `weather` topic = Weather section (all weather updates go here)
- `business` topic = Business section (all business news goes here)

**💡 Common Topic Examples:**
- `user-events` - User interactions (clicks, logins, purchases)
- `order-processing` - E-commerce order lifecycle events
- `system-logs` - Application and system log messages
- `sensor-data` - IoT device measurements and readings
- `notifications` - Messages to be sent to users

**🏗️ Topic Structure:**
```
Topic: user-events
├── Partition 0: [msg1] [msg2] [msg3] ...
├── Partition 1: [msg4] [msg5] [msg6] ...
└── Partition 2: [msg7] [msg8] [msg9] ...
```

---

## Learning Objectives

In this level you'll learn:
- ✅ **List topics** and understand cluster state
- ✅ **Create topics** with various configurations
- ✅ **Describe topics** to inspect detailed metadata
- ✅ **Alter topic** configurations
- ✅ **Delete topics** safely
- ✅ **Topic configurations** and best practices

---

## 1. Listing Topics

Start by exploring what topics exist in our fresh Kafka cluster:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list
background: false
```

**Expected result:** Empty list (fresh cluster) or internal topics only.

**📚 Documentation:** [kafka-topics command](https://kafka.apache.org/documentation/#basic_ops_add_topic)

---

## 2. Creating Your First Topic

Let's create a simple topic for user events:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic user-events --partitions 3 --replication-factor 1
background: false
```

**Verify creation:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list
background: false
```

**💡 Key Parameters:**
- `--topic user-events` - Topic name (kebab-case recommended)
- `--partitions 3` - Number of partitions (enables parallelism)
- `--replication-factor 1` - Copies per partition (1 for single broker)

---

## 3. Topic Description - Deep Dive

Get detailed information about your topic:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events
background: false
```

**Understanding the output:**
- **Partition Count:** 3 (as specified)
- **Leader:** Which broker handles reads/writes
- **Replicas:** Partition copies (ISR = In-Sync Replicas)
- **Configs:** Topic-specific settings

---

## 4. Creating Topics with Custom Configurations

Create a topic optimized for log retention:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic application-logs --partitions 1 --replication-factor 1 --config retention.ms=86400000 --config cleanup.policy=delete
background: false
```

**Configuration breakdown:**
- `retention.ms=86400000` - Keep messages for 24 hours (86400000 ms)
- `cleanup.policy=delete` - Delete old messages (vs. compact)

**Verify configurations:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic application-logs
background: false
```

---

## 5. High-Throughput Topic

Create a topic designed for high-throughput scenarios:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic metrics-data --partitions 6 --replication-factor 1 --config segment.bytes=104857600 --config compression.type=lz4
background: false
```

**High-throughput settings:**
- `partitions 6` - More partitions = more parallelism
- `segment.bytes=104857600` - 100MB segments (larger segments)
- `compression.type=lz4` - Fast compression algorithm

---

## 6. Altering Topic Configurations

Modify an existing topic's configuration:

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name user-events --alter --add-config retention.ms=604800000
background: false
```

**Change applied:** Retention increased to 7 days (604800000 ms)

**Verify the change:**

```terminal:execute
command: docker exec kafka kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name user-events --describe
background: false
```

---

## 7. List All Topics with Details

**List topic names only:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list --exclude-internal
background: false
```

**View all topics with comprehensive details:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --exclude-internal
background: false
```

---

## 8. Adding More Partitions

**⚠️ Important:** You can increase partitions but NEVER decrease them!

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --alter --topic user-events --partitions 5
background: false
```

**Verify partition increase:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events
background: false
```

**🚨 Why can't you decrease partitions?**
- Data would be lost or corrupted
- Consumer offsets would become invalid
- Message ordering guarantees would break

---

## 9. Topic Naming Best Practices

**📝 Naming Guidelines:**
- Use **kebab-case** or **dot.notation**
- Be descriptive: `user-events`, `order-processing.payments`
- Include business domain: `marketing.email-campaigns`, `analytics.user-behavior`
- Avoid spaces, special characters (!, @, #, $, etc.)
- Keep length reasonable (< 50 characters)
- Use consistent patterns across your organization
- Consider environment prefixes: `prod.orders`, `dev.orders`, `test.orders`
- Group related topics: `payments.processed`, `payments.failed`, `payments.refunded`
- Include data type hints: `events.user-clicks`, `state.user-profiles`, `logs.application`

**🎯 Examples of Good Topic Names:**
- `user-events` - Clear, concise, purpose-driven
- `order-processing.payments` - Hierarchical, business domain included
- `analytics.page-views` - Domain + specific data type
- `notifications.email-delivery` - Service + action
- `inventory.stock-updates` - Domain + event type

**❌ Examples of Poor Topic Names:**
- `data` - Too generic
- `user events` - Contains space
- `UserEvents123!!!` - Mixed case, special characters
- `this-is-a-really-long-topic-name-that-exceeds-reasonable-limits` - Too long
- `temp` - Not descriptive

---

## 10. Inspecting Topic in Kafka UI

Switch to the **Dashboard** tab and explore:

1. **Topics** section - Visual topic overview
2. **Click on `user-events`** - Detailed topic view
3. **Partitions tab** - Visual partition layout
4. **Configs tab** - Configuration settings

**Compare CLI vs UI information** - notice how the visual interface complements CLI commands.

---

## 11. Safe Topic Deletion

**⚠️ WARNING: Deletion is permanent!**

Delete the test topic we no longer need:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --delete --topic application-logs
background: false
```

**Verify deletion:**

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list --exclude-internal
background: false
```

**🔒 Production Safety:**
- Enable `delete.topic.enable=true` (our setup has this)
- Use proper access controls
- Always backup critical data
- Consider topic rename vs deletion

---

## Key Takeaways

**Essential Commands Mastered:**
```bash
# List topics
kafka-topics --bootstrap-server localhost:9092 --list

# Create topic
kafka-topics --bootstrap-server localhost:9092 --create --topic TOPIC_NAME --partitions N --replication-factor N

# Describe topic
kafka-topics --bootstrap-server localhost:9092 --describe --topic TOPIC_NAME

# Alter topic configuration
kafka-configs --bootstrap-server localhost:9092 --entity-type topics --entity-name TOPIC_NAME --alter --add-config key=value

# Delete topic
kafka-topics --bootstrap-server localhost:9092 --delete --topic TOPIC_NAME
```

**🎯 Production Checklist:**
- ✅ Choose appropriate partition count (start conservative)
- ✅ Set proper retention policies
- ✅ Use descriptive names
- ✅ Document topic purposes
- ✅ Plan for growth (partitions can only increase)

---

**Ready for Level 2!** 🚀

Next, we'll put these topics to work with **Producers and Consumers** - the applications that write and read messages.

**🔗 Useful References:**
- [Topic Configuration Reference](https://kafka.apache.org/documentation/#topicconfigs)
- [Choosing Partition Count](https://www.confluent.io/blog/how-choose-number-topics-partitions-kafka-cluster/)
- [Kafka Topic Best Practices](https://kafka.apache.org/documentation/#design_topics)