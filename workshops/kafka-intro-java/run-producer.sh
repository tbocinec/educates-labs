#!/bin/bash

echo "🚀 Starting Kafka Producer..."
echo "📝 Sending 50 messages to 'test-messages' topic..."
echo ""

cd kafka-apps/producer
mvn exec:java -Dexec.mainClass="com.example.KafkaProducer"