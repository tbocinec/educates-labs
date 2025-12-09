# Module 2: Register and Produce with Schemas

In this module, you'll create your first Avro schema, register it with Schema Registry, and produce schema-validated messages.

## Understanding Avro Schemas

Apache Avro is a binary serialization format with:
- **Schema-based**: Data structure is defined upfront
- **Compact**: Binary encoding (smaller than JSON)
- **Fast**: No parsing overhead
- **Evolution-friendly**: Built-in compatibility rules

### Anatomy of an Avro Schema

Let's examine the `OrderCreated` schema:

```json
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.example.events",
  "doc": "Event emitted when a new order is created",
  "fields": [
    {
      "name": "order_id",
      "type": "string",
      "doc": "Unique identifier for the order"
    },
    {
      "name": "customer_id",
      "type": "string",
      "doc": "Customer who placed the order"
    },
    {
      "name": "product_id",
      "type": "string",
      "doc": "Product being ordered"
    },
    {
      "name": "quantity",
      "type": "int",
      "doc": "Number of items ordered"
    },
    {
      "name": "total_price",
      "type": "double",
      "doc": "Total price in USD"
    },
    {
      "name": "created_at",
      "type": "long",
      "doc": "Order creation timestamp (epoch seconds)"
    }
  ]
}
```

**Key Elements:**
- `type: "record"` → Avro record (like a struct/class)
- `name` → Schema name (must be unique in namespace)
- `namespace` → Java package-like hierarchy
- `fields` → List of field definitions with types
- `doc` → Documentation for humans and tooling

### Avro Data Types

| Type | Description | Example |
|------|-------------|---------|
| `string` | UTF-8 string | `"ORD-123"` |
| `int` | 32-bit integer | `42` |
| `long` | 64-bit integer | `1638360000` |
| `float` | 32-bit float | `3.14` |
| `double` | 64-bit float | `99.99` |
| `boolean` | True/false | `true` |
| `null` | Null value | `null` |
| `array` | List of items | `["A", "B"]` |
| `record` | Nested object | `{...}` |
| `enum` | Fixed set of values | `"PENDING"` |

## Hands-On: Register Your First Schema

### Step 1: View the Schema

Let's look at the schema we'll use:

```terminal:execute
command: cat schemas/order-v1.avsc
session: 1
```

This is version 1 of our `OrderCreated` event schema.

### Step 2: Register the Schema

Use the helper script to register the schema:

```terminal:execute
command: ./scripts/register-schema.sh orders-value schemas/order-v1.avsc
session: 1
```

**Expected output:**
```
📤 Registering schema for subject: orders-value
📄 Schema file: ../schemas/order-v1.avsc

✅ Schema registered successfully!
   Schema ID: 1
   Subject: orders-value
```

### Step 3: Verify Registration

List all registered subjects:

```terminal:execute
command: ./scripts/list-subjects.sh
session: 1
```

**Expected output:**
```
📋 Listing all subjects in Schema Registry...

Subjects:
  📦 orders-value
      Version: 1
      Schema ID: 1
```

### Step 4: Explore the REST API

Schema Registry exposes a REST API. Let's explore it:

**List all subjects:**
```terminal:execute
command: curl http://localhost:8081/subjects
session: 1
```

Output: `["orders-value"]`

**Get latest version for a subject:**
```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions/latest | jq .
session: 1
```

Output:
```json
{
  "subject": "orders-value",
  "version": 1,
  "id": 1,
  "schema": "{\"type\":\"record\",\"name\":\"OrderCreated\",...}"
}
```

**Get schema by ID:**
```terminal:execute
command: curl http://localhost:8081/schemas/ids/1 | jq .
session: 1
```

Output:
```json
{
  "schema": "{\"type\":\"record\",...}"
}
```

## Understanding Schema Registration Flow

Here's what happens when you register a schema:

```
1. Client sends schema to Schema Registry
   POST /subjects/{subject}/versions
   Body: {"schema": "...", "schemaType": "AVRO"}

2. Schema Registry validates the schema
   - Checks JSON syntax
   - Validates Avro schema structure
   - Checks compatibility with existing versions

3. If valid, Schema Registry:
   - Assigns a globally unique ID (e.g., 1)
   - Stores schema in internal Kafka topic (_schemas)
   - Returns the ID to client

4. Client caches the ID
   - Producer: Use ID when sending messages
   - Consumer: Fetch schema by ID when reading
```

## Hands-On: Produce Messages with Schema Registry

Now let's produce messages using the registered schema!

### Step 1: Build the Producer Application

```terminal:execute
command: ./build-apps.sh
session: 1
```

This compiles the Avro schema into Java classes and builds the producer.

**What happens during build:**
1. Maven Avro Plugin reads `order-v1.avsc`
2. Generates `OrderCreated.java` class
3. Compiles producer code
4. Creates executable JAR

### Step 2: Understand the Producer Code

Open `kafka-apps/producer-avro/src/main/java/com/example/OrderProducer.java`:

**Key configuration:**
```java
// Use Avro serializer
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, 
          KafkaAvroSerializer.class.getName());

// Point to Schema Registry
props.put("schema.registry.url", SCHEMA_REGISTRY_URL);
```

**Creating an Avro record:**
```java
OrderCreated order = OrderCreated.newBuilder()
    .setOrderId(orderId)
    .setCustomerId(customerId)
    .setProductId(productId)
    .setQuantity(quantity)
    .setTotalPrice(totalPrice)
    .setCreatedAt(createdAt)
    .build();
```

**Sending the message:**
```java
ProducerRecord<String, OrderCreated> record = 
    new ProducerRecord<>(TOPIC_NAME, orderId, order);
    
producer.send(record, callback);
```

### Step 3: Run the Producer

Start the producer in a terminal:

```terminal:execute
command: ./run-producer.sh
session: 1
```

**Expected output:**
```
🛒 Starting Order Producer with Avro Schema Registry
📊 Topic: orders
🔗 Schema Registry: http://localhost:8081

✅ Order sent: ORD-A3F2 | Customer: CUST-002 | Product: LAPTOP-PRO | Qty: 2 | $2599.98
   📍 Partition: 0 | Offset: 0
✅ Order sent: ORD-B7E1 | Customer: CUST-001 | Product: WIRELESS-MOUSE | Qty: 1 | $29.99
   📍 Partition: 0 | Offset: 1
```

**What's happening:**
1. Producer builds `OrderCreated` Avro record
2. `KafkaAvroSerializer` serializes to binary
3. Serializer adds magic byte (0x00) + schema ID (1)
4. Message sent to Kafka topic `orders`

Let the producer run for a minute, then stop it (Ctrl+C).

## Inspecting the Wire Format

Let's look at the actual binary data in Kafka!

### Option 1: Using Kafka Console Consumer (with hex dump)

```terminal:execute
command: docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic orders --from-beginning --max-messages 1 --property print.key=true | xxd
session: 1
```

You'll see the hex dump showing:
```
00000000: 0000 0000 0106 4f52 442d ...
          │  │        │  └─ Avro data starts
          │  │        └─── "ORD-" (4F 52 44 2D)
          │  └──────────── Schema ID = 1
          └─────────────── Magic byte
```

### Option 2: Using Kafka UI

1. Open http://localhost:8080
2. Click **Topics** → **orders**
3. Click **Messages** tab
4. Expand a message to see:
   - Key: `ORD-A3F2`
   - Value: Binary data with schema reference
   - Headers: (empty)

Kafka UI automatically decodes Avro using Schema Registry!

## How Producer Schema Registration Works

The first time a producer sends a message:

```
Producer                Schema Registry              Kafka
   │                           │                       │
   │  1. Check cache           │                       │
   │     (schema not cached)   │                       │
   │                           │                       │
   │  2. Register schema       │                       │
   │─────────────────────────> │                       │
   │   POST /subjects/.../     │                       │
   │   versions                │                       │
   │                           │                       │
   │  3. Return schema ID (1)  │                       │
   │ <─────────────────────────│                       │
   │                           │                       │
   │  4. Cache schema ID       │                       │
   │     locally               │                       │
   │                           │                       │
   │  5. Serialize message     │                       │
   │     [0x00][ID=1][data]    │                       │
   │                           │                       │
   │  6. Send to Kafka         │                       │
   │──────────────────────────────────────────────────>│
```

**On subsequent messages:**
- Producer uses **cached** schema ID
- No Schema Registry call needed
- Much faster!

## Key Learnings

✅ **Schemas are contracts** - Define structure before sending data  
✅ **Schema IDs are cached** - Reduces Registry lookups  
✅ **Wire format is efficient** - Binary + schema ID = compact  
✅ **Registration is automatic** - Producer handles it for you  
✅ **REST API is powerful** - Inspect schemas programmatically  

## Common Producer Questions

**Q: What if the schema already exists?**  
A: Schema Registry returns the existing ID. No duplicate created.

**Q: What if I send invalid data?**  
A: Serialization fails before sending to Kafka. No bad data in topics!

**Q: Can I use JSON instead of Avro?**  
A: Yes! Schema Registry supports JSON Schema and Protobuf too.

**Q: Do I need to register schemas manually?**  
A: No! The serializer auto-registers. Manual registration is for CI/CD validation.

## What's Next?

In the next module, you'll:

1. ✅ Build a consumer that uses Schema Registry
2. ✅ See automatic schema resolution in action
3. ✅ Understand schema caching on the consumer side

---

**Time:** 20 minutes  
**Previous:** [Introduction](01-introduction.md)  
**Next:** [Consume with Schema Registry](03-consume-with-registry.md)

