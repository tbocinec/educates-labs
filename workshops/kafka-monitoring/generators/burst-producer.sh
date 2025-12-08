#!/bin/bash
# Burst traffic generator - simulates traffic spikes
# Usage: ./burst-producer.sh <topic>

TOPIC=${1:-test-topic}

echo "Starting burst traffic generator for topic: $TOPIC"
echo "Press Ctrl+C to stop"

while true; do
    # Normal traffic for 30 seconds (5 msg/sec)
    echo "=== Normal traffic (5 msg/sec) ==="
    for i in {1..150}; do
        TIMESTAMP=$(date +%s%3N)
        MESSAGE="{\"timestamp\":$TIMESTAMP,\"value\":$RANDOM,\"phase\":\"normal\"}"
        echo "$MESSAGE" | docker exec -i kafka kafka-console-producer \
            --bootstrap-server localhost:9092 \
            --topic "$TOPIC" > /dev/null 2>&1
        sleep 0.2
    done
    
    # Burst traffic for 10 seconds (50 msg/sec)
    echo "=== BURST traffic (50 msg/sec) ==="
    for i in {1..500}; do
        TIMESTAMP=$(date +%s%3N)
        MESSAGE="{\"timestamp\":$TIMESTAMP,\"value\":$RANDOM,\"phase\":\"burst\"}"
        echo "$MESSAGE" | docker exec -i kafka kafka-console-producer \
            --bootstrap-server localhost:9092 \
            --topic "$TOPIC" > /dev/null 2>&1
        sleep 0.02
    done
    
    echo "Cycle complete. Repeating..."
done
