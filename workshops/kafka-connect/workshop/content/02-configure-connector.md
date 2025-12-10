# Configure Kafka Connect Source Connector

Now we'll create a JDBC Source Connector to stream data from PostgreSQL into Kafka.

## Understanding the Connector Configuration

Let's examine the connector configuration file. Click to open it in the editor:

```editor:open-file
file: postgres-source-connector.json
```

Or view it in the terminal:

```terminal:execute
command: cat postgres-source-connector.json
session: 1
```

**Key configuration parameters:**

- `connector.class`: `JdbcSourceConnector` - Reads from JDBC databases
- `connection.url`: `jdbc:postgresql://postgres:5432/inventory` - Database connection
- `connection.user` / `connection.password`: Database credentials (postgres/postgres)
- `table.whitelist`: `products` - Only stream the products table
- `mode`: `incrementing` - Track new rows by ID column
- `incrementing.column.name`: `id` - Use the id column to detect new rows
- `topic.prefix`: `postgres-` - Topic will be named `postgres-products`
- `poll.interval.ms`: `5000` - Check for new data every 5 seconds

💡 **Tip:** You can modify the configuration in the editor to change polling frequency or add more tables!

## Create the Connector

First, let's copy the connector config into the container:

```terminal:execute
command: |
  docker cp postgres-source-connector.json kafka-connect:/tmp/
session: 1
```

Now deploy the connector using the Kafka Connect REST API:

```terminal:execute
command: |
  docker exec kafka-connect curl -X POST http://localhost:8083/connectors \
    -H "Content-Type: application/json" \
    -d @/tmp/postgres-source-connector.json
session: 1
```

You should see a JSON response with the connector configuration if successful.

## Verify Connector Status

Check that the connector was created successfully:

```terminal:execute
command: |
  docker exec kafka-connect curl -s http://localhost:8083/connectors/postgres-source-connector/status | grep -o '"state":"[^"]*"'
session: 1
```

The connector should be in `RUNNING` state.

## Troubleshooting Connector Issues

If the connector doesn't create the topic or data doesn't appear, let's debug step by step.

### Check Connector Status in Detail

```terminal:execute
command: |
  docker exec kafka-connect curl -s http://localhost:8083/connectors/postgres-source-connector/status | jq '.'
session: 1
```

Look for:
- `"state": "RUNNING"` for both connector and tasks
- If `"FAILED"`, check the `"trace"` field for error details

### Check Connector Logs

```terminal:execute
command: |
  docker logs kafka-connect --tail 50
session: 1
```

Look for errors like:
- Database connection issues
- Authentication problems
- JDBC driver not found

### Verify Database Connection from Kafka Connect

```terminal:execute
command: |
  docker exec kafka-connect curl -s http://localhost:8083/connectors/postgres-source-connector/config | jq '.["connection.url"]'
session: 1
```

### List All Topics

```terminal:execute
command: |
  docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list
session: 1
```

You should see:
- `postgres-products` - the data topic
- `_connect-configs` - connector configuration
- `_connect-offsets` - connector progress tracking
- `_connect-status` - connector status


## View Topic Data

Let's consume messages from the topic to see the data streamed from PostgreSQL:

```terminal:execute
command: |
  docker exec kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic postgres-products \
    --from-beginning \
    --max-messages 5
session: 1
```

You should see all 5 products from the database in JSON format!

**If no messages appear:**

1. Wait 10 seconds (connector polls every 5s)
2. Check connector status: `docker exec kafka-connect curl -s http://localhost:8083/connectors/postgres-source-connector/status`
3. Check logs: `docker logs kafka-connect --tail 30`
4. Verify database has data: `docker exec postgres psql -U postgres -d inventory -c "SELECT COUNT(*) FROM products;"`

## Test Live Data Streaming

Now let's insert a new product into PostgreSQL and watch it appear in Kafka:

```terminal:execute
command: |
  docker exec postgres psql -U postgres -d inventory -c \
    "INSERT INTO products (name, category, price, stock) VALUES ('Webcam', 'Electronics', 89.99, 120);"
session: 1
```

Wait a few seconds and check for the new message:

```terminal:execute
command: |
  sleep 6
  docker exec kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic postgres-products \
    --from-beginning \
    --max-messages 6
session: 1
```

The new product "Webcam" should now appear in the stream! 🎉

## View Data in Kafka UI

Now let's visualize the data in Kafka UI:

```dashboard:open-dashboard
name: Kafka UI
```

In Kafka UI:

1. Click on **Topics** in the left menu
2. Find and click on **postgres-products** topic
3. Click on the **Messages** tab
4. You'll see all 6 products from the database in JSON format

**What you can explore in Kafka UI:**

- 📊 **Messages** - View all streamed product records
- 📈 **Statistics** - Topic size, message rate, partition count
- ⚙️ **Settings** - Topic configuration (retention, replication)
- 🔌 **Connectors** - View your running postgres-source-connector

The Kafka UI provides a much better view than console commands - you can see:
- Formatted JSON messages
- Message keys and values
- Partition distribution
- Real-time updates as new products are added

## How It Works

```
┌─────────────┐
│ PostgreSQL  │
│  products   │
└──────┬──────┘
       │ JDBC reads every 5s
       ↓
┌─────────────────┐
│ Kafka Connect   │
│ JDBC Source     │
└──────┬──────────┘
       │ Produces messages
       ↓
┌─────────────────┐
│ Kafka Topic     │
│ postgres-       │
│ products        │
└─────────────────┘
```

The connector:
1. Polls PostgreSQL every 5 seconds
2. Reads rows where `id > last_seen_id`
3. Converts rows to JSON messages
4. Publishes to `postgres-products` topic

## Connector is Running! ✅

Your Kafka Connect source connector is now streaming data from PostgreSQL to Kafka in real-time!
