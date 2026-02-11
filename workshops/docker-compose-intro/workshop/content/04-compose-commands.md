# Essential Compose Commands

Now that you've built and run multi-container applications, let's master the full set of `docker compose` commands for managing your stacks.

---

## Setting Up a Practice Stack

Copy the prepared Compose file:

```terminal:execute
command: mkdir -p ~/compose-commands && cp ~/exercises/compose-commands/compose.yaml ~/compose-commands/
```

**Review the Compose file in the Editor tab:**

```editor:open-file
file: ~/compose-commands/compose.yaml
```

```terminal:execute
command: cd ~/compose-commands && docker compose up -d
```

---

## Listing Services

**Show running services:**

```terminal:execute
command: cd ~/compose-commands && docker compose ps
```

**Show all services (including stopped):**

```terminal:execute
command: cd ~/compose-commands && docker compose ps -a
```

---

## Viewing Logs

**Stream logs from all services:**

```terminal:execute
command: cd ~/compose-commands && docker compose logs --tail 10
```

The `--tail 10` flag shows only the last 10 lines per service. Without it, you may get a lot of output.

**View logs from a specific service:**

```terminal:execute
command: cd ~/compose-commands && docker compose logs web --tail 5
```

**Follow logs in real-time (Ctrl+C to stop):**

```terminal:execute
command: cd ~/compose-commands && docker compose logs -f web --tail 3
session: 2
```

Generate some log entries by making a request:

```terminal:execute
command: curl -s http://localhost:8080 > /dev/null && echo "Request sent!"
```

You should see the access log entry appear in Terminal 2. Press **Ctrl+C** in Terminal 2 to stop following.

---

## Executing Commands Inside Containers

**Run an interactive shell inside a service:**

```terminal:execute
command: cd ~/compose-commands && docker compose exec web bash -c 'echo "Hello from $(hostname)"'
```

**Run a command in the database service:**

```terminal:execute
command: cd ~/compose-commands && docker compose exec db psql -U demo -d demo -c '\l'
```

**Run a one-off command with `run` (creates a new container):**

```terminal:execute
command: cd ~/compose-commands && docker compose run --rm cache redis-cli --version
```

> **`exec` vs `run`:** `exec` runs a command inside an **existing, running** container. `run` creates a **new** container for the command. Use `--rm` with `run` to auto-remove it when done.

---

## Stopping, Starting, and Restarting

**Stop services (without removing containers):**

```terminal:execute
command: cd ~/compose-commands && docker compose stop web
```

**Check the stopped service:**

```terminal:execute
command: cd ~/compose-commands && docker compose ps -a
```

The `web` service shows as "exited" while others remain running.

**Start the stopped service:**

```terminal:execute
command: cd ~/compose-commands && docker compose start web
```

**Restart a service (stop + start):**

```terminal:execute
command: cd ~/compose-commands && docker compose restart cache
```

---

## Pulling and Recreating

**Pull the latest images for all services:**

```terminal:execute
command: cd ~/compose-commands && docker compose pull
```

**Recreate containers without pulling (useful after config changes):**

```terminal:execute
command: cd ~/compose-commands && docker compose up -d --force-recreate
```

---

## Viewing Configuration

**Validate and display the resolved Compose file:**

```terminal:execute
command: cd ~/compose-commands && docker compose config
```

This shows the fully resolved YAML after processing variables, defaults, and merges. Useful for debugging configuration issues.

---

## Pausing and Unpausing

**Pause all processes in a service (freeze without stopping):**

```terminal:execute
command: cd ~/compose-commands && docker compose pause web
```

```terminal:execute
command: curl -s --max-time 3 http://localhost:8080 || echo "Connection timed out — web is paused!"
```

**Unpause:**

```terminal:execute
command: cd ~/compose-commands && docker compose unpause web
```

```terminal:execute
command: curl -s http://localhost:8080 | head -3
```

---

## Command Quick Reference

| Command | Description |
|---------|-------------|
| `docker compose up -d` | Start all services in background |
| `docker compose down` | Stop and remove all containers + networks |
| `docker compose ps` | List running services |
| `docker compose logs` | View service logs |
| `docker compose exec <svc> <cmd>` | Run command in running container |
| `docker compose run --rm <svc> <cmd>` | Run one-off command in new container |
| `docker compose stop [svc]` | Stop service(s) without removing |
| `docker compose start [svc]` | Start stopped service(s) |
| `docker compose restart [svc]` | Restart service(s) |
| `docker compose pull` | Pull latest images |
| `docker compose config` | Validate and display resolved config |
| `docker compose pause/unpause` | Freeze/unfreeze service processes |

---

## Cleanup

```terminal:execute
command: cd ~/compose-commands && docker compose down
```
