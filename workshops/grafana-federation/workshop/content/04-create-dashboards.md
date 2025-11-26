# Step 04 - Create Federated Dashboards

In this final step, you'll create powerful unified dashboards that combine sensor data and business metrics from both federated Grafana sources.

---
## Understanding Unified Dashboards

**What makes federation powerful:**
- 🏢 **Operational + Business correlation** - See how infrastructure affects business
- 🔗 **Cross-system insights** - Connect sensor data to business performance  
- 📊 **Single view** - All critical metrics in one dashboard
- ⚡ **Real-time federation** - Live data from multiple sources

---
## Create Unified Dashboard

**In Federation Grafana (http://localhost:3000):**

1. **Navigate:** **+ Create** → **Dashboard**
2. **Click:** **+ Add visualization**

### Panel 1: Temperature Monitoring

**Data Source:** `Grafana Sensors`

**Query Configuration:**
- Browse available queries from sensor Grafana
- Select temperature metric from InfluxDB
- Configure time range and aggregation

**Panel Settings:**
- **Title:** `Office Temperature`
- **Visualization:** `Time series`
- **Unit:** `Temperature (°C)`
- **Thresholds:** 
  - Green: 18-25°C
  - Yellow: 15-18°C, 25-30°C
  - Red: <15°C, >30°C

### Panel 2: Sales Performance

**Add new panel:** **+ Add panel**

**Data Source:** `Grafana Business`

**Query Configuration:**
- Browse available queries from business Grafana
- Select sales metrics from ClickHouse
- Choose appropriate time aggregation

**Panel Settings:**
- **Title:** `Sales by Region`
- **Visualization:** `Pie chart`
- **Legend placement:** `Right`

### Panel 3: Environment vs Business Correlation

**Add new panel:** **+ Add panel**

**This panel shows both data sources side-by-side:**

**Query A - Temperature:**
- **Data Source:** `Grafana Sensors`
- **Metric:** Temperature from sensors
- **Legend:** `Office Temperature`

**Query B - Website Performance:**
- **Data Source:** `Grafana Business`
- **Metric:** Response time from ClickHouse
- **Legend:** `Website Response Time`

**Panel Settings:**
- **Title:** `Environment Impact on Performance`
- **Visualization:** `Time series`
- **Left Y-axis:** Temperature (°C)
- **Right Y-axis:** Response Time (ms)

### Panel 4: System Health Overview

**Add new panel:** **+ Add panel**

**Multi-source status panel:**

**Query A - Sensor Status:**
- **Data Source:** `Grafana Sensors`
- **Metric:** Latest sensor readings
- **Transform:** Last value

**Query B - Server Performance:**
- **Data Source:** `Grafana Business`
- **Metric:** CPU/Memory from ClickHouse
- **Transform:** Current values

**Panel Settings:**
- **Title:** `System Health Status`
- **Visualization:** `Stat`
- **Color mode:** `Value`
- **Graph mode:** `Area`

### Panel 5: Business Impact Summary

**Add new panel:** **+ Add panel**

**Data Source:** `Grafana Business`

**Query Configuration:**
- Aggregate sales data by time period
- Show total revenue and transaction count
- Include regional breakdown

**Panel Settings:**
- **Title:** `Business Summary (24h)`
- **Visualization:** `Table`
- **Show totals:** ✅
- **Sort by:** Revenue (descending)

---
## Save and Configure Dashboard

### Save Dashboard

1. **Click:** 💾 **Save dashboard**
2. **Dashboard name:** `Unified Operations Dashboard`
3. **Description:** `Combined sensor and business monitoring via federation`
4. **Folder:** `General`
5. **Click:** **Save**

### Configure Dashboard Settings

1. **Click:** ⚙️ **Dashboard settings**
2. **General tab:**
   - **Tags:** `federation`, `unified`, `sensors`, `business`
   - **Timezone:** `Browser`
   - **Auto-refresh:** `1m`

3. **Variables tab:**
   - **Add variable:** Time range selector
   - **Name:** `time_range`
   - **Type:** `Interval`
   - **Values:** `5m,15m,1h,6h,24h`

4. **Links tab:**
   - **Add link:** Source dashboards
   - **Title:** `Sensor Details`
   - **URL:** `http://localhost:3001`
   - **Title:** `Business Details` 
   - **URL:** `http://localhost:3002`

---
## Advanced Federation Techniques

### Mixed Data Source Panels

**Combine different data types:**

**Temperature + Sales correlation:**
```
Theory: Higher office temperature might affect:
- Employee productivity
- System performance
- Customer service quality
- Sales conversion rates
```

**Create correlation panel:**
1. **Query A:** Temperature from sensors
2. **Query B:** Sales rate from business data
3. **Visualization:** Dual-axis time series
4. **Analysis:** Look for patterns

### Cross-System Alerting

**Create alerts that span both systems:**

**Example alert rule:**
- **Condition:** Temperature > 28°C AND Response time > 500ms
- **Evaluation:** Every 1m for 5m
- **Action:** Notify operations team

### Dashboard Templates

**Create reusable dashboard patterns:**

**Template variables:**
- `$sensor_location` - Filter by office location
- `$business_region` - Filter by sales region
- `$time_range` - Adjustable time periods

**Use in queries:**
```
Temperature WHERE location = '$sensor_location'
Sales WHERE region = '$business_region'
```

---
## Real-World Use Cases

### Smart Office Monitoring

**Scenario:**
- **Environmental sensors** track office conditions
- **Business systems** monitor productivity metrics
- **Correlation** shows environment impact on performance

**Dashboard panels:**
- Temperature, humidity, air quality
- Employee productivity metrics
- System performance indicators
- Cost/energy optimization

### Retail Store Analytics

**Scenario:**
- **IoT sensors** monitor foot traffic, temperature
- **POS systems** track sales, inventory
- **Federation** creates unified store dashboard

**Insights:**
- Optimal store temperature for sales
- Traffic patterns vs conversion rates
- Inventory levels vs sensor data
- Energy costs vs comfort vs sales

### Manufacturing Operations

**Scenario:**
- **Industrial sensors** monitor equipment
- **ERP systems** track production metrics
- **Quality systems** monitor output

**Unified view:**
- Equipment health vs production quality
- Energy consumption vs output
- Maintenance needs vs production schedule
- Cost optimization opportunities

---
## Dashboard Performance Optimization

### Query Efficiency

**Best practices:**
- ✅ **Limit data ranges** - Don't query more than needed
- ✅ **Use aggregations** - GROUP BY for large datasets
- ✅ **Cache frequently used queries** - Reduce source load
- ✅ **Optimize refresh rates** - Balance freshness vs performance

### Visual Optimization

**Dashboard design:**
- 📊 **Logical grouping** - Related panels together
- 🎨 **Consistent styling** - Same units, colors, formats
- 📱 **Responsive layout** - Works on different screen sizes
- ⚡ **Fast loading** - Minimize complex visualizations

### Federation Monitoring

**Monitor federation health:**
- 📈 **Query response times** from each source
- ❌ **Error rates** in federated queries
- 🌐 **Network latency** between Grafanas
- 💾 **Resource usage** on federation instance

---
## Testing Your Unified Dashboard

### Generate More Test Data

**To add fresh data for testing:**

```terminal:execute
command: ./regenerate-all-data.sh
background: false
```

This will regenerate all sensor and business data with new timestamps.

### Observe Federation

**Watch for:**
- 📊 **Data updates** in federated panels
- ⚡ **Real-time refresh** across sources
- 🔗 **Correlation patterns** between sensor and business data
- 📈 **Performance** of federated queries

### Validate Data Flow

**Check data path:**
1. **Source systems** (InfluxDB, ClickHouse) have data
2. **Source Grafanas** can query their data sources
3. **Federation Grafana** can query source Grafanas
4. **Unified dashboard** displays combined data

---
## Key Takeaways

✅ **Unified Dashboard Created** - Single view of multiple data sources  
✅ **Cross-System Correlation** - Sensor data + business metrics  
✅ **Real-Time Federation** - Live data from multiple Grafanas  
✅ **Advanced Techniques** - Mixed panels, alerting, templates  
✅ **Performance Optimized** - Efficient queries and visualization  
✅ **Production Ready** - Scalable federation pattern  

---

🎉 **Congratulations!** You've successfully implemented Grafana federation and created unified monitoring dashboards!

**What you've accomplished:**
- **Deployed multi-Grafana architecture** with specialized data sources
- **Configured federation** between Grafana instances
- **Created unified dashboards** combining sensor and business data
- **Learned federation concepts** applicable to enterprise environments

**This pattern enables:**
- **Scalable monitoring** across multiple teams and systems
- **Centralized insights** without data duplication
- **Team autonomy** with enterprise oversight
- **Cross-system correlation** for better decision making

**Next:** Workshop Summary