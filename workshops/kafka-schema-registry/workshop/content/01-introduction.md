# Module 1: Introduction to Data Governance

Welcome to the Kafka Schema Registry workshop! In this module, you'll learn why data governance is critical for event-driven systems and how Schema Registry solves common data evolution challenges.

## Why Data Governance Matters

### The Problem: Uncontrolled Data Evolution

Imagine you're running an e-commerce platform with Kafka. Your order processing system works perfectly... until:

❌ **Developer A** changes the `OrderCreated` event structure  
❌ **Consumer B** breaks because it expects the old format  
❌ **Production outage** at 2 AM  
❌ **Lost revenue** while you debug and redeploy  

This is the reality of **uncontrolled schema evolution**.

### Real-World Horror Stories

**Scenario 1: The Renamed Field**
```json
// Old format (what consumers expect)
{"order_id": "123", "total_price": 99.99}

// New format (what producer sends)
{"order_id": "123", "total_amount": 99.99}  // Renamed!

// Result: Consumers can't find "total_price" → NULL values → broken reports
```

**Scenario 2: The Missing Default**
```json
// Old format
{"order_id": "123", "customer_id": "C001"}

// New format (added required field)
{"order_id": "123", "customer_id": "C001", "payment_method": "CARD"}

// Result: Old messages fail validation → consumers crash
```

**Scenario 3: The Type Change**
```json
// Old: price as number
{"product_id": "P123", "price": 29.99}

// New: price as string
{"product_id": "P123", "price": "29.99"}

// Result: Type mismatch → deserialization errors
```

### The Cost of No Governance

- ⏰ **Debugging time**: Hours to identify schema mismatches
- 💰 **Lost revenue**: Downtime during peak hours
- 🔧 **Emergency fixes**: Rushed patches and rollbacks
- 😤 **Team friction**: Blame games between teams
- 📉 **Technical debt**: Workarounds accumulate

## The Solution: Schema Registry

Schema Registry is a **centralized schema management service** that:

✅ **Enforces contracts** between producers and consumers  
✅ **Validates schema evolution** before deployment  
✅ **Prevents breaking changes** from reaching production  
✅ **Enables independent evolution** of services  
✅ **Provides schema versioning** and history  

### How Schema Registry Works

```
┌─────────────┐                    ┌──────────────────┐
│  Producer   │                    │ Schema Registry  │
│             │  1. Register       │                  │
│             │────────────────────>│  - Stores schemas│
│             │     schema         │  - Assigns IDs   │
│             │                    │  - Validates     │
│             │  2. Get ID         │                  │
│             │<────────────────────│                  │
└─────────────┘                    └──────────────────┘
      │
      │ 3. Send message with schema ID
      │
      v
┌─────────────┐
│   Kafka     │     [magic byte][schema ID][data]
│   Topic     │     [   0x00   ][    1    ][{...}]
└─────────────┘
      │
      │ 4. Read message
      │
      v
┌─────────────┐                    ┌──────────────────┐
│  Consumer   │  5. Fetch schema   │ Schema Registry  │
│             │<───────────────────>│                  │
│             │     by ID          │  (cached!)       │
│             │                    │                  │
│             │  6. Deserialize    │                  │
└─────────────┘     with schema    └──────────────────┘
```

### Key Concepts

#### 1. **Schema**
A formal definition of your data structure (Avro, JSON Schema, or Protobuf)

```json
{
  "type": "record",
  "name": "OrderCreated",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "total_price", "type": "double"}
  ]
}
```

#### 2. **Subject**
A named context for schema evolution (usually `{topic}-value` or `{topic}-key`)

Example: `orders-value` → schemas for values in the `orders` topic

#### 3. **Schema ID**
A globally unique integer assigned to each schema version

- Schema ID `1` → `OrderCreated` v1
- Schema ID `2` → `OrderCreated` v2 (with new optional fields)

#### 4. **Wire Format**
How messages are stored in Kafka:

```
┌───────────┬────────────┬──────────────────┐
│ Magic Byte│ Schema ID  │ Avro Binary Data │
│  (0x00)   │  (4 bytes) │  (variable)      │
└───────────┴────────────┴──────────────────┘
```

The magic byte (`0x00`) indicates: "This message uses Schema Registry"

#### 5. **Compatibility Mode**
Rules that determine what schema changes are allowed:

- **BACKWARD**: New schema can read old data (most common)
- **FORWARD**: Old schema can read new data
- **FULL**: Both backward and forward compatible
- **NONE**: No compatibility checks (dangerous!)

## Understanding Wire Format

Let's examine a real Kafka message with Schema Registry:

```
Hexadecimal representation:
00 00 01 06 4F 52 44 2D 31 32 33 ...
│   │           │
│   │           └─ Avro binary data starts here
│   └───────────── Schema ID = 1 (4bytes)
│  
└────────────────── Magic byte ( 1byte)
```

**Without Schema Registry** (plain JSON):
```
Size: ~150 bytes per message
{"order_id":"ORD-123","customer_id":"CUST-001","total_price":99.99,...}
```

**With Schema Registry** (Avro):
```
Size: ~40 bytes per message (60% smaller!)
[0x00][0x00 0x00 0x00 0x01][binary data]
```

### Benefits of Wire Format

✅ **Compact**: Binary encoding reduces message size  
✅ **Fast**: No JSON parsing overhead  
✅ **Schema enforcement**: Invalid data rejected at serialization  
✅ **Evolution support**: Schema ID links to versioning  

## Hands-On: Explore Your Environment

Let's check if Schema Registry is ready:

```terminal:execute
command: curl http://localhost:8081/subjects
session: 1
```

Expected output: `[]` (empty list - no schemas yet)

If you see an error, ensure Docker Compose is running:

```terminal:execute
command: docker compose up -d
session: 1
```

```terminal:execute
command: docker ps
session: 1
```

You should see three containers:
- `kafka` (port 9092)
- `schema-registry` (port 8081)
- `kafka-ui` (port 8080)

## What's Next?

In the next module, you'll:

1. ✅ Create your first Avro schema
2. ✅ Register it with Schema Registry
3. ✅ Produce messages with schema validation
4. ✅ Inspect the wire format

**Key Takeaway**: Schema Registry transforms Kafka from a "message bus" into a "type-safe event streaming platform" with governance built in.

---

**Time:** 15 minutes  
**Next Module:** [Register and Produce with Schemas](02-register-and-produce.md)

