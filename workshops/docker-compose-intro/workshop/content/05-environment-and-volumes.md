# Environment Variables and Volumes

Docker Compose provides powerful mechanisms for configuring services through environment variables and persisting data with volumes.

---

## Environment Variables in Compose

There are several ways to pass environment variables to your services.

### Inline `environment` Block

The simplest approach — define variables directly in the Compose file. Copy the prepared file:

```terminal:execute
command: mkdir -p ~/env-volumes && cp ~/exercises/env-volumes/compose.yaml ~/env-volumes/
```

**Open the Compose file in the Editor tab:**

```editor:open-file
file: ~/env-volumes/compose.yaml
```

Notice the `environment` block with hardcoded values for `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB`.

```terminal:execute
command: cd ~/env-volumes && docker compose up -d
```

**Verify the environment variables inside the container:**

```terminal:execute
command: cd ~/env-volumes && docker compose exec db env | grep POSTGRES
```

---

### Using `.env` Files

Hardcoding passwords in your Compose file is not ideal. A better approach is using an **environment file**.

**Copy the prepared `.env` file:**

```terminal:execute
command: cp ~/exercises/env-volumes/env ~/env-volumes/.env
```

**Open the `.env` file in the Editor tab to see its contents:**

```editor:open-file
file: ~/env-volumes/.env
```

**Now apply a Compose file that uses variable substitution instead of hardcoded values:**

```terminal:execute
command: cp ~/exercises/env-volumes/compose-substitution.yaml ~/env-volumes/compose.yaml
```

**Open the updated Compose file — notice the `${VARIABLE}` syntax:**

```editor:open-file
file: ~/env-volumes/compose.yaml
```

```editor:select-matching-text
file: ~/env-volumes/compose.yaml
text: ${DB_USER}
```

**Verify the resolved configuration:**

```terminal:execute
command: cd ~/env-volumes && docker compose config | grep -A5 environment
```

The `${VARIABLE}` syntax reads from the `.env` file in the same directory. This is the **Compose-level** `.env` file — it's automatically loaded.

**Recreate the service with new variables:**

```terminal:execute
command: cd ~/env-volumes && docker compose up -d
```

```terminal:execute
command: cd ~/env-volumes && docker compose exec db env | grep POSTGRES
```

---

### Using `env_file` Directive

You can also point a service to a specific environment file using `env_file`. This loads the variables **into the container** (unlike `.env` which is used for Compose-level substitution).

**Copy the prepared `app.env` file:**

```terminal:execute
command: cp ~/exercises/env-volumes/app.env ~/env-volumes/
```

**Open the `app.env` file in the Editor:**

```editor:open-file
file: ~/env-volumes/app.env
```

Now apply the updated Compose file that includes the `env_file` directive:

```terminal:execute
command: cp ~/exercises/env-volumes/compose-envfile.yaml ~/env-volumes/compose.yaml
```

**Open the updated Compose file and notice the `env_file` section:**

```editor:open-file
file: ~/env-volumes/compose.yaml
```

```editor:select-matching-text
file: ~/env-volumes/compose.yaml
text: env_file
```

```terminal:execute
command: cd ~/env-volumes && docker compose up -d
```

**Verify that both sources of variables are present:**

```terminal:execute
command: cd ~/env-volumes && docker compose exec db env | grep -E 'POSTGRES|APP_MODE|LOG_LEVEL|MAX_CONNECTIONS'
```

> **Summary:** Use `.env` for Compose-level substitution (image tags, port numbers). Use `env_file` to load application configuration into containers.

---

## Volumes in Docker Compose

Volumes persist data beyond the lifecycle of containers.

### Named Volumes

Our Compose file already uses a named volume `dbdata`. Let's verify data persistence.

**Insert some data into PostgreSQL:**

```terminal:execute
command: cd ~/env-volumes && docker compose exec db psql -U admin -d production -c "CREATE TABLE notes (id SERIAL PRIMARY KEY, text VARCHAR(255)); INSERT INTO notes (text) VALUES ('Compose volumes work');"
```

> **Note:** The credentials `admin` / `production` come from the `.env` file (`DB_USER`, `DB_NAME`). PostgreSQL doesn't require a password when connecting locally inside the container.

```terminal:execute
command: cd ~/env-volumes && docker compose down && docker compose up -d
```

**Check that data survived:**

```terminal:execute
command: cd ~/env-volumes && docker compose exec db psql -U admin -d production -c "SELECT * FROM notes;"
```

The data is still there — the named volume persists across container restarts and recreation.

---

### Multiple Volumes

Services can use multiple volumes. Let's apply a version that adds a logs volume:

```terminal:execute
command: cp ~/exercises/env-volumes/compose-multi-volumes.yaml ~/env-volumes/compose.yaml
```

**Open the file to see the new `dblogs` volume:**

```editor:open-file
file: ~/env-volumes/compose.yaml
```

```editor:select-matching-text
file: ~/env-volumes/compose.yaml
text: dblogs
```

```terminal:execute
command: cd ~/env-volumes && docker compose up -d
```

**List volumes managed by this Compose project:**

```terminal:execute
command: docker volume ls --filter "name=env-volumes"
```

You should see both `env-volumes_dbdata` and `env-volumes_dblogs`.

---

### Removing Volumes

**Remove containers but keep volumes (default):**

```terminal:execute
command: cd ~/env-volumes && docker compose down
```

**Verify volumes still exist:**

```terminal:execute
command: docker volume ls --filter "name=env-volumes"
```

**Remove containers AND volumes:**

```terminal:execute
command: cd ~/env-volumes && docker compose down -v
```

**Verify volumes are gone:**

```terminal:execute
command: docker volume ls --filter "name=env-volumes"
```

> **Best Practice:** Use `docker compose down` during development to preserve data. Use `docker compose down -v` for clean resets or when you're done with a project.

---

## Cleanup

```terminal:execute
command: cd ~/env-volumes && docker compose down -v 2>/dev/null; rm -rf ~/env-volumes
```
