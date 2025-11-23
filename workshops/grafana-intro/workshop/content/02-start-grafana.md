# Step 03 - Start Grafana

Inside the container, systemd is not available, so we'll start Grafana directly as a process.

---
## Start Grafana Server

We'll start the Grafana server with specific configuration:
- `--config=/etc/grafana/grafana.ini` - Specifies the configuration file location (contains all Grafana settings like port, database, authentication, etc.)
- `--homepath=/usr/share/grafana` - Sets the home directory where Grafana assets (UI files, plugins) are located
- `&` - Runs the process in the background, allowing you to continue using the terminal

**Option 1: Run in background (recommended)**

Start Grafana in the background so you can continue working in the terminal:

```terminal:execute
command: /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana > /var/log/grafana/grafana.log 2>&1 &
```

**Option 2: Run in foreground (see logs directly)**

Or start Grafana in the foreground to see logs in real-time (press Ctrl+C to stop):

```terminal:execute
command: /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana
```

If you chose option 2, press Ctrl+C and run option 1 to continue with the workshop.

---
## Verify Grafana is Running

Check that the Grafana process started successfully:

```terminal:execute
command: ps aux | grep grafana-server | grep -v grep
```

You should see the grafana-server process in the output.

---
## Check Network Listening

Install network diagnostic tools:

```terminal:execute
command: apt-get install -y net-tools
```

Verify that Grafana is listening on port 3000:

```terminal:execute
command: netstat -tulpn | grep :3000
```

You should see Grafana listening on `0.0.0.0:3000` or `:::3000`.

---
## View Logs (Optional)

To check Grafana logs for troubleshooting:

```terminal:execute
command: tail -20 /var/log/grafana/grafana.log
```

Or follow logs in real-time (press Ctrl+C to stop):

```terminal:execute
command: tail -f /var/log/grafana/grafana.log
```

---
## Restart Grafana (If Needed)

If you need to restart Grafana:

```terminal:execute
command: pgrep -f grafana | xargs kill -9 && /usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana > /var/log/grafana/grafana.log 2>&1 &
```

> Grafana is now running on port 3000 inside the container. Thanks to the `-p 3000:3000` port forwarding, it will be accessible from outside!

---
## Note: Production Deployment with systemd

In production environments (outside containers), Grafana is typically managed by **systemd**, a system service manager available on most Linux distributions.

**Benefits of systemd:**
- **Auto-start on boot** - Grafana starts automatically when the server restarts
- **Process monitoring** - systemd automatically restarts Grafana if it crashes
- **Logging integration** - Logs are centralized and managed by journald
- **Resource management** - CPU and memory limits can be easily configured
- **Dependency management** - Ensures required services start in the correct order

Typical systemd commands for Grafana:
```bash
# Start Grafana
sudo systemctl start grafana-server

# Enable auto-start on boot
sudo systemctl enable grafana-server

# Check status
sudo systemctl status grafana-server

# View logs
sudo journalctl -u grafana-server -f
```

In our container environment, systemd is not available, which is why we start Grafana manually.

Proceed to accessing the UI.
