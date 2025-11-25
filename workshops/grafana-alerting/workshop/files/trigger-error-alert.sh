#!/bin/bash

echo "💳 ALERT SCENARIO 4: Failed Transactions Spike"
echo "Simulating payment gateway issue"
echo "Transaction failure rate will spike from 3% to 30%"
echo "This should trigger: Transaction Failure Rate > 10% alert"
echo ""
echo "Duration: 3 minutes (18 data points, 10-second intervals)"
echo "Starting..."
echo ""

for i in {1..18}; do
  # Failure rate increases from 3% to 30%
  if [ $i -le 5 ]; then
    # Normal: 97% success
    FAILURE_RATIO=3
  elif [ $i -le 10 ]; then
    # Rising: 85% success (15% failures)
    FAILURE_RATIO=15
  else
    # Peak: 70% success (30% failures)
    FAILURE_RATIO=30
  fi
  
  # Generate 5 transactions per iteration
  for j in {1..5}; do
    if [ $((RANDOM % 100)) -lt $FAILURE_RATIO ]; then
      STATUS='failed'
      AMOUNT=0
      ERROR_CODE="'payment_declined'"
    else
      STATUS='success'
      AMOUNT=$((50 + RANDOM % 450))
      ERROR_CODE="NULL"
    fi
    
    docker exec clickhouse clickhouse-client --user admin --password admin --query "
    INSERT INTO monitoring.transactions VALUES (
      now(),
      'txn_' || toString(rand()),
      'user_' || toString(1000 + (rand() % 100)),
      ${AMOUNT},
      '${STATUS}',
      ${ERROR_CODE}
    )" 2>/dev/null
  done
  
  SUCCESS_RATIO=$((100 - FAILURE_RATIO))
  echo "📊 Writing: 5 transactions, ~${SUCCESS_RATIO}% success rate"
  
  if [ $i -eq 7 ]; then
    echo ""
    echo "⚠️  Failure rate reached 15% - approaching threshold..."
    echo ""
  fi
  
  if [ $i -eq 9 ]; then
    echo ""
    echo "🚨 Failure rate above 10% - ALERT SHOULD TRIGGER!"
    echo ""
  fi
  
  sleep 10
done

echo ""
echo "✅ Alert scenario complete!"
echo "💳 Peak failure rate: ~30% (Alert threshold: > 10%)"
echo ""
echo "Check Grafana Alerting page to see the triggered alert!"
echo "Alert rule to check: 'Transaction Failure Rate High'"
