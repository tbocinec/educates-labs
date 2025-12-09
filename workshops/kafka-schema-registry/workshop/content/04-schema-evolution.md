# Module 4: Schema Evolution & Compatibility

In this module, you'll learn the rules of schema evolution and practice evolving schemas safely using different compatibility modes.

## Compatibility Modes Explained

Schema Registry enforces **compatibility rules** to prevent breaking changes. Think of it as a "type checker" for your event schemas.

### The Four Main Compatibility Modes

| Mode | Rule | Producer | Consumer | Use Case |
|------|------|----------|----------|----------|
| **BACKWARD** | New schema can read **old data** | Can upgrade | Must stay old | **Most common** - Upgrade consumers last |
| **FORWARD** | Old schema can read **new data** | Must stay old | Can upgrade | Upgrade producers last |
| **FULL** | Both backward AND forward | Can upgrade | Can upgrade | Maximum flexibility |
| **NONE** | No checks | ⚠️ Risky | ⚠️ Risky | Development only |

### Transitive Variants

- **BACKWARD_TRANSITIVE**: New schema compatible with ALL previous versions
- **FORWARD_TRANSITIVE**: All old schemas compatible with new schema
- **FULL_TRANSITIVE**: Both backward and forward transitive

**Default mode:** `BACKWARD` (safe for most use cases)

## BACKWARD Compatibility (Most Common)

**Rule:** New schema can read data written with old schema.

**Deployment order:** Upgrade consumers BEFORE producers

### Allowed Changes ✅

1. **Add optional field** (with default value)
2. **Delete field**
3. **Promote field to union** (e.g., `string` → `["null", "string"]`)

### Forbidden Changes ❌

1. **Add required field** (no default)
2. **Rename field**
3. **Change field type**
4. **Delete required field**

### Example: Adding Optional Field

**v1 (old schema):**
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

**v2 (new schema - BACKWARD compatible ✅):**
```json
{
  "type": "record",
  "name": "OrderCreated",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "total_price", "type": "double"},
    {"name": "discount_code", "type": ["null", "string"], "default": null}
  ]
}
```

**Why it works:**
- Consumer with v2 can read old messages (discount_code = null)
- Consumer with v1 ignores the new field

### Example: Breaking Change

**v3 (BREAKING - will be rejected ❌):**
```json
{
  "type": "record",
  "name": "OrderCreated",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "total_amount", "type": "double"},  // Renamed!
    {"name": "payment_method", "type": "string"}  // Required, no default!
  ]
}
```

**Why it breaks:**
- Field renamed: `total_price` → `total_amount`
- New required field: `payment_method` (old messages don't have it)

## FORWARD Compatibility

**Rule:** Old schema can read data written with new schema.

**Deployment order:** Upgrade producers BEFORE consumers

### Allowed Changes ✅

1. **Add field** (any type)
2. **Delete optional field** (with default)

### Forbidden Changes ❌

1. **Delete required field**
2. **Rename field**
3. **Change field type**

### Use Case: Adding New Event Fields

Producers add new metrics/tracking fields. Old consumers ignore them until they upgrade.

## FULL Compatibility

**Rule:** Both backward AND forward compatible.

**Allowed changes:** Only adding/removing optional fields with defaults

**Most restrictive but safest!**

## Hands-On: Test Compatibility

Let's experiment with schema evolution!

### Step 1: Check Current Compatibility Mode

```terminal:execute
command: curl http://localhost:8081/config/orders-value | jq .
session: 1
```

**Output:**
```json
{
  "compatibilityLevel": "BACKWARD"
}
```

If no subject-level config exists, it uses the global default:
```terminal:execute
command: curl http://localhost:8081/config | jq .
session: 1
```

### Step 2: Test Compatible Evolution

Let's try registering v2 (which is BACKWARD compatible):

```terminal:execute
command: ./scripts/check-compatibility.sh orders-value schemas/order-v2-compatible.avsc
session: 1
```

**Expected output:**
```
🔍 Checking compatibility for subject: orders-value
📄 Schema file: ../schemas/order-v2-compatible.avsc

✅ Schema is COMPATIBLE

You can safely register this schema evolution.
```

**What was checked:**
- Added fields have default values ✅
- No fields were renamed ✅
- No type changes ✅

### Step 3: Register the Compatible Schema

```terminal:execute
command: ./scripts/register-schema.sh orders-value schemas/order-v2-compatible.avsc
session: 1
```

**Output:**
```
✅ Schema registered successfully!
   Schema ID: 2
   Subject: orders-value
```

### Step 4: Verify Version History

```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions
session: 1
```

**Output:** `[1, 2]`

Get details:
```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions/2 | jq .
session: 1
```

### Step 5: Test Breaking Change

Now let's try registering v3 (which has breaking changes):

```terminal:execute
command: ./scripts/check-compatibility.sh orders-value schemas/order-v3-breaking.avsc
session: 1
```

**Expected output:**
```
❌ Schema is NOT COMPATIBLE

Messages:
  - Field 'total_price' in old schema is missing in new schema
  - Field 'payment_method' in new schema does not have a default value

This schema would break existing consumers!
```

**Try to register it anyway:**
```terminal:execute
command: ./scripts/register-schema.sh orders-value schemas/order-v3-breaking.avsc
session: 1
```

**Result:**
```
❌ Failed to register schema
{
  "error_code": 409,
  "message": "Schema being registered is incompatible with an earlier schema"
}
```

🎉 **Schema Registry blocked the breaking change!**

## Hands-On: Change Compatibility Mode

Let's experiment with different modes.

### Step 1: Change to FORWARD Mode

```terminal:execute
command: ./scripts/compatibility-mode.sh orders-value FORWARD
session: 1
```

**Output:**
```
⚙️  Setting compatibility mode for subject: orders-value
   New mode: FORWARD

✅ Compatibility mode updated: FORWARD
```

### Step 2: Verify the Change

```terminal:execute
command: ./scripts/compatibility-mode.sh orders-value
session: 1
```

**Output:** `Current mode: FORWARD`

### Step 3: Test Compatibility Again

```terminal:execute
command: ./scripts/check-compatibility.sh orders-value schemas/order-v2-compatible.avsc
session: 1
```

Still compatible! (v2 is both BACKWARD and FORWARD compatible)

### Step 4: Change to FULL Mode

```terminal:execute
command: ./scripts/compatibility-mode.sh orders-value FULL
session: 1
```

### Step 5: Try a FORWARD-only Compatible Schema

Create a new schema that's FORWARD compatible but not BACKWARD:

**order-v4-forward-compatible.avsc** (removes optional field):
```json
{
  "type": "record",
  "name": "OrderCreated",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "customer_id", "type": "string"},
    {"name": "product_id", "type": "string"},
    {"name": "quantity", "type": "int"},
    {"name": "total_price", "type": "double"},
    {"name": "created_at", "type": "long"}
    // Removed shipping_address and discount_code
  ]
}
```

Test it:
```terminal:execute
command: ./scripts/check-compatibility.sh orders-value schemas/order-v4-forward-compatible.avsc
session: 1
```

**Under FULL mode:** ❌ Rejected (removing fields breaks BACKWARD)  
**Under FORWARD mode:** ✅ Accepted (old schema can still read new messages)

## Real-World Evolution Scenarios

### Scenario 1: Adding Analytics Field

**Change:**
```json
{"name": "user_agent", "type": ["null", "string"], "default": null}
```

**Compatible?** ✅ BACKWARD (optional field with default)

**Deployment:**
1. Upgrade consumers (they ignore the new field)
2. Upgrade producers (they start sending user_agent)

### Scenario 2: Deprecating a Field

**Change:**
```json
// Remove: {"name": "legacy_id", "type": "string"}
```

**Compatible?** ✅ BACKWARD (deleting fields is allowed)

**Deployment:**
1. Ensure no consumers use `legacy_id`
2. Deploy new schema
3. Producers stop sending it

### Scenario 3: Making Field Optional

**Change:**
```json
// Old: {"name": "email", "type": "string"}
// New: {"name": "email", "type": ["null", "string"], "default": null}
```

**Compatible?** ✅ BACKWARD (widening type with union)

**Deployment:**
1. Deploy schema change
2. Update producer logic to handle optional email
3. Consumers handle null values

### Scenario 4: Splitting a Field

**Change:**
```json
// Old: {"name": "full_name", "type": "string"}
// New: {"name": "first_name", "type": "string"}
//      {"name": "last_name", "type": "string"}
```

**Compatible?** ❌ BREAKING (can't rename/split fields)

**Solution:**
1. Add new fields as optional:
   ```json
   {"name": "first_name", "type": ["null", "string"], "default": null}
   {"name": "last_name", "type": ["null", "string"], "default": null}
   ```
2. Dual-write phase (send both full_name and first_name/last_name)
3. Migrate consumers to use new fields
4. Remove full_name in next version

## Compatibility Mode Decision Tree

```
Start: Need to evolve schema
│
├─ Will old consumers break?
│  ├─ Yes → Must use BACKWARD
│  └─ No → Continue
│
├─ Will old producers break?
│  ├─ Yes → Must use FORWARD
│  └─ No → Continue
│
├─ Need both guarantees?
│  ├─ Yes → Use FULL
│  └─ No → Use BACKWARD (default)
│
└─ Development/testing only?
   └─ Can use NONE (temporarily!)
```

## Advanced: Transitive Compatibility

### BACKWARD vs BACKWARD_TRANSITIVE

**BACKWARD:** New schema compatible with **version N-1**
```
v3 must be compatible with v2
v2 must be compatible with v1
But v3 might NOT be compatible with v1!
```

**BACKWARD_TRANSITIVE:** New schema compatible with **ALL previous versions**
```
v3 must be compatible with v2 AND v1
v2 must be compatible with v1
```

**Example where they differ:**
```
v1: {"name": "status", "type": "string"}
v2: {"name": "status", "type": ["null", "string"], "default": null}  // Made optional
v3: (delete "status" field)  // Remove it entirely

BACKWARD: v3 is compatible with v2 ✅ (can delete optional field)
BACKWARD_TRANSITIVE: v3 is NOT compatible with v1 ❌ (v1 required status)
```

## Compatibility Cheat Sheet

| Change | BACKWARD | FORWARD | FULL | NONE |
|--------|----------|---------|------|------|
| Add optional field (with default) | ✅ | ✅ | ✅ | ✅ |
| Add required field | ❌ | ✅ | ❌ | ✅ |
| Delete optional field | ✅ | ❌ | ❌ | ✅ |
| Delete required field | ✅ | ❌ | ❌ | ✅ |
| Rename field | ❌ | ❌ | ❌ | ✅ |
| Change field type | ❌ | ❌ | ❌ | ✅ |

## Key Learnings

✅ **BACKWARD is default** - Safest for most systems  
✅ **Schema Registry prevents breaking changes** - Governance in action  
✅ **Test before registering** - Use compatibility API  
✅ **Optional fields are your friend** - Enable evolution  
✅ **Transitive modes are stricter** - Consider long-term compatibility  

## What's Next?

In the next module, you'll:

1. ✅ See governance in action (rejected changes)
2. ✅ Explore Schema Registry REST API deeply
3. ✅ Learn CI/CD integration patterns
4. ✅ Troubleshoot schema issues

---

**Time:** 20 minutes  
**Previous:** [Consume with Schema Registry](03-consume-with-registry.md)  
**Next:** [Governance in Action](05-governance-in-action.md)

