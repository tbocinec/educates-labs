# Starting the Environment

Let's start all required services using Docker Compose.

## Start Services

Run the following command to start Kafka, PostgreSQL, Kafka Connect, and Kafka UI:

```terminal:execute
command: docker compose up -d
session: 1
```

This will start:
- **Kafka** broker on port 9092
- **PostgreSQL** database on port 5432
- **Kafka Connect** on port 8083
- **Kafka UI** on port 8080

## Wait for Services to Start

The services need time to initialize. Let's wait for them to be healthy:

```terminal:execute
command: |
  echo "Waiting for services to start..."
  sleep 10
  docker compose ps
session: 1
```

All services should show status as `Up` and `healthy`.

## Verify PostgreSQL Database

Check that the PostgreSQL database is running and contains our sample data:

```terminal:execute
command: |
  docker exec postgres psql -U postgres -d inventory -c "SELECT * FROM products;"
session: 1
```

You should see 5 products in the `products` table:
- Laptop
- Mouse
- Keyboard
- Monitor
- USB Cable

💡 **How did the data get there?** PostgreSQL automatically ran `init-db.sql` during startup (via Docker's `docker-entrypoint-initdb.d`), which created the table and inserted sample products.

## Verify Kafka Connect

Check that Kafka Connect is running and ready:

```terminal:execute
command: |
  docker exec kafka-connect curl -s http://localhost:8083/
session: 1
```

## Check Available Connectors

List the installed connector plugins:

```terminal:execute
command: |
  docker exec kafka-connect curl -s http://localhost:8083/connector-plugins | grep -o '"class":"[^"]*"' | cut -d'"' -f4
session: 1
```

You should see `JdbcSourceConnector` in the list - this is what we'll use to connect to PostgreSQL.

## Environment is Ready! ✅

All services are now running and ready. In the next step, we'll configure the JDBC Source Connector to stream data from PostgreSQL to Kafka.
