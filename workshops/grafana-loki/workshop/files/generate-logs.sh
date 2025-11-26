#!/bin/bash

echo "📝 Starting log generation..."
echo "Sending logs to Loki at localhost:3100"
echo ""

# Simulate application logs
for i in {1..50}; do
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000000Z")
  
  # Generate different log levels
  if [ $((i % 10)) -eq 0 ]; then
    LEVEL="ERROR"
    MESSAGE="Database connection timeout after 30s"
  elif [ $((i % 5)) -eq 0 ]; then
    LEVEL="WARN"
    MESSAGE="Slow query detected: 2500ms"
  else
    LEVEL="INFO"
    MESSAGE="Request completed successfully"
  fi
  
  SERVICE="api-server"
  REQUEST_ID="req_$(printf '%05d' $i)"
  RESPONSE_TIME=$((50 + RANDOM % 2000))
  
  # Send to Loki
  curl -s -X POST "http://localhost:3100/loki/api/v1/push" \
    -H "Content-Type: application/json" \
    -d @- <<EOF
{
  "streams": [
    {
      "stream": {
        "job": "application",
        "service": "${SERVICE}",
        "level": "${LEVEL}"
      },
      "values": [
        [
          "$(date +%s%N)",
          "${TIMESTAMP} [${LEVEL}] ${MESSAGE} (${RESPONSE_TIME}ms, ${REQUEST_ID})"
        ]
      ]
    }
  ]
}
EOF
  
  echo "✓ Log $i/$50 - $LEVEL: $MESSAGE"
  sleep 0.5
done

echo ""
echo "✅ Log generation complete!"
echo "📊 Visit Grafana at http://localhost:3000"
echo "   Username: admin"
echo "   Password: admin"
