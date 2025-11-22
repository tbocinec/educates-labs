# Step 03 - Access Grafana

Use the Grafana dashboard tab provided in this workshop. If the page shows a login screen, use the default credentials.

Default initial credentials:
```
Username: admin
Password: admin
```
You will be prompted to set a new password – choose something simple (e.g. `grafana123`).

---
## Reset Admin Password (If Needed)
```bash
# Only if you changed and forgot it; uses grafana cli.
cd grafana-11.0.0
./bin/grafana-cli admin reset-admin-password grafana123
```

Reload the Grafana tab after a reset.

Proceed to adding a data source.
