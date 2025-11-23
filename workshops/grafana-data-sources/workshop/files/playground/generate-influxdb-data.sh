#!/bin/bash

echo "🚀 Starting data generation for InfluxDB..."

# InfluxDB Configuration
INFLUXDB_TOKEN="mytoken123456789"
INFLUXDB_ORG="myorg"
INFLUXDB_BUCKET="mybucket"

echo "📊 Generating IoT sensor data..."

# Generate temperature and humidity data (last 2 hours)
for i in {1..120}; do
  TIMESTAMP=$(($(date +%s) - (120 - i) * 60))
  
  # Living Room Sensors
  TEMP_LIVING=$((20 + RANDOM % 8))
  HUMIDITY_LIVING=$((45 + RANDOM % 25))
  
  # Bedroom Sensors
  TEMP_BEDROOM=$((18 + RANDOM % 6))
  HUMIDITY_BEDROOM=$((50 + RANDOM % 20))
  
  # Kitchen Sensors
  TEMP_KITCHEN=$((22 + RANDOM % 10))
  HUMIDITY_KITCHEN=$((55 + RANDOM % 30))
  
  # Office Sensors
  TEMP_OFFICE=$((21 + RANDOM % 7))
  HUMIDITY_OFFICE=$((40 + RANDOM % 25))
  
  docker exec influxdb influx write \
    --bucket "$INFLUXDB_BUCKET" \
    --org "$INFLUXDB_ORG" \
    --token "$INFLUXDB_TOKEN" \
    --precision s "
temperature,room=living_room,sensor=temp_01 value=${TEMP_LIVING} ${TIMESTAMP}
humidity,room=living_room,sensor=hum_01 value=${HUMIDITY_LIVING} ${TIMESTAMP}
temperature,room=bedroom,sensor=temp_02 value=${TEMP_BEDROOM} ${TIMESTAMP}
humidity,room=bedroom,sensor=hum_02 value=${HUMIDITY_BEDROOM} ${TIMESTAMP}
temperature,room=kitchen,sensor=temp_03 value=${TEMP_KITCHEN} ${TIMESTAMP}
humidity,room=kitchen,sensor=hum_03 value=${HUMIDITY_KITCHEN} ${TIMESTAMP}
temperature,room=office,sensor=temp_04 value=${TEMP_OFFICE} ${TIMESTAMP}
humidity,room=office,sensor=hum_04 value=${HUMIDITY_OFFICE} ${TIMESTAMP}
" 2>/dev/null
done

echo "🌡️  Generating weather station data..."

# Generate weather data
for i in {1..120}; do
  TIMESTAMP=$(($(date +%s) - (120 - i) * 60))
  
  OUTDOOR_TEMP=$((15 + RANDOM % 15))
  PRESSURE=$((1000 + RANDOM % 40))
  WIND_SPEED=$((RANDOM % 30))
  RAIN=$((RANDOM % 10))
  
  docker exec influxdb influx write \
    --bucket "$INFLUXDB_BUCKET" \
    --org "$INFLUXDB_ORG" \
    --token "$INFLUXDB_TOKEN" \
    --precision s "
weather,location=outdoor,station=main temperature=${OUTDOOR_TEMP},pressure=${PRESSURE},wind_speed=${WIND_SPEED},rainfall=${RAIN} ${TIMESTAMP}
" 2>/dev/null
done

echo "⚡ Generating energy consumption data..."

# Generate power consumption data
for i in {1..120}; do
  TIMESTAMP=$(($(date +%s) - (120 - i) * 60))
  
  POWER_TOTAL=$((2000 + RANDOM % 3000))
  POWER_HVAC=$((800 + RANDOM % 1200))
  POWER_APPLIANCES=$((500 + RANDOM % 800))
  POWER_LIGHTING=$((200 + RANDOM % 300))
  VOLTAGE=$((220 + RANDOM % 20))
  CURRENT=$((POWER_TOTAL / 220))
  
  docker exec influxdb influx write \
    --bucket "$INFLUXDB_BUCKET" \
    --org "$INFLUXDB_ORG" \
    --token "$INFLUXDB_TOKEN" \
    --precision s "
energy,type=total,unit=watts consumption=${POWER_TOTAL},voltage=${VOLTAGE},current=${CURRENT} ${TIMESTAMP}
energy,type=hvac,unit=watts consumption=${POWER_HVAC} ${TIMESTAMP}
energy,type=appliances,unit=watts consumption=${POWER_APPLIANCES} ${TIMESTAMP}
energy,type=lighting,unit=watts consumption=${POWER_LIGHTING} ${TIMESTAMP}
" 2>/dev/null
done

echo "💧 Generating water quality data..."

# Generate water quality metrics
for i in {1..60}; do
  TIMESTAMP=$(($(date +%s) - (60 - i) * 120))
  
  PH=$((65 + RANDOM % 20))  # pH * 10 (6.5 - 8.5)
  TDS=$((100 + RANDOM % 300))  # Total Dissolved Solids
  TURBIDITY=$((RANDOM % 50))
  CHLORINE=$((5 + RANDOM % 15))  # mg/L * 10
  
  docker exec influxdb influx write \
    --bucket "$INFLUXDB_BUCKET" \
    --org "$INFLUXDB_ORG" \
    --token "$INFLUXDB_TOKEN" \
    --precision s "
water_quality,location=main_tank,sensor=wq_01 ph=${PH},tds=${TDS},turbidity=${TURBIDITY},chlorine=${CHLORINE} ${TIMESTAMP}
" 2>/dev/null
done

echo "🏭 Generating industrial sensor data..."

# Generate industrial machine metrics
for i in {1..120}; do
  TIMESTAMP=$(($(date +%s) - (120 - i) * 60))
  
  # Machine A
  MACHINE_A_TEMP=$((60 + RANDOM % 40))
  MACHINE_A_VIBRATION=$((RANDOM % 100))
  MACHINE_A_RPM=$((1000 + RANDOM % 2000))
  MACHINE_A_PRESSURE=$((80 + RANDOM % 40))
  
  # Machine B
  MACHINE_B_TEMP=$((65 + RANDOM % 35))
  MACHINE_B_VIBRATION=$((RANDOM % 100))
  MACHINE_B_RPM=$((1200 + RANDOM % 1800))
  MACHINE_B_PRESSURE=$((85 + RANDOM % 35))
  
  docker exec influxdb influx write \
    --bucket "$INFLUXDB_BUCKET" \
    --org "$INFLUXDB_ORG" \
    --token "$INFLUXDB_TOKEN" \
    --precision s "
machine,name=machine_a,type=press temperature=${MACHINE_A_TEMP},vibration=${MACHINE_A_VIBRATION},rpm=${MACHINE_A_RPM},pressure=${MACHINE_A_PRESSURE} ${TIMESTAMP}
machine,name=machine_b,type=lathe temperature=${MACHINE_B_TEMP},vibration=${MACHINE_B_VIBRATION},rpm=${MACHINE_B_RPM},pressure=${MACHINE_B_PRESSURE} ${TIMESTAMP}
" 2>/dev/null
done

echo ""
echo "✅ InfluxDB data generation complete!"
echo ""
echo "📈 Data Summary:"
echo "  - IoT Sensors: 960 measurements (4 rooms × 2 metrics × 120 points)"
echo "  - Weather Station: 120 measurements"
echo "  - Energy Consumption: 480 measurements (4 types × 120 points)"
echo "  - Water Quality: 60 measurements"
echo "  - Industrial Machines: 240 measurements (2 machines × 120 points)"
echo ""
echo "Total: ~1,860 data points across multiple measurements"
echo ""
echo "🎉 Ready to visualize in Grafana!"
