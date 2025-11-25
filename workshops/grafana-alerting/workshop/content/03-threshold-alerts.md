# Step 03 - Basic Threshold Alerts

In this step, you'll create your first threshold-based alert rules using Grafana Unified Alerting with ClickHouse.

---
## What is a Threshold Alert?

A **threshold alert** triggers when a metric crosses a specified value:
- Response time > 500ms
- Error rate > 10%
- CPU usage > 80%

These are the most common type of alerts in production systems.

In this step, we'll create a simple alert for **API Response Time**.

---
## Understanding Grafana Unified Alerting

**Unified Alerting uses a multi-step approach:**

1. **Query (A)** - Fetch data from ClickHouse
2. **Reduce (B)** - Convert time-series to single value (last, avg, max)
3. **Threshold (C)** - Compare against threshold
4. **Alert Rule** - Fire alert when condition is met

This is more powerful than legacy alerting!

---
## Access Grafana Alerting

**In the Grafana tab:**

1. Click **Alerting** (🔔 bell icon) in the left sidebar
2. Click **Alert rules**
3. Click **+ New alert rule**

You're now in the alert rule creation interface!

---
## Create Alert: API Response Time High

Let's create an alert that triggers when API response time exceeds 500ms for the `/api/products` endpoint.

---
## Section 1 - Enter Alert Rule and Name

**At the top of the alert creation form:**

1. **Alert rule name:** `API Response Time High`

This is the first thing you enter when creating a new alert rule.

---
## Section 2 - Define Query and Alert Condition

### Step 1: Define Query (Expression A)

1. **Data source:** Select `ClickHouse`
2. **Query type:** `SQL Editor`
3. Enter this SQL query:

```sql
SELECT avg(response_time_ms) as response_time
FROM monitoring.api_metrics
WHERE timestamp >= now() - INTERVAL 1 MINUTE
  AND endpoint = '/api/products'
```

**What this does:**
- Looks at last 1 minute of API requests
- Filters only `/api/products` endpoint
- Returns average response time

**Simple:** One number = is the API slow?

Click **Run queries** to test it.

### Step 2: Add Threshold Expression (Expression B)

Below your query, click **+ Expression**:

1. **Operation:** `Threshold`
2. **Input:** Select `A` (your ClickHouse query)
3. **IS ABOVE:** `500`

This triggers when average response time > 500ms.

### Step 3: Set Alert Condition

At the top of the expressions section, click the star icon on **Expression B** to set it as the alert condition.

---
## Section 3 - Add Folder and Labels

### Step 4: Configure Folder and Labels

Scroll down to this section:

1. **Folder:** Click **+ New folder** → Name: `API Alerts`

2. **Labels** (click **+ Add label**):
   - Label: `severity` = `warning`
   - Label: `service` = `api`
   - Label: `endpoint` = `/api/products`

These labels help route alerts to the right notification policies.

---
## Section 4 - Set Evaluation Behavior

### Step 5: Configure Evaluation Group and Intervals

1. **Evaluation group:** Click **+ New evaluation group**
   - **Group name:** `api-monitoring`
   - **Evaluation interval:** `1m` (check every minute)
   
2. **Pending period:** `2m` (wait 2 minutes before firing)

3. **Keep firing for:** Leave as `0m` (fires immediately after pending period)

---
## Section 5 - Configure Notifications

### Step 6: Select Notification Contact Point

1. **Contact point:** Select `Webhook - API Monitoring` (the webhook you created earlier)

This is where the alert notification will be sent!

---
## Section 6 - Configure Notification Message

### Step 7: Customize Alert Message

**Summary:**
```
API response time is {{ $values.B }}ms
```

**Description:**
```
API response time exceeded 500ms for /api/products endpoint. 

This indicates:
- Database query performance issue
- Slow queries or missing indexes
- Connection pool exhaustion
- Network latency issues

Action: Check database performance and query logs.
```

---
## Save Alert

Click **Save rule and exit** at the top right.

You've created your first Unified Alert! 🎉

---
## View Your Alert Rule

Click **Alerting** → **Alert rules**

You should see your alert rule in the **API Alerts** folder:
- **API Response Time High**

It should show status: **Normal** (green checkmark)

---
## Understanding Alert States

**Alert states:**
- 🟢 **Normal** - Response time < 500ms
- 🟡 **Pending** - Response time > 500ms, waiting 2 minutes to confirm
- 🔴 **Alerting** - Response time still > 500ms after 2 minutes
- ⚪ **NoData** - No API requests in last minute

**Pending period = grace period** - prevents false alarms from momentary spikes.

---
## How It Works

**Every 1 minute:**
1. Query ClickHouse: "What's the average response time in the last minute?"
2. Compare: Is it > 500ms?
3. If YES → Enter Pending state
4. After 2 minutes of being > 500ms → Send alert notification
5. When response time drops back < 500ms → Alert resolves

**That's it!** Simple and effective.

---
## Key Takeaways

✅ Created a threshold-based alert with Unified Alerting  
✅ Used ClickHouse SQL query as data source  
✅ Set threshold condition (response_time > 500ms)  
✅ Organized alert in the API Alerts folder  
✅ Added labels for alert routing (severity, service, endpoint)  
✅ Configured evaluation interval (1m) and pending period (2m)  
✅ Connected to webhook notification contact point  
✅ Customized alert summary and description messages  

---

Next, you'll trigger this alert and watch the notification workflow in action!


````

