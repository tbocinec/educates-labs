# Step 02 - Start Grafana

Run Grafana pointing its data path to the directory you created.

---
## Change Into Folder
```bash
cd grafana-11.0.0
```

## Start Server (Foreground First Time)
```bash
./bin/grafana-server \
  --homepath=$(pwd) \
  --packaging=standalone \
  --config=$(pwd)/conf/defaults.ini \
  --pidfile=/tmp/grafana.pid
```

Let it start until you see: `HTTP Server Listen`.
Press Ctrl+C after confirming it works to restart in background.

## Start In Background
```bash
nohup ./bin/grafana-server \
  --homepath=$(pwd) \
  --packaging=standalone \
  --config=$(pwd)/conf/defaults.ini \
  --pidfile=/tmp/grafana.pid \
  > ~/grafana.log 2>&1 &
```

## Check Process
```bash
ps -ef | grep grafana-server | grep -v grep
```

## Tail Logs
```bash
tail -n 20 ~/grafana.log
```

Grafana listens on port 3000; the ingress in this workshop maps that port.

Proceed to accessing the UI.
