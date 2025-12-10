# Getting Started - Cluster Setup

Set up your Kafka cluster and access the command-line environment.

## Start the Kafka Cluster

Launch a 3-node Kafka cluster using Docker Compose:

```terminal:execute
command: |
  docker compose up -d
session: 1
```

Wait for all brokers to start (approximately 30 seconds):

```terminal:execute
command: |
  docker compose ps
session: 1
```

Wait until all three containers (`kafka-1`, `kafka-2`, `kafka-3`) show **healthy** status (may take 30-60 seconds).

## Connect to Kafka Container

Instead of running `docker exec` for every command, we'll **connect directly into the container** and work from inside:

```terminal:execute
command: |
  docker exec -it kafka-1 bash
session: 1
```

You're now **inside the kafka-1 container**. All subsequent commands will run directly here without needing `docker exec` prefixes.

> **Note:** From this point forward, all commands assume you're inside the container. If you get disconnected, simply re-run the command above.

## Verify Kafka Installation

Check that Kafka CLI tools are available:

```terminal:execute
command: |
  ls -la /usr/bin/kafka-* | head -n 15
session: 1
```

You should see numerous `kafka-*` scripts including:
- `kafka-topics`
- `kafka-console-producer`
- `kafka-console-consumer`
- `kafka-consumer-groups`
- `kafka-configs`
- And many more...

## Test Cluster Connectivity

Verify the cluster is running and accessible:

```terminal:execute
command: |
  kafka-broker-api-versions --bootstrap-server kafka-1:19092 | head -n 10
session: 1
```

This command shows the API versions supported by each broker. You should see output for all 3 brokers.

## Set Bootstrap Server Alias

Create an environment variable for the bootstrap server to avoid typing it repeatedly:

```terminal:execute
command: |
  export BOOTSTRAP="kafka-1:19092,kafka-2:19092,kafka-3:19092"
  echo "export BOOTSTRAP='kafka-1:19092,kafka-2:19092,kafka-3:19092'" >> ~/.bashrc
  echo "✅ Bootstrap servers: $BOOTSTRAP"
session: 1
```

Now you can use `$BOOTSTRAP` in commands instead of typing the full broker list.

**Example:**
```bash
kafka-topics --bootstrap-server $BOOTSTRAP --list
```

## Verify Cluster Status

### Check Cluster ID

```terminal:execute
command: |
  kafka-cluster cluster-id --bootstrap-server $BOOTSTRAP
session: 1
```

All brokers in a cluster share the same Cluster ID.

### List Active Brokers

```terminal:execute
command: |
  kafka-broker-api-versions --bootstrap-server $BOOTSTRAP
session: 1
```

You should see all 3 brokers with their API versions.

## Understanding --bootstrap-server

The `--bootstrap-server` parameter tells Kafka CLI tools where to find the cluster.

**Best Practices:**
- **Multiple brokers**: Always list multiple brokers for high availability
- **Load balancing**: Kafka client automatically distributes connections
- **Failover**: If one broker is down, others can handle the request

```bash
# Good - Multiple brokers
--bootstrap-server kafka-1:19092,kafka-2:19092,kafka-3:19092

# Acceptable - Single broker (others used as backup)
--bootstrap-server kafka-1:19092
```

## Common CLI Patterns

Most Kafka CLI tools follow this pattern:

```bash
kafka-<tool> --bootstrap-server <brokers> <action> [options]
```

**Examples:**
```bash
# Topics
kafka-topics --bootstrap-server $BOOTSTRAP --list

# Consumer groups
kafka-consumer-groups --bootstrap-server $BOOTSTRAP --list

# Configs
kafka-configs --bootstrap-server $BOOTSTRAP --entity-type brokers --describe --entity-name 1
```

## Using --help

Every Kafka CLI tool has extensive help documentation:

```terminal:execute
command: |
  kafka-topics --help | head -n 30
session: 1
```

**Tip:** Use `--help` whenever you're unsure about options. It shows:
- Required vs optional parameters
- Available commands/actions
- Examples and usage patterns

## Kafka UI (Optional)

Open the **Kafka UI** tab (port 8080) to see a visual representation of your cluster:
- **Brokers**: All 3 nodes should be visible
- **Topics**: Empty for now (we'll create some next)
- **Consumers**: No consumer groups yet

While Kafka UI is helpful for visualization, **CLI tools are essential for production operations, automation, and troubleshooting**.

## Troubleshooting

### Connection Issues

If you get "Connection refused" errors, verify that all broker containers are running and healthy:

```terminal:execute
command: |
  docker compose ps
session: 1
```

All three brokers should show status as `Up` and `healthy`.

### Check Broker Logs

If something isn't working:

```bash
# Exit the container first (Ctrl+D), then:
docker logs kafka-1 --tail 50
```

### Reconnect to Container

If you get disconnected from the container:

```bash
docker exec -it kafka-1 bash
export BOOTSTRAP="kafka-1:19092,kafka-2:19092,kafka-3:19092"
```

## Summary

You've successfully:
- ✅ Started a 3-node Kafka cluster
- ✅ Connected to the Kafka container
- ✅ Verified Kafka CLI tools are available
- ✅ Set up bootstrap server environment variable
- ✅ Tested cluster connectivity
- ✅ Learned common CLI patterns

## Next Steps

In the next level, we'll dive into **kafka-topics** - the most frequently used CLI tool for topic management.
