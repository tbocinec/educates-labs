# Volumes & Persistent Data

By default, all data inside a container is stored in its **writable layer** and is lost when the container is removed. **Volumes** provide a mechanism for persisting data beyond the container lifecycle and for sharing data between containers.

---

## The Problem: Ephemeral Container Storage

Let's demonstrate why volumes are necessary:

```terminal:execute
command: docker run -d --name ephemeral-demo nginx:latest
```

**Write some data inside the container:**

```terminal:execute
command: docker exec ephemeral-demo bash -c 'echo "Important data" > /tmp/mydata.txt && cat /tmp/mydata.txt'
```

**Remove and recreate the container:**

```terminal:execute
command: docker rm -f ephemeral-demo
```

```terminal:execute
command: docker run -d --name ephemeral-demo nginx:latest
```

**Try to read the data:**

```terminal:execute
command: docker exec ephemeral-demo cat /tmp/mydata.txt 2>&1 || echo "File not found — data was lost!"
```

The file is gone. This is expected behavior — the new container starts from a clean image layer.

```terminal:execute
command: docker rm -f ephemeral-demo
```

---

## Docker Volumes

A **Docker volume** is a directory managed by Docker, stored outside the container's filesystem on the host. Volumes survive container removal, can be shared between containers, and offer better performance than bind mounts.

### Creating a Volume

```terminal:execute
command: docker volume create workshop-data
```

**List all volumes:**

```terminal:execute
command: docker volume ls
```

**Inspect the volume to see where it's stored on the host:**

```terminal:execute
command: docker volume inspect workshop-data
```

---

## Using a Volume with a Container

Mount a volume into a container using the `-v` flag:

```
-v VOLUME_NAME:CONTAINER_PATH
```

```terminal:execute
command: docker run -d --name vol-demo1 -v workshop-data:/app/data alpine:latest sh -c 'echo "Hello from container 1" > /app/data/message.txt && sleep 3600'
```

**Verify the data was written:**

```terminal:execute
command: docker exec vol-demo1 cat /app/data/message.txt
```

**Now run a second container sharing the same volume:**

```terminal:execute
command: docker run --rm -v workshop-data:/app/data alpine:latest cat /app/data/message.txt
```

The second container reads the data written by the first — volumes enable **data sharing between containers**.

---

## Data Persistence Across Container Removal

Let's prove that volume data survives container removal:

```terminal:execute
command: docker rm -f vol-demo1
```

**Run a new container and check if the data is still there:**

```terminal:execute
command: docker run --rm -v workshop-data:/app/data alpine:latest cat /app/data/message.txt
```

The data persists because it lives in the volume, not in the container.

---

## Copying Files Into Containers with `docker cp`

Another way to inject files into a running container is the `docker cp` command. This works by copying files directly between the host and the container's filesystem:

```
docker cp HOST_PATH CONTAINER:CONTAINER_PATH
docker cp CONTAINER:CONTAINER_PATH HOST_PATH
```

**Start an Nginx container:**

```terminal:execute
command: docker run -d --name cp-demo -p 8090:80 nginx:latest
```

**Create a custom HTML file and copy it into the container:**

```terminal:execute
command: echo "<h1>Custom Page via docker cp</h1>" > /tmp/custom-index.html
```

```terminal:execute
command: docker cp /tmp/custom-index.html cp-demo:/usr/share/nginx/html/index.html
```

**Verify the custom page is served:**

```terminal:execute
command: curl -s http://localhost:8090
```

You should see your custom HTML content.

**Copy a file out of the container to the host:**

```terminal:execute
command: docker cp cp-demo:/etc/nginx/nginx.conf /tmp/nginx.conf && cat /tmp/nginx.conf | head -10
```

This is useful for extracting configuration files or logs from a container for inspection.

> **Note:** `docker cp` creates a one-time copy — changes to the source are **not** automatically reflected. For live synchronization, **bind mounts** are used (mapping a host directory directly into the container with `-v /host/path:/container/path`). Bind mounts are commonly used in local development environments where the Docker daemon has direct access to the host filesystem.

---

## Bind Mounts (Theory)

A **bind mount** maps a specific directory on the host filesystem directly into a container:

```
docker run -v /host/path:/container/path nginx:latest
```

For example, to mount a local project directory as the Nginx web root:

```
mkdir -p /tmp/my-site
echo "<h1>Hello from Host</h1>" > /tmp/my-site/index.html
docker run -d -p 8080:80 -v /tmp/my-site:/usr/share/nginx/html:ro nginx:latest
```

The `:ro` suffix makes the mount **read-only** inside the container. Any changes to files on the host are reflected inside the container **instantly** — there is no copy involved. This makes bind mounts ideal for development workflows where you want to edit code on the host and see updates in real time.

> **Note:** Bind mounts cannot be demonstrated in this workshop environment because Docker runs as Docker-in-Docker (DinD) — the Docker daemon operates in a separate container and does not have access to the session's filesystem. On a standard Docker installation (e.g., your laptop), bind mounts work as described above.

---

## Volumes vs Bind Mounts vs docker cp

| Feature | Volume | Bind Mount | docker cp |
|---------|--------|------------|-----------|
| **Managed by Docker** | Yes | No | N/A |
| **Live sync** | Yes | Yes | No (one-time copy) |
| **Portability** | High | Low — depends on host paths | High |
| **Performance** | Optimized by Docker | Depends on host filesystem | N/A |
| **Use case** | Databases, persistent data | Development, config files | Quick file injection/extraction |
| **Backup** | Via Docker CLI or volume drivers | Standard filesystem tools | Manual |

---

## Practical Example: PostgreSQL with Persistent Storage

Let's run PostgreSQL with a named volume so data survives container restarts:

```terminal:execute
command: docker volume create pg-data
```

```terminal:execute
command: docker run -d --name pg-vol-demo -e POSTGRES_PASSWORD=workshop -v pg-data:/var/lib/postgresql/data postgres:17
```

**Wait for initialization and create some data:**

```terminal:execute
command: sleep 5 && docker exec pg-vol-demo psql -U postgres -c "CREATE TABLE demo (id serial, name text); INSERT INTO demo (name) VALUES ('persisted data');"
```

**Remove the container and recreate it:**

```terminal:execute
command: docker rm -f pg-vol-demo
```

```terminal:execute
command: docker run -d --name pg-vol-demo -e POSTGRES_PASSWORD=workshop -v pg-data:/var/lib/postgresql/data postgres:17
```

**Verify the data survived:**

```terminal:execute
command: sleep 5 && docker exec pg-vol-demo psql -U postgres -c "SELECT * FROM demo;"
```

The data is intact. This is exactly how databases should be run in Docker.

---

## Cleanup

```terminal:execute
command: docker rm -f cp-demo pg-vol-demo
```

```terminal:execute
command: docker volume rm workshop-data pg-data
```

```terminal:execute
command: rm -f /tmp/custom-index.html /tmp/nginx.conf
```

```terminal:execute
command: rm -rf /tmp/workshop-bind
```
