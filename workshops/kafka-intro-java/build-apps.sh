#!/bin/bash

echo "🔨 Building Kafka Producer..."
cd kafka-apps/producer/
mvn clean compile
echo "✅ Producer compiled!"

echo ""
echo "🔨 Building Kafka Consumer..."
cd ../consumer/
mvn clean compile
echo "✅ Consumer compiled!"

echo ""
echo "🎉 All Java applications built successfully!"