# Step 01 - Setup ClickHouse & Generate Data

In this step, you'll set up the monitoring environment with Grafana and ClickHouse, then generate baseline data for alerting.

---
## What You'll Set Up

- **Grafana** - Visualization and alerting platform with Unified Alerting
- **ClickHouse** - Fast column-oriented database for API metrics
- **Baseline data** - 2 hours of normal API response times

---
## Start the Environment

Navigate to your home directory and copy the prepared files:

```terminal:execute
command: mkdir -p ~/alerting && cp -r /opt/workshop/files/* ~/alerting/ && cd ~/alerting
```

**View the files:**

```terminal:execute
command: ls -la
```

You should see:
- `docker-compose.yml` - Grafana + ClickHouse setup
- `generate-baseline-data.sh` - Creates 2 hours of normal data
- `trigger-slow-api.sh` - Script to trigger slow response time alert

---
## Launch Grafana and ClickHouse

Start both services:

```terminal:execute
command: docker compose up -d
```

**Wait for services to initialize:**

```terminal:execute
command: sleep 15 && docker compose ps
```

Both services should be **Up**!

---
## Generate Baseline Data

This script creates 2 hours of historical data representing normal operating conditions.

**Run the baseline data generator:**

```terminal:execute
command: chmod +x generate-baseline-data.sh && ./generate-baseline-data.sh
```

This creates **~120 data points** in the `api_metrics` table:
- **api_metrics** - HTTP requests to `/api/products` with response times

The script takes about 10-15 seconds to complete.

---
## Verify Data in ClickHouse

**Switch to the ClickHouse tab** - it opens the SQL editor at `/play`.

**Run this query to see all tables:**

```sql
SHOW TABLES FROM monitoring
```

You should see the `api_metrics` table.

**Check API response times:**

```sql
SELECT 
  toStartOfMinute(timestamp) as time,
  endpoint,
  round(avg(response_time_ms), 2) as avg_response_ms,
  count() as requests
FROM monitoring.api_metrics
WHERE timestamp >= now() - INTERVAL 2 HOUR
  AND endpoint = '/api/products'
GROUP BY toStartOfMinute(timestamp), endpoint
ORDER BY time DESC
LIMIT 10
```

You should see healthy baseline values around 50-150ms!

---
## Configure ClickHouse Data Source in Grafana

**Switch to the Grafana tab** and login:
- **Username:** `admin`
- **Password:** `admin`

**Add ClickHouse data source:**

1. Go to **Connections** → **Data sources**
2. Click **Add data source**
3. Search for **ClickHouse** and select it

**Configure:**
- **Server address:** `clickhouse`
- **Server port:** `9000` (native protocol)
- **Protocol:** `Native`
- **Username:** `admin`
- **Password:** `admin`
- **Default database:** `monitoring`

Click **Save & Test** - you should see ✅ "Data source is working"

---
## Create Monitoring Dashboard

Before setting up alerts, let's create a simple dashboard to visualize API response times.

**Create new dashboard:**
1. Click **Dashboards** → **New** → **New Dashboard**
2. Click **Add visualization**
3. Select **ClickHouse**

**Add API Response Time Panel:**

Enter this SQL query:

```sql
SELECT 
  toStartOfMinute(timestamp) as time,
  avg(response_time_ms) as avg_response
FROM monitoring.api_metrics
WHERE timestamp >= now() - INTERVAL 2 HOUR
  AND endpoint = '/api/products'
GROUP BY toStartOfMinute(timestamp)
ORDER BY time
```

**Panel settings:**
- **Title:** `API Response Time - /api/products`
- **Visualization:** `Time series` (line chart)
- **Unit:** Milliseconds (ms)
- **Thresholds:** Add red threshold at 500ms (alert level)
- **Color scheme:** Green → Yellow → Red

Click **Apply**

**Save the dashboard:**
1. Click **Save** (💾)
2. Name: `API Monitoring`
3. Click **Save**

---
## Understanding the Data

**Normal Operating Range:**

| Metric | Normal Range | Alert Threshold |
|--------|--------------|-----------------|  
| API Response Time (/api/products) | 50-150ms | > 500ms |

This baseline will help you understand when the alert should trigger!

---
## Understanding Grafana Unified Alerting

This workshop uses **Grafana Unified Alerting** - the modern alerting system (Grafana 8+):

**Key concepts:**
- **Alert Rules** - SQL queries + threshold conditions
- **Expressions** - Transform query results (Reduce, Math, Threshold)
- **Evaluation Groups** - How often to check alerts
- **Contact Points** - Where to send notifications
- **Notification Policies** - Route alerts based on labels

**Workflow:**
1. Query ClickHouse for metric
2. Reduce to single value (last, avg, max)
3. Compare against threshold
4. Trigger alert if condition met
5. Send to contact point

---
## Key Takeaways

✅ Grafana and ClickHouse are running  
✅ 120 baseline data points generated for `/api/products`  
✅ ClickHouse data source configured with native protocol  
✅ Simple monitoring dashboard created  
✅ Ready to set up notification channels!

---

Next, you'll configure webhook notifications before creating the alert!


````
