# Kafka Monitoring & Observability Workshop

Master Apache Kafka monitoring using CLI tools, JMX Exporter, Kafka Exporter, Prometheus, and Grafana.

## Overview

This hands-on workshop teaches comprehensive Kafka observability through progressive levels:

1. **CLI Monitoring** - Native Kafka commands for quick diagnostics
2. **JMX Metrics** - Deep broker insights with Prometheus
3. **Kafka Exporter** - Specialized consumer group monitoring  
4. **Grafana Dashboards** - Visual monitoring and alerting

## Workshop Structure

### Modules

- **00-workshop-overview** - Introduction and objectives
- **01-setup-environment** - Deploy Kafka with monitoring stack
- **02-cli-monitoring** - Command-line monitoring techniques
- **03-jmx-monitoring** - JMX Exporter and Prometheus
- **04-kafka-exporter** - Consumer-focused metrics
- **05-grafana-dashboards** - Build custom dashboards
- **99-workshop-summary** - Recap and best practices

### Technology Stack

- **Apache Kafka 7.7.1** - Streaming platform
- **Prometheus 2.48** - Metrics collection
- **Grafana 10.2** - Visualization
- **JMX Exporter 0.20** - JVM metrics
- **Kafka Exporter** - Consumer metrics
- **Kafka UI 0.7.2** - Web interface

## Features

### Traffic Generators

Located in `generators/`:
- `simple-producer.sh` - Steady traffic generation
- `burst-producer.sh` - Simulates traffic spikes
- `slow-consumer.sh` - Creates consumer lag scenarios

### Monitoring Configurations

Two docker-compose setups:
1. `docker-compose.yml` - Kafka + JMX Exporter + Prometheus + Grafana
2. `docker-compose-exporter.yml` - Kafka + Kafka Exporter + Prometheus + Grafana

### Prometheus Configuration

- `prometheus/prometheus.yml` - Config for JMX monitoring
- `prometheus/prometheus-exporter.yml` - Config for Kafka Exporter
- `prometheus/jmx-exporter/kafka-broker.yml` - JMX metric mappings

## Prerequisites

- Basic Kafka knowledge (topics, producers, consumers)
- Familiarity with command-line tools
- Understanding of metrics and monitoring concepts

## Learning Outcomes

After completing this workshop, you will be able to:

- Monitor Kafka using native CLI tools
- Expose and collect JMX metrics
- Track consumer lag per partition
- Build Grafana dashboards
- Set up alerts for critical conditions
- Debug performance issues
- Plan capacity based on trends

## Key Metrics Covered

**Broker Metrics:**
- Messages in/out per second
- Bytes in/out per second
- JVM heap usage
- Garbage collection
- Under-replicated partitions

**Consumer Metrics:**
- Consumer lag (total and per partition)
- Current offset
- Commit rate
- Consumer group members

**Topic Metrics:**
- Partition count
- Replication factor
- Offset range per partition

## Quick Start

```bash
# Start environment
docker compose up -d

# Download JMX Exporter
cd prometheus/jmx-exporter
./download-jmx-exporter.sh

# Create test topic
docker exec kafka kafka-topics --create \
  --topic monitoring-demo \
  --partitions 3 \
  --replication-factor 1 \
  --bootstrap-server localhost:9092

# Start traffic generator
./generators/simple-producer.sh monitoring-demo 10
```

## Access Points

- **Kafka UI**: http://localhost:8080
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000

## Best Practices Demonstrated

- Multi-layer monitoring (CLI, metrics, dashboards)
- Consumer lag tracking and alerting
- JVM health monitoring
- Dashboard organization
- Alert threshold configuration
- Metric retention strategies

## Production Readiness

This workshop demonstrates production-ready monitoring:

- ✅ High-availability metric collection
- ✅ Long-term metric storage
- ✅ Multi-level alerting
- ✅ Performance testing tools
- ✅ Capacity planning metrics

## Workshop Duration

Estimated: **2.5 hours**

- Setup: 15 minutes
- CLI Monitoring: 30 minutes
- JMX Monitoring: 45 minutes
- Kafka Exporter: 30 minutes
- Grafana: 30 minutes

## Support

For issues or questions:
- Check workshop content in `workshop/content/`
- Review configurations in `prometheus/` and `grafana/`
- Examine docker-compose files for service setup

## License

Educational use for Educates platform workshops.

---

**Happy Monitoring!** 📊🚀
