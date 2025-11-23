# Step 01 - Prometheus Data Source

In this section, you'll set up Grafana with Prometheus and learn how to visualize metrics data.

---
## What is Prometheus?

**Prometheus** is an open-source monitoring and alerting toolkit designed for reliability and scalability.

**Key features:**
- Time-series database for metrics
- Powerful query language (PromQL)
- Built-in service discovery
- Widely used for Kubernetes and microservices monitoring

**Documentation:** https://prometheus.io/docs/introduction/overview/

---
## Prepare Docker Compose Setup

We've prepared a complete setup with Grafana, Prometheus, and Node Exporter for you.

**Navigate to the Prometheus exercise directory:**

```terminal:execute
command: mkdir -p ~/prometheus && cp -r /opt/workshop/files/prometheus/* ~/prometheus/ && cd ~/prometheus
```

**View the prepared files:**

```terminal:execute
command: ls -la
```

You should see:
- `docker-compose.yml` - Defines all services
- `prometheus.yml` - Prometheus configuration

**Optional: View the files in the Editor tab**

You can open and explore these files:
1. Switch to the **Editor** tab
2. Navigate to `exercises/prometheus/`
3. Open `docker-compose.yml` to see the service definitions
4. Open `prometheus.yml` to see Prometheus scrape configuration

**Understanding the setup:**

The `docker-compose.yml` includes:
- **Prometheus** - Metrics database on port 9090
- **Node Exporter** - System metrics collector on port 9100
- **Grafana** - Visualization platform on port 3000

---
## Start the Stack

Launch all services:

```terminal:execute
command: docker compose up -d
```

**Verify all containers are running:**

```terminal:execute
command: docker compose ps
```

You should see 3 containers: `grafana`, `prometheus`, and `node-exporter`.

---
## Access Prometheus UI

**Switch to the Prometheus tab** at the top of your workshop interface.

You should see the Prometheus web UI!

**Explore Prometheus:**
1. Click **Status** → **Targets** to see scrape targets
2. Both targets (prometheus and node-exporter) should show as "UP"
3. Try running a query: `up` - shows which targets are up
4. Click **Graph** and try: `node_cpu_seconds_total`

**Prometheus UI features:**
- **Graph** - Query and visualize metrics
- **Alerts** - View active alerts
- **Status** - Check targets, configuration, and runtime info
- **Help** - PromQL documentation

---
## Verify Prometheus is Collecting Data

**Check Prometheus logs:**

```terminal:execute
command: docker compose logs prometheus | tail -20
```

**Check if Prometheus is scraping targets:**

```terminal:execute
command: curl -s http://localhost:9090/api/v1/targets | grep -o '"health":"[^"]*"' | head -5
```

You should see `"health":"up"` for both targets.

---
## Access Grafana

**Switch to the Grafana tab** and log in:
- Username: `admin`
- Password: `admin`

---
## Add Prometheus Data Source

Now let's configure Prometheus as a data source in Grafana.

**Step 1: Navigate to Data Sources**
1. In Grafana, click **Connections** → **Data sources** (in the left menu)
2. Click **Add data source**
3. Select **Prometheus**

**Step 2: Configure Prometheus**
Fill in the following:
- **Name:** `Prometheus`
- **URL:** `http://prometheus:9090`
- Leave other settings as default

**Step 3: Save and Test**
1. Scroll down and click **Save & Test**
2. You should see a green message: ✅ "Successfully queried the Prometheus API."

---
## Explore Metrics

Let's verify we can query Prometheus data:

**Step 1: Go to Explore**
1. Click **Explore** in the left menu (compass icon)
2. Select **Prometheus** as the data source

**Step 2: Try some queries**

In the query builder, try these PromQL queries:

**Query 1: CPU usage**
```promql
rate(node_cpu_seconds_total{mode="user"}[5m])
```

**Query 2: Memory available**
```promql
node_memory_MemAvailable_bytes
```

**Query 3: Network traffic**
```promql
rate(node_network_receive_bytes_total[5m])
```

Click **Run query** to see the results!

---
## Create Your First Dashboard

Let's create a dashboard with real Prometheus metrics.

**Step 1: Create Dashboard**
1. Click **Dashboards** → **New** → **New Dashboard**
2. Click **Add visualization**
3. Select **Prometheus** as data source

**Step 2: Add CPU Usage Panel**
- **Query:** `rate(node_cpu_seconds_total{mode="user"}[5m])`
- **Title:** `CPU Usage (User Mode)`
- **Visualization:** Time series
- Click **Apply**

**Step 3: Add Memory Panel**
1. Click **Add** → **Visualization**
2. Select **Prometheus**
3. **Query:** `node_memory_MemAvailable_bytes / 1024 / 1024`
4. **Title:** `Available Memory (MB)`
5. **Visualization:** Stat
6. **Unit:** Set to `short` (under Standard options → Unit)
7. Click **Apply**

**Step 4: Add Network Traffic Panel**
1. Click **Add** → **Visualization**
2. Select **Prometheus**
3. **Query:** `rate(node_network_receive_bytes_total[5m])`
4. **Title:** `Network Receive Rate`
5. **Visualization:** Time series
6. Click **Apply**

**Step 5: Save Dashboard**
1. Click the **Save** icon (💾)
2. Name: `Node Exporter Metrics`
3. Click **Save**

---
## Understanding PromQL

**PromQL** (Prometheus Query Language) is powerful for querying time-series data.

**Common patterns:**

**Rate of change:**
```promql
rate(metric_name[5m])
```

**Aggregate by label:**
```promql
sum by (cpu) (rate(node_cpu_seconds_total[5m]))
```

**Filter by label:**
```promql
node_cpu_seconds_total{mode="idle"}
```

**Documentation:** https://prometheus.io/docs/prometheus/latest/querying/basics/

---
## Exercise: Explore More Metrics

Try creating additional panels with these queries:

**Disk usage:**
```promql
node_filesystem_avail_bytes{fstype!="tmpfs"} / 1024 / 1024 / 1024
```

**System load:**
```promql
node_load1
```

**Network transmit:**
```promql
rate(node_network_transmit_bytes_total[5m])
```

---
## Key Takeaways

✅ **Prometheus** excels at metrics monitoring  
✅ **PromQL** provides powerful query capabilities  
✅ **Node Exporter** provides system metrics  
✅ **Grafana + Prometheus** is the standard for monitoring  

---

> You've successfully connected Grafana to Prometheus and created metric visualizations!

Proceed to InfluxDB data source.
