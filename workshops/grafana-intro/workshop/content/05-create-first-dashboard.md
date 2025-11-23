# Step 06 - Exploring Grafana UI

Before creating dashboards, let's familiarize ourselves with Grafana's user interface. Understanding the layout will help you navigate efficiently.

**Switch to the Grafana tab** - your Grafana UI should be running in a separate browser tab. If you don't see it, look for the **Grafana** tab at the top of your workshop interface.

---
## Main Navigation (Left Sidebar)

The left sidebar is your main navigation menu:

**🏠 Home**
- Quick access to recently viewed dashboards
- Starred dashboards for easy access

**📊 Dashboards**
- Browse all dashboards
- Create new dashboards
- Organize dashboards into folders
- Manage dashboard playlists

**🔍 Explore**
- Ad-hoc query interface
- Test queries without creating dashboards
- Useful for data exploration and troubleshooting

**🔔 Alerting**
- Configure alert rules
- View alert history
- Manage notification channels
- Set up contact points

**🔌 Connections**
- **Data sources** - Connect to databases, APIs, and monitoring systems
- **Plugins** - Install and manage visualization plugins

**⚙️ Administration** (Admin only)
- User management
- Organization settings
- Server settings and configuration
- Plugin management
- Service accounts and API keys

**👤 User Profile** (Bottom left)
- Change password
- Update preferences (theme, timezone, language)
- Switch organizations

---
## Dashboard Interface Components

Let's explore the dashboard view by opening the default Home dashboard.

### Top Bar Elements

**Dashboard Title** (Top left)
- Shows current dashboard name
- Click to see dashboard info and settings

**⭐ Star Icon**
- Mark dashboard as favorite for quick access

**📤 Share**
- Share dashboard via link
- Create snapshot (static copy)
- Export dashboard JSON

**⚙️ Dashboard Settings** (Gear icon)
- General settings (name, description, tags)
- Variables configuration
- Annotations
- JSON model (raw dashboard definition)
- Permissions

**🔄 Refresh** (Circular arrow)
- Manual refresh
- Auto-refresh interval settings

**⏰ Time Range Picker** (Top right)
- Select time window for data
- Common ranges: Last 5m, Last 1h, Last 24h, Last 7d
- Custom absolute time ranges
- Relative time ranges (e.g., "now-1h to now")

**🔍 Zoom** (Time range shortcut)
- Click and drag on any graph to zoom into a time range

---
## Panel Types Overview

Grafana supports various visualization types. Here are the most common:

**Time Series (Graph)**
- Line, bar, or point visualization over time
- Most common for metrics monitoring

**Stat**
- Single value display
- Shows current, min, max, or average
- Good for KPIs

**Gauge**
- Visual representation of value within a range
- Shows thresholds (green/yellow/red)

**Bar Chart / Bar Gauge**
- Compare multiple values
- Horizontal or vertical orientation

**Table**
- Tabular data display
- Sortable columns
- Good for logs and structured data

**Pie Chart / Donut Chart**
- Show proportions and percentages
- Useful for distribution visualization

**Text Panel**
- Display static text, markdown, or HTML
- Useful for documentation and instructions

**Heatmap**
- Visualize data density over time
- Color intensity shows value magnitude

---
## Hands-On: Explore the Interface

### Step 1: Navigate to Dashboards

1. Click **Dashboards** in the left sidebar
2. Click **New** → **New Dashboard**
3. Notice the "Add visualization" button
4. **Don't add anything** - just observe the options

### Step 2: Explore Data Sources

1. Click **Connections** in the left sidebar
2. Click **Data sources**
3. Click **Add data source**
4. Browse available data source types (Prometheus, MySQL, PostgreSQL, etc.)
5. **Don't add anything** - just observe the options

### Step 3: Check Installed Plugins

1. Still in **Administrations**, click **Plugins and data** click **Plugins**
2. Browse installed plugins
3. You should see the **Pie Chart** plugin we installed earlier via CLI
4. You can also see built-in plugins like Time series, Table, Stat, etc.

### Step 4: Explore User Settings

1. Click your **user icon** (bottom left)
2. Click **Preferences**
3. Notice options for:
   - **UI Theme** (Dark/Light)
   - **Home Dashboard** (default landing page)
   - **Timezone** (browser, UTC, or specific timezone)
   - **Week start** (Sunday/Monday)

Feel free to change the theme or timezone!

---

> You now understand Grafana's interface and navigation!

Proceed to creating your first dashboard.
