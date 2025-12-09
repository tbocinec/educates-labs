# Starting a Single Kafka Broker

Now let's configure and start a single Kafka broker in KRaft mode.

## Generate a Cluster ID

In KRaft mode, each cluster needs a unique cluster ID. Generate one:

```terminal:execute
command: |
  cd /opt/kafka
  KAFKA_CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)
  echo $KAFKA_CLUSTER_ID
```

Save this ID for the next steps.

## Explore the Configuration File

Before we start Kafka, let's take a look at the default KRaft configuration file:

```terminal:execute
command: cat /opt/kafka/config/server.properties
```

This file contains all the Kafka broker settings. You can review the full documentation of all configuration options here:

📖 **[Kafka Configuration Documentation](https://kafka.apache.org/documentation/#brokerconfigs)**

The most important settings we'll use are already configured in this file. You can modify these settings based on your needs in production environments.

## Format the Storage Directory

Before starting Kafka for the first time, we need to format the storage directory. This is a **required one-time operation** that initializes the Kafka cluster metadata in KRaft mode.

**Why is formatting necessary?**
- **Initializes cluster metadata** - Creates the internal metadata structures that KRaft uses instead of ZooKeeper
- **Generates unique cluster identity** - Ensures this cluster has a unique ID to prevent accidental mixing of data from different clusters
- **Prepares log directories** - Sets up the directory structure for storing topics, partitions, and metadata
- **Creates metadata snapshots** - Initializes the metadata log that tracks cluster configuration and state

Without formatting, Kafka won't start because it needs this metadata foundation to operate in KRaft mode.

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/server.properties --standalone
```

This command:
- Formats the log directories specified in `server.properties`
- Initializes metadata for KRaft mode with the cluster ID
- Uses `--standalone` flag for single-node combined broker/controller mode
- Prepares the broker to start

**Note:** You only need to format once when setting up a new cluster. Re-formatting will **erase all existing data**!

## Inspect the Storage Directory

After formatting, you can view the created storage structure:

```terminal:execute
command: ls -la /tmp/kraft-combined-logs/
```

You should see files and directories like:
- `__cluster_metadata-0/` - Metadata partition for KRaft consensus
- `meta.properties` - Cluster and node identification
- Various log and snapshot files

## Understanding the Configuration

Let's look at the key configuration properties for KRaft mode:

```terminal:execute
command: cat /opt/kafka/config/server.properties | grep -E "^(process.roles|node.id|controller.quorum.voters|listeners|log.dirs)" | head -10
```

Key properties:
- **process.roles=broker,controller** - This node acts as both broker and controller
- **node.id=1** - Unique identifier for this node
- **controller.quorum.voters** - List of controller nodes in the cluster
- **listeners** - Network addresses the broker listens on
- **log.dirs** - Where Kafka stores data

## Start the Kafka Broker

Start the broker in the background:

```terminal:execute
command: |
  cd /opt/kafka
  mkdir -p logs
  nohup bin/kafka-server-start.sh config/server.properties > logs/kafka.log 2>&1 &
```

Wait a few seconds for the broker to start, then check the logs:

```terminal:execute
command: |
  sleep 5
  tail -n 20 /opt/kafka/logs/kafka.log
```

Look for messages like:
- `[KafkaServer id=1] started` - Broker successfully started
- `Awaiting socket connections` - Ready to accept connections

## Verify Broker is Running

Check if the Kafka process is running:

```terminal:execute
command: ps aux
```

You should see the Java process running `kafka.Kafka`.

## Test Connection

Verify the broker is listening on port 9092:

```terminal:execute
command: netstat -tlnp | grep 9092
```

## Troubleshooting

If the broker didn't start, check the logs:

```terminal:execute
command: tail -n 50 /opt/kafka/logs/kafka.log
```

Common issues:
- **Port already in use** - Another process is using port 9092
- **Storage not formatted** - Run the kafka-storage.sh format command again
- **Java version** - Ensure Java 11+ is installed

## Next Steps

Now that we have a running broker, let's create topics and produce/consume messages!
