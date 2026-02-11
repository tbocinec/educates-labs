# What is Docker Compose?

Docker Compose is a tool for defining and running multi-container applications. It uses a declarative YAML file to describe your application's services, networks, and volumes — then starts everything with a single command.

---

## Why Docker Compose?

Consider launching a typical web application with `docker run`:

```
# Create a network
docker network create myapp

# Start a database
docker run -d --name db --network myapp \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:17

# Start a cache
docker run -d --name cache --network myapp redis:7

# Start the web app
docker run -d --name web --network myapp \
  -p 8080:80 \
  -e DATABASE_URL=postgres://postgres:secret@db:5432 \
  nginx:latest
```

That's four separate commands, and you have to remember the exact flags, network names, and volume names every time. With Docker Compose, the same stack becomes a single file:

```yaml
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - pgdata:/var/lib/postgresql/data

  cache:
    image: redis:7

  web:
    image: nginx:latest
    ports:
      - "8080:80"
    environment:
      DATABASE_URL: postgres://postgres:secret@db:5432

volumes:
  pgdata:
```

And you start it all with: `docker compose up -d`

---

## Compose File Structure

A Compose file has three top-level sections:

| Section | Purpose |
|---------|---------|
| **services** | The containers that make up your application |
| **volumes** | Named volumes for persistent data |
| **networks** | Custom networks (optional — Compose creates a default network automatically) |

The default filename is `compose.yaml` (or `docker-compose.yml` for older versions).

---

## Verifying Compose is Available

Let's confirm Docker Compose is installed:

```terminal:execute
command: docker compose version
```

Docker Compose v2 is integrated directly into the Docker CLI as a plugin (`docker compose`) — there's no need for a separate `docker-compose` binary.

---

## Compose vs Docker CLI

| Feature | Docker CLI | Docker Compose |
|---------|-----------|----------------|
| **Scope** | Single container | Entire application stack |
| **Configuration** | Command-line flags | Declarative YAML file |
| **Networking** | Manual (`docker network create`) | Automatic (default network per project) |
| **Reproducibility** | Hard to replicate exact flags | File can be version-controlled |
| **Lifecycle** | Manage containers individually | `up` / `down` for entire stack |

---

## The Compose Project

When you run `docker compose up`, Compose creates a **project**. By default, the project name is derived from the directory name. All resources (containers, networks, volumes) are prefixed with the project name to avoid conflicts.

For example, in a directory called `myapp`:
- Container names: `myapp-web-1`, `myapp-db-1`
- Network name: `myapp_default`
- Volume name: `myapp_pgdata`

You will see this naming convention in action throughout this workshop.
