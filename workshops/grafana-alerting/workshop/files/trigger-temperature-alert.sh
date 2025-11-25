#!/bin/bash

echo "🔥 ALERT SCENARIO 1: API Error Rate Spike"
echo "Simulating deployment issue causing server errors (500)"
echo "Error rate will spike from 2% to 35%"
echo "This should trigger: API Error Rate > 10% alert"
echo ""
echo "Duration: 3 minutes (18 data points, 10-second intervals)"
echo "Starting..."
echo ""

for i in {1..18}; do
  # Determine status code based on iteration
  if [ $i -le 5 ]; then
    # Normal: 95% success
    STATUS_RATIO=95
  elif [ $i -le 10 ]; then
    # Rising: 80% success (20% errors)
    STATUS_RATIO=80
  else
    # Peak: 65% success (35% errors)
    STATUS_RATIO=65
  fi
  
  # Generate 10 requests per iteration
  for j in {1..10}; do
    if [ $((RANDOM % 100)) -lt $STATUS_RATIO ]; then
      STATUS=200
      RESPONSE_TIME=$((50 + RANDOM % 100))
    else
      STATUS=500
      RESPONSE_TIME=$((500 + RANDOM % 1000))
    fi
    
    docker exec clickhouse clickhouse-client --user admin --password admin --query "
    INSERT INTO monitoring.api_metrics VALUES (
      now(),
      '/api/users',
      'GET',
      ${STATUS},
      ${RESPONSE_TIME},
      $((RANDOM % 1000 + 1)),
      'us-east'
    )" 2>/dev/null
  done
  
  ERROR_RATE=$((100 - STATUS_RATIO))
  echo "📊 Iteration $i: Generated 10 requests, ~${ERROR_RATE}% error rate"
  
  if [ $i -eq 7 ]; then
    echo ""
    echo "⚠️  Error rate reached ~20% - approaching threshold..."
    echo ""
  fi
  
  if [ $i -eq 9 ]; then
    echo ""
    echo "🚨 Error rate above 10% - ALERT SHOULD TRIGGER!"
    echo ""
  fi
  
  sleep 10
done

echo ""
echo "✅ Alert scenario complete!"
echo "🔥 Peak error rate: ~35% (Alert threshold: > 10%)"
echo ""
echo "Check Grafana Alerting page to see the triggered alert!"
echo "Alert rule to check: 'API Error Rate High'"

