# Grafana Data Sources Workshop

This workshop teaches you how to connect Grafana to various data sources and create comprehensive monitoring and analytics dashboards.

## Overview

Learn how to:
- Connect Grafana to **Prometheus** for metrics monitoring
- Connect Grafana to **InfluxDB** for time-series data
- Connect Grafana to **ClickHouse** for analytical queries
- Use Docker Compose for complete monitoring stacks
- Query data using PromQL, Flux, and SQL
- Create dashboards for different use cases

## Duration

Approximately 2.5 hours

## Prerequisites

- Basic Docker and Docker Compose knowledge
- Grafana basics (recommended: complete Grafana Intro workshops first)
- Understanding of metrics and time-series data

## Workshop Structure

1. **Prometheus Data Source** - Metrics monitoring with Node Exporter
2. **InfluxDB Data Source** - Time-series sensor data
3. **ClickHouse Data Source** - Web analytics and business intelligence

Each section includes:
- Pre-configured Docker Compose setup
- Sample data generation
- Data source configuration
- Dashboard creation exercises

## Key Topics

- **Prometheus**: PromQL queries, metrics monitoring, Node Exporter
- **InfluxDB**: Flux language, time-series data, IoT use cases
- **ClickHouse**: SQL analytics, column-oriented storage, OLAP queries
- Docker Compose for multi-container stacks
- Comparing different data source types

## Use Cases Covered

- **Infrastructure Monitoring** (Prometheus + Node Exporter)
- **IoT Sensor Data** (InfluxDB)
- **Web Analytics** (ClickHouse)

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [InfluxDB Documentation](https://docs.influxdata.com/)
- [ClickHouse Documentation](https://clickhouse.com/docs)
- [Grafana Data Sources](https://grafana.com/docs/grafana/latest/datasources/)

## Related Workshops

- **Grafana Intro Workshop** - Dashboard creation and UI basics
- **Grafana with Docker** - Docker fundamentals for Grafana

Content lives under `workshop/content/` following numbered steps.

To publish via GitHub Action ensure a tag `X.Y` is pushed and the action `publish-multiple-workshops` includes this directory.
