# Step 04 - Playground: Explore and Experiment

Welcome to the **Playground**! This is your space to experiment with Grafana and multiple data sources in one integrated environment.

---
## What's in the Playground?

This playground combines all data sources you've learned:
- **Prometheus** - Metrics monitoring (Node Exporter for system metrics)
- **InfluxDB** - Time-series database with IoT and sensor data
- **ClickHouse** - Fast analytical database with rich sample datasets
- **Grafana** - Unified visualization platform

**No constraints!** This is your environment to:
- Create complex dashboards
- Mix data from multiple sources
- Experiment with advanced queries
- Build custom visualizations
- Test real-world scenarios

---
## Clean Up Previous Environments

First, stop all previous Docker Compose stacks:

```terminal:execute
command: cd ~/clickhouse && docker compose down
```

```terminal:execute
command: cd ~
```

---
## Setup Playground Environment

Navigate to the playground directory:

```terminal:execute
command: mkdir -p ~/playground && cp -r /opt/workshop/files/playground/* ~/playground/ && cd ~/playground
```

**View the integrated setup:**

```terminal:execute
command: ls -la
```

You should see:
- `docker-compose.yml` - All services combined
- `prometheus.yml` - Prometheus configuration
- `generate-clickhouse-data.sh` - Rich dataset generator
- `generate-influxdb-data.sh` - IoT and sensor data generator

**Optional: Review the docker-compose.yml in the Editor tab**

This setup includes:
- Grafana with ClickHouse plugin pre-installed
- Prometheus with Node Exporter
- InfluxDB 2.7 with auto-initialization
- ClickHouse with optimized configuration
- Shared network for inter-service communication
- Persistent volumes for data retention

---
## Start the Playground

Launch all services:

```terminal:execute
command: docker compose up -d
```

**Wait for services to initialize:**

```terminal:execute
command: sleep 15 && docker compose ps
```

All services should be running!

---
## Generate Rich Sample Datasets

We've prepared comprehensive data generators for both ClickHouse and InfluxDB.

### Generate ClickHouse Data

**Run the ClickHouse generator:**

```terminal:execute
command: chmod +x generate-clickhouse-data.sh && ./generate-clickhouse-data.sh
```

This creates **4 different datasets** in ClickHouse:

### 📊 1. Web Analytics (`analytics.page_views`)
- 1,000 page view records
- User behavior tracking
- Geographic data (countries, cities)
- Device, browser, OS information
- Session tracking
- Referrer sources

**Sample queries:**
```sql
-- Top pages by views
SELECT page_url, count() as views 
FROM analytics.page_views 
GROUP BY page_url 
ORDER BY views DESC;

-- Traffic by country
SELECT country, count() as visits 
FROM analytics.page_views 
GROUP BY country 
ORDER BY visits DESC;

-- Device distribution
SELECT device, count() as count 
FROM analytics.page_views 
GROUP BY device;
```

### 🛒 2. E-commerce Sales (`analytics.sales`)
- 500 sales transactions
- Product catalog with categories
- Pricing and discount information
- Payment methods
- Geographic sales data

**Sample queries:**
```sql
-- Revenue by product
SELECT product_name, sum(price * quantity) as revenue 
FROM analytics.sales 
GROUP BY product_name 
ORDER BY revenue DESC;

-- Sales by payment method
SELECT payment_method, count() as count, sum(price * quantity) as total 
FROM analytics.sales 
GROUP BY payment_method;

-- Top selling categories
SELECT category, sum(quantity) as units_sold 
FROM analytics.sales 
GROUP BY category 
ORDER BY units_sold DESC;
```

### 💻 3. System Metrics (`metrics.system_stats`)
- 2,000 metric points
- Multiple servers (web, database, cache)
- CPU, memory, disk usage
- Network traffic statistics
- Time-series performance data

**Sample queries:**
```sql
-- Average CPU by hostname
SELECT hostname, avg(cpu_usage) * 100 as avg_cpu_percent 
FROM metrics.system_stats 
GROUP BY hostname 
ORDER BY avg_cpu_percent DESC;

-- Memory usage over time
SELECT timestamp, hostname, memory_usage * 100 as memory_percent 
FROM metrics.system_stats 
ORDER BY timestamp DESC 
LIMIT 100;
```

### 📝 4. Application Logs (`logs.app_logs`)
- 1,000 log entries
- Multiple microservices
- Different log levels (INFO, WARN, ERROR, DEBUG)
- Response time tracking
- Error code distribution

**Sample queries:**
```sql
-- Error distribution by service
SELECT service, count() as errors 
FROM logs.app_logs 
WHERE level = 'ERROR' 
GROUP BY service 
ORDER BY errors DESC;

-- Average response time by service
SELECT service, avg(duration_ms) as avg_response_ms 
FROM logs.app_logs 
GROUP BY service 
ORDER BY avg_response_ms DESC;

-- Log level distribution
SELECT level, count() as count 
FROM logs.app_logs 
GROUP BY level;
```

### Generate InfluxDB Data

**Run the InfluxDB generator:**

```terminal:execute
command: chmod +x generate-influxdb-data.sh && ./generate-influxdb-data.sh
```

This creates **5 different time-series datasets** in InfluxDB:

### 🌡️ 1. IoT Home Sensors (`temperature`, `humidity`)
- 960 measurements across 4 rooms
- Living room, bedroom, kitchen, office
- Temperature and humidity readings
- 2 hours of historical data (1-minute intervals)

**Sample Flux queries:**
```flux
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> filter(fn: (r) => r.room == "living_room")
```

```flux
// Average temperature by room
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> group(columns: ["room"])
  |> mean()
```

### 🌦️ 2. Weather Station (`weather`)
- 120 outdoor weather measurements
- Temperature, pressure, wind speed, rainfall
- Real-time weather monitoring data

**Sample queries:**
```flux
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "weather")
  |> filter(fn: (r) => r._field == "temperature" or r._field == "pressure")
```

### ⚡ 3. Energy Consumption (`energy`)
- 480 power consumption measurements
- Total, HVAC, appliances, lighting
- Voltage and current data
- Track energy usage patterns

**Sample queries:**
```flux
// Total energy consumption over time
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "energy")
  |> filter(fn: (r) => r.type == "total")
  |> filter(fn: (r) => r._field == "consumption")
```

```flux
// Energy breakdown by type
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "energy")
  |> filter(fn: (r) => r._field == "consumption")
  |> group(columns: ["type"])
  |> sum()
```

### 💧 4. Water Quality (`water_quality`)
- 60 water quality measurements
- pH, TDS (Total Dissolved Solids), turbidity, chlorine
- 2-minute intervals
- Monitor water treatment system

**Sample queries:**
```flux
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "water_quality")
  |> filter(fn: (r) => r._field == "ph" or r._field == "tds")
```

### 🏭 5. Industrial Machines (`machine`)
- 240 industrial sensor measurements
- 2 machines (press and lathe)
- Temperature, vibration, RPM, pressure
- Predictive maintenance data

**Sample queries:**
```flux
// Machine temperature monitoring
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "machine")
  |> filter(fn: (r) => r._field == "temperature")
  |> group(columns: ["name"])
```

```flux
// High vibration alerts
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "machine")
  |> filter(fn: (r) => r._field == "vibration")
  |> filter(fn: (r) => r._value > 70)
```

---
## Explore Data in Native UIs

### Explore ClickHouse Data

**Switch to the ClickHouse tab** and login (admin/admin)

Try exploring the data:

```sql
-- List all databases
SHOW DATABASES;

-- List all tables
SHOW TABLES FROM analytics;
SHOW TABLES FROM metrics;
SHOW TABLES FROM logs;

-- Quick data preview
SELECT * FROM analytics.page_views LIMIT 10;
SELECT * FROM analytics.sales LIMIT 10;
SELECT * FROM metrics.system_stats LIMIT 10;
SELECT * FROM logs.app_logs LIMIT 10;
```

### Explore InfluxDB Data

**Switch to the InfluxDB tab** and login (admin/adminpassword)

Try exploring the time-series data:

**In Data Explorer:**
1. Select `mybucket`
2. Choose measurements: `temperature`, `humidity`, `weather`, `energy`, `water_quality`, `machine`
3. Select fields and apply filters
4. Click **Submit** to visualize

**Sample queries in Script Editor:**
```flux
// Room temperature comparison
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> aggregateWindow(every: 5m, fn: mean)
```

```flux
// Energy consumption trends
from(bucket: "mybucket")
  |> range(start: -2h)
  |> filter(fn: (r) => r._measurement == "energy" and r._field == "consumption")
```

---
## Configure All Data Sources in Grafana

**Switch to the Grafana tab** and login (admin/admin)

### Add Prometheus Data Source

1. Go to **Connections** → **Data sources** → **Add data source**
2. Select **Prometheus**
3. Configure:
   - **URL:** `http://prometheus:9090`
4. Click **Save & Test**

### Add ClickHouse Data Source

1. **Add data source** → Search for **ClickHouse**
2. Configure:
   - **Server Address:** `clickhouse`
   - **Server Port:** `9000`
   - **Protocol:** `Native`
   - **Username:** `admin`
   - **Password:** `admin`
   - **Default Database:** `analytics`
3. Click **Save & Test**

### Add InfluxDB Data Source

1. **Add data source** → Select **InfluxDB**
2. Configure:
   - **Query Language:** `Flux`
   - **URL:** `http://influxdb:8086`
   - **Organization:** `myorg`
   - **Token:** `mytoken123456789`
   - **Default Bucket:** `mybucket`
3. Click **Save & Test**

---
## Ideas to Explore

Now it's your turn! Here are some ideas to get you started:

### 🎯 Dashboard Ideas

**1. Business Intelligence Dashboard**
- Total revenue from sales
- Top-selling products
- Sales by country (map visualization)
- Payment method distribution
- Revenue trends over time

**2. Web Analytics Dashboard**
- Real-time visitor count
- Traffic by country/city
- Device breakdown (pie chart)
- Most visited pages
- Average session duration
- Bounce rate calculations

**3. Infrastructure Monitoring**
- System resource usage (CPU, Memory, Disk) from Prometheus
- Network traffic patterns
- Server comparison heatmap
- Alert thresholds and annotations
- Prometheus + ClickHouse combined metrics

**4. Application Performance**
- Request rate from Prometheus
- Error rates from logs (ClickHouse)
- Response time percentiles
- Service health overview
- Log level trends

**5. Smart Home Dashboard**
- Temperature and humidity by room (InfluxDB)
- Energy consumption breakdown
- Weather station data
- Water quality monitoring
- Combined environmental metrics

**6. Industrial IoT Dashboard**
- Machine performance metrics (InfluxDB)
- Temperature and vibration monitoring
- RPM and pressure trends
- Predictive maintenance alerts
- Multi-machine comparison

### 🔧 Advanced Techniques to Try

**Mixed Data Sources:**
- Combine Prometheus metrics with ClickHouse analytics
- Correlate system metrics with application logs
- Overlay sales data with infrastructure performance
- Mix InfluxDB IoT data with ClickHouse business data
- Create unified dashboards with all three sources

**Complex Visualizations:**
- Geomap with country-level data (ClickHouse)
- Heatmaps for time-based patterns (InfluxDB)
- Stat panels with sparklines
- Table panels with multi-column sorting
- Bar gauge for comparisons
- Time-series with multiple Y-axes

**Advanced Queries:**
- Window functions in ClickHouse
- Join multiple ClickHouse tables
- PromQL rate() and increase() functions
- Flux aggregateWindow() and pivot() functions
- Aggregations with grouping
- Subqueries and CTEs

**Dashboard Features:**
- Variables for dynamic filtering
- Template variables for multi-server views
- Time range synchronization
- Dashboard links and drill-downs
- Annotations from multiple sources

### 📚 Additional Data Generation

Want more data? You can:

**Generate continuous ClickHouse data:**
```bash
# Run this in a loop to keep adding data
for i in {1..10}; do
  docker exec clickhouse clickhouse-client --user admin --password admin --query "
    INSERT INTO analytics.page_views 
    SELECT now() - INTERVAL (number * 5) SECOND, (rand() % 1000) + 1, concat('session_', toString(rand() % 500)), 
    arrayElement(['/home', '/products', '/blog'], (rand() % 3) + 1), 'direct', (rand() % 300) + 10, 
    arrayElement(['USA', 'UK', 'Germany'], (rand() % 3) + 1), arrayElement(['New York', 'London', 'Berlin'], (rand() % 3) + 1),
    arrayElement(['desktop', 'mobile'], (rand() % 2) + 1), 'Chrome', 'Windows' 
    FROM numbers(100);
  "
  sleep 30
done
```

**Generate continuous InfluxDB data:**
```bash
# Continuous IoT sensor data
for i in {1..100}; do
  TEMP=$((20 + RANDOM % 10))
  HUMIDITY=$((50 + RANDOM % 30))
  
  docker exec influxdb influx write \
    --bucket mybucket \
    --org myorg \
    --token mytoken123456789 \
    --precision s \
    "temperature,room=living_room,sensor=temp_01 value=${TEMP}
    humidity,room=living_room,sensor=hum_01 value=${HUMIDITY}"
  
  sleep 10
done
```

**Prometheus metrics** are automatically collected from Node Exporter - check them in Prometheus UI!

---
## External Dataset Resources

Want to import real-world datasets? Check these sources:

**ClickHouse Public Datasets:**
- [ClickHouse Example Datasets](https://clickhouse.com/docs/en/getting-started/example-datasets)
- NYC Taxi Data
- GitHub Events Archive
- Stack Overflow Data

**Time-Series Datasets:**
- [Kaggle Time Series Datasets](https://www.kaggle.com/datasets?tags=13303-Time+Series)
- [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/index.php)

**How to import:**
1. Download dataset as CSV
2. Copy to ClickHouse container: `docker cp data.csv clickhouse:/tmp/`
3. Import: `clickhouse-client --query "INSERT INTO table FORMAT CSV" < /tmp/data.csv`

---
## Tips for Success

**🎨 Design Tips:**
- Use consistent color schemes across panels
- Group related metrics together
- Add descriptions to panels (Edit → Panel options → Description)
- Use meaningful dashboard names and tags

**⚡ Performance Tips:**
- Use appropriate time ranges (don't query years of data)
- Leverage ClickHouse's `LIMIT` clause
- Use aggregation to reduce data points
- Enable query caching in Grafana

**🐛 Debugging:**
- Use **Explore** to test queries before adding to dashboards
- Check **Query Inspector** for performance insights
- Review container logs: `docker compose logs [service]`
- Verify data in native UIs (Prometheus, ClickHouse Play)

---
## Save Your Work

**Export your dashboards:**
1. Dashboard settings (⚙️) → **JSON Model**
2. Copy the JSON
3. Save to a file for later reuse

**Share your findings:**
- Take screenshots of interesting visualizations
- Document your queries and discoveries
- Export data as CSV for further analysis

---
## Need Inspiration?

**Grafana Dashboard Library:**
- [Grafana Dashboard Gallery](https://grafana.com/grafana/dashboards/)
- Search for ClickHouse, Prometheus dashboards
- Import and customize existing dashboards

**Query Examples:**
- **ClickHouse:** https://clickhouse.com/docs/en/sql-reference
- **PromQL:** https://prometheus.io/docs/prometheus/latest/querying/basics/

---
## Clean Up

When you're done exploring:

```terminal:execute
command: docker compose down -v
```

This removes all containers and volumes.

---

**🎉 Happy Exploring!**

This is your playground - experiment, learn, break things, and have fun! There are no wrong answers here, only discoveries waiting to be made.

> Remember: The best way to learn is by doing. Try different combinations, test various visualizations, and see what insights you can uncover from the data!

