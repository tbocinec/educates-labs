# Step 01 - Launch Grafana and Loki

In this step, you'll start the complete logging stack using Docker Compose.

---
## Navigate to Workshop Directory

Open a terminal and copy workshop files to your home directory:

```terminal:execute
command: mkdir -p ~/loki-workshop && cp -r /opt/workshop/files/* ~/loki-workshop/ && cd ~/loki-workshop
```

View the files:

```terminal:execute
command: ls -la
```

You should see:
- `docker-compose.yml` - Complete logging stack setup
- `loki-config.yml` - Loki configuration
- `promtail-config.yml` - Log collector configuration

---
## Start the Logging Stack

Launch all services:

```terminal:execute
command: docker compose up -d
```

This starts three services:
- **Loki** - Log storage backend (port 3100)
- **Promtail** - Log collector (port 9080) 
- **Grafana** - Visualization UI (port 3000)

---
## Verify Services are Running

Check that all containers started:

```terminal:execute
command: sleep 10 && docker compose ps
```

**Expected:** All services should show **Up** status.

---
## What is Grafana Loki?

**Loki** is a log aggregation system inspired by Prometheus:

### Key Features:
- **Label-based indexing** - Only indexes labels, not full log content
- **Cost-effective** - Lower storage requirements than traditional logging
- **PromQL-like queries** - Uses LogQL (similar to Prometheus)
- **Grafana integration** - Native support in Grafana

### Architecture:
```
Applications → Promtail → Loki → Grafana
```

- **Promtail** - Discovers and ships logs
- **Loki** - Stores logs with labels 
- **Grafana** - Queries and visualizes logs

### Why Loki vs Traditional Logging?
- ✅ **Cheaper** - Only indexes labels (not content)
- ✅ **Simpler** - Easy to operate and scale
- ✅ **Familiar** - Uses concepts from Prometheus
- ✅ **Integrated** - Built for Grafana ecosystem

---
## Access Grafana

Open Grafana using the **Grafana** dashboard tab.

**Login credentials:**
- Username: `admin`
- Password: `admin`

---
## Key Takeaways

✅ Launched complete Loki logging stack  
✅ Understood Loki architecture and benefits  
✅ Accessed Grafana UI successfully  

---

Next, you'll configure Loki as a data source in Grafana!
