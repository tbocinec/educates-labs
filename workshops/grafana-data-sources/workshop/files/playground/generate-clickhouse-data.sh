#!/bin/bash

echo "🚀 Starting data generation for ClickHouse..."

# Create sample datasets
docker exec -i clickhouse clickhouse-client --user admin --password admin << 'EOF'

-- Create databases
CREATE DATABASE IF NOT EXISTS analytics;
CREATE DATABASE IF NOT EXISTS metrics;
CREATE DATABASE IF NOT EXISTS logs;

-- Web Analytics Table
CREATE TABLE IF NOT EXISTS analytics.page_views (
    event_time DateTime,
    user_id UInt32,
    session_id String,
    page_url String,
    referrer String,
    duration_seconds UInt32,
    country String,
    city String,
    device String,
    browser String,
    os String
) ENGINE = MergeTree()
ORDER BY (event_time, user_id);

-- E-commerce Sales Table
CREATE TABLE IF NOT EXISTS analytics.sales (
    sale_time DateTime,
    order_id String,
    customer_id UInt32,
    product_name String,
    category String,
    quantity UInt16,
    price Float32,
    discount Float32,
    payment_method String,
    country String
) ENGINE = MergeTree()
ORDER BY (sale_time, customer_id);

-- System Metrics Table
CREATE TABLE IF NOT EXISTS metrics.system_stats (
    timestamp DateTime,
    hostname String,
    cpu_usage Float32,
    memory_usage Float32,
    disk_usage Float32,
    network_in_mbps Float32,
    network_out_mbps Float32
) ENGINE = MergeTree()
ORDER BY (timestamp, hostname);

-- Application Logs Table
CREATE TABLE IF NOT EXISTS logs.app_logs (
    timestamp DateTime,
    level String,
    service String,
    message String,
    error_code UInt16,
    duration_ms UInt32
) ENGINE = MergeTree()
ORDER BY timestamp;

EOF

echo "✅ Tables created successfully!"
echo ""
echo "📊 Generating sample data..."

# Generate web analytics data
docker exec -i clickhouse clickhouse-client --user admin --password admin << 'EOF'
INSERT INTO analytics.page_views 
SELECT
    now() - INTERVAL (number * 60) SECOND as event_time,
    (number % 1000) + 1 as user_id,
    concat('session_', toString(number % 500)) as session_id,
    arrayElement(['/home', '/products', '/about', '/blog', '/contact', '/checkout', '/cart'], (number % 7) + 1) as page_url,
    arrayElement(['google.com', 'facebook.com', 'direct', 'twitter.com', 'linkedin.com'], (number % 5) + 1) as referrer,
    (number % 300) + 10 as duration_seconds,
    arrayElement(['USA', 'UK', 'Germany', 'France', 'Spain', 'Italy', 'Canada', 'Australia', 'Japan'], (number % 9) + 1) as country,
    arrayElement(['New York', 'London', 'Berlin', 'Paris', 'Madrid', 'Rome', 'Toronto', 'Sydney', 'Tokyo'], (number % 9) + 1) as city,
    arrayElement(['desktop', 'mobile', 'tablet'], (number % 3) + 1) as device,
    arrayElement(['Chrome', 'Firefox', 'Safari', 'Edge', 'Opera'], (number % 5) + 1) as browser,
    arrayElement(['Windows', 'macOS', 'Linux', 'iOS', 'Android'], (number % 5) + 1) as os
FROM numbers(1000);
EOF

# Generate sales data
docker exec -i clickhouse clickhouse-client --user admin --password admin << 'EOF'
INSERT INTO analytics.sales
SELECT
    now() - INTERVAL (number * 120) SECOND as sale_time,
    concat('ORDER_', toString(number)) as order_id,
    (number % 500) + 1 as customer_id,
    arrayElement(['Laptop', 'Smartphone', 'Tablet', 'Headphones', 'Mouse', 'Keyboard', 'Monitor', 'Camera'], (number % 8) + 1) as product_name,
    arrayElement(['Electronics', 'Accessories', 'Gaming', 'Office'], (number % 4) + 1) as category,
    (number % 5) + 1 as quantity,
    (number % 1000) + 50 as price,
    (number % 30) as discount,
    arrayElement(['Credit Card', 'PayPal', 'Bank Transfer', 'Cash'], (number % 4) + 1) as payment_method,
    arrayElement(['USA', 'UK', 'Germany', 'France', 'Spain'], (number % 5) + 1) as country
FROM numbers(500);
EOF

# Generate system metrics
docker exec -i clickhouse clickhouse-client --user admin --password admin << 'EOF'
INSERT INTO metrics.system_stats
SELECT
    now() - INTERVAL (number * 30) SECOND as timestamp,
    arrayElement(['web-server-01', 'web-server-02', 'db-server-01', 'cache-server-01'], (number % 4) + 1) as hostname,
    (rand() % 100) / 100.0 as cpu_usage,
    (rand() % 100) / 100.0 as memory_usage,
    (rand() % 100) / 100.0 as disk_usage,
    (rand() % 1000) / 10.0 as network_in_mbps,
    (rand() % 500) / 10.0 as network_out_mbps
FROM numbers(2000);
EOF

# Generate application logs
docker exec -i clickhouse clickhouse-client --user admin --password admin << 'EOF'
INSERT INTO logs.app_logs
SELECT
    now() - INTERVAL (number * 10) SECOND as timestamp,
    arrayElement(['INFO', 'WARN', 'ERROR', 'DEBUG'], (number % 4) + 1) as level,
    arrayElement(['api-gateway', 'auth-service', 'payment-service', 'notification-service'], (number % 4) + 1) as service,
    concat('Log message ', toString(number)) as message,
    (number % 600) as error_code,
    (number % 5000) + 10 as duration_ms
FROM numbers(1000);
EOF

echo ""
echo "✅ Sample data generated successfully!"
echo ""
echo "📈 Data Summary:"
docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT 'Page Views: ' || toString(count()) FROM analytics.page_views"
docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT 'Sales Records: ' || toString(count()) FROM analytics.sales"
docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT 'System Metrics: ' || toString(count()) FROM metrics.system_stats"
docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT 'Application Logs: ' || toString(count()) FROM logs.app_logs"
echo ""
echo "🎉 Ready to explore in Grafana!"
