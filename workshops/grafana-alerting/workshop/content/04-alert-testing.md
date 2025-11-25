# Step 04 - Testing & Triggering Alerts

In this final step, you'll trigger the API response time alert and observe the complete alerting workflow.

---
## Alert Testing Strategy

You'll trigger the **Slow API Response Time** alert:
- 🐌 Script: `trigger-slow-api.sh`
- Normal: 50-150ms → Alert: 2000ms (2 seconds)
- Duration: ~3 minutes

The script gradually increases response time to cross the 500ms alert threshold.

---
## Before You Start

**Open these views for monitoring:**

1. **Grafana Alerting** - Alerting → Alert rules (watch state changes)
2. **Grafana Dashboard** - Your API Monitoring dashboard (see data spikes)
3. **webhook.site** - Watch for webhook notifications
4. **Terminal** - Execute trigger script

**Tip:** Arrange browser windows side-by-side to watch everything in real-time!

---
## Trigger the Alert: Slow API Response Time

This simulates database performance degradation causing `/api/products` endpoint to slow from 100ms to 2000ms.

### Run the Script

```terminal:execute
command: cd ~/alerting && chmod +x trigger-slow-api.sh && ./trigger-slow-api.sh
```

**What happens:**
- Script runs for ~3 minutes (18 iterations)
- Every 10 seconds: generates 10 API requests to `/api/products`
- Response time gradually increases: 100ms → 400ms → 500ms → 1500ms → 2000ms
- Alert threshold: 500ms

### Watch the Alert Fire

**In Grafana → Alerting → Alert rules:**

1. Find `API Response Time High` alert
2. Watch status transition:
   - 🟢 **Normal** (initial state, response time < 500ms)
   - 🟡 **Pending** (response time > 500ms, in 2min pending period)
   - 🔴 **Alerting** (after pending period expires)

**Click on the alert** to see:
- Current response time value
- Query result
- Time alert started
- Alert state history

### Monitor the Dashboard

**Go to Dashboards → API Monitoring:**

You should see the response time graph spike dramatically:
- Green zone: 50-150ms (normal)
- Yellow zone: approaching 500ms
- Red zone: above 500ms threshold

### Verify in ClickHouse

Switch to **ClickHouse tab** and run:

```sql
SELECT 
  toStartOfMinute(timestamp) as minute,
  round(avg(response_time_ms), 2) as avg_response_ms,
  count() as requests
FROM monitoring.api_metrics
WHERE timestamp >= now() - INTERVAL 5 MINUTE
  AND endpoint = '/api/products'
GROUP BY toStartOfMinute(timestamp)
ORDER BY minute DESC
```

You should see response times spiking above 500ms!

### Check Webhook Notification

**Go to webhook.site** (the URL you configured earlier):

You should see a JSON payload like:

```json
{
  "receiver": "Webhook - API Monitoring",
  "status": "firing",
  "alerts": [
    {
      "status": "firing",
      "labels": {
        "alertname": "API Response Time High",
        "severity": "warning",
        "service": "api",
        "endpoint": "/api/products"
      },
      "annotations": {
        "description": "API response time exceeded 500ms...",
        "summary": "API response time is 1523ms"
      },
      "startsAt": "2025-11-25T10:30:00Z",
      "values": {
        "B": 1523
      }
    }
  ]
}
```

**This webhook payload can be used to:**
- Trigger automation scripts
- Create tickets in Jira/ServiceNow
- Page on-call engineers
- Post to Slack/Teams channels
- Store alert history in a database

---
## Understanding the Alert Lifecycle

Let's review what happened:

### 1. Data Collection (Continuous)
- ClickHouse receives API metrics every minute
- Baseline: 50-150ms response time
- Trigger script: Injects slow requests (2000ms)

### 2. Alert Evaluation (Every 1 minute)
- Grafana runs SQL query: `avg(response_time_ms)` 
- Reduce expression gets last value
- Threshold checks: Is it > 500ms?

### 3. Pending State (2 minutes)
- First time threshold crossed → Pending
- Prevents false alarms from brief spikes
- Alert waits 2 minutes to confirm issue

### 4. Alerting State
- After pending period, if still > 500ms → Alerting
- Notification sent to webhook
- Alert visible in Grafana UI

### 5. Resolution (Automatic)
- When response time drops < 500ms
- Alert returns to Normal state
- "Resolved" notification sent

---
## Examine Alert Details

**Click on the firing alert** to see:

### Query Tab
- Expression A: ClickHouse SQL query
- Expression B: Reduce to last value
- Expression C: Threshold check (> 500)
- Current values and results

### History Tab
- State transition timeline
- Normal → Pending → Alerting
- Timestamps for each transition

### Instances Tab
- Alert instance details
- Labels: severity, service, endpoint
- Current state and value

---
## Practice: Silence the Alert

While the alert is firing, practice creating a silence.

**Go to: Alerting → Silences**

**Click "+ Create silence"**

### Configuration:

**Silence start:** `Now`
**Silence end:** `Duration` → `30 minutes`

**Matchers:**
- Label: `alertname`
- Operator: `=`
- Value: `API Response Time High`

**Comment:** `Testing alert workflow - temporary silence`

Click **Submit**

### What Happens:
- Alert continues to evaluate
- State remains **Alerting**
- ❌ **No new notifications sent** (webhook not called)
- After 30 minutes, notifications resume

---
## Wait for Alert to Resolve

After the trigger script completes (~3 minutes), wait 5-10 minutes.

**Watch the alert:**
- Response time drops back to normal (50-150ms)
- Alert state: Alerting → Normal
- "Resolved" notification sent to webhook

**Check webhook.site** - you should see a "resolved" payload:
```json
{
  "status": "resolved",
  "alerts": [...]
}
```

---
## Optional: Re-run the Test

Want to see it again? Clean up and re-run:

```terminal:execute
command: ./trigger-slow-api.sh
```

Remove the silence first to see notifications:
1. Go to **Alerting → Silences**
2. Find your silence
3. Click **Expire** to end it early

---
## Key Takeaways

✅ Triggered API response time alert with test script  
✅ Watched alert lifecycle: Normal → Pending → Alerting → Resolved  
✅ Monitored dashboard showing response time spike  
✅ Verified data in ClickHouse with SQL queries  
✅ Received webhook notification with alert details  
✅ Practiced silencing alerts temporarily  
✅ Understood complete alerting workflow  

---

Congratulations! You've completed the Grafana Alerting workshop. You now understand how to set up monitoring, create alerts, configure notifications, and trigger alerts with real scenarios!
