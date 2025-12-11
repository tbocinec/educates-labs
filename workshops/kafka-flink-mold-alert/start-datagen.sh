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

curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @schemas/datagen-connector.json

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Datagen connector registered!"
    echo "📊 Generating sensor data to 'raw_sensors' topic"
    echo "🔍 View connector status: http://localhost:8083/connectors/humidity-datagen-source/status"
else
    echo "❌ Failed to register connector"
    exit 1
fi

