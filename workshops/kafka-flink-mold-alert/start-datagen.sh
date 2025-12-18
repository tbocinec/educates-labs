#!/bin/bash

echo "📡 Starting Humidity Sensor Data Generator..."

echo "⏳ Waiting for Kafka Connect to be ready..."
until curl -s http://localhost:8083/ > /dev/null; do
    echo "   Waiting for Kafka Connect..."
    sleep 3
done

echo "✅ Kafka Connect is ready!"
echo ""
echo "🔧 Registering Datagen Connector..."

# Get current timestamp in milliseconds
CURRENT_TIMESTAMP=$(date +%s)000

# Create a temporary config with current timestamp
TEMP_CONFIG=$(mktemp)
sed "s/\"start\":[0-9]*/\"start\":$CURRENT_TIMESTAMP/" schemas/datagen-connector.json > "$TEMP_CONFIG"

echo "⏰ Using current timestamp: $CURRENT_TIMESTAMP"

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @"$TEMP_CONFIG"

# Clean up temp file
rm -f "$TEMP_CONFIG"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Datagen connector registered!"
    echo "📊 Generating sensor data to 'raw_sensors' topic"
    echo "🔍 View connector status: http://localhost:8083/connectors/humidity-datagen-source/status"
else
    echo "❌ Failed to register connector"
    exit 1
fi

