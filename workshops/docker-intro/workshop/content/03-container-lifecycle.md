# Container Lifecycle Management

Understanding how to manage the container lifecycle is essential for day-to-day Docker operations. In this section, you will learn how to stop, start, restart, pause, and remove containers.

---

## Container States

A Docker container can exist in several states:

```
Created ──► Running ──► Paused
                │           │
                │           ▼
                │       Unpaused (Running)
                │
                ▼
            Stopped (Exited) ──► Removed
```

| State | Description |
|-------|-------------|
| **Created** | Container has been created but never started |
| **Running** | Container is actively running its main process |
| **Paused** | Container's processes are suspended (frozen in memory) |
| **Stopped** | Container's main process has exited |
| **Removed** | Container has been deleted from the system |

---

## Stopping a Container

The `docker stop` command sends a **SIGTERM** signal to the container's main process, giving it a grace period (default: 10 seconds) to shut down cleanly. If the process doesn't stop within that window, Docker sends a **SIGKILL** to force termination:

```terminal:execute
command: docker stop webserver
```

**Verify the container has stopped:**

```terminal:execute
command: docker ps -a --filter "name=webserver"
```

The status should now show `Exited`.

You can customize the grace period with the `--time` or `-t` flag:

```
docker stop -t 30 webserver   # Wait 30 seconds before SIGKILL
```

---

## Starting a Stopped Container

A stopped container retains its filesystem and configuration. You can start it again:

```terminal:execute
command: docker start webserver
```

```terminal:execute
command: docker ps --filter "name=webserver"
```

The container is running again with the same configuration, data, and container ID as before.

---

## Restarting a Container

The `docker restart` command stops and then starts a container in a single operation. This is useful when a service needs a fresh start:

```terminal:execute
command: docker restart webserver
```

```terminal:execute
command: docker ps --filter "name=webserver"
```

The container's **uptime** resets, but the container ID and all configurations remain the same.

---

## Pausing and Unpausing a Container

Pausing a container **freezes all processes** using the Linux cgroup freezer. The container remains in memory but consumes no CPU cycles. This is useful for temporarily suspending a workload without losing its state:

**Pause the container:**

```terminal:execute
command: docker pause webserver
```

```terminal:execute
command: docker ps --filter "name=webserver"
```

Notice the status shows `(Paused)`.

**Unpause the container:**

```terminal:execute
command: docker unpause webserver
```

```terminal:execute
command: docker ps --filter "name=webserver"
```

The container resumes execution exactly where it left off.

---

## Killing a Container

If a container is unresponsive and `docker stop` takes too long, you can forcefully kill it with `docker kill`, which sends **SIGKILL** immediately (no grace period):

```terminal:execute
command: docker kill my-nginx-bg
```

> **Tip:** Use `docker stop` for graceful shutdowns and `docker kill` only when necessary. Forceful termination can lead to data corruption in some applications.

---

## Removing Containers

Stopped containers still consume disk space. To remove a stopped container:

```terminal:execute
command: docker rm my-nginx
```

```terminal:execute
command: docker rm my-nginx-bg
```

**Remove a running container** (force removal):

You cannot remove a running container by default. Use the `-f` (force) flag to stop and remove it in one step:

```terminal:execute
command: docker rm -f webserver
```

**Verify all containers are cleaned up:**

```terminal:execute
command: docker ps -a
```

---

## Automatic Container Removal

You've already seen the `--rm` flag, which automatically removes a container when it exits. This is especially useful for short-lived or one-shot containers:

```terminal:execute
command: docker run --rm --name temp-container alpine:latest echo "I will be removed automatically"
```

```terminal:execute
command: docker ps -a --filter "name=temp-container"
```

The container no longer exists — it was removed the instant it exited.

---

## Quick Reference: Lifecycle Commands

| Command | Description |
|---------|-------------|
| `docker run` | Create and start a container |
| `docker stop` | Gracefully stop a running container |
| `docker start` | Start a stopped container |
| `docker restart` | Stop and start a container |
| `docker pause` | Freeze a container's processes |
| `docker unpause` | Resume a paused container |
| `docker kill` | Forcefully stop a container |
| `docker rm` | Remove a stopped container |
| `docker rm -f` | Force-remove a running container |
