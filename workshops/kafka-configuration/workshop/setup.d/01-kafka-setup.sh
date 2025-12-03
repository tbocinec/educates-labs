#!/bin/bash

set -e

echo "🚀 Starting Kafka Configuration Workshop setup..."

# Start Docker Compose services
echo "📦 Starting Kafka and Kafka UI services..."
cd /home/eduk8s
docker compose up -d

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka to be ready..."
timeout=60
counter=0

while ! docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 >/dev/null 2>&1; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout waiting for Kafka to start"
        exit 1
    fi
    echo "⏳ Kafka not ready yet, waiting... ($counter/$timeout)"
    sleep 2
    counter=$((counter + 2))
done

echo "✅ Kafka is ready!"

# Wait for Kafka UI to be ready
echo "⏳ Waiting for Kafka UI to be ready..."
timeout=30
counter=0

while ! curl -sf http://localhost:8080/actuator/health >/dev/null 2>&1; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout waiting for Kafka UI to start"
        exit 1
    fi
    echo "⏳ Kafka UI not ready yet, waiting... ($counter/$timeout)"
    sleep 2
    counter=$((counter + 2))
done

echo "✅ Kafka UI is ready!"

# Create configuration examples directory
echo "📁 Creating configuration examples..."
docker exec kafka mkdir -p /opt/kafka/config-examples

# Create sample configuration files
echo "📄 Creating sample configuration files..."

# Broker configuration examples
docker exec kafka tee /opt/kafka/config-examples/broker-high-throughput.properties << 'EOF'
# High Throughput Broker Configuration
num.network.threads=8
num.io.threads=16
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.segment.bytes=1073741824
log.retention.hours=168
log.cleanup.policy=delete
compression.type=lz4
EOF

# Producer configuration examples
docker exec kafka tee /opt/kafka/config-examples/producer-performance.properties << 'EOF'
# High Performance Producer Configuration
bootstrap.servers=localhost:9092
acks=1
retries=2147483647
max.in.flight.requests.per.connection=1
compression.type=lz4
batch.size=32768
linger.ms=5
buffer.memory=67108864
EOF

# Consumer configuration examples  
docker exec kafka tee /opt/kafka/config-examples/consumer-performance.properties << 'EOF'
# High Performance Consumer Configuration
bootstrap.servers=localhost:9092
group.id=performance-group
enable.auto.commit=false
fetch.min.bytes=1024
fetch.max.wait.ms=500
max.poll.records=1000
session.timeout.ms=30000
heartbeat.interval.ms=10000
EOF

# Topic configuration examples
docker exec kafka tee /opt/kafka/config-examples/topic-configs.json << 'EOF'
{
  "high-throughput": {
    "partitions": 6,
    "replication-factor": 1,
    "config": {
      "compression.type": "lz4",
      "retention.ms": "604800000",
      "segment.bytes": "104857600"
    }
  },
  "low-latency": {
    "partitions": 1,
    "replication-factor": 1,
    "config": {
      "compression.type": "none",
      "min.insync.replicas": "1",
      "unclean.leader.election.enable": "false"
    }
  },
  "compacted": {
    "partitions": 3,
    "replication-factor": 1,
    "config": {
      "cleanup.policy": "compact",
      "min.cleanable.dirty.ratio": "0.1",
      "delete.retention.ms": "86400000"
    }
  }
}
EOF

echo "✅ Configuration examples created!"
echo ""
echo "🎯 Kafka Configuration Workshop is ready!"
echo "   • Kafka broker: localhost:9092"
echo "   • Kafka UI: http://localhost:8080 (Dashboard tab)"
echo "   • Configuration examples: /opt/kafka/config-examples/"
echo ""
echo "🚀 Ready to explore Kafka configuration!"