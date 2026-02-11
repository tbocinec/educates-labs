# Working with Container Logs

Logs are the primary mechanism for observing what happens inside a container. Docker captures everything written to **stdout** and **stderr** by the container's main process and makes it available through the `docker logs` command.

---

## Setting Up a Container That Generates Logs

Let's start an Nginx container and generate some log output:

```terminal:execute
command: docker run -d --name log-demo -p 8080:80 nginx:latest
```

**Generate some traffic to produce log entries:**

```terminal:execute
command: for i in $(seq 1 10); do curl -s -o /dev/null http://localhost:8080; done
```

---

## Viewing Logs

**View all logs from the container:**

```terminal:execute
command: docker logs log-demo
```

You should see Nginx access log entries showing the HTTP requests we just made.

---

## Following Logs in Real Time

The `-f` (follow) flag streams new log entries as they arrive — similar to `tail -f`:

```terminal:execute
command: docker logs -f log-demo
```

While the log stream is active, generate more traffic from the second terminal:

```terminal:execute
command: curl http://localhost:8080
session: 2
```

You'll see new entries appear in real time. **Press `Ctrl+C`** to stop following logs.

---

## Showing Timestamps

Add the `-t` flag to prefix each log line with a precise timestamp:

```terminal:execute
command: docker logs -t log-demo
```

Timestamps are in ISO 8601 format and are invaluable for correlating events across multiple containers.

---

## Tail: Limiting Log Output

For containers that produce a large volume of logs, use `--tail` to show only the most recent entries:

**Show only the last 5 log lines:**

```terminal:execute
command: docker logs --tail 5 log-demo
```

**Combine with follow to see new entries starting from the last 3 lines:**

```terminal:execute
command: docker logs --tail 3 -f log-demo
```

Press `Ctrl+C` to stop.

---

## Filtering Logs by Time

The `--since` and `--until` flags filter logs by time:

**Show logs from the last 30 seconds:**

```terminal:execute
command: docker logs --since 30s log-demo
```

**Show logs from the last 2 minutes:**

```terminal:execute
command: docker logs --since 2m log-demo
```

You can also use absolute timestamps:

```
docker logs --since "2026-02-10T10:00:00" log-demo
docker logs --until "2026-02-10T10:30:00" log-demo
```

---

## Combining Logs with grep

Since Docker logs output to stdout, you can pipe them through standard Unix tools for advanced filtering:

**Find only GET requests:**

```terminal:execute
command: docker logs log-demo 2>&1 | grep "GET"
```

**Count the number of log lines:**

```terminal:execute
command: docker logs log-demo 2>&1 | wc -l
```

> **Note:** Nginx writes access logs to **stdout** and error logs to **stderr**. The `2>&1` redirects stderr to stdout so both streams are captured by `grep`.

---



## Cleanup

```terminal:execute
command: docker rm -f log-demo
```
