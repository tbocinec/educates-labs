# Step 02 - Configure Loki Data Source

In this step, you'll add Loki as a data source in Grafana so you can query and visualize logs.

---
## Open Grafana

Switch to the **Grafana** tab in your browser.

**Login:**
- Username: `admin`
- Password: `admin`

---
## Navigate to Data Sources

In Grafana main menu:

1. Click the **gear icon** (⚙️) at bottom of left sidebar → **Administration**
2. Click **Data sources**
3. You'll see a list of data sources (may be empty)

---
## Add New Data Source

Click the blue **+ Add new data source** button.

You'll see a search box with a list of data source types.

---
## Select Loki

1. **Search box:** Type `Loki`
2. Click **Loki** when it appears

You're now in the Loki data source configuration page.

---
## Configure Loki URL

**Important section: Connection**

1. **URL field:** You'll see an input box labeled "URL"
2. **Enter:** `http://loki:3100`
3. Leave all other fields with default values

**That's it!** The URL points to the Loki service running in Docker.

---
## Save and Test Connection

At the bottom of the page:

1. Click the **Save & test** button (blue button)
2. Wait a moment for the test to complete

**Expected result:** You should see a green message: ✅ **"Data source is working"**

---
## Understanding LogQL vs SQL

**LogQL** is Loki's query language, similar to Prometheus PromQL:

### Basic Structure:
```
{label="value"} |= "search text"
```

### Key Concepts:
- **Labels** - Indexed metadata (fast searches)
- **Log content** - Raw text (full-text search)
- **Operators** - Filter and transform logs

### Common Operators:
- `{job="app"}` - Filter by labels
- `|=` - Include lines containing text
- `!=` - Exclude lines containing text
- `|~` - Regex match
- `!~` - Regex not match

### Examples:
```
# All logs from Grafana service
{container="grafana"}

# Error logs only
{container="loki-workshop-grafana-1"}|= "error"

# Exclude health checks
{container="loki-workshop-grafana-1"}!= "health"
```

---
## Verify in Data Sources List

You're automatically returned to the Data Sources page. You should now see:

**Loki** - Listed as a data source with status **Green** (working)

---
## What You Just Did

✅ Connected Grafana to Loki  
✅ Tested the connection successfully  
✅ Loki is now available for queries in Grafana  

Now you can use Loki to explore logs!

---

Next, you'll explore the logs that Grafana and other containers are generating!
