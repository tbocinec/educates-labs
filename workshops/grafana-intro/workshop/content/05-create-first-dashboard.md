# Step 05 - Create Your First Dashboard

1. In Grafana left menu: Dashboards → New → New Dashboard.
2. Click *Add new panel*.
3. Query editor: choose Prometheus (if added) and use a sample query:
   `up`
4. Set Panel title to *Uptime Status*.
5. Apply / Save dashboard with name `Intro Dashboard`.

---
## Export Dashboard JSON
```bash
# Use the UI: Dashboard settings (gear) → JSON Model → Copy
```

## (Optional) Save JSON to File
Paste JSON into editor (VS Code tab) into `grafana-dashboard.json` if you wish.

## (Optional) Import via API (Requires API Key)
```bash
# Replace YOUR_API_KEY
cat > dashboard.json <<'EOF'
{
  "dashboard": {
    "title": "Intro Dashboard",
    "panels": [
      {
        "title": "Uptime Status",
        "type": "graph",
        "targets": [ { "expr": "up" } ]
      }
    ]
  },
  "overwrite": true
}
EOF
curl -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d @dashboard.json \
     $(ingress_protocol)://$(session_namespace)-grafana.$(ingress_domain)/api/dashboards/db
```

Proceed to summary.
