# Step 03 - Install Plugins

Grafana's functionality can be extended with plugins. Let's learn how to install them in a Docker container.

---
## Plugin Installation Methods

There are **two main ways** to install plugins in Docker:

1. **Environment variable** - Install on container startup
2. **Manual installation** - Using `grafana-cli` inside the container

---
## Method 1: Install Plugins on Startup

The easiest method is using the `GF_INSTALL_PLUGINS` environment variable.

**Stop and remove current container:**

```terminal:execute
command: docker stop grafana && docker rm grafana
```

**Run Grafana with plugins:**

```terminal:execute
command: docker run -d --name=grafana -p 3000:3000 -v grafana-storage:/var/lib/grafana -e "GF_SECURITY_ADMIN_PASSWORD=secret" -e "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-piechart-panel" grafana/grafana
```

**What this does:**
- Installs Clock Panel plugin
- Installs Pie Chart Panel plugin
- Both plugins install automatically on startup

**Check the logs to see plugin installation:**

```terminal:execute
command: docker logs grafana | grep -i plugin
```

You should see messages about installing plugins!

---
## Verify Plugins in UI

1. **Switch to the Grafana tab**
2. Log in (admin / secret)
3. Go to **Administration** → **Plugins**
4. You should see the Clock and Pie Chart plugins installed!

---
## Method 2: Manual Installation with grafana-cli

You can also install plugins manually inside a running container.

**Enter the container:**

```terminal:execute
command: docker exec -it grafana /bin/bash
```

**Inside the container, install a plugin:**

```terminal:execute
command: grafana-cli plugins install grafana-worldmap-panel
```

**Exit the container:**

```terminal:execute
command: exit
```

**Restart Grafana to load the plugin:**

```terminal:execute
command: docker restart grafana
```

---
## Finding Plugins

Browse available plugins:
- **Grafana Plugin Catalog:** https://grafana.com/grafana/plugins/
- Filter by type: Panels, Data sources, Apps
- Check compatibility with your Grafana version

**Popular plugins:**
- `grafana-piechart-panel` - Pie charts
- `grafana-clock-panel` - Clock widget
- `grafana-worldmap-panel` - World map visualization
- `grafana-polystat-panel` - Multi-stat panels
- `grafana-simple-json-datasource` - JSON data source

---
## Install Multiple Plugins

You can install multiple plugins by separating them with commas:

```bash
-e "GF_INSTALL_PLUGINS=plugin1,plugin2,plugin3"
```

**Example with specific versions:**

```bash
-e "GF_INSTALL_PLUGINS=grafana-clock-panel:1.3.0,grafana-piechart-panel:1.6.2"
```

---
## Persistent Plugin Installation

**Important:** When using volumes, plugins installed manually persist across container restarts!

The plugin files are stored in `/var/lib/grafana/plugins` which is part of our mounted volume.

---
## Custom Plugin Directory

You can also mount a custom plugin directory:

```bash
docker run -d --name=grafana -p 3000:3000 -v grafana-storage:/var/lib/grafana -v /path/to/custom/plugins:/var/lib/grafana/plugins grafana/grafana
```

This is useful for:
- Custom/private plugins
- Development and testing
- Offline environments

---
## Troubleshooting

**Plugin not loading?**
1. Check logs: `docker logs grafana`
2. Verify plugin name is correct
3. Ensure Grafana was restarted after manual installation
4. Check plugin compatibility with your Grafana version

---

> You now know how to extend Grafana with plugins in Docker!

Proceed to use Docker Compose.
