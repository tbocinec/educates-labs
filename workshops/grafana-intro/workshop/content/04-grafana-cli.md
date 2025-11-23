# Step 05 - Grafana CLI

Grafana comes with a powerful command-line interface (CLI) tool called `grafana-cli`. This tool allows you to manage Grafana without using the web interface.

---
## What is Grafana CLI?

The `grafana-cli` tool enables administrators to:
- **Install, update, and remove plugins** - Main focus of this section
- **Manage admin users** - Reset passwords when locked out
- **Database operations** - Migrations and data management
- **Configuration management** - Command-line configuration

---
## Primary Use Case: Plugin Management

The most reliable and commonly used feature of `grafana-cli` is **plugin management**. Let's explore this in detail.

### List Installed Plugins

See what plugins are currently installed:

```terminal:execute
command: grafana-cli plugins ls
```

This shows all installed plugins with their versions.

### Search for Available Plugins

Browse the Grafana plugin catalog:

```terminal:execute
command: grafana-cli plugins list-remote | head -30
```

This displays popular plugins like:
- **Clock panel** - Display current time/date
- **Pie chart** - Pie and donut visualizations
- **Worldmap panel** - Geographic data visualization
- **Bar chart** - Enhanced bar charts
- **Data source plugins** - Connect to various databases and APIs

### Install a Plugin

Let's install the **Clock Panel** plugin:

```terminal:execute
command: grafana-cli plugins install grafana-clock-panel
```

You should see:
- Download progress
- Installation confirmation
- Plugin version information

**Important**: After installing a plugin, you must restart Grafana to load it:

**Stop Grafana:**

```terminal:execute
command: pkill grafana-server
```

**Start Grafana again:**

```terminal:execute
command: /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana > /var/log/grafana/grafana.log 2>&1 &
```

### Verify Plugin Installation

Check that the plugin was installed successfully:

```terminal:execute
command: grafana-cli plugins ls
```

You should now see `grafana-clock-panel` in the list.

### Upgrade a Plugin

Update an existing plugin to the latest version:

```terminal:execute
command: grafana-cli plugins upgrade grafana-clock-panel
```

### Remove a Plugin

Uninstall a plugin you no longer need:

```terminal:execute
command: grafana-cli plugins remove grafana-clock-panel
```

---
## Hands-On Exercise: Install Pie Chart Plugin

Let's install a useful visualization plugin!

**Step 1: Search for the pie chart plugin**

```terminal:execute
command: grafana-cli plugins list-remote | grep -i pie
```

**Step 2: Install the Pie Chart plugin**

```terminal:execute
command: grafana-cli plugins install grafana-piechart-panel
```

Watch the installation progress. You should see download status and success message.

**Step 3: Verify installation**

```terminal:execute
command: grafana-cli plugins ls
```

The pie chart plugin should appear in the list.

**Step 4: Restart Grafana to load the plugin**

**Stop Grafana:**

```terminal:execute
command: pgrep -f grafana | xargs kill -9
```

**Start Grafana again:**

```terminal:execute
command: /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana > /var/log/grafana/grafana.log 2>&1 &
```

**Step 5: Verify in the Web UI** (optional)

1. Reload the Grafana tab in your browser
2. Go to create a new panel (we'll do this in the next section)
3. When selecting visualization type, you should see "Pie Chart" as an option

---
## Plugin Locations

Grafana looks for plugins in these directories:

**User-installed plugins:**
```terminal:execute
command: ls -la /var/lib/grafana/plugins/
```

This is where `grafana-cli` installs plugins.

**Built-in plugins:**
```terminal:execute
command: ls /usr/share/grafana/public/app/plugins/panel/
```

These come pre-installed with Grafana (table, graph, stat, etc.).

---
## Other Grafana CLI Capabilities (Theory)

While we focus on plugin management in this workshop, `grafana-cli` can also perform other administrative tasks:

### User Management

**Reset admin password:**
When locked out of Grafana, you can reset the admin password:
```bash
# Stop Grafana first
pgrep -f grafana | xargs kill -9

# Reset password
grafana-cli admin reset-admin-password newpassword

# Restart Grafana
/usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana &
```

This is useful for disaster recovery when you forget the admin password.

### Database Operations

**Data migration:**
Grafana CLI can help with database migrations when upgrading versions:
```bash
grafana-cli admin data-migration <command>
```

**Secret migration:**
When changing encryption keys, migrate secrets in the database:
```bash
grafana-cli admin secrets-migration <command>
```

These commands are typically used during major version upgrades or when changing database backends (e.g., from SQLite to PostgreSQL) or rotating encryption keys for security compliance.

**Note**: These database commands require Grafana to be stopped and should only be run by experienced administrators during maintenance windows.


---
## Why Use Grafana CLI?

**Automation**: Script plugin installations across multiple Grafana instances

**CI/CD Integration**: Add plugins during container builds or deployments

**Troubleshooting**: Reset passwords, check versions, diagnose plugin issues

**Offline Management**: Manage Grafana when the web UI is unavailable

---
## Popular Plugins to Explore

- **grafana-clock-panel** - Display current time/date
- **grafana-piechart-panel** - Pie and donut charts
- **grafana-worldmap-panel** - Geographic data visualization
- **grafana-simple-json-datasource** - Connect to any JSON API
- **alexanderzobnin-zabbix-app** - Zabbix monitoring integration
- **grafana-image-renderer** - Server-side image rendering for reports

Browse all plugins at: [Grafana Plugin Catalog](https://grafana.com/grafana/plugins/)

---

> You now understand how to use Grafana CLI for plugin and user management!

Proceed to creating your first dashboard.
