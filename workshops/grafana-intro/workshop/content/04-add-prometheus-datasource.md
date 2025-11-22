# Step 04 - Add a Prometheus Data Source

We will simulate connecting to a Prometheus endpoint. If you do not have Prometheus running, you can still walk through the UI steps.

1. Open Grafana (Grafana tab).
2. Left side menu: Connections → Data sources → Add data source.
3. Choose *Prometheus*.
4. Set URL to `http://prometheus:9090` (placeholder) or leave default if you have one.
5. Click *Save & test*.

---
## (Optional) Run a Mock Prometheus (If Docker Enabled)
Docker is disabled here, but if enabled in future you could run:
```bash
docker run -d --name prom -p 9090:9090 prom/prometheus
```

---
## Verify Data Source via API
You can query Grafana's HTTP API for data sources list once logged in.
Get an API key from: Administration → Service Accounts or API Keys.
```bash
# Replace YOUR_API_KEY with created key value
curl -H "Authorization: Bearer YOUR_API_KEY" \
     $(ingress_protocol)://$(session_namespace)-grafana.$(ingress_domain)/api/datasources
```

Proceed to creating a dashboard.
