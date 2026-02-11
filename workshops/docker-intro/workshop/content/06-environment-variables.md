# Environment Variables & Configuration

Environment variables are the standard mechanism for passing configuration to Docker containers. They allow you to customize container behavior without modifying the image itself — a core principle of **twelve-factor app** design.

---

## Setting Environment Variables with `-e`

The `-e` (or `--env`) flag sets an environment variable inside the container:

```terminal:execute
command: docker run --rm alpine:latest env
```

This shows the default environment variables inside an Alpine container. Now let's add our own:

```terminal:execute
command: docker run --rm -e MY_NAME="Docker Workshop" -e MY_ROLE="Student" alpine:latest env
```

Notice that `MY_NAME` and `MY_ROLE` appear in the output alongside the default variables.

---

## Practical Example: Configuring a Database

Many official Docker images use environment variables for configuration. Let's run a **PostgreSQL** database and configure it entirely through environment variables:

```terminal:execute
command: docker run -d --name my-postgres -e POSTGRES_USER=workshop -e POSTGRES_PASSWORD=secret123 -e POSTGRES_DB=myapp postgres:17
```

**Wait a moment for PostgreSQL to initialize, then verify it's running:**

```terminal:execute
command: sleep 5 && docker exec my-postgres psql -U workshop -d myapp -c "SELECT current_database(), current_user;"
```

PostgreSQL used the environment variables to:
- Create a user named `workshop`
- Set the password to `secret123`
- Create a database called `myapp`

All without modifying any configuration files.

---


## Using an Environment File

When you have many environment variables, maintaining them on the command line becomes unwieldy. Use an **env file** instead:

**Create an environment file:**

```terminal:execute
command: printf 'APP_NAME=MyDockerApp\nAPP_ENV=development\nAPP_DEBUG=true\nAPP_PORT=3000\nDATABASE_HOST=db.example.com\nDATABASE_PORT=5432\n' > /tmp/app.env
```

**Verify the file contents:**

```terminal:execute
command: cat /tmp/app.env
```

**Run a container using the env file:**

```terminal:execute
command: docker run --rm --env-file /tmp/app.env alpine:latest env
```

All variables defined in `app.env` are available inside the container. This approach is cleaner, supports version control, and reduces the risk of command-line typos.

---

## Inspecting Container Environment Variables

You can view the environment variables of a running container using `docker inspect`:

```terminal:execute
command: docker inspect my-postgres --format '{{range .Config.Env}}{{println .}}{{end}}'
```

This reveals all environment variables set when the container was created, including both user-defined and image-default variables.

---

## Practical Example: Running Redis with Custom Configuration

Let's run **Redis** with a custom configuration via environment variables and command-line arguments:

```terminal:execute
command: docker run -d --name my-redis redis:7 redis-server --maxmemory 64mb --maxmemory-policy allkeys-lru
```

**Verify Redis is running and check its configuration:**

```terminal:execute
command: docker exec my-redis redis-cli CONFIG GET maxmemory
```

```terminal:execute
command: docker exec my-redis redis-cli CONFIG GET maxmemory-policy
```

While Redis uses command-line arguments rather than environment variables for server configuration, this demonstrates that different images have different configuration mechanisms. Always consult the image's documentation on Docker Hub.

---

## Cleanup

```terminal:execute
command: docker rm -f my-postgres my-redis
```
