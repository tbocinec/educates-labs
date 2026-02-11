# Scaling and Profiles

Docker Compose lets you run multiple instances of a service and selectively enable services using profiles.

---

## Scaling Services

You can run multiple replicas of a service using the `--scale` flag.

### Setting Up a Scalable Service

Copy the prepared Compose file:

```terminal:execute
command: mkdir -p ~/scaling-demo && cp ~/exercises/scaling-demo/compose.yaml ~/scaling-demo/
```

**Open the Compose file in the Editor tab:**

```editor:open-file
file: ~/scaling-demo/compose.yaml
```

### Scaling Up

**Start with 3 worker instances:**

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d --scale worker=3
```

**View all running containers:**

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

You should see 3 `worker` containers and 1 `web` container.

**Check logs from all workers:**

```terminal:execute
command: cd ~/scaling-demo && docker compose logs worker
```

Each worker has a unique hostname.

---

### Scaling Up and Down Dynamically

**Scale workers up to 5:**

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d --scale worker=5
```

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

**Scale back down to 2:**

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d --scale worker=2
```

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

Compose gracefully stops the extra containers.

> **Note:** You cannot scale a service that has a `container_name` set, or that uses a host port mapping (e.g., `ports: "8080:80"`), because multiple containers would conflict on the same name/port.

---

### Using `deploy.replicas` in the Compose File

Instead of the `--scale` flag, you can define the desired replica count directly in the Compose file:

```terminal:execute
command: cd ~/scaling-demo && docker compose down
```

**Apply the version with `deploy.replicas`:**

```terminal:execute
command: cp ~/exercises/scaling-demo/compose-replicas.yaml ~/scaling-demo/compose.yaml
```

**Open the file in the Editor — notice the `deploy.replicas` section:**

```editor:open-file
file: ~/scaling-demo/compose.yaml
```

```editor:select-matching-text
file: ~/scaling-demo/compose.yaml
text: replicas: 3
```

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d
```

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

Three workers are started automatically based on the `deploy.replicas` setting.

---

## Profiles

Profiles let you define services that should **only start when explicitly requested**. This is useful for development tools, debugging sidecars, or optional components.

### Defining Profiles

```terminal:execute
command: cd ~/scaling-demo && docker compose down
```

**Apply the version with profiles:**

```terminal:execute
command: cp ~/exercises/scaling-demo/compose-profiles.yaml ~/scaling-demo/compose.yaml
```

**Open the file in the Editor — review the profiles configuration:**

```editor:open-file
file: ~/scaling-demo/compose.yaml
```

```editor:select-matching-text
file: ~/scaling-demo/compose.yaml
text: profiles
```

Services with `profiles` are **not started by default**.

---

### Starting Without Profiles

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d
```

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

Only `web` and `cache` are running — the `debug` and `monitoring` services are skipped.

---

### Activating a Profile

**Start services including the debug profile:**

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug up -d
```

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug ps
```

Now `web`, `cache`, and `debug` are running.

**Activate multiple profiles:**

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug --profile monitoring up -d
```

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug --profile monitoring ps
```

All four services are now running.

---

### When to Use Profiles

| Use Case | Example |
|----------|---------|
| **Development tools** | Database admin UI, debug containers |
| **Testing** | Test runners, mock services |
| **Monitoring** | Metrics exporters, log aggregators |
| **CI/CD** | Services only needed in specific pipelines |

---

## Cleanup

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug --profile monitoring down
```

```terminal:execute
command: rm -rf ~/scaling-demo
```
