# Grafana Loki - Log Aggregation Workshop

Welcome to the Grafana Loki workshop! In this short workshop, you'll learn how to set up log aggregation using Grafana and Loki.

---
## What You'll Learn

✅ **Set up Grafana + Loki + Promtail** using Docker Compose  
✅ **Configure Loki data source** in Grafana  
✅ **Collect logs automatically** from Grafana container  
✅ **Explore system logs** in Grafana using LogQL queries  
✅ **Search and filter logs** by service, container, and content  
✅ **Understand log aggregation pipeline**  

---
## What is Grafana Loki?

**Loki** is a log aggregation system optimized for Grafana:
- 🐛 **Log Storage** - Stores logs with minimal resources
- 🔍 **LogQL** - Simple query language (similar to Prometheus)
- 📊 **Integration** - Works seamlessly with Grafana
- ⚡ **Lightweight** - Lower resource footprint than traditional logging

**Use cases:**
- Application log aggregation
- Troubleshooting issues
- Performance monitoring
- Audit trail tracking

---
## Workshop Duration

⏱️ **~30 minutes**

---
## What You'll Do

### Step 1: Launch Services
- Start Grafana, Loki, and Promtail with Docker Compose
- Verify all services are running

### Step 2: Configure Data Source
- Add Loki as a data source in Grafana
- Test the connection

### Step 3: Explore Grafana's Logs
- View logs that Grafana itself generates
- See how Promtail collects logs from Docker
- Search logs using LogQL queries

---
## Prerequisites

- Docker and Docker Compose installed
- Basic familiarity with Docker
- Web browser for Grafana UI

---
## Let's Get Started!

Ready? Click **Next** to launch Grafana and Loki! 🚀
