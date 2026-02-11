---
title: Liveness & Readiness Probes
---

# Level 4A: Liveness & Readiness Probes

How does Kubernetes know if your application is healthy? By default, Kubernetes only checks if the container **process is running**. But a running process doesn't mean the app is actually working — it could be stuck in a deadlock, running out of memory, or failing to connect to a database.

**Probes** let you define custom health checks so Kubernetes can detect and recover from these situations automatically.

> **Docs**: [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

## Types of Probes

| Probe | Purpose | On Failure |
|-------|---------|------------|
| **Liveness** | Is the container still alive? | **Restart** the container |
| **Readiness** | Is the container ready to serve traffic? | **Remove** from Service endpoints |
| **Startup** | Has the container started? | Block other probes until success |

### Probe Methods

| Method | How It Works | Example |
|--------|-------------|---------|
| **HTTP GET** | Sends HTTP request, success = 2xx/3xx | `httpGet: {path: /health, port: 8080}` |
| **TCP Socket** | Opens TCP connection | `tcpSocket: {port: 3306}` |
| **Exec** | Runs a command, success = exit code 0 | `exec: {command: [cat, /tmp/healthy]}` |

## A Healthy Pod with Probes

Let's start with a well-configured Pod. Open the exercise file:

```editor:open-file
file: exercises/probes/pod-probes.yaml
```

Key configuration:

```editor:select-matching-text
file: exercises/probes/pod-probes.yaml
text: livenessProbe
```

- **livenessProbe**: HTTP GET to `/` on port 80, checks every 10s, starts after 5s
- **readinessProbe**: HTTP GET to `/` on port 80, checks every 5s, starts after 3s

Apply and observe:

```terminal:execute
command: cp -r ~/exercises/probes ~/probes && kubectl apply -f ~/probes/pod-probes.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/healthy-app --timeout=60s
```

Check the Pod status — notice the `READY` column:

```terminal:execute
command: kubectl get pod healthy-app
```

`1/1` means the readiness probe passed and the Pod is ready to receive traffic.

Describe the Pod to see probe configuration:

```terminal:execute
command: kubectl describe pod healthy-app | grep -A5 -E "Liveness|Readiness"
```

## Watching a Failing Liveness Probe

Now let's see what happens when a liveness probe **fails**. Open the exercise file:

```editor:open-file
file: exercises/probes/pod-liveness-fail.yaml
```

This Pod has a clever setup:
1. It creates a file `/tmp/healthy` on startup
2. After **15 seconds**, it deletes the file
3. The liveness probe checks if `/tmp/healthy` exists
4. When the file is deleted, the probe **fails** and Kubernetes **restarts** the container

Apply and watch in real-time. Use the second terminal for monitoring:

```terminal:execute
command: kubectl apply -f ~/probes/pod-liveness-fail.yaml
```

Now watch the Pod status with the `-w` flag in the second terminal:

```terminal:execute
command: kubectl get pod liveness-fail -w
session: 2
```

Wait about 30–40 seconds. You should see the `RESTARTS` counter increase!

When you see one or more restarts, stop the watch:

```terminal:interrupt
session: 2
```

Check the events to see exactly what happened:

```terminal:execute
command: kubectl describe pod liveness-fail | tail -15
```

You should see events like:
- `Liveness probe failed: cat: /tmp/healthy: No such file or directory`
- `Container liveness-fail failed liveness probe, will be restarted`

This demonstrates the **self-healing** power of Kubernetes — it automatically detects unhealthy containers and restarts them.

## Readiness vs Liveness — Why Both?

Consider a web application that takes 30 seconds to start up:

- Without probes: Kubernetes sends traffic immediately → users see errors
- **Readiness probe**: Tells Kubernetes "don't send traffic until I'm ready"
- **Liveness probe**: Tells Kubernetes "restart me if I'm stuck"

```
Pod starts → Readiness probe fails (not ready yet)
             → No traffic routed to Pod
             → App finishes loading
             → Readiness probe passes
             → Traffic starts flowing
             → Later, app gets stuck in deadlock
             → Liveness probe fails
             → Kubernetes restarts the container
```

## Probe Timing Parameters

Fine-tune probe behavior with these parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `initialDelaySeconds` | 0 | Wait before first probe |
| `periodSeconds` | 10 | Time between probes |
| `timeoutSeconds` | 1 | Max wait for a response |
| `successThreshold` | 1 | Consecutive successes to pass |
| `failureThreshold` | 3 | Consecutive failures to fail |

> **Tip**: Set `initialDelaySeconds` high enough for your app to start. Too low = unnecessary restarts.

## Cleanup

```terminal:execute
command: kubectl delete -f ~/probes/ 2>/dev/null; echo "Cleanup done"
```

## Level 4A Summary

In this chapter you learned:
- **Liveness probes** detect stuck containers → Kubernetes **restarts** them
- **Readiness probes** detect unready containers → Kubernetes **stops routing traffic** to them
- Probe methods: **HTTP GET**, **TCP Socket**, **Exec** (command)
- Probes enable Kubernetes **self-healing** — automatic detection and recovery
- Timing parameters let you fine-tune probe behavior

| Command | Purpose |
|---------|---------|
| `kubectl describe pod <name>` | View probe configuration and events |
| `kubectl get pod <name> -w` | Watch for restarts in real-time |
| `kubectl get events --sort-by=.lastTimestamp` | View cluster events chronologically |

Next, let's look at **Jobs and CronJobs** — running batch and scheduled workloads!
