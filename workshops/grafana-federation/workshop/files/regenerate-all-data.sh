#!/bin/bash

echo "🔄 Regenerating all workshop data..."
echo ""

echo "🌡️ Regenerating sensor data..."
./generate-sensor-data.sh

echo ""
echo "💰 Regenerating business data..."
./generate-business-data.sh

echo ""
echo "✅ All data regenerated successfully!"
echo ""
echo "🎯 You can now:"
echo "  1. View sensor data in Grafana InfluxDB (port 3001)"
echo "  2. View business data in Grafana ClickHouse (port 3002)"
echo "  3. Create federated dashboards in Grafana Federation (port 3000)"