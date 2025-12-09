# Working with Topics and Messages

Let's create topics and send some messages to our Kafka broker.

## Create a Topic

Create a topic named `test-topic` with 3 partitions:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-topics.sh --create \
    --topic test-topic \
    --partitions 3 \
    --replication-factor 1 \
    --bootstrap-server localhost:9092
```

Since we only have one broker, the replication factor is 1.

## List Topics

Verify the topic was created:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

## Describe the Topic

Get detailed information about the topic:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-topics.sh --describe \
    --topic test-topic \
    --bootstrap-server localhost:9092
```

You'll see:
- **Partition count** - Number of partitions (3)
- **Replication factor** - Number of replicas (1)
- **Leader** - Which broker leads each partition
- **Replicas** - Where replicas are stored
- **ISR** - In-Sync Replicas

## Produce Messages

Open a producer console and send some messages:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-console-producer.sh \
    --topic test-topic \
    --bootstrap-server localhost:9092
```

Type a few messages and press Enter after each one:
```
Hello Kafka!
This is my first message
KRaft mode is awesome
```

Press `Ctrl+C` to exit the producer.

Or send messages directly:

```terminal:execute
command: |
  cd /opt/kafka
  echo -e "Message 1\nMessage 2\nMessage 3" | bin/kafka-console-producer.sh \
    --topic test-topic \
    --bootstrap-server localhost:9092
```

## Consume Messages

Read the messages from the beginning:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-console-consumer.sh \
    --topic test-topic \
    --from-beginning \
    --bootstrap-server localhost:9092
```

You should see all the messages you produced!

Press `Ctrl+C` to stop the consumer.

## Consumer Groups

Create a consumer in a consumer group (the group is automatically created when you specify the `--group` parameter):

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-console-consumer.sh \
    --topic test-topic \
    --group my-consumer-group \
    --bootstrap-server localhost:9092 > /tmp/consumer-output.log 2>&1 &
```

This runs the consumer in the background and redirects output to `/tmp/consumer-output.log`.

## Check Consumer Group Status

View consumer group details:

```terminal:execute
command: |
  cd /opt/kafka
  bin/kafka-consumer-groups.sh \
    --describe \
    --group my-consumer-group \
    --bootstrap-server localhost:9092
```

This shows:
- **Current offset** - Last consumed message
- **Log end offset** - Latest message in partition
- **Lag** - How many messages behind the consumer is

## Next Steps

Now let's set up Kafka UI - a web dashboard for easier monitoring and management of our Kafka cluster!
