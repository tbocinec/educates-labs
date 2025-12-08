# Environment Setup

Let's set up our Kafka monitoring environment with all the necessary components.

## Start Kafka with JMX Exporter

We'll start with the first docker-compose setup that includes:
- Kafka broker with JMX enabled
- JMX Exporter (standalone container)
- Kafka UI for web-based management
- Prometheus for metrics collection
- Grafana for visualization

```terminal:execute
command: docker compose up -d
session: 1
```

Wait for all services to start:

```terminal:execute
command: docker compose ps
session: 1
```

You should see:
- ✅ **kafka** - Kafka broker
- ✅ **jmx-exporter** - JMX to Prometheus exporter
- ✅ **kafka-ui** - Web UI
- ✅ **prometheus** - Metrics storage
- ✅ **grafana** - Dashboards

## Create Test Topic

Create a topic for our monitoring exercises:

```terminal:execute
command: |
  docker exec kafka kafka-topics --create \
    --topic monitoring-demo \
    --partitions 3 \
    --replication-factor 1 \
    --bootstrap-server localhost:9092
session: 1
```

Verify the topic:

```terminal:execute
command: |
  docker exec kafka kafka-topics --list \
    --bootstrap-server localhost:9092
session: 1
```

## Access Dashboards

You can now access the monitoring dashboards:

- **Kafka UI** - Click the "Kafka UI" tab above
- **Prometheus** - Click the "Prometheus" tab above
- **Grafana** - Click the "Grafana" tab above

## Generate Sample Data

Let's start a simple data generator in the background:

```terminal:execute
command: |
  chmod +x generators/*.sh
  nohup ./generators/simple-producer.sh monitoring-demo 5 > producer.log 2>&1 &
  echo "Producer started (5 msg/sec)"
session: 2
```

## Verify Data Flow

Check that messages are being produced:

```terminal:execute
command: |
  docker exec kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic monitoring-demo \
    --from-beginning \
    --max-messages 5
session: 1
```

Perfect! Your monitoring environment is ready. Let's explore Kafka monitoring with CLI tools!
