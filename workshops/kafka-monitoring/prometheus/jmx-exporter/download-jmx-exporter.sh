#!/bin/bash
# Download JMX Prometheus Java Agent
# This should be run during workshop setup

cd "$(dirname "$0")"
EXPORTER_VERSION="0.20.0"
EXPORTER_JAR="jmx_prometheus_javaagent-${EXPORTER_VERSION}.jar"

if [ ! -f "${EXPORTER_JAR}" ]; then
    echo "Downloading JMX Prometheus Java Agent ${EXPORTER_VERSION}..."
    curl -L "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${EXPORTER_VERSION}/${EXPORTER_JAR}" \
        -o "${EXPORTER_JAR}"
    echo "Downloaded ${EXPORTER_JAR}"
else
    echo "${EXPORTER_JAR} already exists"
fi
