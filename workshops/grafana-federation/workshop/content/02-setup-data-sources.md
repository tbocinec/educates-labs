# Step 02 - Setup Data Sources

In this step, you'll configure each Grafana instance with its specific data source and create basic dashboards to verify the setup.

---
## Configure Grafana InfluxDB (Port 3001)

**Open:** http://localhost:3001  
**Login:** admin / admin

### Add InfluxDB Data Source

1. **Navigate:** ⚙️ **Configuration** → **Data Sources**
2. **Click:** **Add data source**
3. **Select:** **InfluxDB**

**Configuration:**
- **Name:** `Sensors InfluxDB`
- **Query Language:** `Flux`
- **URL:** `http://influxdb:8086`
- **Organization:** `workshop`
- **Token:** `workshop-token-123456789`
- **Default Bucket:** `sensors`

4. **Click:** **Save & Test**

✅ **Expected:** "Data source is working"

### Create InfluxDB Dashboard

1. **Navigate:** **+ Create** → **Dashboard**
2. **Click:** **+ Add visualization**
3. **Select:** `Sensors InfluxDB` data source

**Panel 1: Temperature**
- **Query Builder:**
  - **Bucket:** `sensors`
  - **Measurement:** `temperature`
  - **Field:** `value`
  - **Filter by:** `location` (select office)

- **Panel Settings:**
  - **Title:** `Office Temperature`
  - **Unit:** `Temperature (°C)`
  - **Visualization:** `Time series`

**Panel 2: Humidity**
- **Add Panel** → **+ Add visualization**
- **Query Builder:**
  - **Bucket:** `sensors`
  - **Measurement:** `humidity`
  - **Field:** `value`
  - **Filter by:** `location` (select office)

- **Panel Settings:**
  - **Title:** `Office Humidity`
  - **Unit:** `Percent (0-100)`
  - **Visualization:** `Time series`

3. **Save Dashboard:**
   - **Name:** `Sensor Monitoring`
   - **Click:** **Save**

---
## Configure Grafana ClickHouse (Port 3002)

**Open:** http://localhost:3002  
**Login:** admin / admin

### Add ClickHouse Data Source

1. **Navigate:** ⚙️ **Configuration** → **Data Sources**
2. **Click:** **Add data source**
3. **Select:** **ClickHouse**

**Configuration:**
- **Name:** `Business ClickHouse`
- **Server Address:** `clickhouse`
- **Server Port:** `9000`
- **Username:** `admin`
- **Password:** `admin`
- **Database:** `workshop`

4. **Click:** **Save & Test**

✅ **Expected:** "Database Connection OK"

### Create ClickHouse Dashboard

1. **Navigate:** **+ Create** → **Dashboard**
2. **Click:** **+ Add visualization**
3. **Select:** `Business ClickHouse` data source

**Panel 1: Sales by Region**
- **Query Mode:** `SQL Editor`
- **Query:**
```sql
SELECT 
    region,
    sum(amount) as total_sales
FROM sales 
WHERE timestamp >= now() - INTERVAL 3 HOUR
GROUP BY region
ORDER BY total_sales DESC
```
- **Title:** `Sales by Region (3h)`
- **Visualization:** `Pie chart`

**Panel 2: Website Performance**
- **Add Panel** → **+ Add visualization**
- **Query:**
```sql
SELECT 
    toUnixTimestamp(timestamp) * 1000 as time,
    avg(response_time_ms) as avg_response
FROM website_stats 
WHERE timestamp >= now() - INTERVAL 3 HOUR
GROUP BY toStartOfInterval(timestamp, INTERVAL 10 MINUTE)
ORDER BY time
```
- **Title:** `Average Response Time`
- **Visualization:** `Time series`
- **Unit:** `Milliseconds`

**Panel 3: Server Performance**
- **Add Panel** → **+ Add visualization**
- **Query:**
```sql
SELECT 
    server_name,
    avg(cpu_usage) as avg_cpu,
    avg(memory_usage_mb) as avg_memory
FROM performance 
WHERE timestamp >= now() - INTERVAL 3 HOUR
GROUP BY server_name
```
- **Title:** `Server Performance`
- **Visualization:** `Table`

3. **Save Dashboard:**
   - **Name:** `Business Analytics`
   - **Click:** **Save**

---
## Verify Data Sources

### Test InfluxDB Connection

**In Grafana InfluxDB (Port 3001):**
1. Go to **Explore** (🔍)
2. Select `Sensors InfluxDB`
3. **Query Builder:**
   - **Bucket:** `sensors`
   - **Measurement:** `temperature`
   - **Field:** `value`
4. **Run Query**

**Expected:** Temperature data from office sensors

### Test ClickHouse Connection

**In Grafana ClickHouse (Port 3002):**
1. Go to **Explore** (🔍)
2. Select `Business ClickHouse`
3. **Query Mode:** `SQL Editor`
4. **Query:**
```sql
SELECT product, COUNT(*) as sales_count 
FROM sales 
GROUP BY product
ORDER BY sales_count DESC
```
5. **Run Query**

**Expected:** Product sales counts

---
## Understanding Data Types

### InfluxDB Sensor Data

**Time Series Structure:**
```
measurement,tag_set field_set timestamp
temperature,sensor=room1,location=office value=23.5 1647875400
humidity,sensor=room1,location=office value=65.2 1647875400
```

**Key Concepts:**
- 📊 **Measurements** - Like database tables (temperature, humidity)
- 🏷️ **Tags** - Indexed metadata (sensor, location)
- 📈 **Fields** - Actual values (value)
- ⏰ **Timestamp** - High precision time

### ClickHouse Business Data

**SQL Tables Structure:**
- 💰 **sales** - Product sales transactions
- 🌐 **website_stats** - Page analytics
- 🖥️ **performance** - Server metrics

**Benefits:**
- ✅ **SQL queries** - Familiar query language
- ✅ **Aggregations** - GROUP BY, SUM, AVG
- ✅ **Analytics** - Business intelligence
- ✅ **Columnar storage** - Fast analytics

---
## Data Source Best Practices

### InfluxDB Configuration

**Optimal settings:**
- **Use Flux** query language (modern, powerful)
- **Proper bucket** organization
- **Retention policies** for data lifecycle
- **Appropriate time ranges** for performance

### ClickHouse Configuration

**Performance tips:**
- **Index on timestamp** for time-based queries
- **Proper data types** for efficiency
- **Aggregation tables** for fast queries
- **Partitioning** by time periods

---
## Dashboard Design Principles

### Sensor Dashboard (InfluxDB)

**Focus on:**
- 🌡️ **Real-time monitoring** - Current sensor values
- 📈 **Trend analysis** - Temperature/humidity over time
- 🚨 **Threshold alerts** - Out-of-range values
- 📍 **Location comparison** - Different rooms/sensors

### Business Dashboard (ClickHouse)

**Focus on:**
- 💰 **KPI monitoring** - Sales, revenue, performance
- 🌍 **Regional analysis** - Geographic breakdowns
- 📊 **Time-based trends** - Daily, weekly patterns
- 🔍 **Drill-down capability** - From summary to detail

---
## Key Takeaways

✅ **InfluxDB Grafana Configured** - Sensor data source ready  
✅ **ClickHouse Grafana Configured** - Business data source ready  
✅ **Dashboards Created** - Basic visualizations working  
✅ **Data Verified** - Both data sources returning data  
✅ **Query Languages** - Flux and SQL working correctly  
✅ **Different Data Types** - Time series vs analytics data  

---

Excellent! Both source Grafanas are now configured with their respective data sources. Next, you'll configure the federation Grafana to read from both sources.

**Next:** Step 3 - Configure Grafana Federation