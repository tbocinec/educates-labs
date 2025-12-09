# Module 3: Consume with Schema Registry

In this module, you'll build and run a consumer that automatically fetches schemas from Schema Registry and deserializes Avro messages.

## How Consumers Use Schema Registry

When a consumer reads a message from Kafka:

```
Consumer              Kafka                Schema Registry
   │                    │                        │
   │  1. Poll messages  │                        │
   │<───────────────────│                        │
   │  [0x00][ID=1][data]│                        │
   │                    │                        │
   │  2. Extract schema ID from message          │
   │     (first 5 bytes: magic byte + 4-byte ID) │
   │                    │                        │
   │  3. Check cache    │                        │
   │     (schema not cached)                     │
   │                    │                        │
   │  4. Fetch schema by ID                      │
   │────────────────────────────────────────────>│
   │     GET /schemas/ids/1                      │
   │                    │                        │
   │  5. Return schema  │                        │
   │<────────────────────────────────────────────│
   │                    │                        │
   │  6. Cache schema   │                        │
   │                    │                        │
   │  7. Deserialize binary data using schema    │
   │     → OrderCreated object                   │
```

**Key insight:** Consumers don't need to know the schema upfront—they **discover** it from the message!

## Understanding Consumer Schema Resolution

### The Magic of Schema Registry

Without Schema Registry:
```java
// Manual deserialization - fragile!
String json = new String(record.value());
OrderCreated order = objectMapper.readValue(json, OrderCreated.class);
// What if the JSON structure changed? 💥
```

With Schema Registry:
```java
// Automatic schema resolution!
ConsumerRecord<String, OrderCreated> record = ...;
OrderCreated order = record.value();  // Just works! ✅
// Schema fetched automatically based on message's schema ID
```

### Consumer Configuration

The key settings for Schema Registry integration:

```java
// Use Avro deserializer
props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
          KafkaAvroDeserializer.class.getName());

// Point to Schema Registry
props.put("schema.registry.url", "http://localhost:8081");

// Use specific Avro classes (not GenericRecord)
props.put(KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG, true);
```

**Without `SPECIFIC_AVRO_READER_CONFIG`:**
```java
// You get a GenericRecord (like a Map)
GenericRecord record = ...;
String orderId = record.get("order_id").toString();  // Runtime errors possible
```

**With `SPECIFIC_AVRO_READER_CONFIG`:**
```java
// You get a typed OrderCreated object
OrderCreated order = ...;
String orderId = order.getOrderId();  // Compile-time safety! ✅
```

## Hands-On: Build and Run the Consumer

### Step 1: Review the Consumer Code

Open `kafka-apps/consumer-avro/src/main/java/com/example/OrderConsumer.java`:

**Key parts:**

```java
// Deserializer config
props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
          KafkaAvroDeserializer.class.getName());
props.put("schema.registry.url", SCHEMA_REGISTRY_URL);
props.put(KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG, true);

// Poll and process
ConsumerRecords<String, OrderCreated> records = consumer.poll(Duration.ofMillis(1000));

for (ConsumerRecord<String, OrderCreated> record : records) {
    OrderCreated order = record.value();  // Type-safe access!
    
    System.out.printf("Order ID: %s%n", order.getOrderId());
    System.out.printf("Total Price: $%.2f%n", order.getTotalPrice());
}
```

### Step 2: Build the Consumer (if not already done)

```terminal:execute
command: ./build-apps.sh
session: 1
```

### Step 3: Start the Producer (in Terminal 1)

Keep the producer running to generate messages:

```terminal:execute
command: ./run-producer.sh
session: 1
```

### Step 4: Start the Consumer (in Terminal 2)

In a new terminal, run the consumer:

```terminal:execute
command: ./run-consumer.sh
session: 2
```

**Expected output:**
```
🛒 Starting Order Consumer with Avro Schema Registry
📊 Topic: orders
👥 Group: order-processor-group
🔗 Schema Registry: http://localhost:8081

✅ Subscribed to topic: orders
⏳ Waiting for messages...

═══════════════════════════════════════════════
📦 Order Received #1
───────────────────────────────────────────────
   Order ID:    ORD-A3F2
   Customer:    CUST-002
   Product:     LAPTOP-PRO
   Quantity:    2
   Total Price: $2599.98
   Created At:  1638360000 (epoch)
───────────────────────────────────────────────
   Partition:   0 | Offset: 0
═══════════════════════════════════════════════
💰 Total Revenue: $2599.98 | Messages: 1
```

### Step 5: Observe Schema Fetching

Watch the consumer logs when it first starts. You might see:

```
[INFO] Registering new schema reader for schema id 1
[INFO] Fetched schema from registry for id 1
```

This happens **once** per schema ID, then it's cached!

## Consumer Schema Caching

### First Message with a Schema ID

```
1. Consumer receives message: [0x00][0x00 0x00 0x00 0x01][binary data]
2. Extracts schema ID: 1
3. Checks local cache: MISS
4. Fetches schema from Registry
5. Caches schema locally
6. Deserializes message
```

### Subsequent Messages

```
1. Consumer receives message: [0x00][0x00 0x00 0x00 0x01][binary data]
2. Extracts schema ID: 1
3. Checks local cache: HIT! ✅
4. Deserializes message (no Registry call)
```

**Performance impact:**
- First message: ~10ms (includes Registry fetch)
- Subsequent messages: ~0.5ms (cached)
- **20x faster** with caching!

## Understanding Schema Evolution Impact

What happens when the producer evolves the schema?

### Scenario: Producer Upgrades to v2

Let's simulate this:

1. **Stop the producer** (Ctrl+C)
2. **Register v2 schema** (has optional fields):

```terminal:execute
command: ./scripts/register-schema.sh orders-value schemas/order-v2-compatible.avsc
session: 1
```

Output:
```
✅ Schema registered successfully!
   Schema ID: 2
   Subject: orders-value
```

3. **Update producer** to use v2 schema:

Edit `producer-avro/pom.xml`:
```xml
<includes>
  <include>order-v2-compatible.avsc</include>  <!-- Changed from v1 -->
</includes>
```

4. **Rebuild and restart producer:**

```terminal:execute
command: ./build-apps.sh
session: 1
```

```terminal:execute
command: ./run-producer.sh
session: 1
```

5. **Observe consumer (still running with v1)**:

The consumer with v1 schema **still works**! 🎉

**Why?**
- Schema Registry validates **backward compatibility**
- v2 added **optional** fields with defaults
- Old consumers can ignore new fields
- No redeployment needed!

### What You'll See

Producer sends:
```json
{
  "order_id": "ORD-123",
  "customer_id": "CUST-001",
  "product_id": "LAPTOP-PRO",
  "quantity": 1,
  "total_price": 1299.99,
  "created_at": 1638360000,
  "shipping_address": "123 Main St",  // New field!
  "discount_code": "SAVE10"           // New field!
}
```

Consumer v1 reads:
```json
{
  "order_id": "ORD-123",
  "customer_id": "CUST-001",
  "product_id": "LAPTOP-PRO",
  "quantity": 1,
  "total_price": 1299.99,
  "created_at": 1638360000
  // New fields ignored - no error!
}
```

## Hands-On: Inspect Schema Versions

### List All Versions for a Subject

```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions
session: 1
```

Output: `[1, 2]`

### Compare Versions

**Get v1:**
```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions/1 | jq -r '.schema' | jq .
session: 1
```

**Get v2:**
```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions/2 | jq -r '.schema' | jq .
session: 1
```

**Spot the differences:**
- v2 has `shipping_address` (optional, default: null)
- v2 has `discount_code` (optional, default: null)

## Consumer Best Practices

✅ **Enable schema caching** - Massive performance improvement  
✅ **Use specific Avro readers** - Type safety and IDE support  
✅ **Handle schema evolution** - Test with old/new schemas  
✅ **Monitor Registry calls** - Too many = cache misconfiguration  
✅ **Set appropriate timeouts** - Registry might be slow under load  

### Advanced Configuration

```java
// Cache up to 1000 schemas
props.put("max.schemas.per.subject", "1000");

// Use basic auth if Registry is secured
props.put("basic.auth.credentials.source", "USER_INFO");
props.put("basic.auth.user.info", "username:password");

// Custom deserializer error handling
props.put("value.subject.name.strategy", 
          "io.confluent.kafka.serializers.subject.TopicRecordNameStrategy");
```

## Common Consumer Questions

**Q: What if Schema Registry is down?**  
A: Consumer uses cached schemas. Only new schema IDs fail.

**Q: Can different consumers use different schema versions?**  
A: Yes! Each consumer fetches the schema it was built with.

**Q: What happens if a message has an unknown schema ID?**  
A: Deserialization fails. Consumer skips or retries based on error handling.

**Q: How long are schemas cached?**  
A: Forever (until consumer restart). Consider cache eviction for long-running consumers.

## Key Learnings

✅ **Automatic schema resolution** - Consumers discover schemas from messages  
✅ **Schema caching** - Huge performance benefit  
✅ **Backward compatibility** - Old consumers work with new schemas  
✅ **Type safety** - Compile-time errors instead of runtime surprises  
✅ **Independent evolution** - Producers and consumers evolve separately  

## What's Next?

In the next module, you'll dive deep into:

1. ✅ Compatibility modes (BACKWARD, FORWARD, FULL)
2. ✅ Compatible vs. breaking changes
3. ✅ Hands-on schema evolution exercises
4. ✅ Testing compatibility before deploying

---

**Time:** 15 minutes  
**Previous:** [Register and Produce](02-register-and-produce.md)  
**Next:** [Schema Evolution & Compatibility](04-schema-evolution.md)

