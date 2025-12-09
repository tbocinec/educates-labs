# Kafka CLI Tools Workshop

Practical hands-on workshop for mastering Kafka command-line tools.

## Overview

This workshop covers all essential Kafka CLI tools with real-world use cases:

1. **CLI Introduction** - Environment setup, Docker container access pattern
2. **kafka-topics** - Topic management (create, list, describe, alter, delete)
3. **kafka-console-producer** - Publishing messages with keys and configurations
4. **kafka-console-consumer** - Reading messages, formatting output, consumer groups
5. **kafka-consumer-groups** - Lag monitoring, offset reset, group management
6. **kafka-reassign-partitions** - Partition rebalancing, broker decommissioning
7. **kafka-log-dirs** - Disk usage analysis, capacity planning
8. **kafka-configs** - Dynamic configuration without broker restarts
9. **kafka-acls** - Security, authorization, multi-tenant setups
10. **kafka-leader-election & kafka-replica-verification** - Replication management
11. **kafka-advanced-tools** - dump-log, delete-records, get-offsets, GDPR compliance
12. **Workshop Summary** - Cheat sheet, best practices, troubleshooting guide

## Key Features

- **No repetitive docker exec** - Connect to container once in Level 01, stay inside
- **Environment variables** - Use `$BOOTSTRAP` instead of full server addresses
- **Progressive learning** - From basics to advanced production scenarios
- **Real-world use cases** - Emergency retention, lag monitoring, GDPR deletion
- **Professional content** - Concise, well-structured, with best practices

## Environment

- 3-node Kafka cluster (KRaft mode - no ZooKeeper)
- Kafka UI for visual comparison
- Hands-on examples - just click and execute!
- Docker-based setup for consistency

## Target Audience

- Kafka beginners to intermediate users
- DevOps engineers managing Kafka clusters
- Backend developers using Kafka
- Data engineers building pipelines

## Duration

150-180 minutes (11 CLI tools + summary)

## Setup

```bash
docker compose up -d
```

Wait for healthy brokers (kafka-1, kafka-2, kafka-3).
