# EXTRA: Module 5: Governance in Action

In this module, you'll experience how Schema Registry prevents production disasters, explore the full REST API, and learn how to integrate schema governance into CI/CD pipelines.

## Preventing Breaking Changes

Let's simulate a real-world scenario where a developer tries to deploy a breaking change.

### Scenario: The Midnight Deployment Gone Wrong

**Context:**
- Your team runs an e-commerce platform
- Orders topic has 10 consumers across 5 microservices
- A developer wants to rename `total_price` to `total_amount` for "clarity"

**Without Schema Registry:**
```
1. Developer deploys new producer (11:00 PM)
2. New messages have "total_amount" field
3. All 10 consumers break (11:05 PM)
4. Payment processing stops
5. Revenue loss: $50,000/hour
6. Emergency rollback (2:00 AM)
7. Incident retrospective (next day)
```

**With Schema Registry:**
```
1. Developer tries to register new schema
2. Schema Registry: ❌ "Incompatible - field renamed"
3. Registration fails in CI/CD pipeline
4. Developer revises approach (adds new field, keeps old one)
5. No production impact!
```

### Hands-On: Simulate Breaking Change Detection

**Step 1: Try to Register Breaking Schema**

```terminal:execute
command: ./scripts/check-compatibility.sh orders-value schemas/order-v3-breaking.avsc
session: 1
```

**Output:**
```
❌ Schema is NOT COMPATIBLE

Messages:
  - Field 'total_price' in old schema is missing in new schema
  - New field 'payment_method' does not have a default value

This schema would break existing consumers!
```

**Step 2: Examine the Breaking Schema**

```terminal:execute
command: cat schemas/order-v3-breaking.avsc | jq .
session: 1
```

**Issues found:**
1. `total_price` renamed to `total_amount` (field removal)
2. `payment_method` added as required field (no default)

**Step 3: Fix the Schema**

Create a compatible version:

```terminal:execute
command: |
  cat > /tmp/order-v3-fixed.avsc << 'EOF'
  {
    "type": "record",
    "name": "OrderCreated",
    "namespace": "com.example.events",
    "fields": [
      {"name": "order_id", "type": "string"},
      {"name": "customer_id", "type": "string"},
      {"name": "product_id", "type": "string"},
      {"name": "quantity", "type": "int"},
      {"name": "total_price", "type": "double"},
      {"name": "created_at", "type": "long"},
      {"name": "payment_method", "type": ["null", "string"], "default": null}
    ]
  }
  EOF
session: 1
```

**Changes made:**
- Kept `total_price` (no renaming)
- Made `payment_method` optional with default

**Step 4: Verify Fix**

```terminal:execute
command: ./scripts/check-compatibility.sh orders-value /tmp/order-v3-fixed.avsc
session: 1
```

**Output:**
```
✅ Schema is COMPATIBLE

You can safely register this schema evolution.
```

**Step 5: Register the Fixed Schema**

```terminal:execute
command: ./scripts/register-schema.sh orders-value /tmp/order-v3-fixed.avsc
session: 1
```

Success! 🎉

## Deep Dive: Schema Registry REST API

Let's explore the full REST API for troubleshooting and automation.

### Core API Endpoints

#### 1. Subjects (Schema Namespaces)

**List all subjects:**
```terminal:execute
command: curl http://localhost:8081/subjects | jq .
session: 1
```

**Delete a subject (dangerous!):**
```terminal:execute
command: curl -X DELETE http://localhost:8081/subjects/orders-value
session: 1
```

#### 2. Schemas by Subject

**List versions for a subject:**
```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions | jq .
session: 1
```

**Get specific version:**
```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions/1 | jq .
session: 1
```

**Get latest version:**
```terminal:execute
command: curl http://localhost:8081/subjects/orders-value/versions/latest | jq .
session: 1
```

**Response structure:**
```json
{
  "subject": "orders-value",
  "version": 2,
  "id": 2,
  "schema": "{\"type\":\"record\",...}",
  "references": []
}
```

#### 3. Schemas by ID

**Get schema by global ID:**
```terminal:execute
command: curl http://localhost:8081/schemas/ids/1 | jq .
session: 1
```

**Get subjects using a schema ID:**
```terminal:execute
command: curl http://localhost:8081/schemas/ids/1/subjects | jq .
session: 1
```

#### 4. Compatibility Testing

**Test compatibility without registering:**
```terminal:execute
command: |
  SCHEMA=$(cat schemas/order-v2-compatible.avsc | jq -c . | jq -R .)
  PAYLOAD=$(jq -n --arg schema "$SCHEMA" '{schema: $schema}')
  curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" --data "$PAYLOAD" "http://localhost:8081/compatibility/subjects/orders-value/versions/latest" | jq .
session: 1
```

**Response:**
```json
{
  "is_compatible": true
}
```

**For incompatible schema:**
```json
{
  "is_compatible": false,
  "messages": [
    "Field 'total_price' in old schema is missing in new schema"
  ]
}
```

#### 5. Configuration Management

**Get global compatibility mode:**
```terminal:execute
command: curl http://localhost:8081/config | jq .
session: 1
```

**Set global compatibility mode:**
```terminal:execute
command: curl -X PUT -H "Content-Type: application/vnd.schemaregistry.v1+json" --data '{"compatibility": "BACKWARD"}' http://localhost:8081/config | jq .
session: 1
```

**Get subject-level compatibility:**
```terminal:execute
command: curl http://localhost:8081/config/orders-value | jq .
session: 1
```

**Set subject-level compatibility:**
```terminal:execute
command: curl -X PUT -H "Content-Type: application/vnd.schemaregistry.v1+json" --data '{"compatibility": "FULL"}' http://localhost:8081/config/orders-value | jq .
session: 1
```

**Delete subject-level config (revert to global):**
```terminal:execute
command: curl -X DELETE http://localhost:8081/config/orders-value
session: 1
```

### Advanced: Schema References

For complex schemas with nested types:

```terminal:execute
command: |
  curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
    --data '{"schema": "{\"type\":\"record\",\"name\":\"Address\",\"fields\":[...]}"}' \
    http://localhost:8081/subjects/address-value/versions
session: 1
```

## CI/CD Integration Patterns

### Pattern 1: Schema Validation in Pull Requests

**GitHub Actions example:**

```yaml
name: Schema Validation

on: [pull_request]

jobs:
  validate-schemas:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Start Schema Registry
        run: docker compose up -d schema-registry
      
      - name: Wait for Registry
        run: |
          until curl -f http://localhost:8081/subjects; do
            sleep 2
          done
      
      - name: Check Schema Compatibility
        run: |
          for schema in schemas/*.avsc; do
            subject=$(basename $schema .avsc)
            ./scripts/check-compatibility.sh "$subject-value" "$schema"
          done
      
      - name: Fail if Incompatible
        run: exit $?
```

### Pattern 2: Schema Registry First Deployment

**Deployment sequence:**

```bash
# 1. Register schema in dev
./scripts/register-schema.sh orders-value schemas/order-v2.avsc

# 2. Run integration tests
mvn verify -Pintegration-tests

# 3. Promote schema to staging
curl -X POST http://staging-registry:8081/subjects/orders-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  --data @schema-payload.json

# 4. Deploy consumers to staging
kubectl apply -f k8s/consumer-deployment.yaml

# 5. Wait for consumer readiness
kubectl wait --for=condition=ready pod -l app=order-consumer

# 6. Deploy producer to staging
kubectl apply -f k8s/producer-deployment.yaml

# 7. Repeat for production
```

### Pattern 3: Schema as Code

**Maven plugin example:**

```xml
<plugin>
  <groupId>io.confluent</groupId>
  <artifactId>kafka-schema-registry-maven-plugin</artifactId>
  <version>7.7.1</version>
  <configuration>
    <schemaRegistryUrls>
      <url>http://localhost:8081</url>
    </schemaRegistryUrls>
    <subjects>
      <orders-value>schemas/order.avsc</orders-value>
    </subjects>
    <compatibilityLevels>
      <orders-value>BACKWARD</orders-value>
    </compatibilityLevels>
  </configuration>
  <executions>
    <execution>
      <goals>
        <goal>test-compatibility</goal>
        <goal>register</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

**Run during build:**
```bash
mvn schema-registry:test-compatibility  # In CI
mvn schema-registry:register            # In CD
```

## Troubleshooting Schema Issues

### Issue 1: Schema Not Found Error

**Symptom:**
```
Caused by: org.apache.kafka.common.errors.SerializationException: 
  Error retrieving Avro schema for id 5
```

**Diagnosis:**
```bash
# Check if schema ID exists
curl http://localhost:8081/schemas/ids/5

# If 404, schema was deleted or wrong Registry URL
```

**Solutions:**
1. Verify `schema.registry.url` in producer/consumer config
2. Check Schema Registry logs for deletions
3. Restore from backup if deleted

### Issue 2: Compatibility Error During Registration

**Symptom:**
```
409 Conflict: Schema being registered is incompatible with an earlier schema
```

**Diagnosis:**
```bash
# Test compatibility
./scripts/check-compatibility.sh orders-value schemas/new-schema.avsc

# Review error messages
```

**Solutions:**
1. Add default values to new fields
2. Use union types for optional fields
3. Consider compatibility mode change (with caution!)

### Issue 3: Performance Degradation

**Symptom:**
Consumer throughput drops from 10k/sec to 100/sec

**Diagnosis:**
```terminal:execute
command: docker logs schema-registry | grep "GET /schemas/ids" | wc -l
session: 1
```

**Should be low (caching should work)**

**Solutions:**
1. Verify cache configuration:
   ```java
   props.put("max.schemas.per.subject", "1000");
   ```
2. Check Schema Registry resource limits
3. Enable metrics to monitor cache hit rate

### Issue 4: Schema Registry Unavailable

**Symptom:**
Producer/consumer hangs on startup

**Diagnosis:**
```terminal:execute
command: curl http://localhost:8081/subjects
session: 1
```

**Solutions:**
1. Check Registry health:
   ```terminal:execute
   command: docker ps | grep schema-registry
   session: 1
   ```
   
   ```terminal:execute
   command: docker logs schema-registry
   session: 1
   ```
2. Verify Kafka connectivity (Registry stores schemas in Kafka)
3. Check firewall/network policies

## Monitoring and Observability

### Key Metrics to Track

**Schema Registry Metrics:**
- `schema.count` - Total schemas registered
- `schema.registry.api.request.count` - API call rate
- `schema.registry.kafka.store.lag` - Replication lag

**Producer Metrics:**
- `schema.registry.serializer.cache.hit.ratio` - Cache effectiveness
- `serializer.errors` - Serialization failures

**Consumer Metrics:**
- `schema.registry.deserializer.cache.hit.ratio` - Cache effectiveness
- `deserializer.errors` - Deserialization failures

### Enabling JMX Metrics

```yaml
# docker-compose.yml
schema-registry:
  environment:
    SCHEMA_REGISTRY_JMX_PORT: 9999
    SCHEMA_REGISTRY_JMX_HOSTNAME: localhost
  ports:
    - "9999:9999"
```

**Query metrics:**
```bash
# Using jmxterm
java -jar jmxterm.jar -l localhost:9999
beans
get -b kafka.schema.registry:type=registered-count -a Value
```

## Production Best Practices

### 1. Schema Design Principles

✅ **Use meaningful names** - `OrderCreated` not `Event1`  
✅ **Add documentation** - Use `doc` fields extensively  
✅ **Plan for evolution** - Start with optional fields where possible  
✅ **Namespace properly** - Group related schemas logically  
✅ **Avoid deeply nested structures** - Flatten when reasonable  

### 2. Compatibility Strategy

✅ **Default to BACKWARD** - Safest for most teams  
✅ **Document exceptions** - If using FORWARD/FULL, explain why  
✅ **Test in staging first** - Never go straight to production  
✅ **Maintain compatibility for 30 days** - Allow time for gradual rollouts  

### 3. Operational Excellence

✅ **Monitor Registry health** - Alerts for downtime  
✅ **Backup schemas regularly** - Export to Git  
✅ **Version control schemas** - Track changes over time  
✅ **Automate validation** - CI/CD integration  
✅ **Document breaking changes** - If you must break, plan migration  

### 4. Security

✅ **Enable authentication** - Don't allow anonymous access  
✅ **Use HTTPS** - Encrypt traffic to Registry  
✅ **Implement RBAC** - Control who can register schemas  
✅ **Audit schema changes** - Log all registrations  

## Exporting Schemas for Backup

```bash
#!/bin/bash
# backup-schemas.sh

REGISTRY_URL="http://localhost:8081"
BACKUP_DIR="schema-backups/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

# Get all subjects
subjects=$(curl -s "$REGISTRY_URL/subjects" | jq -r '.[]')

for subject in $subjects; do
    echo "Backing up $subject..."
    
    # Get all versions
    versions=$(curl -s "$REGISTRY_URL/subjects/$subject/versions" | jq -r '.[]')
    
    for version in $versions; do
        schema=$(curl -s "$REGISTRY_URL/subjects/$subject/versions/$version")
        echo "$schema" | jq . > "$BACKUP_DIR/${subject}-v${version}.json"
    done
done

echo "✅ Backup complete: $BACKUP_DIR"
```

## Key Learnings

✅ **Schema Registry prevents disasters** - Blocking bad changes before production  
✅ **REST API is powerful** - Automation and troubleshooting  
✅ **CI/CD integration is essential** - Validate schemas in pipelines  
✅ **Monitoring is critical** - Track cache hits and errors  
✅ **Backups save lives** - Export schemas regularly  

## What's Next?

In the final module, we'll:

1. ✅ Review key concepts
2. ✅ Discuss production deployment strategies
3. ✅ Explore advanced topics
4. ✅ Provide next learning steps

---

**Time:** 15 minutes  
**Previous:** [Schema Evolution](04-schema-evolution.md)  
**Next:** [Wrap-Up](99-wrap-up.md)

