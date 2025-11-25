#!/bin/bash

echo "🐌 ALERT SCENARIO 3: Slow API Response Time"
echo "Simulating database connection pool exhaustion"
echo "Response time will degrade from 100ms to 2000ms"
echo "This should trigger: API Response Time > 500ms alert"
echo ""
echo "Duration: 3 minutes (18 data points, 10-second intervals)"
echo "Starting..."
echo ""

for i in {1..18}; do
  # Response time degrades from 100ms to 2000ms
  RESPONSE_TIME=$((100 + (i * 1900 / 18)))
  
  # Request success but slow
  STATUS=200
  
  # Generate 10 slow requests per iteration
  for j in {1..10}; do
    docker exec clickhouse clickhouse-client --user admin --password admin --query "
    INSERT INTO monitoring.api_metrics VALUES (
      now(),
      '/api/products',
      'GET',
      ${STATUS},
      ${RESPONSE_TIME},
      $((RANDOM % 1000 + 1)),
      'eu-west'
    )" 2>/dev/null
  done
  
  echo "📊 Writing: 10 requests with avg response time = ${RESPONSE_TIME}ms"
  
  if [ $i -eq 6 ]; then
    echo ""
    echo "⚠️  Response time reached 400ms - approaching threshold..."
    echo ""
  fi
  
  if [ $i -eq 9 ]; then
    echo ""
    echo "🚨 Response time reached 500ms - ALERT SHOULD TRIGGER!"
    echo ""
  fi
  
  if [ $i -eq 14 ]; then
    echo ""
    echo "🔴 CRITICAL: Response time > 1500ms - users experiencing timeouts!"
    echo ""
  fi
  
  sleep 10
done

echo ""
echo "✅ Alert scenario complete!"
echo "🐌 Peak response time: 2000ms (Alert threshold: > 500ms)"
echo ""
echo "Check Grafana Alerting page to see the triggered alert!"
echo "Alert rule to check: 'API Response Time High'"
