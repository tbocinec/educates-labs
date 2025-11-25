# Grafana Alerting Workshop

Welcome to the **Grafana Alerting Workshop**! In this hands-on lab, you will learn to set up complete end-to-end alerting in Grafana.

---
## What You'll Learn

This workshop teaches you how to:

1. **Set up ClickHouse** with realistic API monitoring data
2. **Configure notification channels** using webhooks
3. **Create threshold-based alerts** for API response time
4. **Test and trigger alerts** with real data scenarios

By the end of this workshop, you'll understand the basics of Grafana Unified Alerting!

---
## Workshop Structure

| # | Topic | Duration |
|---|-------|----------|
| 01 | Setup ClickHouse & Data | 20 min |
| 02 | Notification Channels | 20 min |
| 03 | Threshold Alert | 25 min |
| 04 | Testing & Triggering Alert | 20 min |
| 99 | Summary | 5 min |

**Total Duration:** ~90 minutes

---
## Workshop Tabs

You have multiple tabs available at the top:
- **Terminal** - Run Docker commands and scripts
- **Editor** - View configuration files
- **Grafana** - Access Grafana UI (http://localhost:3000)
- **ClickHouse** - Access ClickHouse SQL editor (http://localhost:8123/play)

---
## Alert Scenario

You'll work with a realistic API monitoring scenario:

### 🐌 Slow API Response Time
- **Baseline:** 50-150ms average response time
- **Alert Threshold:** > 500ms
- **Trigger:** Database performance degradation or connection pool exhaustion
- **Endpoint:** `/api/products`

This simple scenario demonstrates the complete alerting workflow from data collection to notification delivery.

---
## Prerequisites

- Basic understanding of Grafana (dashboards, queries)
- Familiarity with time-series concepts
- Basic Docker knowledge

**Tip:** If you're new to Grafana, consider taking the "Grafana Intro" workshop first!

---
## Key Concepts

**Alerting in Grafana:**
- **Alert Rules** - Define conditions that trigger alerts
- **Thresholds** - Values that when crossed, trigger alerts
- **Evaluation** - How often Grafana checks alert conditions
- **Notifications** - How alerts are delivered (email, Slack, etc.)
- **Alert States** - Normal, Pending, Alerting, NoData, Error

**Why Alerting Matters:**
- **Proactive monitoring** - Catch issues before users notice
- **Reduce downtime** - Respond quickly to problems
- **Compliance** - Meet SLA requirements
- **Peace of mind** - Automated 24/7 monitoring

---
## What Makes This Workshop Different?

✅ **Hands-on** - You configure everything yourself  
✅ **Simple** - Focus on one clear scenario  
✅ **End-to-end** - From setup to triggered alert  
✅ **Realistic** - Real-world API monitoring  
✅ **Practical** - Skills you can use immediately  

---

> **Tip:** All shell command blocks are clickable – when you click, the command will be executed in the terminal pane.

Let's get started!

