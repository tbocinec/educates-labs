# Step 03 - Explore Container Logs

In this step, you'll explore logs that Docker containers are automatically generating.

---
## How Log Collection Works

**Automatic log collection pipeline:**

1. **Docker containers** generate logs (stdout/stderr)
2. **Promtail** discovers containers and collects their logs
3. **Loki** stores logs with container labels
4. **Grafana** queries and displays logs

**No manual log generation needed!** Containers are already producing logs.

---
## Open Grafana Explore

In Grafana:

1. Click **Explore** (🔍 icon) in the left sidebar
2. **Data source dropdown:** Select **Loki**
3. You'll see the query builder interface

---
## View All Container Logs

In the query builder, click **+ Operations** → **Label filter**:

- **Label:** `container`
- **Operator:** `=~` (regex)
- **Value:** `.*` (all containers)

Click **Run query**

You should see logs from all Docker containers! 🎉

---
## Filter by Container

### View Only Grafana Logs

Change the label filter:
- **Label:** `container`
- **Operator:** `=`
- **Value:** `grafana`

**Result:** Only logs from Grafana container.

### View Only Loki Logs

Change value to: `loki`

**Result:** Loki's operational logs.

---
## Search Within Logs

Try raw LogQL queries. Switch to **Code** view (top right):

### Find Errors
```
{container="loki-workshop-grafana-1"}|= "error"
```

### Find API Requests
```
{container="loki-workshop-grafana-1"}|= "api"
```

### Exclude Health Checks
```
{container="loki-workshop-grafana-1"}!= "health"
```

---
## Create a Log Dashboard

Let's build a dashboard to monitor container logs.

### Create New Dashboard

1. **Grafana home** → **Dashboards** → **+ Create** → **New Dashboard**
2. Click **+ Add visualization**
3. Select **Loki** as data source

### Panel 1: Grafana Error Logs

**Query:**
```
{container="loki-workshop-grafana-1"}|= "error"
```

**Panel settings:**
- **Title:** `Grafana Error Logs`
- **Visualization type:** `Logs`

Click **Apply**

### Panel 2: All Container Activity

Click **+ Add panel** → **+ Add visualization** → **Loki**

**Query:**
```
{container=~".*"}
```

**Panel settings:**
- **Title:** `All Container Logs`
- **Visualization type:** `Logs`
- **Limit:** `100` (to avoid too many logs)

Click **Apply**

### Panel 3: Log Volume by Container

Click **+ Add panel** → **+ Add visualization** → **Loki**

**Query:**
```
sum by (container) (count_over_time({container=~".*"}[5m]))
```

**Panel settings:**
- **Title:** `Log Volume (5min)`
- **Visualization type:** `Time series`

Click **Apply**

### Save Dashboard

1. Click **Save** (💾) at top
2. **Name:** `Container Logs Monitoring`
3. Click **Save**

---
## Understanding Log Labels

Loki automatically adds labels from Docker:

### Available Labels:
- `container` - Container name
- `stream` - stdout/stderr
- `compose_project` - Docker Compose project
- `compose_service` - Service name from docker-compose

### Label Examples:
```
# Query by service name
{compose_service="grafana"}

# Only stderr logs
{stream="stderr"}

# Specific project
{compose_project="loki-workshop"}
```

---
## Generate More Activity

To see more diverse logs, perform actions in Grafana:

1. Create a new dashboard panel
2. Go to **Data Sources** → **Add new data source**
3. Navigate through menus

Return to **Explore** → **Loki** and run:
```
{container="grafana"}
```

You'll see new API activity logs! 📈

---
## Log Analytics Examples

### Count Logs by Level
```
{container="loki-workshop-grafana-1"}
| pattern `<timestamp> <level> <message>` 
| stats count() by level
```

### Response Time Distribution
```
{container="loki-workshop-grafana-1"}
| pattern `took <duration>ms` 
| stats avg(duration), max(duration)
```

### Error Rate Over Time
```
sum(rate({container="loki-workshop-grafana-1"}|= "error" [5m]))
```

---
## Key Takeaways

✅ Viewed logs from all Docker containers automatically  
✅ Filtered logs by container and content  
✅ Created a log monitoring dashboard with 3 panels  
✅ Learned LogQL query syntax and operators  
✅ Understood Loki's label-based indexing  
✅ Explored log analytics and aggregation  

---

Congratulations! You've successfully set up and explored Grafana Loki for container log aggregation! 🎉

You now understand how to:
- Deploy Loki with Docker Compose
- Automatically collect container logs with Promtail
- Query logs using LogQL
- Build dashboards with log data
- Perform log analytics and monitoring
