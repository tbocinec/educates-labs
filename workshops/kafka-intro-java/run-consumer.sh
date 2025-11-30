#!/bin/bash

echo "📖 Starting Kafka Consumer..."
echo "🔄 Listening for messages from 'test-messages' topic..."
echo "💡 Press Ctrl+C to stop the consumer"
echo ""

cd kafka-apps/consumer
mvn exec:java -Dexec.mainClass="com.example.KafkaConsumer"