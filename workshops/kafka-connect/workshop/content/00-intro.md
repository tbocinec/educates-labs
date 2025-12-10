# Kafka Connect - Introduction

Welcome to the **Kafka Connect** workshop! 

## What is Kafka Connect?

Kafka Connect is a framework for streaming data between Apache Kafka and other systems in a scalable and reliable way. It makes it simple to:

- **Import data** from databases, message queues, and files into Kafka topics
- **Export data** from Kafka topics to databases, search indexes, and storage systems
- Scale up and down dynamically based on load
- Handle failures and retries automatically

## Why Use Kafka Connect?

Instead of writing custom producer/consumer code for each data source, Kafka Connect provides:

✅ **Pre-built connectors** for common systems (PostgreSQL, MySQL, MongoDB, etc.)  
✅ **Automatic schema management** and data transformation  
✅ **Fault tolerance** and automatic recovery  
✅ **Scalability** with distributed worker mode  
✅ **REST API** for easy management  

## Workshop Architecture

In this workshop, we'll work with:

```
PostgreSQL Database
       ↓
   [Kafka Connect] ← JDBC Source Connector
       ↓
   Kafka Topic (postgres-products)
       ↓
   [Kafka UI] - Visualization
```

## What You'll Learn

In this workshop, you will:

1. ✅ Start PostgreSQL database with sample product data
2. ✅ Configure Kafka Connect JDBC Source Connector
3. ✅ Stream database changes into Kafka topics
4. ✅ View data in Kafka UI

## Environment

Your workshop environment includes:

- **Kafka** (KRaft mode) - Message broker
- **PostgreSQL** - Source database with products table
- **Kafka Connect** - Data streaming framework
- **Kafka UI** - Web interface for monitoring

All services are managed via Docker Compose and will start automatically.

Let's get started! 🚀
