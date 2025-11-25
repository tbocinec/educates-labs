#!/bin/bash

echo "🚀 Starting baseline data generation for ClickHouse..."
echo "This creates normal operating conditions for the past 2 hours"
echo ""

# Wait for ClickHouse to be ready
echo "⏳ Waiting for ClickHouse to be ready..."
sleep 5

# Create databases and tables
echo "📦 Creating databases and tables..."
docker exec -i clickhouse clickhouse-client --user admin --password admin << 'EOF'
-- Create monitoring database
CREATE DATABASE IF NOT EXISTS monitoring;

-- API Performance Metrics Table
CREATE TABLE IF NOT EXISTS monitoring.api_metrics (
    timestamp DateTime,
    endpoint String,
    method String,
    status_code UInt16,
    response_time_ms UInt32,
    user_id Nullable(UInt32),
    region String
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (timestamp, endpoint, method);

-- Application Logs Table
CREATE TABLE IF NOT EXISTS monitoring.application_logs (
    timestamp DateTime,
    level String,
    service String,
    message String,
    error_code Nullable(UInt16),
    duration_ms UInt32
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (timestamp, service, level);

-- Business Transactions Table
CREATE TABLE IF NOT EXISTS monitoring.transactions (
    created_at DateTime,
    transaction_id String,
    amount Decimal(10,2),
    status String,
    payment_method String,
    country String,
    processing_time_ms UInt32
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(created_at)
ORDER BY created_at;
EOF

echo "✅ Tables created successfully!"
echo ""

# Generate API metrics - normal conditions (last 2 hours)
echo "📊 Generating API metrics (normal operations)..."
docker exec clickhouse clickhouse-client --user admin --password admin --query "
INSERT INTO monitoring.api_metrics
SELECT 
    now() - (number * 60) as timestamp,
    arrayElement(['/api/users', '/api/products', '/api/orders', '/api/checkout'], (number % 4) + 1) as endpoint,
    arrayElement(['GET', 'POST', 'PUT'], (number % 3) + 1) as method,
    -- Normal: 95% success (200), 3% client errors (400), 2% server errors (500)
    CASE 
        WHEN number % 100 < 95 THEN 200
        WHEN number % 100 < 98 THEN 400
        ELSE 500
    END as status_code,
    -- Normal response time: 50-150ms
    50 + (rand() % 100) as response_time_ms,
    (number % 1000) + 1 as user_id,
    arrayElement(['us-east', 'eu-west', 'ap-south'], (number % 3) + 1) as region
FROM numbers(120);
"

echo "✅ API metrics: 120 data points"

# Generate application logs - normal error rate
echo "📝 Generating application logs..."
docker exec clickhouse clickhouse-client --user admin --password admin --query "
INSERT INTO monitoring.application_logs
SELECT 
    now() - (number * 60) as timestamp,
    -- Normal: 85% INFO, 10% WARN, 5% ERROR
    CASE 
        WHEN number % 100 < 85 THEN 'INFO'
        WHEN number % 100 < 95 THEN 'WARN'
        ELSE 'ERROR'
    END as level,
    arrayElement(['api-gateway', 'auth-service', 'payment-service'], (number % 3) + 1) as service,
    concat('Log message ', toString(number)) as message,
    CASE WHEN number % 100 >= 95 THEN (number % 500) + 400 ELSE NULL END as error_code,
    (rand() % 200) + 50 as duration_ms
FROM numbers(120);
"

echo "✅ Application logs: 120 log entries"

# Server metrics - commented out to simplify workshop
# echo "💻 Generating server metrics..."
# docker exec clickhouse clickhouse-client --user admin --password admin --query "
# INSERT INTO monitoring.server_metrics
# SELECT 
#     now() - (number * 60) as timestamp,
#     arrayElement(['web-server-01', 'web-server-02', 'db-server-01'], (number % 3) + 1) as hostname,
#     30 + (rand() % 30) as cpu_percent,
#     40 + (rand() % 30) as memory_percent,
#     50 + (rand() % 25) as disk_percent,
#     10 + (rand() % 40) as network_in_mbps,
#     5 + (rand() % 25) as network_out_mbps
# FROM numbers(120);
# "
# echo "✅ Server metrics: 120 data points"

# Generate business transactions - normal success rate
echo "💳 Generating transaction data..."
docker exec clickhouse clickhouse-client --user admin --password admin --query "
INSERT INTO monitoring.transactions
SELECT 
    now() - (number * 120) as created_at,
    concat('TXN-', toString(number)) as transaction_id,
    (rand() % 50000) / 100 as amount,
    -- Normal: 97% success, 3% failed
    CASE WHEN number % 100 < 97 THEN 'success' ELSE 'failed' END as status,
    arrayElement(['credit_card', 'paypal', 'bank_transfer'], (number % 3) + 1) as payment_method,
    arrayElement(['USA', 'UK', 'Germany', 'France'], (number % 4) + 1) as country,
    -- Normal processing: 100-500ms
    100 + (rand() % 400) as processing_time_ms
FROM numbers(60);
"

echo "✅ Transactions: 60 records"

echo ""
echo "✅ Baseline data generation complete!"
echo ""
echo "📈 Data Summary:"
echo "  - API Metrics: 120 requests (95% success, 5% errors)"
echo "  - Application Logs: 120 entries (85% INFO, 10% WARN, 5% ERROR)"
echo "  - Server Metrics: 120 measurements (3 servers × 40 data points)"
echo "  - Transactions: 60 transactions (97% success, 3% failed)"
echo ""
echo "Total: ~420 baseline data points across 2 hours"
echo ""
echo "✨ Ready to configure alerts in Grafana!"

