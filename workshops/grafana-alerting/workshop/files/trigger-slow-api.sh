#!/bin/bash

echo "🐌 ALERT SCENARIO: Slow API Response Time"
echo "Simulating database performance degradation"
echo "Response time will spike from 100ms to 2000ms"
echo "This should trigger: API Response Time High (> 500ms) alert"
echo ""
echo "Duration: 3 minutes (18 data points, 10-second intervals)"
echo "Starting..."
echo ""

for i in {1..18}; do
  # Response time increases from ~100ms to 2000ms
  if [ $i -le 5 ]; then
    # Normal: 100-150ms (baseline)
    RESPONSE_TIME_MS=$((100 + RANDOM % 50))
  elif [ $i -le 10 ]; then
    # Rising: 300-400ms
    RESPONSE_TIME_MS=$((300 + RANDOM % 100))
  elif [ $i -le 12 ]; then
    # Crossing threshold: 500-600ms
    RESPONSE_TIME_MS=$((500 + RANDOM % 100))
  elif [ $i -le 15 ]; then
    # Elevated: 1000-1500ms
    RESPONSE_TIME_MS=$((1000 + RANDOM % 500))
  else
    # Peak: 1500-2000ms
    RESPONSE_TIME_MS=$((1500 + RANDOM % 500))
  fi
  
  # Generate 10 API requests per iteration
  for j in {1..10}; do
    # Simulate status codes (95% success, 5% errors)
    if [ $((RANDOM % 100)) -lt 95 ]; then
      STATUS_CODE=200
    else
      STATUS_CODE=500
    fi
    
    docker exec clickhouse clickhouse-client --user admin --password admin --query "
    INSERT INTO monitoring.api_metrics VALUES (
      now(),
      '/api/products',
      'GET',
      ${STATUS_CODE},
      ${RESPONSE_TIME_MS},
      $(( (RANDOM % 1000) + 1 )),
      'us-east'
    )" 2>/dev/null
  done
  
  echo "📊 Iteration $i/18: Writing 10 requests, response_time: ${RESPONSE_TIME_MS}ms"
  
  if [ $i -eq 10 ]; then
    echo ""
    echo "⚠️  Response time crossed 400ms - approaching threshold..."
    echo ""
  fi
  
  if [ $i -eq 12 ]; then
    echo ""
    echo "🚨 Response time above 500ms - ALERT SHOULD TRIGGER!"
    echo ""
  fi
  
  sleep 10
done

echo ""
echo "✅ Alert scenario complete!"
echo "🐌 Peak response time: ~2000ms (Alert threshold: > 500ms)"
echo ""
echo "Check Grafana Alerting page to see the triggered alert!"
echo "Alert rule to check: 'API Response Time High'"
