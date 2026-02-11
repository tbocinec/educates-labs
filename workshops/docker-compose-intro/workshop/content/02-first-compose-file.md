# Your First Compose File

Let's create and run your very first Docker Compose application — a simple Nginx web server.

---

## Creating the Project Directory

We have prepared a Compose file for you. Let's copy it to a working directory and examine it:

```terminal:execute
command: mkdir -p ~/first-compose && cp ~/exercises/first-compose/compose.yaml ~/first-compose/
```

**Open the file in the Editor tab to review it:**

```editor:open-file
file: ~/first-compose/compose.yaml
```

This is the simplest possible Compose file — it defines a single service called `web` that runs Nginx and maps port 8080 on the host to port 80 in the container.

---

## Starting the Application

```terminal:execute
command: cd ~/first-compose && docker compose up -d
```

The `-d` flag runs all services in **detached mode** (background). Without it, logs would stream to your terminal and block it.

Compose will:
1. Create a default **network** for the project
2. Pull the `nginx:latest` image (if not already available)
3. Create and start the `web` container

---

## Verifying the Application

**Check running services:**

```terminal:execute
command: cd ~/first-compose && docker compose ps
```

You should see the `web` service with status `running` and the port mapping `0.0.0.0:8080->80/tcp`.

**Test the web server:**

```terminal:execute
command: curl -s http://localhost:8080 | head -5
```

You can also click the **Web App** tab at the top to see the Nginx welcome page in your browser.

---

## Stopping the Application

```terminal:execute
command: cd ~/first-compose && docker compose down
```

`docker compose down` stops and removes:
- All containers defined in the Compose file
- The default network created by Compose

> **Note:** Named volumes are **not** removed by default. Use `docker compose down -v` to also remove volumes.

**Verify everything is cleaned up:**

```terminal:execute
command: docker ps -a --filter "name=first-compose"
```

No containers remain.

---

## The `up` and `down` Cycle

This is the fundamental Docker Compose workflow:

```
docker compose up -d     # Start the entire stack
docker compose down       # Stop and remove everything
```

It's that simple. You will use this cycle throughout the rest of this workshop.

---

## Recreating After Changes

If you modify the `compose.yaml` file, just run `up` again — Compose detects what changed and only recreates the affected services.

**Let's apply an updated version that adds a container name and a restart policy:**

```terminal:execute
command: cp ~/exercises/first-compose/compose-updated.yaml ~/first-compose/compose.yaml
```

**Open the updated file in the Editor — notice the two new lines:**

```editor:open-file
file: ~/first-compose/compose.yaml
```

```editor:select-matching-text
file: ~/first-compose/compose.yaml
text: container_name: my-web
```

```editor:select-matching-text
file: ~/first-compose/compose.yaml
text: restart: unless-stopped
```

Now apply the changes:

```terminal:execute
command: cd ~/first-compose && docker compose up -d
```

Compose recreates only the `web` service because its configuration changed.

```terminal:execute
command: docker ps --filter "name=my-web"
```

---

## Cleanup

```terminal:execute
command: cd ~/first-compose && docker compose down
```
