#!/bin/bash

echo "🌡️ Starting sensor data generation for InfluxDB..."

# InfluxDB Configuration
INFLUXDB_TOKEN="workshop-token-123456789"
INFLUXDB_ORG="workshop"
INFLUXDB_BUCKET="sensors"

echo "📊 Generating temperature and humidity data..."

# Generate data for the last 2 hours
for i in {1..120}; do
  TIMESTAMP=$(($(date +%s) - (120 - i) * 60))
  
  # Office sensors
  TEMP_OFFICE=$((22 + RANDOM % 8))  # 22-30°C
  HUMIDITY_OFFICE=$((45 + RANDOM % 25))  # 45-70%
  
  # Warehouse sensors
  TEMP_WAREHOUSE=$((18 + RANDOM % 12))  # 18-30°C
  HUMIDITY_WAREHOUSE=$((35 + RANDOM % 35))  # 35-70%
  
  # Conference room sensors
  TEMP_CONFERENCE=$((21 + RANDOM % 6))  # 21-27°C
  HUMIDITY_CONFERENCE=$((40 + RANDOM % 30))  # 40-70%
  
  # Server room sensors (cooler)
  TEMP_SERVER=$((16 + RANDOM % 8))  # 16-24°C
  HUMIDITY_SERVER=$((30 + RANDOM % 20))  # 30-50%
  
  docker exec influxdb influx write \
    --bucket "$INFLUXDB_BUCKET" \
    --org "$INFLUXDB_ORG" \
    --token "$INFLUXDB_TOKEN" \
    --precision s "
temperature,sensor=room1,location=office value=${TEMP_OFFICE} ${TIMESTAMP}
humidity,sensor=room1,location=office value=${HUMIDITY_OFFICE} ${TIMESTAMP}
temperature,sensor=room2,location=warehouse value=${TEMP_WAREHOUSE} ${TIMESTAMP}
humidity,sensor=room2,location=warehouse value=${HUMIDITY_WAREHOUSE} ${TIMESTAMP}
temperature,sensor=room3,location=conference value=${TEMP_CONFERENCE} ${TIMESTAMP}
humidity,sensor=room3,location=conference value=${HUMIDITY_CONFERENCE} ${TIMESTAMP}
temperature,sensor=room4,location=server value=${TEMP_SERVER} ${TIMESTAMP}
humidity,sensor=room4,location=server value=${HUMIDITY_SERVER} ${TIMESTAMP}
" 2>/dev/null
  
  # Progress indicator
  if (( i % 20 == 0 )); then
    echo "   Generated $i/120 data points..."
  fi
done

echo ""
echo "✅ Sensor data generation complete!"
echo ""
echo "📈 Data Summary:"
echo "  - Temperature readings: 4 locations × 120 points = 480 measurements"
echo "  - Humidity readings: 4 locations × 120 points = 480 measurements"
echo "  - Total: 960 sensor measurements over 2 hours"
echo ""
echo "📍 Locations:"
echo "  - Office (22-30°C, 45-70% humidity)"
echo "  - Warehouse (18-30°C, 35-70% humidity)"
echo "  - Conference Room (21-27°C, 40-70% humidity)"
echo "  - Server Room (16-24°C, 30-50% humidity)"
echo ""
echo "🎉 Ready to visualize in Grafana InfluxDB (port 3001)!"

# Verify data was inserted
echo "🔍 Verifying data insertion..."
TEMP_COUNT=$(docker exec influxdb influx query \
  --org "$INFLUXDB_ORG" \
  --token "$INFLUXDB_TOKEN" \
  'from(bucket:"sensors") |> range(start:-3h) |> filter(fn:(r) => r._measurement == "temperature") |> count()' \
  2>/dev/null | grep -o '[0-9]\+' | tail -1)

if [ ! -z "$TEMP_COUNT" ] && [ "$TEMP_COUNT" -gt 0 ]; then
  echo "✅ Successfully inserted $TEMP_COUNT temperature measurements"
else
  echo "⚠️  Warning: Could not verify data insertion"
fi