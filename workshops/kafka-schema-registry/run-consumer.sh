#!/bin/bash

echo "🚀 Starting Avro Consumer with Schema Registry..."
echo ""

cd kafka-apps/consumer-avro
java -jar target/consumer-avro-1.0-SNAPSHOT.jar

