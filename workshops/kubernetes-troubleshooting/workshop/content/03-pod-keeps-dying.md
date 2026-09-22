---
title: The Pod Starts, Then Dies
---

# Level 3: The Pod Starts, Then Dies

Symptom: the restart counter keeps climbing. The Pod flickers between `Running`
and `Error`, and eventually settles into `CrashLoopBackOff`.

Good news: the container **did** run, so this time there *are* logs. The trick is
asking for the right ones.

## Scenario 3: CrashLoopBackOff

```editor:open-file
file: broken/03-crashloop/pod-crashloop.yaml
```

```terminal:execute
command: kubectl apply -f ~/broken/03-crashloop/pod-crashloop.yaml
```

### Observe

Watch the restart count grow. Run this in your **second terminal** and leave it
running:

```terminal:execute
command: kubectl get pod worker -w
session: 2
```

Meanwhile, check the status here:

```terminal:execute
command: kubectl get pod worker
```

The Pod cycles: `Running` → `Error` → `CrashLoopBackOff` → `Running` → … Each
restart waits longer than the last (10s, 20s, 40s… capped at 5 minutes).

### Diagnose

Ask for the logs the obvious way:

```terminal:execute
command: kubectl logs worker
```

Depending on timing you may get the current attempt's output — or nothing at
all, if the container is between restarts. That's the trap. Ask for the
**previous** container instead:

```terminal:execute
command: kubectl logs worker --previous
```

There it is: `FATAL: cannot open /etc/worker/config.yaml`. The application told
you exactly what it needed.

> **If you see `unable to retrieve container logs for containerd://...`**, you
> caught the Pod mid-restart — the old container is gone and the new one hasn't
> logged yet. Wait a few seconds and run the command again. This is a timing
> race, not a broken cluster.

> **`--previous` is the whole lesson of this scenario.** A crash-looping
> container's useful output belongs to the instance that already died. Without
> this flag you are reading the one that hasn't failed *yet*.

Confirm how it terminated:

```terminal:execute
command: kubectl get pod worker -o jsonpath='reason={.status.containerStatuses[0].lastState.terminated.reason} exit={.status.containerStatuses[0].lastState.terminated.exitCode}{"\n"}'
```

`Error` with exit code `1` — the application chose to exit. Compare that with the
next scenario, where the exit code tells a very different story.

Stop the watch in the second terminal:

```terminal:interrupt
session: 2
```

### Root Cause

The app requires a config file that was never mounted. In production this is
almost always one of:

| Exit code | Usually means |
|-----------|---------------|
| `1` | Application error — read the logs, it told you |
| `137` | `SIGKILL` — almost always OOMKilled (see below) |
| `143` | `SIGTERM` — shut down on request, often a failing liveness probe |
| `127` | Command not found — wrong `command`/`args` or wrong image |

### Fix and Verify

The real fix is mounting the config. Delete the broken Pod:

```terminal:execute
command: kubectl delete pod worker --ignore-not-found
```

```terminal:execute
command: kubectl apply -f ~/broken/03-crashloop/pod-fixed.yaml
```

```terminal:execute
command: kubectl get pod worker-fixed
```

```terminal:execute
command: kubectl logs worker-fixed
```

The worker now finds its config and keeps running.

```terminal:execute
command: kubectl delete -f ~/broken/03-crashloop/pod-fixed.yaml --ignore-not-found
```

## Scenario 4: OOMKilled

Same "keeps dying" symptom, but the application never gets to complain.

```editor:open-file
file: broken/04-oom/pod-oom.yaml
```

This Pod writes 200 MB into a memory-backed volume while holding a **64 Mi**
memory limit.

```terminal:execute
command: kubectl apply -f ~/broken/04-oom/pod-oom.yaml
```

### Observe

```terminal:execute
command: kubectl get pod memory-hog
```

### Diagnose

Wait a few seconds, then read the termination reason:

```terminal:execute
command: kubectl get pod memory-hog -o jsonpath='reason={.status.containerStatuses[0].state.terminated.reason} exit={.status.containerStatuses[0].state.terminated.exitCode}{"\n"}'
```

`OOMKilled`, exit code `137`. Now look at the logs:

```terminal:execute
command: kubectl logs memory-hog
```

Notice what's **missing**: no error, no stack trace, no goodbye. The kernel
killed the process instantly — the app had no chance to log anything. An empty
log plus exit 137 is the signature of an OOM kill.

See it in `describe` too:

```terminal:execute
command: kubectl describe pod memory-hog | grep -A6 "Last State"
```

And compare what it asked for against what it used:

```terminal:execute
command: kubectl get pod memory-hog -o jsonpath='limits={.spec.containers[0].resources.limits}{"\n"}'
```

### Root Cause

The container exceeded its `resources.limits.memory`. The kernel's OOM killer
enforces that limit — Kubernetes doesn't ask politely.

> **Memory limits are hard; CPU limits are not.** Exceed a CPU limit and your
> container is *throttled* (slow). Exceed a memory limit and it is *killed*.
> That asymmetry surprises people.

### Fix and Verify

There are two honest fixes: give it more memory, or make the app use less. Here
the workload genuinely needs ~200 MB, so raise the limit:

```terminal:execute
command: kubectl delete pod memory-hog --ignore-not-found
```

```terminal:execute
command: kubectl apply -f ~/broken/04-oom/pod-oom-fixed.yaml
```

```terminal:execute
command: kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/memory-hog-fixed --timeout=120s
```

```terminal:execute
command: kubectl logs memory-hog-fixed
```

It completes and prints `done`.

> **Raising the limit is not always right.** If the app leaks memory, a bigger
> limit just delays the crash. Use `kubectl top pod` (where metrics-server is
> available) to see real usage before choosing a number.

Clean up:

```terminal:execute
command: kubectl delete -f ~/broken/04-oom/pod-oom-fixed.yaml --ignore-not-found
```

## Summary

In this chapter you learned:
- `CrashLoopBackOff` means it ran and exited — read `kubectl logs --previous`
- Restart backoff grows to a 5-minute ceiling, so a fix may look slow to take effect
- Exit `1` = the app failed and logged why; exit `137` = OOMKilled and it logged nothing
- An **empty log with exit 137** is the fingerprint of a memory limit
- Memory limits kill; CPU limits only throttle

Next: Pods that never even reach a node.
