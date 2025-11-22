# Step 99 - Workshop Summary

You completed:
- Download & extract Grafana standalone.
- Start Grafana and view logs.
- Access Grafana through ingress tab.
- Add (mock) Prometheus data source.
- Create an initial dashboard & panel.

---
## Next Steps
- Add real Prometheus or Loki data source.
- Explore provisioning via config files in `conf/`.
- Secure with user management & API keys.

## Cleanup (Optional)
```bash
pkill -f grafana-server
rm -rf grafana-11.0.0 ~/grafana.log ~/grafana-data
```

Thank you for participating!
