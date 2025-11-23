# Workshop Summary

# Workshop Summary

Congratulations! 🎉 You've completed the **Grafana Data Sources Workshop**!

---
## What You Learned

In this workshop, you learned how to:

✅ **Connect Grafana to Prometheus** - Monitor metrics and system performance  
✅ **Connect Grafana to InfluxDB** - Visualize time-series and sensor data  
✅ **Connect Grafana to ClickHouse** - Analyze web analytics and business data  
✅ **Use Docker Compose** for complete monitoring stacks  
✅ **Query different data sources** with their native languages  
✅ **Create dashboards** for various use cases

---
## Data Source Comparison

| Feature | Prometheus | InfluxDB | ClickHouse |
|---------|-----------|----------|------------|
| **Best For** | Metrics & Monitoring | Time-series & IoT | Analytics & OLAP |
| **Query Language** | PromQL | Flux | SQL |
| **Storage** | Time-series | Time-series | Column-oriented |
| **Use Cases** | K8s monitoring, Infrastructure | Sensor data, IoT | Web analytics, BI |
| **Retention** | Limited | Built-in policies | Highly efficient |

---
## Key Concepts Review

### Prometheus
- **PromQL** for powerful metric queries
- **Node Exporter** for system metrics
- **rate()** and **aggregation** functions
- Perfect for **Kubernetes** and **microservices**

### InfluxDB
- **Flux** language for data transformation
- Built-in **retention policies**
- Optimized for **high-frequency** writes
- Ideal for **IoT** and **sensor data**

### ClickHouse
- **SQL-based** queries with extensions
- **Column-oriented** for fast aggregations
- **Analytical** workloads
- Great for **web analytics** and **business intelligence**

---
## Docker Compose Configurations

All exercise files are available in:

**Prometheus:**
```bash
~/prometheus/
  ├── docker-compose.yml
  └── prometheus.yml
```

**InfluxDB:**
```bash
~/influxdb/
  └── docker-compose.yml
```

**ClickHouse:**
```bash
~/clickhouse/
  └── docker-compose.yml
```

You can reuse these configurations for your own projects!

---
## Query Examples

### Prometheus (PromQL)
```promql
# CPU usage rate
rate(node_cpu_seconds_total[5m])

# Memory available
node_memory_MemAvailable_bytes / 1024 / 1024

# Aggregate by label
sum by (cpu) (rate(node_cpu_seconds_total[5m]))
```

### InfluxDB (Flux)
```flux
# Last value
from(bucket: "mybucket")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> last()

# Mean over window
from(bucket: "mybucket")
  |> range(start: -1h)
  |> aggregateWindow(every: 5m, fn: mean)
```

### ClickHouse (SQL)
```sql
-- Time-based aggregation
SELECT 
    toStartOfInterval(event_time, INTERVAL 5 MINUTE) as time,
    count() as views
FROM page_views
WHERE $__timeFilter(event_time)
GROUP BY time
ORDER BY time

-- Unique count
SELECT uniq(user_id) FROM page_views
```

---
## Next Steps

Ready to learn more? Explore these topics:

1. **Advanced Queries**
   - Complex PromQL aggregations
   - Flux transformations and joins
   - ClickHouse window functions

2. **Alerting**
   - Set up alerts on metric thresholds
   - Configure notification channels
   - Create alert rules for anomalies

3. **Additional Data Sources**
   - MySQL/PostgreSQL for relational data
   - Elasticsearch for logs
   - Loki for log aggregation
   - Tempo for distributed tracing

4. **Production Best Practices**
   - High availability setups
   - Data retention policies
   - Query optimization
   - Security and authentication

---
## Resources

📚 **Prometheus:**
- Documentation: https://prometheus.io/docs/
- PromQL Guide: https://prometheus.io/docs/prometheus/latest/querying/basics/

📚 **InfluxDB:**
- Documentation: https://docs.influxdata.com/
- Flux Language: https://docs.influxdata.com/flux/

📚 **ClickHouse:**
- Documentation: https://clickhouse.com/docs
- SQL Reference: https://clickhouse.com/docs/en/sql-reference/

📚 **Grafana:**
- Data Sources: https://grafana.com/docs/grafana/latest/datasources/
- Dashboards: https://grafana.com/grafana/dashboards/

---

Thank you for participating! 🚀

You now have the skills to connect Grafana to multiple data sources and create comprehensive monitoring and analytics dashboards!

Happy monitoring! 📊
