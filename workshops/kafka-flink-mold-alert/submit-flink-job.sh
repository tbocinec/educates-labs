#!/bin/bash

echo "🚀 Deploying Mold Alert Job to Flink..."

JAR_PATH="flink-app/target/mold-alert-flink-1.0.0.jar"

if [ ! -f "$JAR_PATH" ]; then
    echo "❌ JAR file not found at $JAR_PATH"
    echo "💡 Run ./build-flink-job.sh first"
    exit 1
fi

echo "📤 Copying JAR to Flink JobManager..."
docker cp "$JAR_PATH" flink-jobmanager:/tmp/mold-alert-flink.jar

echo "🎯 Submitting job to Flink..."
docker exec flink-jobmanager flink run \
    -d \
    /tmp/mold-alert-flink.jar

if [ $? -eq 0 ]; then
    echo "✅ Job submitted successfully!"
    echo "🌐 View job status at: http://localhost:8081"
else
    echo "❌ Job submission failed!"
    exit 1
fi

