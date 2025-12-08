#!/bin/bash
# Simple producer that generates continuous messages
# Usage: ./simple-producer.sh <topic> <messages-per-second>

TOPIC=${1:-test-topic}
RATE=${2:-10}

echo "Starting producer for topic: $TOPIC at $RATE msg/sec"
echo "Press Ctrl+C to stop"

while true; do
    TIMESTAMP=$(date +%s%3N)
    MESSAGE="{\"timestamp\":$TIMESTAMP,\"value\":$RANDOM,\"host\":\"generator-1\"}"
    echo "$MESSAGE" | docker exec -i kafka kafka-console-producer \
        --bootstrap-server localhost:9092 \
        --topic "$TOPIC" > /dev/null 2>&1
    
    sleep $(awk "BEGIN {print 1/$RATE}")
done
