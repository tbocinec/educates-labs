# Step 01 - Launch All Services

In this step, you'll deploy the complete federation environment: 3 Grafana instances, InfluxDB, and ClickHouse using Docker Compose.

---
## Understanding the Setup

**Our deployment includes:**

🎛️ **3 Grafana Instances:**
- **grafana-influx** (Port 3001) - Connected to InfluxDB
- **grafana-clickhouse** (Port 3002) - Connected to ClickHouse  
- **grafana-federation** (Port 3000) - Federation hub (main)

📊 **Data Sources:**
- **InfluxDB** (Port 8086) - Time series sensor data
- **ClickHouse** (Port 8123) - Business analytics data

---
## Navigate to Workshop Directory

Open a terminal and copy workshop files to your home directory:

```terminal:execute
command: mkdir -p ~/grafana-federation && cp -r /opt/workshop/files/* ~/grafana-federation/ && cd ~/grafana-federation
background: false
```

View the files:

```terminal:execute
command: ls -la
background: false
```

You should see:
- `docker-compose.yml` - Complete federation stack setup
- `generate-sensor-data.sh` - InfluxDB sensor data generator
- `generate-business-data.sh` - ClickHouse business data generator
- `data/` - ClickHouse table initialization files

---
## Start All Services

**Launch entire stack:**

```terminal:execute
command: docker compose up -d
background: false
```

**Check services status:**

```terminal:execute
command: docker compose ps
background: false
```

**Expected output:**
- ✅ grafana-influx (port 3001)
- ✅ grafana-clickhouse (port 3002)
- ✅ grafana-federation (port 3000)
- ✅ influxdb (port 8086)
- ✅ clickhouse (port 8123)

---
## Access Each Service

### Grafana Federation (Main)
- **URL:** http://localhost:3000
- **Login:** admin / admin
- **Purpose:** Will federate data from other Grafanas

### Grafana InfluxDB
- **URL:** http://localhost:3001
- **Login:** admin / admin  
- **Purpose:** Sensor monitoring dashboards

### Grafana ClickHouse
- **URL:** http://localhost:3002
- **Login:** admin / admin
- **Purpose:** Business analytics dashboards

### InfluxDB
- **URL:** http://localhost:8086
- **Login:** admin / adminpass
- **Purpose:** Time series sensor data

---
## Verify Data Sources

### Check InfluxDB Data

**In InfluxDB UI (http://localhost:8086):**
1. **Login:** admin / adminpass
2. Go to **Data Explorer**
3. **From:** `sensors` (bucket)
4. **Filter:** `_measurement` → `temperature`
5. **Submit** - Should see temperature data

---
## Generate Sample Data

After all services are running, generate sample data for both data sources:

**Generate sensor data for InfluxDB:**

```terminal:execute
command: ./generate-sensor-data.sh
background: false
```

This creates:
- 🌡️ **Temperature data** from 4 locations (office, warehouse, conference, server room)
- 💧 **Humidity data** from the same 4 locations  
- ⏰ **2 hours of historical data** (120 data points per sensor)

**Generate business data for ClickHouse:**

```terminal:execute
command: ./generate-business-data.sh
background: false
```

This creates:
- 💰 **Sales transactions** (100 records across 5 regions)
- 🌐 **Website analytics** (200 page requests with response times)
- 🖥️ **Server performance** (150 metrics from 4 servers)

**Wait for data generation to complete** (about 1-2 minutes total).

---
## Verify Data Sources

### Login to Each Grafana

**Test Grafana Federation:**

```terminal:execute
command: curl -I http://localhost:3000
background: false
```

**Test Grafana InfluxDB:**

```terminal:execute
command: curl -I http://localhost:3001
background: false
```

**Test Grafana ClickHouse:**

```terminal:execute
command: curl -I http://localhost:3002
background: false
```

**All should return HTTP 200 OK**

---
## Understanding Federation Architecture

**Federation Flow:**

```
Data Sources:
InfluxDB ─→ Grafana1 (3001)
ClickHouse ─→ Grafana2 (3002)

Federation:
Grafana1 ─┐
          ├─→ Grafana3 (3000) ─→ Unified Dashboard
Grafana2 ─┘
```

**Key Concepts:**
- 🔗 **Data Source Federation** - Grafana can query other Grafanas
- 🌐 **API Communication** - Uses Grafana HTTP API
- 🔐 **Authentication** - Basic auth or API keys
- 📊 **Query Delegation** - Queries forwarded to source Grafanas

---
## Network Connectivity

**All containers in same Docker network:**
- **grafana-influx** can reach **influxdb**
- **grafana-clickhouse** can reach **clickhouse**  
- **grafana-federation** can reach both other Grafanas
- Docker DNS resolves container names

**Internal hostnames:**
- `influxdb` → InfluxDB container
- `clickhouse` → ClickHouse container
- `grafana-influx` → Grafana1 container
- `grafana-clickhouse` → Grafana2 container

---
## Troubleshooting

**If containers fail to start:**

```terminal:execute
command: docker compose logs
background: false
```

**Check specific service:**

```terminal:execute
command: docker compose logs grafana-federation
background: false
```

**Restart services if needed:**

```terminal:execute
command: docker compose restart
background: false
```

**Check port conflicts:**

```terminal:execute
command: netstat -tlnp | grep -E ":(3000|3001|3002|8086|8123)"
background: false
```

---
## Key Takeaways

✅ **Multi-Grafana Stack Deployed** - 3 Grafana instances running  
✅ **Data Sources Ready** - InfluxDB and ClickHouse with sample data  
✅ **Network Configured** - All containers can communicate  
✅ **Web Interfaces Accessible** - All UIs available on different ports  
✅ **Sample Data Available** - Sensors and business metrics ready  

---

Great! Your federation environment is now running. Next, you'll configure each Grafana with its respective data source.

**Next:** Step 2 - Setup Data Sources