# Grafana Dashboards

Build comprehensive Kafka monitoring dashboards in Grafana using the metrics we've explored.

## Access Grafana

Click the **Grafana** tab above. You should see the Grafana interface with anonymous access enabled (no login required).

## Verify Prometheus Data Source

1. Click the menu icon (☰) in the top-left
2. Go to **Connections** → **Data sources**
3. You should see **Prometheus** configured and ready

## Create Your First Dashboard

### Method 1: Via UI

1. Click **Dashboards** in the left menu
2. Click **New** → **New Dashboard**
3. Click **Add visualization**
4. Select **Prometheus** as the data source

### Method 2: Import Pre-built Dashboard

Let's import a Kafka dashboard from Grafana's community:

1. Click **Dashboards** → **New** → **Import**
2. Enter dashboard ID: **7589** (Kafka Exporter Overview)
3. Click **Load**
4. Select **Prometheus** as the data source
5. Click **Import**

## Build a Custom Consumer Lag Dashboard

Let's create a dashboard focused on consumer lag monitoring:

### Panel 1: Total Lag per Consumer Group

1. Create new dashboard: **Dashboards** → **New Dashboard**
2. Click **Add visualization**
3. Select **Prometheus**
4. In the query field, enter:
   ```
   sum by (consumergroup) (kafka_consumergroup_lag)
   ```
5. Set visualization to **Time series**
6. Panel title: "Consumer Group Lag"
7. Click **Apply**

### Panel 2: Lag Growth Rate

1. Click **Add** → **Visualization**
2. Query:
   ```
   rate(kafka_consumergroup_lag[5m])
   ```
3. Set visualization to **Time series**
4. Title: "Lag Growth Rate (msg/sec)"
5. In **Field** tab, set:
   - Unit: `msg/sec`
   - Thresholds: Green (< 0), Yellow (0-10), Red (> 10)
6. Click **Apply**

### Panel 3: Messages per Second

1. Add new visualization
2. Query:
   ```
   rate(kafka_consumergroup_current_offset[1m])
   ```
3. Title: "Consumer Throughput"
4. Visualization: **Time series**
5. Click **Apply**

### Panel 4: Consumer Group Status

1. Add **Stat** visualization
2. Query:
   ```
   kafka_consumergroup_members
   ```
3. Title: "Active Consumers"
4. Set thresholds:
   - Red: value == 0
   - Green: value > 0
5. Click **Apply**

### Save the Dashboard

1. Click the **Save** icon (💾) in top-right
2. Name it: "Kafka Consumer Monitoring"
3. Click **Save**

## Create Broker Health Dashboard

### Panel 1: JVM Heap Usage

1. Create another new dashboard
2. Query:
   ```
   (jvm_memory_heap_used / jvm_memory_heap_max) * 100
   ```
3. Visualization: **Gauge**
4. Unit: Percent (0-100)
5. Thresholds:
   - Green: 0-70
   - Yellow: 70-85
   - Red: 85-100
6. Title: "JVM Heap Usage %"

### Panel 2: Message Rate

1. Query:
   ```
   rate(kafka_server_brokertopicmetrics_messagesinpersec_count[1m])
   ```
2. Visualization: **Time series**
3. Title: "Messages In Per Second"

### Panel 3: Bytes In/Out

1. Query A:
   ```
   rate(kafka_server_brokertopicmetrics_bytesinpersec_count[1m])
   ```
2. Query B:
   ```
   rate(kafka_server_brokertopicmetrics_bytesoutpersec_count[1m])
   ```
3. Visualization: **Time series**
4. Title: "Network Throughput"
5. Unit: `bytes/sec`

### Panel 4: Under-Replicated Partitions

1. Query:
   ```
   kafka_server_replicamanager_underreplicatedpartitions
   ```
2. Visualization: **Stat**
3. Title: "Under-Replicated Partitions"
4. Thresholds:
   - Green: 0
   - Red: > 0

## Generate Load for Visualization

Start traffic generators to see the dashboards come alive:

```terminal:execute
command: |
  # Recreate topic if needed
  docker exec kafka kafka-topics --create \
    --topic monitoring-demo \
    --partitions 3 \
    --replication-factor 1 \
    --bootstrap-server localhost:9092 \
    --if-not-exists
  
  # Start burst producer
  nohup ./generators/burst-producer.sh monitoring-demo > burst.log 2>&1 &
  
  # Start fast consumer
  docker exec -d kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic monitoring-demo \
    --group fast-consumer \
    --from-beginning > /dev/null 2>&1
  
  # Start slow consumer  
  nohup ./generators/slow-consumer.sh monitoring-demo slow-consumer 500 > slow.log 2>&1 &
  
  echo "Traffic generators started!"
  echo "Watch your Grafana dashboards update in real-time"
session: 2
```

## Dashboard Variables

Make dashboards dynamic with variables:

1. Open dashboard settings (gear icon ⚙️)
2. Go to **Variables**
3. Click **Add variable**
4. Configure:
   - **Name**: `consumer_group`
   - **Type**: Query
   - **Data source**: Prometheus
   - **Query**: `label_values(kafka_consumergroup_lag, consumergroup)`
5. Click **Apply**

Now use the variable in queries:
```
kafka_consumergroup_lag{consumergroup="$consumer_group"}
```

## Alert Rules in Grafana

Create alerts directly in Grafana:

1. Edit a panel (e.g., Consumer Lag)
2. Go to **Alert** tab
3. Click **Create alert rule**
4. Set conditions:
   - WHEN: `avg()` of query
   - IS ABOVE: `1000`
   - FOR: `5m`
5. Add notification channel
6. Save

## Pre-built Dashboard JSON

Create a complete dashboard from JSON:

```editor:append-lines-to-file
file: ~/kafka-dashboard.json
text: |
  {
    "dashboard": {
      "title": "Kafka Complete Monitoring",
      "panels": [
        {
          "title": "Consumer Lag",
          "targets": [
            {
              "expr": "sum by (consumergroup) (kafka_consumergroup_lag)"
            }
          ],
          "type": "timeseries"
        },
        {
          "title": "Throughput",
          "targets": [
            {
              "expr": "rate(kafka_consumergroup_current_offset[1m])"
            }
          ],
          "type": "timeseries"
        }
      ]
    }
  }
```

Import it:
1. **Dashboards** → **New** → **Import**
2. Paste the JSON
3. Click **Load**

## Grafana Best Practices

### Organization
- **Folders** - Group dashboards by team/service
- **Tags** - Make dashboards searchable
- **Naming** - Use consistent naming conventions

### Visualization
- **Time series** - For trends over time
- **Stat** - For current values
- **Gauge** - For percentages/ratios
- **Table** - For detailed breakdowns

### Performance
- **Limit time range** - Don't query years of data
- **Use variables** - Reduce dashboard count
- **Cache data** - Set appropriate refresh intervals

### Alerting
- **Set baselines** - Know normal behavior first
- **Use folders** - Organize alerts logically
- **Test notifications** - Verify delivery works

## Explore Features

### 1. Query Inspector

- Click any panel
- Click **⋮** (more options)
- Select **Inspect** → **Query**
- See exact Prometheus query and response

### 2. Dashboard Playlist

Create a playlist to rotate dashboards:
1. **Dashboards** → **Playlists**
2. **New Playlist**
3. Add dashboards
4. Set interval (e.g., 30 seconds)
5. Start playlist for monitoring walls

### 3. Annotations

Mark events on your graphs:
1. Dashboard settings → **Annotations**
2. Add annotation query
3. Events appear as vertical lines

### 4. Dashboard Links

Link related dashboards:
1. Dashboard settings → **Links**
2. Add dashboard link
3. Appears in top-right

## Export and Share

### Share Snapshot

1. Click **Share** icon (in dashboard)
2. Choose **Snapshot**
3. Set expiration
4. Get shareable link

### Export JSON

1. Dashboard settings → **JSON Model**
2. Copy JSON
3. Save to file
4. Share with team

## Production Dashboard Examples

### SRE Dashboard
- Broker health (CPU, memory, disk)
- Topic counts and sizes
- Consumer lag overview
- Alert summary

### Developer Dashboard
- Specific consumer group lag
- Message rates per topic
- Error rates
- Processing latency

### Business Dashboard
- Messages processed (counter)
- Events per minute
- System availability %
- SLA compliance

## Cleanup

Stop the traffic generators:

```terminal:execute
command: |
  pkill -f burst-producer.sh
  pkill -f slow-consumer.sh
  docker exec kafka kafka-consumer-groups --delete --group fast-consumer --bootstrap-server localhost:9092
  docker exec kafka kafka-consumer-groups --delete --group slow-consumer --bootstrap-server localhost:9092
  echo "Cleanup complete"
session: 2
```

## Summary

Grafana provides:
- ✅ **Visual insights** - See patterns at a glance
- ✅ **Alerting** - Proactive problem detection
- ✅ **Sharing** - Team collaboration
- ✅ **Customization** - Tailored to your needs

You now have complete Kafka observability!
