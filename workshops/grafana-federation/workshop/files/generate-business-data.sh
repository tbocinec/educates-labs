#!/bin/bash

echo "💰 Starting business data generation for ClickHouse..."

# Generate sample business data
docker exec -i clickhouse clickhouse-client --user admin --password admin << 'EOF'

-- Ensure database exists
CREATE DATABASE IF NOT EXISTS workshop;

USE workshop;

-- Clear existing data (optional)
TRUNCATE TABLE IF EXISTS sales;
TRUNCATE TABLE IF EXISTS website_stats;
TRUNCATE TABLE IF EXISTS performance;

-- Generate comprehensive sales data
INSERT INTO sales 
SELECT
    now() - INTERVAL (number * 300) SECOND as timestamp,  -- 5 minute intervals
    arrayElement(['Laptop', 'Desktop', 'Tablet', 'Phone', 'Monitor', 'Keyboard', 'Mouse', 'Headphones', 'Speaker', 'Camera'], (number % 10) + 1) as product,
    arrayElement(['Europe', 'North America', 'Asia', 'South America', 'Africa'], (number % 5) + 1) as region,
    (rand() % 2000) + 100 as amount,  -- $100-$2100
    (rand() % 5) + 1 as quantity,
    1000 + number as customer_id
FROM numbers(100);

-- Generate website analytics data
INSERT INTO website_stats
SELECT
    now() - INTERVAL (number * 60) SECOND as timestamp,  -- 1 minute intervals
    arrayElement(['/home', '/products', '/api/users', '/api/orders', '/checkout', '/login', '/api/payment'], (number % 7) + 1) as page_url,
    arrayElement(['Chrome/91.0', 'Firefox/89.0', 'Safari/14.1', 'Edge/91.0'], (number % 4) + 1) as user_agent,
    (rand() % 2000) + 50 as response_time_ms,  -- 50-2050ms
    arrayElement([200, 200, 200, 200, 404, 500, 503], (number % 7) + 1) as status_code,  -- Mostly 200s
    arrayElement(['US', 'UK', 'DE', 'FR', 'JP', 'CA', 'AU', 'BR', 'IN'], (number % 9) + 1) as user_country
FROM numbers(200);

-- Generate server performance data
INSERT INTO performance
SELECT
    now() - INTERVAL (number * 120) SECOND as timestamp,  -- 2 minute intervals
    arrayElement(['web-server-1', 'web-server-2', 'db-server-1', 'cache-server-1'], (number % 4) + 1) as server_name,
    (rand() % 8000) / 100.0 as cpu_usage,  -- 0-80%
    (rand() % 6000) + 1000 as memory_usage_mb,  -- 1000-7000 MB
    (rand() % 5000) / 100.0 as disk_usage_percent,  -- 0-50%
    (rand() % 20000) / 100.0 as network_io_mb  -- 0-200 MB
FROM numbers(150);

EOF

echo ""
echo "✅ Business data generation complete!"
echo ""
echo "📈 Data Summary:"

# Get actual counts from database
SALES_COUNT=$(docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT count() FROM workshop.sales" 2>/dev/null)
WEBSITE_COUNT=$(docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT count() FROM workshop.website_stats" 2>/dev/null)
PERF_COUNT=$(docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT count() FROM workshop.performance" 2>/dev/null)

echo "  - Sales records: ${SALES_COUNT:-0} transactions"
echo "  - Website analytics: ${WEBSITE_COUNT:-0} requests"
echo "  - Server performance: ${PERF_COUNT:-0} metrics"
echo ""
echo "💰 Sales Data:"
echo "  - Products: Laptop, Desktop, Tablet, Phone, etc."
echo "  - Regions: Europe, North America, Asia, South America, Africa"
echo "  - Amount range: $100-$2,100 per transaction"
echo ""
echo "🌐 Website Analytics:"
echo "  - Pages: /home, /products, /api/*, /checkout, etc."
echo "  - Response times: 50-2,050ms"
echo "  - Status codes: Mostly 200, some 404/500"
echo ""
echo "🖥️ Server Performance:"
echo "  - Servers: web-server-1/2, db-server-1, cache-server-1"
echo "  - CPU usage: 0-80%"
echo "  - Memory: 1-7 GB"
echo ""
echo "🎉 Ready to visualize in Grafana ClickHouse (port 3002)!"

# Show sample data
echo ""
echo "📊 Sample Sales Data:"
docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT product, region, amount FROM workshop.sales ORDER BY timestamp DESC LIMIT 5" 2>/dev/null

echo ""
echo "📊 Sample Website Stats:"
docker exec clickhouse clickhouse-client --user admin --password admin --query "SELECT page_url, response_time_ms, status_code FROM workshop.website_stats ORDER BY timestamp DESC LIMIT 5" 2>/dev/null