# Setting Up Kafka UI

Kafka UI is a web-based dashboard for managing and monitoring Apache Kafka clusters. Let's set it up to visualize our Kafka broker.

## What is Kafka UI?

Kafka UI provides a user-friendly interface to:
- **View topics** and their configurations
- **Browse messages** in topics
- **Monitor consumer groups** and their lag
- **See broker information** and cluster health
- **Create and manage topics** without command line

## Start Kafka UI

We'll use Docker Compose to start Kafka UI in a separate container that shares the network with our Kafka container:

```terminal:execute
command: docker compose up -d && echo "Kafka UI starting in background..."
session: 2
```

This command:
- Downloads the Kafka UI image (if not already present)
- Starts Kafka UI in detached mode
- Connects it to our Kafka broker on localhost:9092

Wait a few seconds for Kafka UI to start:

```terminal:execute
command: sleep 5 && docker compose ps
session: 2
```

## Access Kafka UI

Once Kafka UI is running, click on the **Kafka UI** tab at the top of this page to open the dashboard.

You should see:
- **Cluster overview** - Number of brokers, topics, partitions
- **Brokers list** - Your single broker (id=1)
- **Topics** - Any topics you created (like `test-topic`)

## Explore the Dashboard

In the Kafka UI dashboard, you can:

1. **View Topics**: Click on "Topics" in the left menu to see all topics
2. **Browse Messages**: Click on a topic name to view messages
3. **Topic Details**: See partitions, replication factor, configuration
4. **Consumer Groups**: Monitor consumer group offsets and lag

## Create a Topic via UI

Try creating a topic through the web interface:

1. Click **Topics** in the left menu
2. Click **Add a Topic** button
3. Enter topic name: `ui-created-topic`
4. Set partitions: `3`
5. Click **Create**

## Verify Topic Creation

Check that the topic was created using the command line:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

You should see both `test-topic` and `ui-created-topic`!

## Benefits of Kafka UI

- **Visual monitoring** - See cluster health at a glance
- **Easier management** - No need to remember CLI commands
- **Message browsing** - Quickly view message content
- **Real-time updates** - Dashboard refreshes automatically

## Next Steps

Now that we have Kafka UI running, let's scale to a multi-broker cluster to see how replication works!
