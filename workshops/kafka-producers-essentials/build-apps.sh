#!/bin/bash
set -e

echo "🔨 Building Kafka Producer applications..."
echo ""

echo "📦 Building Basic Producer..."
cd kafka-apps/producer-basic/
mvn clean package -q
echo "✅ Basic Producer built"
echo ""

echo "📦 Building Callback Producer..."
cd ../producer-callback/
mvn clean package -q
echo "✅ Callback Producer built"
echo ""

echo "📦 Building Sync Producer..."
cd ../producer-sync/
mvn clean package -q
echo "✅ Sync Producer built"
echo ""

cd ../..
echo "🎉 Build complete! All producers ready."

