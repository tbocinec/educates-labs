# Create Kafka Topic

In this step, we'll explore the topic that was automatically created and learn how to create additional topics.

---

## Check Existing Topics

First, let's see what topics already exist:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list
background: false
```

You should see the `test-messages` topic that was created automatically.

---

## Topic Details

Let's examine the details of our test topic:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic test-messages
background: false
```

This shows:
- **Partitions:** 3 (for parallel processing)
- **Replication Factor:** 1 (single replica)
- **Leader/Replicas:** Distribution across partitions

---

## Create Additional Topic (Optional)

If you want to create another topic, use this command:

```terminal:execute
command: docker exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic my-custom-topic --partitions 2 --replication-factor 1
background: false
```

---

## Topic Configuration

**Key topic parameters:**
- **Partitions** - Enable parallel processing and scaling
- **Replication Factor** - Number of copies for fault tolerance
- **Retention** - How long messages are kept

**Best practices:**
- More partitions = better parallelism
- Replication factor ≥ 2 for production
- Consider data retention requirements

---

## View Topics in Kafka UI

You can also view and manage topics in the Kafka UI:

1. Open the **Dashboard** tab
2. Navigate to **Topics** section
3. Click on `test-messages` to see details

The UI shows:
- 📊 Topic statistics
- 📈 Message throughput
- 🔧 Configuration settings
- 📝 Recent messages

---

## Next Steps

With our topic ready, we can now:
1. **Build** Java applications
2. **Run Producer** to send messages
3. **Run Consumer** to read messages
4. **Monitor** in Kafka UI

The `test-messages` topic is now ready for our Java applications to use!