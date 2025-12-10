# Summary

Congratulations! 🎉 You've successfully completed the Kafka Connect workshop.

## What You Learned

In this workshop, you:

✅ Started a complete Kafka Connect environment with Docker  
✅ Connected PostgreSQL database to Kafka using JDBC Source Connector  
✅ Streamed database records into Kafka topics automatically  
✅ Tested real-time data streaming by inserting new records  
✅ Viewed data in Kafka UI  

## Key Concepts

### Kafka Connect Architecture

- **Connectors** - Plugins that define how to integrate with specific systems
- **Tasks** - Units of work that actually copy data
- **Workers** - Processes that execute connectors and tasks
- **Converters** - Transform data between Connect format and Kafka

### JDBC Source Connector

- **Incrementing mode** - Tracks new rows by numeric ID column
- **Timestamp mode** - Tracks changes by timestamp column
- **Timestamp+Incrementing** - Combines both for comprehensive tracking
- **Bulk mode** - Reads entire table each poll

### Configuration Parameters

```json
{
  "mode": "incrementing",           // How to detect new data
  "incrementing.column.name": "id", // Column to track
  "poll.interval.ms": "5000",       // Polling frequency
  "topic.prefix": "postgres-"       // Kafka topic naming
}
```

## Production Considerations

When deploying Kafka Connect in production:

1. **Use distributed mode** - Run multiple workers for scalability
2. **Configure proper error handling** - Set retry policies and DLQ
3. **Monitor connector health** - Use metrics and alerting
4. **Optimize polling interval** - Balance freshness vs database load
5. **Use timestamp+incrementing mode** - Catch both inserts and updates
6. **Secure connections** - Use SSL/TLS for database and Kafka

## Next Steps

To expand your Kafka Connect knowledge:

- 📚 Try **sink connectors** (write from Kafka to databases)
- 🔄 Explore **Single Message Transforms (SMT)** for data transformation
- 🔍 Learn about **Change Data Capture (CDC)** with Debezium
- 📊 Integrate with **Schema Registry** for schema evolution
- 🚀 Deploy in **distributed mode** with multiple workers

## Useful Commands

```bash
# List all connectors
curl http://localhost:8083/connectors

# Get connector status
curl http://localhost:8083/connectors/<name>/status

# Pause connector
curl -X PUT http://localhost:8083/connectors/<name>/pause

# Resume connector
curl -X PUT http://localhost:8083/connectors/<name>/resume

# Delete connector
curl -X DELETE http://localhost:8083/connectors/<name>

# Restart connector
curl -X POST http://localhost:8083/connectors/<name>/restart
```

## Cleanup

Stop all services:

```terminal:execute
command: docker compose down -v
session: 1
```

## Resources

- 📖 [Kafka Connect Documentation](https://docs.confluent.io/platform/current/connect/index.html)
- 🔌 [Confluent Hub Connectors](https://www.confluent.io/hub/)
- 📚 [JDBC Connector Guide](https://docs.confluent.io/kafka-connectors/jdbc/current/index.html)

---

**Thank you for completing this workshop!** 🚀
