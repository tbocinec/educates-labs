# Step 03 - Configure Grafana Federation

In this step, you'll configure the main Grafana instance to federate data from both source Grafanas, creating a unified monitoring hub.

---
## Understanding Grafana Federation

**How it works:**
- Grafana can act as a **data source** for another Grafana
- Uses **HTTP API** for communication
- Supports **authentication** and **query forwarding**
- Enables **centralized dashboards** from distributed sources

**Benefits:**
- ✅ **Single pane of glass** - All data in one place
- ✅ **No data duplication** - Data stays at source
- ✅ **Team autonomy** - Each team manages own Grafana
- ✅ **Scalable architecture** - Easy to add new sources

---
## Configure Federation Grafana (Port 3000)

**Open:** http://localhost:3000  
**Login:** admin / admin

### Add Grafana InfluxDB as Data Source

1. **Navigate:** ⚙️ **Configuration** → **Data Sources**
2. **Click:** **Add data source**
3. **Search:** `grafana` and select **Grafana**

**Configuration:**
- **Name:** `Grafana Sensors`
- **URL:** `http://grafana-influx:3000`
- **Access:** `Server (default)`

**Authentication:**
- **Basic Auth:** ✅ Enable
- **User:** `admin`
- **Password:** `admin`

4. **Click:** **Save & Test**

✅ **Expected:** "Data source is working"

### Add Grafana ClickHouse as Data Source

1. **Click:** **Add data source** (again)
2. **Search:** `grafana` and select **Grafana**

**Configuration:**
- **Name:** `Grafana Business`
- **URL:** `http://grafana-clickhouse:3000`
- **Access:** `Server (default)`

**Authentication:**
- **Basic Auth:** ✅ Enable
- **User:** `admin`
- **Password:** `admin`

4. **Click:** **Save & Test**

✅ **Expected:** "Data source is working"

---
## Test Federation Connectivity

### Test Sensor Data Federation

1. **Navigate:** **Explore** (🔍)
2. **Select:** `Grafana Sensors`
3. **Browse available queries** - Should show sensor metrics
4. **Run a query** - Verify data appears

**Expected:** Temperature/humidity data from InfluxDB via Grafana1

### Test Business Data Federation

1. **Change Data Source:** `Grafana Business`
2. **Browse available queries** - Should show business metrics
3. **Run a query** - Verify data appears

**Expected:** Sales/analytics data from ClickHouse via Grafana2

---
## Understanding Federation Flow

**Query Path:**

```
Federation Grafana (3000)
       │
       ▼ HTTP API Request
┌─────────────────────┐    ┌─────────────────────┐
│  Grafana Sensors    │    │  Grafana Business   │
│     (3001)          │    │     (3002)          │
└──────────┬──────────┘    └──────────┬──────────┘
           │                          │
           ▼ Native Query              ▼ Native Query
┌─────────────────────┐    ┌─────────────────────┐
│     InfluxDB        │    │    ClickHouse       │
│  (Sensor Data)      │    │ (Business Data)     │
└─────────────────────┘    └─────────────────────┘
```

**Step-by-step:**
1. **User** queries federation Grafana
2. **Federation Grafana** forwards query to source Grafana
3. **Source Grafana** queries its data source
4. **Data** flows back through the chain
5. **Federation Grafana** displays result

---
## Federation Authentication

### Current Setup: Basic Auth

**Pros:**
- ✅ Simple configuration
- ✅ Works with default admin account
- ✅ No additional setup required

**Cons:**
- ⚠️ Uses admin credentials
- ⚠️ Less secure for production

### Production Alternative: API Keys

**To create API key (optional):**
1. In source Grafana → **Configuration** → **API Keys**
2. **Add API key** with **Viewer** role
3. Use key in federation Grafana:
   - **Auth:** Custom Header
   - **Header:** `Authorization`
   - **Value:** `Bearer your-api-key`

---
## Network Configuration

### Docker Internal Communication

**Container hostnames:**
- `grafana-influx` → Grafana InfluxDB container
- `grafana-clickhouse` → Grafana ClickHouse container
- Docker DNS automatically resolves names

**Port mapping:**
```
Host Port → Container Port
3000      → 3000  (Federation Grafana)
3001      → 3000  (InfluxDB Grafana)
3002      → 3000  (ClickHouse Grafana)
```

**Internal communication uses container names + port 3000**

---
## Troubleshooting Federation

### Test Network Connectivity

**Check if federation can reach source Grafanas:**

```terminal:execute
command: docker exec grafana-federation curl -I http://grafana-influx:3000
background: false
```

```terminal:execute
command: docker exec grafana-federation curl -I http://grafana-clickhouse:3000
background: false
```

**Expected:** HTTP 200 responses

### Test Authentication

**Check if API access works:**

```terminal:execute
command: docker exec grafana-federation curl -u admin:admin http://grafana-influx:3000/api/health
background: false
```

**Expected:** `{"database":"ok",...}`

### Check Federation Logs

**View federation Grafana logs:**

```terminal:execute
command: docker logs grafana-federation --tail 20
background: false
```

**Look for:** Connection errors or authentication failures

---
## Federation Security Best Practices

### Authentication

**Production recommendations:**
- 🔐 **API Keys** instead of basic auth
- 👤 **Service Accounts** for dedicated access
- 🔄 **Token rotation** for security
- 📊 **Audit logging** for access tracking

### Network Security

**Security considerations:**
- 🔒 **HTTPS/TLS** for encrypted communication
- 🛡️ **Firewall rules** to restrict access
- 🌐 **VPN/private networks** for remote federation
- 📝 **Access control** based on roles

### Data Governance

**Control data access:**
- 👥 **Role-based permissions** in source Grafanas
- 🔍 **Query filtering** based on user context
- 📋 **Data retention policies** for compliance
- 🏷️ **Data classification** and labeling

---
## Federation Performance

### Query Optimization

**Best practices:**
- ⏱️ **Limit time ranges** - Avoid querying too much data
- 📊 **Use aggregations** - GROUP BY for large datasets
- 💾 **Enable caching** - Cache frequent queries
- 🔄 **Connection pooling** - Reuse HTTP connections

### Monitoring Federation

**Monitor federation health:**
- 📈 **Query response times** from source Grafanas
- ❌ **Error rates** in federation queries
- 🌐 **Network latency** between Grafanas
- 💾 **Resource usage** on federation instance

---
## Key Takeaways

✅ **Federation Configured** - Main Grafana can query both sources  
✅ **Authentication Working** - Basic auth established successfully  
✅ **Network Connectivity** - Docker containers communicating properly  
✅ **Query Forwarding** - Understanding how queries are proxied  
✅ **Data Access** - Can retrieve data from both InfluxDB and ClickHouse  
✅ **Architecture Understanding** - Federation concepts and flow  

---

Perfect! Your federation is now configured and working. Next, you'll create unified dashboards that combine data from both sources into powerful visualizations.

**Next:** Step 4 - Create Federated Dashboards