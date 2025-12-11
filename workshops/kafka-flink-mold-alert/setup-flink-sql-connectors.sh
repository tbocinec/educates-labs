#!/bin/bash

echo "📦 Downloading Flink Kafka Connectors..."

# Configuration
CONNECTOR_VERSION="3.1.0-1.18"
CONNECTOR_DIR="flink-connectors"

# Create connectors directory
echo ""
echo "📁 Creating ${CONNECTOR_DIR} directory..."
mkdir -p "${CONNECTOR_DIR}"
echo "✅ Directory created: ${CONNECTOR_DIR}"

# Download Flink SQL Kafka Connector
echo ""
echo "⏬ Downloading Flink SQL Kafka Connector..."
SQL_CONNECTOR_JAR="flink-sql-connector-kafka-${CONNECTOR_VERSION}.jar"
SQL_CONNECTOR_PATH="${CONNECTOR_DIR}/${SQL_CONNECTOR_JAR}"
SQL_CONNECTOR_URL="https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/${CONNECTOR_VERSION}/${SQL_CONNECTOR_JAR}"

if [ ! -f "${SQL_CONNECTOR_PATH}" ]; then
    curl -L -o "${SQL_CONNECTOR_PATH}" "${SQL_CONNECTOR_URL}"
    if [ $? -eq 0 ]; then
        echo "✅ Downloaded: ${SQL_CONNECTOR_JAR}"
        echo "   Location: ${SQL_CONNECTOR_PATH}"
        echo "   Size: $(ls -lh "${SQL_CONNECTOR_PATH}" | awk '{print $5}')"
    else
        echo "❌ Failed to download SQL connector"
        exit 1
    fi
else
    echo "✅ SQL connector already exists: ${SQL_CONNECTOR_PATH}"
fi

# Download Flink Kafka Connector (base library)
echo ""
echo "⏬ Downloading Flink Kafka Connector (base)..."
BASE_CONNECTOR_JAR="flink-connector-kafka-${CONNECTOR_VERSION}.jar"
BASE_CONNECTOR_PATH="${CONNECTOR_DIR}/${BASE_CONNECTOR_JAR}"
BASE_CONNECTOR_URL="https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-kafka/${CONNECTOR_VERSION}/${BASE_CONNECTOR_JAR}"

if [ ! -f "${BASE_CONNECTOR_PATH}" ]; then
    curl -L -o "${BASE_CONNECTOR_PATH}" "${BASE_CONNECTOR_URL}"
    if [ $? -eq 0 ]; then
        echo "✅ Downloaded: ${BASE_CONNECTOR_JAR}"
        echo "   Location: ${BASE_CONNECTOR_PATH}"
        echo "   Size: $(ls -lh "${BASE_CONNECTOR_PATH}" | awk '{print $5}')"
    else
        echo "❌ Failed to download base connector"
        exit 1
    fi
else
    echo "✅ Base connector already exists: ${BASE_CONNECTOR_PATH}"
fi

# Summary
echo ""
echo "✅ Download complete!"
echo ""
echo "📋 Downloaded files:"
ls -lh "${CONNECTOR_DIR}"/*.jar 2>/dev/null || echo "   No JAR files found"
echo ""
echo "📂 Connectors location: ${CONNECTOR_DIR}/"
