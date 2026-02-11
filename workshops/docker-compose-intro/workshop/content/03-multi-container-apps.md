# Multi-Container Applications

The real power of Docker Compose is orchestrating **multiple services** that work together. In this section, you'll build a complete application stack with a web frontend, a backend API, and a database.

---

## The Application Stack

We'll create a stack with three services:

```
┌─────────────────────────────────────────────────┐
│                 Compose Project                   │
│                                                   │
│  ┌──────────┐   ┌──────────┐   ┌──────────────┐ │
│  │  Nginx   │──►│  Redis   │   │  PostgreSQL  │ │
│  │  (web)   │   │  (cache) │   │  (db)        │ │
│  │ :8080→80 │   │  :6379   │   │  :5432       │ │
│  └──────────┘   └──────────┘   └──────────────┘ │
│                                                   │
│              default network                      │
└─────────────────────────────────────────────────┘
```

---

## Creating the Project

Copy the prepared Compose file to a working directory:

```terminal:execute
command: mkdir -p ~/multi-app && cp ~/exercises/multi-app/compose.yaml ~/multi-app/
```

This is a larger Compose file. **Open it in the Editor tab to review the full structure:**

```editor:open-file
file: ~/multi-app/compose.yaml
```

**Highlight the health check definition:**

```editor:select-matching-text
file: ~/multi-app/compose.yaml
text: healthcheck
```

**Highlight the dependency configuration:**

```editor:select-matching-text
file: ~/multi-app/compose.yaml
text: depends_on
```

Let's examine the key concepts:

### `depends_on` with Health Checks

The `depends_on` directive controls **startup order**. Combined with `condition: service_healthy`, Compose waits until the dependency passes its health check before starting the dependent service.

Without health checks, `depends_on` only guarantees the container has **started** — not that the service inside is ready. The health check ensures the database is actually accepting connections before the web tier starts.

### Named Volumes

The `pgdata` volume is declared at the bottom of the file. Compose creates it automatically and mounts it into the `db` container. Data persists across `docker compose down` (unless you use the `-v` flag).

---

## Starting the Stack

```terminal:execute
command: cd ~/multi-app && docker compose up -d
```

Watch Compose pull images, create the network, start services in dependency order, and wait for health checks to pass.

**Check the status of all services:**

```terminal:execute
command: cd ~/multi-app && docker compose ps
```

All three services should show `running (healthy)` status.

---

## Verifying Service Connectivity

Services on the same Compose network can reach each other by **service name**. Let's verify:

**From the web container, connect to Redis by name:**

```terminal:execute
command: docker compose -f ~/multi-app/compose.yaml exec web bash -c 'apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq redis-tools > /dev/null 2>&1 && redis-cli -h cache ping'
```

**From the web container, connect to PostgreSQL by name:**

```terminal:execute
command: docker compose -f ~/multi-app/compose.yaml exec web bash -c 'apt-get install -y -qq postgresql-client > /dev/null 2>&1 && PGPASSWORD=secret123 psql -h db -U workshop -d myapp -c "SELECT 1 as connected;"'
```

Both services are reachable by their Compose service names (`cache`, `db`) — no IP addresses needed. Compose creates a DNS entry for each service automatically.

---

## Inspecting the Network

Compose creates a default network named after the project directory:

```terminal:execute
command: docker network ls --filter "name=multi-app"
```

**Inspect the network to see all connected containers:**

```terminal:execute
command: docker network inspect multi-app_default --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'
```

All three containers share the same network and can communicate freely.

---

## Cleanup

```terminal:execute
command: cd ~/multi-app && docker compose down -v
```

The `-v` flag also removes the `pgdata` volume since we don't need the data anymore.
