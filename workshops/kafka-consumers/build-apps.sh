#!/bin/bash
set -e

echo "🔨 Building all Kafka applications..."
echo ""

echo "📦 Building Producer..."
cd kafka-apps/producer
mvn clean package -q
echo "✅ Producer built successfully"
echo ""

echo "📦 Building Basic Consumer..."
cd ../consumer-basic
mvn clean package -q
echo "✅ Basic Consumer built successfully"
echo ""

echo "📦 Building Manual Commit Consumer..."
cd ../consumer-manual
mvn clean package -q
echo "✅ Manual Commit Consumer built successfully"
echo ""

echo "📦 Building Multithreaded Consumer..."
cd ../consumer-multithreaded
mvn clean package -q
echo "✅ Multithreaded Consumer built successfully"
echo ""

cd ../..
echo "🎉 All applications built successfully!"

