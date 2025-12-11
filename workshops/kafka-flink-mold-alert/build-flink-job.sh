#!/bin/bash

echo "🏗️  Building Flink Mold Alert Job..."

cd flink-app

echo "📦 Running Maven package..."
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📄 JAR location: flink-app/target/mold-alert-flink-1.0.0.jar"
else
    echo "❌ Build failed!"
    exit 1
fi

