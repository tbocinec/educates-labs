# Step 07 - Create Your First Dashboard 🎯

Now it's time to put your knowledge into practice! This is a **playground session** where you'll explore different panel types and create your first dashboard.

---
## About TestData DB

Grafana includes a built-in data source called **TestData DB** that generates sample data. This is perfect for:
- Learning and experimenting
- Testing visualizations without a real data source
- Creating demo dashboards

**TestData DB** is already configured and provides various scenario types:
- Random walk (time series data)
- CSV content
- Streaming data
- Predictable pulse patterns
- And more!

---
## Hands-On Exercise: Build Your First Dashboard

### Step 1: Create a New Dashboard

1. Click **Dashboards** in the left sidebar
2. Click **New** → **New Dashboard**
3. Click **+ Add visualization**
4. Select **-- Grafana --** (TestData DB) as the data source

### Step 2: Create a Time Series Panel

You should now see the panel editor.

**Configure the query:**
1. In the ** Query type ** dropdown, select **Random Walk**
2. Leave other settings as default
3. Notice the graph automatically appears!

**Customize the panel:**
1. On the right side, find **Panel options**
2. Change **Title** to: `Random Metrics`
3. Scroll down to **Graph styles**
4. Try changing (let's play with Grafana :) ):
   - **Style** (Lines, Bars, Points)
   - **Line width**
   - **Fill opacity**
1. Click **Back to dashboard** (top right of dashboard)


### Step 3: Add a Stat Panel

1. Click **Add** → **Visualization** (top right of dashboard)
2. Select ** --Grafana-- ** again
3. **Scenario**: Random Walk
4. In the visualization picker (right side), select **Stat**
5. Set **Panel title**: `Current Value`
6. Under **Stat styles**, try:
   - **Graph mode**: Area
   - **Text mode**: Value and name
   - **Color mode**: Background
7. Click **Back to dashboard** (top right of dashboard)

### Step 4: Add a Gauge Panel

1. Add another visualization
2. Select ** --Grafana-- ** again
3. Scenario: **Random Walk**
4. Visualization type: **Gauge**
5. Panel title: `Performance Gauge`
6. Under **Gauge**:
   - **Min**: 0
   - **Max**: 100
   - Try different **orientation** options
7. Click **Back to dashboard** (top right of dashboard)


### Step 6: Arrange Your Panels

**Resize panels:**
- Hover over panel edge until you see resize cursor
- Click and drag to resize

**Add rows:**
- Click **Add** → **Row**

**Move panels:**
- Click and drag panel title bar to reposition
- Panels snap to grid for alignment

**Organize your layout:**
- Try creating a 2x2 grid
- Or place the graph on top spanning full width
- Smaller panels (stat, gauge) below

### Step 7: Save Your Dashboard

1. Click **Save** icon (💾 disk icon, top right)
2. Give it a name: `My Practice Dashboard`
3. Optionally add a description
4. Click **Save**

---
## Explore More Panel Options

Feel free to experiment! This is your **playground** to learn:

**Try different visualizations:**
- Pie Chart (use the plugin we installed!)
- Bar Chart
- Heatmap
- Text panel (add documentation)

**Customize colors and thresholds:**
- Set color thresholds (green < 50, yellow < 75, red >= 75)
- Change color schemes
- Add units (bytes, percent, requests/sec)

**Add panel descriptions:**
- In panel edit mode, scroll to **Panel options**
- Add **Description** - appears as info icon (ℹ️) on panel

---
## 🏆 FINAL CHALLENGE - Competition Time!

**Your Mission:**
Create a visualization with a **Text Panel** that displays:

> **Moj prvý dashboard v Grafane**

**🎁 Prize:** The **first person** to complete this task and show it to the instructor will receive a **small gift**!

---

## About Future Learning

This workshop introduces you to Grafana basics. In more advanced workshops, you'll learn:
- Connecting to real data sources (Prometheus, InfluxDB, MySQL)
- Creating complex queries and transformations
- Setting up alerts and notifications
- Using variables for dynamic dashboards
- Creating dashboard templates
- Advanced visualization techniques

For now, use this playground to familiarize yourself with the interface and panel types!

---

> Excellent work! You've explored Grafana UI and created your first dashboard. This playground experience will help you in future advanced workshops!

Proceed to workshop summary.
