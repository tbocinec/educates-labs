# Step 04 - Using Docker Compose

Docker Compose makes it easy to manage Grafana and its configuration. Let's learn how to use it!

---
## What is Docker Compose?

**Docker Compose** is a tool for defining and running multi-container Docker applications using a YAML file.

**Benefits:**
- Define all settings in one file
- Easy to version control
- Simple to start/stop/update
- Great for local development
- Can include multiple services (Grafana + data sources)

**Documentation:** https://docs.docker.com/compose/

---
## Clean Up Current Setup

First, stop and remove our current Grafana container:

```terminal:execute
command: docker stop grafana && docker rm grafana
```

---
## Create a Docker Compose File

Let's create a `docker-compose.yml` file for Grafana:

```terminal:execute
command: mkdir -p ~/grafana-compose && cd ~/grafana-compose
```

**Create the compose file:**

```terminal:
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - '3000:3000'
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=secret
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-piechart-panel
    volumes:
      - grafana-storage:/var/lib/grafana
    networks:
      - grafana

volumes:
  grafana-storage:
    driver: local

networks:
  grafana:
    driver: bridge
EOF
```

---
## Understanding the Compose File

Let's break down each section:

**Services:**
- `grafana` - Service name
- `image` - Docker image to use
- `container_name` - Name for the container
- `restart` - Restart policy (unless manually stopped)
- `ports` - Port mapping
- `environment` - Environment variables
- `volumes` - Data persistence
- `networks` - Isolated network

**Volumes:**
- Named volume for persistent storage

**Networks:**
- Custom network for service isolation

---
## Start Grafana with Docker Compose

Launch everything with a single command:

```terminal:execute
command: docker compose up -d
```

**What this does:**
- Creates the network
- Creates the volume
- Pulls the image (if needed)
- Starts the container
- `-d` runs in detached mode

---
## Check Status

View running services:

```terminal:execute
command: docker compose ps
```

View logs:

```terminal:execute
command: docker compose logs -f grafana
```

Press `Ctrl+C` to stop following logs.

---
## Access Grafana

**Switch to the Grafana tab** and log in with:
- Username: `admin`
- Password: `secret`

Verify that the plugins are installed (Administration → Plugins).

---
## Manage Grafana with Compose

**Stop Grafana:**

```terminal:execute
command: docker compose stop
```

**Start again:**

```terminal:execute
command: docker compose start
```

**Restart:**

```terminal:execute
command: docker compose restart
```

**View logs:**

```terminal:execute
command: docker compose logs grafana
```

**Stop and remove (keeps volumes):**

```terminal:execute
command: docker compose down
```

**Stop and remove everything (including volumes):**

```terminal:execute
command: docker compose down -v
```

---
## Advanced: Add Prometheus Data Source

Let's extend our setup to include Prometheus as a data source!

**Update docker-compose.yml:**

```terminal:
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - '9090:9090'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-storage:/prometheus
    networks:
      - grafana

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - '3000:3000'
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=secret
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-piechart-panel
    volumes:
      - grafana-storage:/var/lib/grafana
    networks:
      - grafana
    depends_on:
      - prometheus

volumes:
  grafana-storage:
    driver: local
  prometheus-storage:
    driver: local

networks:
  grafana:
    driver: bridge
EOF
```

**Create Prometheus configuration:**

```terminal:
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF
```

**Start both services:**

```terminal:execute
command: docker compose up -d
```

**Verify both are running:**

```terminal:execute
command: docker compose ps
```

Now you have both Grafana and Prometheus running together! 

**In Grafana:**
1. Go to **Connections** → **Data sources**
2. Add Prometheus
3. URL: `http://prometheus:9090`
4. Click **Save & Test**

---
## Exercise: Customize Your Setup

Try modifying the `docker-compose.yml` file:

**Ideas:**
1. Change the admin password
2. Add more plugins
3. Change any settings
4. Just play with it :)

**Edit the file:**

```terminal:execute
command: vim docker-compose.yml
```

**Apply changes:**

```terminal:execute
command: docker compose down && docker compose up -d
```

---
## Best Practices

✅ **Version control** - Keep `docker-compose.yml` in Git  
✅ **Environment files** - Use `.env` for secrets  
✅ **Named volumes** - Easier to manage than bind mounts  
✅ **Health checks** - Add health checks for reliability  
✅ **Resource limits** - Set CPU/memory limits in production  

**Example with environment file:**

Create `.env`:
```bash
GRAFANA_ADMIN_PASSWORD=secret
```

Reference in compose:
```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
```

---
## Resources

**Grafana with Docker Compose examples:**
- https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/#run-grafana-via-docker-compose
- https://github.com/grafana/grafana/tree/main/devenv/docker/blocks/grafana

**Docker Compose documentation:**
- https://docs.docker.com/compose/compose-file/

---

> Congratulations! You now know how to deploy and manage Grafana using Docker Compose!

Proceed to workshop summary.
