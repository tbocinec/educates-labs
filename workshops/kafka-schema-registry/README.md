# Kafka Schema Registry & Data Governance

A comprehensive hands-on workshop covering data governance, schema evolution, and contract-based development in Apache Kafka using Confluent Schema Registry.

## Workshop Overview

**Duration:** 90 minutes  
**Level:** Intermediate  
**Prerequisites:** Basic understanding of Kafka producers and consumers  
**Focus:** Schema Registry, data governance, and schema evolution

## What You'll Learn

Master schema-driven development and data governance in Kafka:

✅ **Data Governance Fundamentals** - Why schemas matter in event-driven systems  
✅ **Schema Registry Architecture** - Subjects, versions, IDs, and wire format  
✅ **Schema Evolution** - BACKWARD, FORWARD, FULL, and transitive compatibility  
✅ **Producer/Consumer Integration** - Serialization and deserialization with Schema Registry  
✅ **Breaking Changes Prevention** - How governance prevents production outages  
✅ **Real-World Workflows** - Contract-based APIs and CI validation  

## Workshop Modules

### Module 1: Introduction to Data Governance (15 min)
- Why data governance matters
- Problems with uncontrolled data evolution
- Introduction to Schema Registry
- Understanding wire format and schema IDs

### Module 2: Register and Produce with Schemas (20 min)
- Creating Avro schemas for events
- Registering schemas in Schema Registry
- Producing messages with schema validation
- Inspecting the wire format (magic byte + schema ID)

### Module 3: Consume with Schema Registry (15 min)
- Consuming schema-encoded messages
- Automatic schema resolution
- Understanding schema caching
- Consumer evolution without code changes

### Module 4: Schema Evolution & Compatibility (20 min)
- Understanding compatibility modes
- Compatible vs. breaking changes
- Hands-on: evolving schemas safely
- Testing backward compatibility

### Module 5: Governance in Action (15 min)
- Preventing breaking changes
- Schema Registry REST API exploration
- CI/CD integration patterns
- Troubleshooting schema issues

### Module 6: Wrap-Up (5 min)
- Key concepts review
- Production best practices
- Next steps

## Domain: Order Management System

We'll use an e-commerce order processing system:

**Events:**
- `OrderCreated` - New orders entering the system
- `OrderUpdated` - Status changes and modifications
- `OrderCompleted` - Fulfillment completion

**Schema Evolution Scenarios:**
- Adding optional fields (new metadata)
- Making fields required
- Renaming fields
- Removing deprecated fields

## Technology Stack

- **Apache Kafka** (KRaft mode)
- **Confluent Schema Registry** (7.7.1)
- **Apache Avro** for serialization
- **Java** with Maven for applications
- **Kafka UI** for monitoring
- **REST API** for schema management

## Quick Start

1. **Start the environment:**
   ```bash
   docker compose up -d
   ```

2. **Verify services:**
   - Kafka: http://localhost:9092
   - Schema Registry: http://localhost:8081
   - Kafka UI: http://localhost:8080

3. **Build applications:**
   ```bash
   ./build-apps.sh
   ```

4. **Follow the workshop modules** in the `workshop/content/` directory

## Project Structure

```
kafka-schema-registry/
├── README.md                          # This file
├── docker-compose.yml                 # Complete Kafka + Schema Registry environment
├── build-apps.sh                      # Build all Java applications
├── kafka-apps/                        # Java applications
│   ├── producer-avro/                 # Producer with Avro schema
│   ├── consumer-avro/                 # Consumer with Avro schema
│   ├── producer-json-schema/          # JSON Schema example
│   └── schema-evolution-demo/         # Evolution scenarios
├── schemas/                           # Avro schema definitions
│   ├── order-v1.avsc                  # Initial schema
│   ├── order-v2-compatible.avsc       # Compatible evolution
│   └── order-v3-breaking.avsc         # Breaking change example
├── scripts/                           # Helper scripts
│   ├── register-schema.sh             # Register schema via REST API
│   ├── list-subjects.sh               # List all subjects
│   ├── check-compatibility.sh         # Test schema compatibility
│   └── inspect-message.sh             # Decode wire format
├── workshop/                          # Educates workshop content
│   ├── config.yaml                    # Workshop configuration
│   └── content/                       # Workshop markdown files
└── resources/                         # Educates resources
    └── workshop.yaml                  # Workshop deployment spec
```

## Key Learning Outcomes

After completing this workshop, participants will:

1. **Understand** why schema governance is critical for production systems
2. **Know** how Schema Registry integrates with Kafka producers and consumers
3. **Be able to** register, evolve, and validate schemas
4. **Recognize** compatible vs. breaking schema changes
5. **Apply** compatibility modes to real-world scenarios
6. **Implement** schema-based producers and consumers in Java
7. **Troubleshoot** schema-related issues using REST API and tools

## Production Best Practices Covered

- Schema design principles
- Choosing the right compatibility mode
- Versioning strategies
- CI/CD integration for schema validation
- Schema governance policies
- Performance considerations (caching, serialization)
- Monitoring and alerting

## Additional Resources

- [Confluent Schema Registry Documentation](https://docs.confluent.io/platform/current/schema-registry/)
- [Apache Avro Documentation](https://avro.apache.org/docs/current/)
- [Schema Evolution and Compatibility](https://docs.confluent.io/platform/current/schema-registry/avro.html)
- [Schema Registry REST API Reference](https://docs.confluent.io/platform/current/schema-registry/develop/api.html)

## Workshop Delivery Notes

**Timing:** The workshop is designed for 90 minutes with hands-on exercises. Adjust the depth of REST API exploration based on participant experience.

**Prerequisites:** Participants should have basic Kafka knowledge (producers, consumers, topics). The "kafka-consumers-essentials" workshop is recommended preparation.

**Environment:** Each participant needs Docker and Java 17+. Pre-pull images before the session to save time.

---

**Created for:** Educates Platform  
**Last Updated:** December 2025  
**Maintainer:** Your Name

