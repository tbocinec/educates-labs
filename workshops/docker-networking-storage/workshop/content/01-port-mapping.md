# Port Mapping & Exposing Services

Containers run in an isolated network by default. To make a containerized service accessible from the host machine (or the outside world), you need to **map** container ports to host ports.

---

## Understanding Port Mapping

When a container runs a service (e.g., a web server on port 80), that port is only accessible **inside** the container's network namespace. Port mapping creates a bridge between the host network and the container network:

```
Host Machine                    Container
┌──────────────────────┐       ┌──────────────────┐
│                      │       │                  │
│  localhost:8080 ─────────────►  container:80    │
│                      │       │  (Nginx)         │
│  localhost:5432 ─────────────►  container:5432  │
│                      │       │  (PostgreSQL)    │
└──────────────────────┘       └──────────────────┘
```

---

## Basic Port Mapping with `-p`

The `-p` flag maps a **host port** to a **container port**:

```
-p HOST_PORT:CONTAINER_PORT
```

**Run Nginx and map host port 8080 to container port 80:**

```terminal:execute
command: docker run -d --name web-port-demo -p 8080:80 nginx:latest
```

**Test the service from the host:**

```terminal:execute
command: curl -s http://localhost:8080 | head -5
```

You should see the Nginx welcome HTML. The request flows from `localhost:8080` on the host to port `80` inside the container.

You can also open the **Nginx** tab at the top of the workshop to see the Nginx welcome page directly in your browser.

---

## Mapping Multiple Ports

You can map multiple ports by specifying `-p` multiple times:

```terminal:execute
command: docker rm -f web-port-demo
```

```terminal:execute
command: docker run -d --name multi-port-demo -p 8080:80 -p 8443:443 nginx:latest
```

**Verify both mappings:**

```terminal:execute
command: docker port multi-port-demo
```

---

## Random Host Port Assignment

If you don't specify a host port, Docker assigns a **random available port** using the `-p` flag with only the container port:

```terminal:execute
command: docker run -d --name random-port-demo -p 80 nginx:latest
```

**Find the assigned port:**

```terminal:execute
command: docker port random-port-demo
```

**Or use `docker ps` to see it in the PORTS column:**

```terminal:execute
command: docker ps --filter "name=random-port-demo"
```

This is useful when running multiple instances of the same service and you want Docker to handle port conflicts automatically.

---

## Binding to a Specific Interface

By default, port mappings bind to **all interfaces** (`0.0.0.0`). You can restrict the binding to a specific IP address:

```
docker run -d -p 127.0.0.1:8080:80 nginx:latest
```

This makes the service accessible only via `localhost` — not from external machines. This is a good security practice for services that should not be publicly exposed.

---

## Practical Example: Running Multiple Web Servers

Let's run three Nginx instances on different host ports to demonstrate that container port 80 can be mapped to different host ports:

```terminal:execute
command: docker run -d --name web1 -p 8081:80 nginx:latest && docker run -d --name web2 -p 8082:80 nginx:latest && docker run -d --name web3 -p 8083:80 nginx:latest
```

**Customize each web server's content:**

```terminal:execute
command: docker exec web1 bash -c 'echo "<h1>Server 1</h1>" > /usr/share/nginx/html/index.html'
```

```terminal:execute
command: docker exec web2 bash -c 'echo "<h1>Server 2</h1>" > /usr/share/nginx/html/index.html'
```

```terminal:execute
command: docker exec web3 bash -c 'echo "<h1>Server 3</h1>" > /usr/share/nginx/html/index.html'
```

**Verify each server returns different content:**

```terminal:execute
command: echo "--- Server 1 ---" && curl -s http://localhost:8081 && echo "--- Server 2 ---" && curl -s http://localhost:8082 && echo "--- Server 3 ---" && curl -s http://localhost:8083
```

All three containers use the same internal port (80) but are accessible on different host ports.

---


## Cleanup

```terminal:execute
command: docker rm -f web-port-demo multi-port-demo random-port-demo web1 web2 web3
```
