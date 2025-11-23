# Step 03 - ClickHouse Data Source

In this section, you'll set up Grafana with ClickHouse and learn how to query analytical data.

---
## What is ClickHouse?

**ClickHouse** is a fast open-source column-oriented database management system designed for real-time analytical data reporting.

**Key features:**
- Extremely fast query performance
- Column-oriented storage
- SQL-like query language
- Excellent for analytics and OLAP queries
- Used by companies like Cloudflare, Uber, eBay

**Documentation:** https://clickhouse.com/docs

---
## Clean Up Previous Setup

Stop the InfluxDB stack:

```terminal:execute
command: cd ~/influxdb && docker compose down
```

---
## Prepare ClickHouse Setup

Navigate to the ClickHouse directory:

```terminal:execute
command: mkdir -p ~/clickhouse && cp -r /opt/workshop/files/clickhouse/* ~/clickhouse/ && cd ~/clickhouse
```

**View the prepared Docker Compose file:**

```terminal:execute
command: ls -la
```

You should see `docker-compose.yml`.

**Optional: View the file in the Editor tab**

Switch to the **Editor** tab and open:
- `exercises/clickhouse/docker-compose.yml`

**Understanding the setup:**

The `docker-compose.yml` includes:
- **ClickHouse** - Analytical database on ports 8123 (HTTP) and 9000 (Native)
- **Grafana** - With ClickHouse plugin pre-installed
- Pre-configured with admin credentials

---
## Start ClickHouse Stack

```terminal:execute
command: docker compose up -d
```

**Wait for services to initialize:**

```terminal:execute
command: docker compose ps
```

---
## Access ClickHouse UI

**Switch to the ClickHouse tab** at the top of your workshop interface.

You should see the ClickHouse Play interface - a web-based SQL console!

**Login to ClickHouse:**
1. In the top left corner, you'll see connection settings
2. Enter credentials:
   - **Username:** `admin`
   - **Password:** `admin`
3. Click **Connect** (or the interface may connect automatically)

**Try running a query:**
1. In the query editor, type:
```sql
SELECT version()
```
2. Click **Run** or press Ctrl+Enter
3. You should see the ClickHouse version!

**What is ClickHouse Play?**

**ClickHouse Play** is the built-in web-based SQL interface for ClickHouse. It provides:

- **SQL Editor** - Write and execute queries with syntax highlighting and auto-completion
- **Results Table** - View query results in a formatted table with sorting and filtering
- **Query History** - Access previously executed queries (click the clock icon)
- **Database Explorer** - Browse databases, tables, and columns (left sidebar)
- **Export Options** - Download results as CSV, JSON, or other formats
- **Query Statistics** - See execution time and rows processed

This interface is ideal for:
- Testing SQL queries before adding them to Grafana
- Exploring your database structure
- Running ad-hoc analytics queries
- Debugging data issues

**Note:** This is perfect for testing queries before using them in Grafana!

---
## Create Database and Table in ClickHouse UI

Let's create a sample web analytics table directly in the **ClickHouse Play interface**.

**Step 1: Create Database**

In the ClickHouse Play query editor, paste and run:

```sql
CREATE DATABASE IF NOT EXISTS analytics;
```

Click **Run** (or Ctrl+Enter). You should see a success message!

**Step 2: Create Table**

Now create the table:

```sql
CREATE TABLE analytics.page_views (
    event_time DateTime,
    user_id UInt32,
    page_url String,
    duration_seconds UInt32,
    country String,
    device String
) ENGINE = MergeTree()
ORDER BY (event_time, user_id);
```

Click **Run**. The table is now created!

**Step 3: Verify Table**

Check the table structure:

```sql
DESCRIBE analytics.page_views;
```

You should see all the columns with their data types!

---
## Insert Sample Data in ClickHouse UI

Let's insert sample web analytics data directly in the UI:

```sql
INSERT INTO analytics.page_views VALUES
    (now() - INTERVAL 60 MINUTE, 1, '/home', 45, 'USA', 'desktop'),
    (now() - INTERVAL 58 MINUTE, 2, '/products', 120, 'UK', 'mobile'),
    (now() - INTERVAL 55 MINUTE, 3, '/about', 30, 'Germany', 'desktop'),
    (now() - INTERVAL 50 MINUTE, 1, '/products', 90, 'USA', 'desktop'),
    (now() - INTERVAL 45 MINUTE, 4, '/home', 60, 'France', 'tablet'),
    (now() - INTERVAL 40 MINUTE, 2, '/checkout', 180, 'UK', 'mobile'),
    (now() - INTERVAL 35 MINUTE, 5, '/home', 25, 'Spain', 'desktop'),
    (now() - INTERVAL 30 MINUTE, 3, '/products', 150, 'Germany', 'desktop'),
    (now() - INTERVAL 25 MINUTE, 6, '/blog', 200, 'USA', 'mobile'),
    (now() - INTERVAL 20 MINUTE, 1, '/checkout', 240, 'USA', 'desktop'),
    (now() - INTERVAL 15 MINUTE, 7, '/home', 35, 'Canada', 'tablet'),
    (now() - INTERVAL 10 MINUTE, 2, '/products', 95, 'UK', 'mobile'),
    (now() - INTERVAL 5 MINUTE, 8, '/about', 40, 'Australia', 'desktop'),
    (now() - INTERVAL 3 MINUTE, 4, '/blog', 180, 'France', 'mobile'),
    (now() - INTERVAL 1 MINUTE, 9, '/home', 50, 'Japan', 'desktop');
```

Click **Run**. You should see "Ok." message - 15 rows inserted!

**Verify data:**

```sql
SELECT count() FROM analytics.page_views;
```

You should see `15`!

**View some data:**

```sql
SELECT * FROM analytics.page_views ORDER BY event_time DESC LIMIT 5;
```

You should see the 5 most recent page views!

---
## Add ClickHouse Data Source in Grafana

**Switch to the Grafana tab** (refresh if needed) and log in.

**About the ClickHouse plugin:**

The ClickHouse plugin is automatically installed when Grafana starts. This is configured in the `docker-compose.yml` file using the `GF_INSTALL_PLUGINS` environment variable.

**View the configuration (optional):**
```terminal:execute
command: grep -A 2 GF_INSTALL_PLUGINS ~/clickhouse/docker-compose.yml
```

You should see: `GF_INSTALL_PLUGINS: grafana-clickhouse-datasource`

**Wait for ClickHouse plugin to install:**

```terminal:execute
command: docker compose logs grafana | grep -i clickhouse
```

Look for plugin installation messages.

**Step 1: Add Data Source**
1. Go to **Connections** → **Data sources**
2. Click **Add data source**
3. Search for **ClickHouse**
4. Select **ClickHouse** (by Grafana Labs)

**Step 2: Configure ClickHouse**

**Server:**
- **Server Address:** `clickhouse`
- **Server Port:** `9000`
- **Protocol:** `Native`

**Authentication:**
- **Username:** `admin`
- **Password:** `admin`

**Default Database:** `analytics`

**Step 3: Save and Test**
1. Scroll down and click **Save & Test**
2. You should see: ✅ "Data source is working"

---
## Create Web Analytics Dashboard

Let's visualize our web analytics data!

**Step 1: Create Dashboard**
1. Go to **Dashboards** → **New** → **New Dashboard**
2. Click **Add visualization**
3. Select **ClickHouse** as data source

**Step 2: Page Views Over Time**

Click on **SQL Editor** (code mode) and enter:

```sql
SELECT 
    toStartOfInterval(event_time, INTERVAL 5 MINUTE) as time,
    count() as views
FROM analytics.page_views
WHERE $__timeFilter(event_time)
GROUP BY time
ORDER BY time
```

**Panel Settings:**
- **Title:** `Page Views Over Time`
- **Visualization:** Time series

Click **Apply**

**Step 3: Views by Country**
1. Click **Add** → **Visualization**
2. Select **ClickHouse**
3. Query:

```sql
SELECT 
    country,
    count() as views
FROM analytics.page_views
WHERE $__timeFilter(event_time)
GROUP BY country
ORDER BY views DESC
```

**Panel Settings:**
- **Title:** `Views by Country`
- **Visualization:** Bar chart (horizontal)

Click **Apply**

**Step 4: Device Breakdown**
1. Click **Add** → **Visualization**
2. Select **ClickHouse**
3. Query:

```sql
SELECT 
    device,
    count() as views
FROM analytics.page_views
WHERE $__timeFilter(event_time)
GROUP BY device
```

**Panel Settings:**
- **Title:** `Device Distribution`
- **Visualization:** Pie chart

Click **Apply**

**Step 5: Top Pages**
1. Click **Add** → **Visualization**
2. Select **ClickHouse**
3. Query:

```sql
SELECT 
    page_url as page,
    count() as views,
    avg(duration_seconds) as avg_duration
FROM analytics.page_views
WHERE $__timeFilter(event_time)
GROUP BY page_url
ORDER BY views DESC
LIMIT 10
```

**Panel Settings:**
- **Title:** `Top Pages`
- **Visualization:** Table

Click **Apply**

**Step 6: Average Session Duration**
1. Click **Add** → **Visualization**
2. Select **ClickHouse**
3. Query:

```sql
SELECT 
    avg(duration_seconds) as avg_duration
FROM analytics.page_views
WHERE $__timeFilter(event_time)
```

**Panel Settings:**
- **Title:** `Average Duration`
- **Visualization:** Stat
- **Unit:** seconds (s)

Click **Apply**

**Step 7: Save Dashboard**
1. Click **Save** (💾)
2. Name: `Web Analytics Dashboard`
3. Click **Save**

---
## Understanding ClickHouse SQL

ClickHouse uses SQL with powerful extensions:

**Time-based aggregation:**
```sql
toStartOfInterval(event_time, INTERVAL 1 HOUR)
```

**Grafana macros:**
```sql
$__timeFilter(event_time)  -- Automatic time filtering
$__interval               -- Dynamic interval
```

**Aggregation functions:**
```sql
count(), sum(), avg(), min(), max()
uniq(column)              -- Count unique values
quantile(0.95)(column)    -- 95th percentile
```

**Documentation:** https://clickhouse.com/docs/en/sql-reference/

---
## Exercise: Create More Analytics

Try these queries:

**Unique users:**
```sql
SELECT uniq(user_id) as unique_users
FROM analytics.page_views
WHERE $__timeFilter(event_time)
```

**Bounce rate (single page visits):**
```sql
SELECT 
    countIf(visit_count = 1) / count() * 100 as bounce_rate
FROM (
    SELECT user_id, count() as visit_count
    FROM analytics.page_views
    WHERE $__timeFilter(event_time)
    GROUP BY user_id
)
```

**Peak hour:**
```sql
SELECT 
    toHour(event_time) as hour,
    count() as views
FROM analytics.page_views
WHERE $__timeFilter(event_time)
GROUP BY hour
ORDER BY views DESC
LIMIT 1
```

---
## Key Takeaways

✅ **ClickHouse** excels at analytical queries  
✅ **Column-oriented** storage for fast aggregations  
✅ Perfect for **web analytics and business intelligence**  
✅ **SQL-like** syntax with powerful extensions  

---

> You've successfully connected Grafana to ClickHouse and created analytical dashboards!

Proceed to workshop summary.
