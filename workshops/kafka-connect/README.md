# Kafka Connect Workshop

This workshop demonstrates how to stream data from PostgreSQL to Kafka using Kafka Connect with JDBC Source Connector.

## Overview

Learn how to:
- Configure Kafka Connect in standalone mode
- Use JDBC Source Connector to read from PostgreSQL
- Stream database records into Kafka topics
- Monitor data flow in Kafka UI

## Architecture

```
PostgreSQL → Kafka Connect (JDBC Source) → Kafka Topic → Kafka UI
```

## Components

- **Kafka** (KRaft mode) - Message broker
- **PostgreSQL** - Source database with sample products table
- **Kafka Connect** - Data streaming framework with JDBC connector
- **Kafka UI** - Web interface for visualization

## Workshop Duration

Approximately 45 minutes

## Prerequisites

- Basic understanding of Kafka concepts
- Familiarity with relational databases
- Docker and Docker Compose knowledge

## Getting Started

Follow the workshop steps in order:
1. Introduction to Kafka Connect
2. Start environment and verify PostgreSQL
3. Configure JDBC Source Connector
4. Summary and next steps

## Local Testing

To run this workshop locally:

```bash
docker compose up -d
```

Wait for all services to be healthy, then follow the workshop content.

## Cleanup

```bash
docker compose down -v
```
