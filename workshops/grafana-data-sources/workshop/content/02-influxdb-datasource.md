# Step 02 - InfluxDB Data Source

In this section, you'll set up Grafana with InfluxDB and learn how to work with time-series data.

---
## What is InfluxDB?

**InfluxDB** is a high-performance time-series database optimized for fast, high-availability storage and retrieval of time-series data.

**Key features:**
- Purpose-built for time-series data
- SQL-like query language (InfluxQL and Flux)
- High write and query performance
- Built-in retention policies
- Popular for IoT, analytics, and real-time monitoring

**Documentation:** https://docs.influxdata.com/

---
## Clean Up Previous Setup

Stop the Prometheus stack:

```terminal:execute
command: cd ~/prometheus && docker compose down
```

---
## Prepare InfluxDB Setup

Navigate to the InfluxDB directory:

```terminal:execute
command: mkdir -p ~/influxdb && cp -r /opt/workshop/files/influxdb/* ~/influxdb/ && cd ~/influxdb
```

**View the prepared Docker Compose file:**

```terminal:execute
command: ls -la
```

You should see `docker-compose.yml`.

**Optional: View the file in the Editor tab**

Switch to the **Editor** tab and open:
- `exercises/influxdb/docker-compose.yml`

**Understanding the setup:**

The `docker-compose.yml` includes:
- **InfluxDB 2.7** - Time-series database on port 8086
- **Grafana** - Visualization platform on port 3000
- Pre-configured with admin credentials and bucket

---
## Start InfluxDB Stack

```terminal:execute
command: docker compose up -d
```

**Wait for services to start:**

```terminal:execute
command: sleep 10 && docker compose ps
```

---
## Access InfluxDB UI

**Switch to the InfluxDB tab** at the top of your workshop interface.

You should see the InfluxDB UI!

**Login to InfluxDB:**
- **Username:** `admin`
- **Password:** `adminpassword`

After login, you'll see the InfluxDB dashboard.

**Explore InfluxDB UI:**
1. Click **Data Explorer** (left menu) - Query builder interface
2. Click **Buckets** - View your `mybucket`
3. Click **Dashboards** - Create InfluxDB-native dashboards
4. Click **Settings** → **Tokens** - View your API token

**Note:** We'll use Grafana for visualization, but InfluxDB has its own powerful UI for data exploration!

---
## Generate Sample Data

Let's write some sample temperature sensor data to InfluxDB.

**The script is already prepared in your directory.**

**View the script (optional):**

```terminal:execute
command: cat generate-data.sh
```

The script uses environment variables for configuration:
- `INFLUXDB_TOKEN` - defaults to `mytoken123456789`
- `INFLUXDB_ORG` - defaults to `myorg`
- `INFLUXDB_BUCKET` - defaults to `mybucket`

**Make it executable and run:**

```terminal:execute
command: chmod +x generate-data.sh && ./generate-data.sh
```

This script will continuously write temperature and humidity data in the background.

---
## Verify Data in InfluxDB

**Option 1: Using CLI**

Check that data is being written:

```terminal:execute
command: docker exec influxdb influx query 'from(bucket:"mybucket") |> range(start:-1h) |> limit(n:5)' --org myorg --token mytoken123456789
```

You should see some data points!

**Option 2: Using InfluxDB UI (Optional)**

1. **Switch to the InfluxDB tab**
2. Click **Data Explorer** in the left menu
3. In the query builder:
   - **FROM:** Select `mybucket`
   - **Filter:** Select `_measurement` → `temperature` (or `humidity`)
   - **Filter:** Select `_field` → `value`
4. Click **Submit** (or use keyboard shortcut)
5. You should see a graph with your sensor data!

**Try exploring:**
- Switch between `temperature` and `humidity` measurements
- Adjust the time range (top right corner)
- Try the **Script Editor** mode to write Flux queries directly

This is a great way to verify data before visualizing it in Grafana!

---
## Add InfluxDB Data Source in Grafana

**Switch to the Grafana tab** (refresh if needed) and log in:
- Username: `admin`
- Password: `admin`

**Step 1: Add Data Source**
1. Go to **Connections** → **Data sources**
2. Click **Add data source**
3. Select **InfluxDB**

**Step 2: Configure InfluxDB**
Fill in the following settings:

**Query Language:** `Flux`

**HTTP:**
- **URL:** `http://influxdb:8086`

**Auth:**
- Keep default settings

**InfluxDB Details:**
- **Organization:** `myorg`
- **Token:** `mytoken123456789`
- **Default Bucket:** `mybucket`

**Step 3: Save and Test**
1. Click **Save & Test**
2. You should see: ✅ "datasource is working. 1 buckets found"

---
## Explore Data with Grafana Explore

Before creating dashboards, let's explore the data using **Grafana Explore** - a powerful tool for ad-hoc queries and data exploration.

**Step 1: Open Explore**
1. Click the **Explore** icon (compass) in the left sidebar
2. Select **InfluxDB** as the data source (top dropdown)

**Step 2: Query Temperature Data**

Switch to **Code** mode and enter:

```flux
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> filter(fn: (r) => r._field == "value")
```

Click **Run query** (or Shift+Enter)

You should see a time-series graph of temperature data!

**Step 3: Try More Queries**

**Query humidity:**
```flux
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "humidity")
  |> filter(fn: (r) => r._field == "value")
```

**Get statistics:**
```flux
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> filter(fn: (r) => r._field == "value")
  |> mean()
```

**Explore features:**
- **Time range picker** - Adjust the time window (top right)
- **Inspector** - View raw data and query stats (bottom panel)
- **Add query** - Compare multiple queries on one graph
- **Table view** - Switch between graph and table format

> **Tip:** Explore is perfect for testing queries before adding them to dashboards!

---
## Create Temperature Dashboard

Let's visualize our sensor data!

**Step 1: Create New Dashboard**
1. Click **Dashboards** → **New** → **New Dashboard**
2. Click **Add visualization**
3. Select **InfluxDB** as data source

**Step 2: Query Temperature Data**

Switch to **Code** mode (toggle in query editor) and enter:

```flux
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> filter(fn: (r) => r._field == "value")
```

**Panel Settings:**
- **Title:** `Office Temperature`
- **Visualization:** Time series
- **Unit:** Celsius (°C) - under Standard options → Unit

Click **Apply**

**Step 3: Add Humidity Panel**
1. Click **Add** → **Visualization**
2. Select **InfluxDB**
3. Query:

```flux
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "humidity")
  |> filter(fn: (r) => r._field == "value")
```

**Panel Settings:**
- **Title:** `Office Humidity`
- **Visualization:** Time series
- **Unit:** Percent (0-100) - under Standard options → Unit

Click **Apply**

**Step 4: Add Current Temperature Stat**
1. Click **Add** → **Visualization**
2. Select **InfluxDB**
3. Query:

```flux
from(bucket: "mybucket")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> filter(fn: (r) => r._field == "value")
  |> last()
```

**Panel Settings:**
- **Title:** `Current Temperature`
- **Visualization:** Stat
- **Unit:** Celsius (°C)
- **Graph mode:** Area

Click **Apply**

**Step 5: Save Dashboard**
1. Click **Save** (💾)
2. Name: `Sensor Monitoring`
3. Click **Save**

---
## Understanding Flux Query Language

**Flux** is InfluxDB's powerful query language.

**Basic structure:**
```flux
from(bucket: "mybucket")        // Data source
  |> range(start: -1h)          // Time range
  |> filter(fn: (r) => ...)     // Filter data
  |> aggregateWindow(...)       // Aggregate
```

**Common operations:**

**Last value:**
```flux
|> last()
```

**Mean over window:**
```flux
|> aggregateWindow(every: 5m, fn: mean)
```

**Multiple filters:**
```flux
|> filter(fn: (r) => r._measurement == "temperature" and r.sensor == "sensor1")
```

**Documentation:** https://docs.influxdata.com/flux/

---
## Exercise: Create More Visualizations

Try creating panels for:

**Average temperature (last hour):**
```flux
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> mean()
```

**Min/Max temperature:**
```flux
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> max()  // or min()
```

---
## Key Takeaways

✅ **InfluxDB** is optimized for time-series data  
✅ **Flux** provides powerful data transformation  
✅ Perfect for **IoT and sensor data**  
✅ Built-in **retention policies** for data management  

---

> You've successfully connected Grafana to InfluxDB and visualized time-series data!

Proceed to ClickHouse data source.
