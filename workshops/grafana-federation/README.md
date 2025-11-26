# Grafana Federation Basics Workshop

This workshop teaches the fundamentals of **Grafana federation** - using Grafana as a data source to aggregate and visualize data from multiple Grafana instances.

## Workshop Overview

Learn how to create a unified monitoring solution by federating data across multiple specialized Grafana instances, each connected to different data sources.

## Architecture

- **3 Grafana instances** with specialized purposes
- **InfluxDB** for sensor time-series data 
- **ClickHouse** for business analytics data
- **Docker Compose** for easy deployment

## Learning Objectives

- Deploy multi-Grafana architecture
- Configure Grafana-to-Grafana federation
- Create unified dashboards from federated sources
- Understand federation best practices

## Workshop Structure

1. **Launch Services** - Deploy 3 Grafanas + data sources
2. **Setup Data Sources** - Connect each Grafana to its data source
3. **Configure Federation** - Setup Grafana-to-Grafana connections
4. **Create Dashboards** - Build unified monitoring dashboards

## Sample Data

- **Sensor data** - Temperature and humidity from office sensors
- **Business data** - Sales, website analytics, server performance
- **Real-time federation** - Live data aggregation across sources

## Duration

Approximately 90 minutes with hands-on exercises.

## Prerequisites

- Basic Grafana knowledge
- Docker Compose familiarity
- Understanding of time series and SQL data

Perfect for learning how to scale Grafana monitoring across multiple teams and data sources while maintaining centralized visibility.