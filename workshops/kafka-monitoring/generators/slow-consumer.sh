#!/bin/bash
# Slow consumer - simulates consumer lag
# Usage: ./slow-consumer.sh <topic> <group-id> <delay-ms>

TOPIC=${1:-test-topic}
GROUP=${2:-slow-consumer-group}
DELAY=${3:-1000}

echo "Starting slow consumer for topic: $TOPIC, group: $GROUP"
echo "Processing delay: ${DELAY}ms per message"
echo "Press Ctrl+C to stop"

docker exec -i kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic "$TOPIC" \
    --group "$GROUP" \
    --from-beginning | while read line; do
    echo "Processed: $line"
    sleep $(awk "BEGIN {print $DELAY/1000}")
done
