# Setting Up a Multi-Broker Cluster

Let's scale up from a single broker to a production-like cluster with 2 brokers and a dedicated controller.

## Understanding the Cluster Architecture

We'll create a 3-node KRaft cluster:
- **Node 1** - KRaft Controller (manages metadata)
- **Node 2** - Kafka Broker (handles data)
- **Node 3** - Kafka Broker (handles data)

## Stop Kafka UI Temporarily

We need to use Terminal 2, so let's stop Kafka UI for now (we'll restart it at the end):

```terminal:execute
command: docker compose down
session: 2
```

## Stop the Single Broker

First, stop the single broker we started earlier:

```terminal:execute
command: |
  pkill -f kafka.Kafka
  sleep 3
session: 1
```

Verify it's stopped:

```terminal:execute
command: ps aux
session: 1
```

## Review Configuration Files

Three configuration files have been prepared for you in the `config/` directory. You can open them directly in the Editor:

```editor:open-file
file: ~/config/controller.properties
```

```editor:open-file
file: ~/config/broker1.properties
```

```editor:open-file
file: ~/config/broker2.properties
```

Key differences between the files:
- **node.id** - Unique ID for each node (1, 2, 3)
- **process.roles** - Controller vs Broker role
- **listeners** - Different ports (9093, 9092, 9094)
- **log.dirs** - Separate data directories

## Copy Configuration Files to Container

Now let's copy these configuration files into the Kafka container:

```terminal:execute
command: |
  docker cp config/controller.properties kafka-workshop:/opt/kafka/config/
  docker cp config/broker1.properties kafka-workshop:/opt/kafka/config/
  docker cp config/broker2.properties kafka-workshop:/opt/kafka/config/
session: 2
```

Verify the files were copied:

```terminal:execute
command: docker exec kafka-workshop ls -la /opt/kafka/config/
session: 2
```

## Generate Cluster ID

Generate a new cluster ID for the cluster:

```terminal:execute
command: |
  cd /opt/kafka
  KAFKA_CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)
  echo "Cluster ID: $KAFKA_CLUSTER_ID"
  echo $KAFKA_CLUSTER_ID > /tmp/cluster-id
session: 1
```

## Format Storage Directories

Format the storage for each node:

```terminal:execute
command: |
  cd /opt/kafka
  KAFKA_CLUSTER_ID=$(cat /tmp/cluster-id)
  bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/controller.properties
session: 1
```

```terminal:execute
command: |
  cd /opt/kafka
  KAFKA_CLUSTER_ID=$(cat /tmp/cluster-id)
  bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/broker1.properties
session: 1
```

```terminal:execute
command: |
  cd /opt/kafka
  KAFKA_CLUSTER_ID=$(cat /tmp/cluster-id)
  bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/broker2.properties
session: 1
```

## Start the Cluster

Start all three nodes:

```terminal:execute
command: |
  cd /opt/kafka
  mkdir -p logs
  nohup bin/kafka-server-start.sh config/controller.properties > logs/controller.log 2>&1 &
session: 1
```

Wait for controller to start:

```terminal:execute
command: sleep 5
session: 1
```

Start broker 1:

```terminal:execute
command: |
  cd /opt/kafka
  nohup bin/kafka-server-start.sh config/broker1.properties > logs/broker1.log 2>&1 &
session: 1
```

Start broker 2:

```terminal:execute
command: |
  cd /opt/kafka
  nohup bin/kafka-server-start.sh config/broker2.properties > logs/broker2.log 2>&1 &
session: 1
```

Wait for cluster to start:

```terminal:execute
command: sleep 10 && echo "Cluster started!"
session: 1
```

## Verify the Cluster

Check that all processes are running:

```terminal:execute
command: ps aux
session: 1
```

You should see three Kafka processes!

Check the logs:

```terminal:execute
command: |
  echo "=== Controller Log ==="
  tail -n 10 /opt/kafka/logs/controller.log
  echo ""
  echo "=== Broker 1 Log ==="
  tail -n 10 /opt/kafka/logs/broker1.log
  echo ""
  echo "=== Broker 2 Log ==="
  tail -n 10 /opt/kafka/logs/broker2.log
session: 1
```

## Verify Network Listeners

Check that brokers are listening on their ports:

```terminal:execute
command: netstat -tlnp | grep -E ":(9092|9093|9094)"
session: 1
```

You should see:
- Port 9093 - Controller
- Port 9092 - Broker 1
- Port 9094 - Broker 2

## Restart Kafka UI

Now that the cluster is running, restart Kafka UI:

```terminal:execute
command: docker compose up -d && echo "Kafka UI restarted!"
session: 2
```

## Next Steps

Now let's test the cluster with replicated topics!
