#!/bin/bash
set -e
echo "🔨 Building Kafka applications..."
echo ""
echo "📦 Building Producer..."
cd kafka-apps/producer
mvn clean package -q
echo "✅ Producer built"
echo ""
echo "📦 Building Consumer..."
cd ../consumer
mvn clean package -q
echo "✅ Consumer built"
echo ""
cd ../..
echo "🎉 Build complete!"