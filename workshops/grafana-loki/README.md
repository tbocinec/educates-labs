# Grafana Loki - Log Aggregation Workshop

This Educates workshop teaches how to set up and use Grafana Loki for log aggregation and visualization.

## Overview

Learn how to:
- Launch Grafana, Loki, and Promtail using Docker Compose
- Configure Loki as a Grafana data source
- Automatically collect container logs with Promtail
- Explore logs from Grafana itself
- Search and filter logs using LogQL
- Create dashboards with log data
- Understand real-world log aggregation pipelines

## Duration

Approximately 30 minutes

## Workshop Structure

1. **Workshop Overview** - Introduction to Loki and log aggregation
2. **Launch Services** - Start Grafana and Loki with Docker Compose
3. **Configure Loki** - Add Loki as a data source in Grafana
4. **Generate and Explore Logs** - Create sample logs and explore them
5. **Workshop Summary** - Key takeaways and next steps

## What You'll Do

- ✅ Start Grafana, Loki, and Promtail in Docker containers
- ✅ Configure Loki as a Grafana data source
- ✅ View logs that Grafana generates
- ✅ Explore logs using Grafana's Log Explorer
- ✅ Filter logs by service and container
- ✅ Write LogQL queries
- ✅ Create a dashboard panel with logs
- ✅ Understand the log collection pipeline

## Prerequisites

- Docker and Docker Compose installed
- Basic familiarity with Docker
- Web browser for Grafana UI

## Files

- `docker-compose.yml` - Container configuration for Grafana, Loki, and Promtail
- `loki-config.yml` - Loki configuration file
- `promtail-config.yml` - Promtail configuration for collecting Docker logs
- `generate-logs.sh` - Optional: Script to generate additional sample logs

## Key Concepts

### Loki
- Log aggregation system designed for Grafana
- Uses labels for indexing (not full text search)
- Lower resource footprint than traditional logging

### LogQL
- Query language for Loki
- Similar to Prometheus query language
- Supports filtering by labels and log content

### Grafana Integration
- Loki appears as a data source in Grafana
- Explore view for ad-hoc log queries
- Dashboards can include log visualizations

## Useful Resources

- [Grafana Loki Documentation](https://grafana.com/docs/loki/)
- [LogQL Query Language](https://grafana.com/docs/loki/latest/logql/)
- [Grafana Documentation](https://grafana.com/docs/grafana/)
- [Docker Documentation](https://docs.docker.com/)

## Quick Start

1. Navigate to the workshop files:
   ```bash
   cd ~/loki-workshop
   ```

2. Start services:
   ```bash
   docker compose up -d
   ```

3. Access Grafana:
   - URL: http://localhost:3000
   - Username: admin
   - Password: admin

4. Generate logs:
   ```bash
   ./generate-logs.sh
   ```

5. Explore logs in Grafana → Explore → Loki

## Cleanup

When finished, stop the containers:

```bash
docker compose down
```

To also remove volumes:

```bash
docker compose down -v
```

---

To publish via GitHub Action ensure a tag `X.Y` is pushed and the action `publish-multiple-workshops` includes this directory.
