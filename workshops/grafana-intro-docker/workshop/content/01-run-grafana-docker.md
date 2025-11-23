# Step 01 - Run Grafana with Docker

In this section, you'll learn how to run Grafana using the official Docker image from Grafana Labs.

---
## Official Grafana Docker Image

Grafana provides official Docker images on Docker Hub:
- **Image:** `grafana/grafana`
- **Documentation:** https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/
- **Docker Hub:** https://hub.docker.com/r/grafana/grafana

The official image is:
- Maintained by Grafana Labs
- Regularly updated with security patches
- Available in different variants (OSS, Enterprise)
- Pre-configured for container environments

---
## Run Grafana Container

Let's start Grafana with a simple Docker command:

```terminal:execute
command: docker run -d --name=grafana -p 3000:3000 grafana/grafana
```

**What this command does:**
- `docker run` - Creates and starts a new container
- `-d` - Runs in detached mode (background)
- `--name=grafana` - Names the container "grafana"
- `-p 3000:3000` - Maps port 3000 from container to host
- `grafana/grafana` - Uses the official Grafana image

---
## Check Container Status

Verify that Grafana is running:

```terminal:execute
command: docker ps
```

You should see the `grafana` container in the list with status "Up".

---
## View Container Logs

Check Grafana startup logs:

```terminal:execute
command: docker logs grafana
```

Look for the line: `HTTP Server Listen` - this indicates Grafana is ready!

---
## Access Grafana

**Switch to the Grafana tab** at the top of your workshop interface.

You should see the Grafana login page!

**Default credentials:**
- **Username:** `admin`
- **Password:** `admin`

You'll be prompted to change the password on first login (you can skip this for the workshop).

---
## Explore the Running Container

Let's inspect what's inside:

**Execute a shell inside the container:**

```terminal:execute
command: docker exec -it grafana /bin/bash
```

**Check Grafana version:**

```terminal:execute
command: grafana-cli --version
```

**List default plugins:**

```terminal:execute
command: grafana-cli plugins ls
```

**Exit the container shell:**

```terminal:execute
command: exit
```

---
## Understanding the Container

The official Grafana Docker image includes:
- Grafana server pre-installed
- Default configuration at `/etc/grafana/grafana.ini`
- Data directory at `/var/lib/grafana`
- Logs at `/var/log/grafana`
- Plugins directory at `/var/lib/grafana/plugins`

**Default port:** 3000

---
## Stop and Remove (Optional)

If you need to restart from scratch:

**Stop the container:**

```terminal:execute
command: docker stop grafana
```

**Remove the container:**

```terminal:execute
command: docker rm grafana
```

**Note:** Stopping/removing loses all data! We'll fix this with volumes in the next section.

---

> You've successfully run Grafana using Docker! Next, we'll learn how to configure and persist data.

Proceed to configure Grafana container.
