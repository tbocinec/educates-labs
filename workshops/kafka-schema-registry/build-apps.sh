#!/bin/bash
set -e

echo "🔨 Building Kafka Schema Registry applications..."
echo ""

echo "📦 Building Avro Producer..."
cd kafka-apps/producer-avro/
mvn clean package -q
echo "✅ Avro Producer built"
echo ""

echo "📦 Building Avro Consumer..."
cd ../consumer-avro/
mvn clean package -q
echo "✅ Avro Consumer built"
echo ""

cd ../..
echo "🎉 Build complete! Producer and Consumer ready."
echo ""
echo "📁 JAR files created:"
echo "   • kafka-apps/producer-avro/target/producer-avro-1.0-SNAPSHOT.jar"
echo "   • kafka-apps/consumer-avro/target/consumer-avro-1.0-SNAPSHOT.jar"

