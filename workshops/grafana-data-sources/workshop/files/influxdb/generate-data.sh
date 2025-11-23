#!/bin/bash

# InfluxDB Configuration
INFLUXDB_TOKEN="${INFLUXDB_TOKEN:-mytoken123456789}"
INFLUXDB_ORG="${INFLUXDB_ORG:-myorg}"
INFLUXDB_BUCKET="${INFLUXDB_BUCKET:-mybucket}"

# Write sample temperature data
for i in {1..50}; do
  TEMP=$((20 + RANDOM % 10))
  HUMIDITY=$((50 + RANDOM % 30))
  
  docker exec influxdb influx write \
    --bucket "$INFLUXDB_BUCKET" \
    --org "$INFLUXDB_ORG" \
    --token "$INFLUXDB_TOKEN" \
    --precision s \
    "temperature,sensor=sensor1,location=office value=${TEMP}"
  
  docker exec influxdb influx write \
    --bucket "$INFLUXDB_BUCKET" \
    --org "$INFLUXDB_ORG" \
    --token "$INFLUXDB_TOKEN" \
    --precision s \
    "humidity,sensor=sensor1,location=office value=${HUMIDITY}"
  
  sleep 2
done &
