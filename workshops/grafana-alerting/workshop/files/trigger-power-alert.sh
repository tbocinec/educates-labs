#!/bin/bash

echo "🔥 ALERT SCENARIO 2: High API Error Rate (Alternative)"
echo "Simulating database timeout causing elevated 500 errors"
echo "Error rate will spike from 5% to 40%"
echo "This should trigger: API Error Rate > 10% alert"
echo ""
echo "Duration: 3 minutes (18 data points, 10-second intervals)"
echo "Starting..."
echo ""

for i in {1..18}; do
  # Determine error ratio based on iteration
  if [ $i -le 5 ]; then
    # Normal: 95% success
    ERROR_RATIO=5
  elif [ $i -le 10 ]; then
    # Rising: 75% success (25% errors)
    ERROR_RATIO=25
  else
    # Peak: 60% success (40% errors)
    ERROR_RATIO=40
  fi
  
  # Generate 10 requests per iteration to /api/checkout endpoint
  for j in {1..10}; do
    if [ $((RANDOM % 100)) -lt $ERROR_RATIO ]; then
      STATUS=500
      RESPONSE_TIME=$((800 + RANDOM % 1200))
    else
      STATUS=200
      RESPONSE_TIME=$((80 + RANDOM % 120))
    fi
    
    docker exec clickhouse clickhouse-client --user admin --password admin --query "
    INSERT INTO monitoring.api_metrics VALUES (
      now(),
      '/api/checkout',
      'POST',
      ${STATUS},
      ${RESPONSE_TIME},
      $((RANDOM % 1000 + 1)),
      'eu-west'
    )" 2>/dev/null
  done
  
  SUCCESS_RATIO=$((100 - ERROR_RATIO))
  echo "📊 Iteration $i: Generated 10 checkout requests, ~${SUCCESS_RATIO}% success rate"
  
  if [ $i -eq 7 ]; then
    echo ""
    echo "⚠️  Error rate reached ~25% - approaching threshold..."
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
echo "🔥 Peak error rate: ~40% (Alert threshold: > 10%)"
echo ""
echo "Check Grafana Alerting page to see the triggered alert!"
echo "Alert rule to check: 'API Error Rate High' for /api/checkout endpoint"
