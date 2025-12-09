#!/bin/bash

echo "🚀 Starting Avro Producer with Schema Registry..."
echo ""

cd kafka-apps/producer-avro
java -jar target/producer-avro-1.0-SNAPSHOT.jar

