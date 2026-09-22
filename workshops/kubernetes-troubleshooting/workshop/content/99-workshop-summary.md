---
title: Workshop Summary
---

# Workshop Summary

Congratulations! You've debugged eight broken workloads across five categories. 🎉

The point was never the eight error messages — it was the method underneath them.

---

## The Method

```
1. kubectl get pods              → what state, how many restarts?
2. kubectl describe pod <name>   → why did Kubernetes decide that?
3. kubectl get events            → what happened, in what order?
4. kubectl logs <name>           → what did the application say?
```

Two rules that save the most time:

- **If the container never started, there are no logs.** Steps 1–3 tell you whether step 4 is even possible.
- **If `kubectl apply` printed an error, there is no object.** Stop looking for a Pod to describe.

---

## Diagnosis by Symptom

| Symptom | Likely cause | Command that proves it |
|---------|--------------|------------------------|
| `ImagePullBackOff` | Wrong tag, private registry, rate limit | `describe` → Events |
| `CreateContainerConfigError` | Missing ConfigMap/Secret key | `describe` → Events |
| `CrashLoopBackOff` | App exits on startup | `logs --previous` |
| `OOMKilled` / exit 137 | Exceeded memory limit | `describe` → Last State |
| `Pending` | Scheduler found no fit | `describe` → `FailedScheduling` |
| Error on `apply` | Admission (LimitRange/quota) | the error text itself |
| Running but unreachable | Selector or port mismatch | `kubectl get endpoints` |

---

## Exit Codes Worth Memorising

| Code | Meaning |
|------|---------|
| `0` | Clean exit — for a long-running app, usually still a bug |
| `1` | Application error — the logs will say why |
| `127` | Command not found — wrong `command`/`args` or wrong image |
| `137` | `SIGKILL` — almost always OOMKilled |
| `143` | `SIGTERM` — terminated on request, often a failing liveness probe |

---

## Where Failures Happen

Knowing *which* subsystem rejected you tells you where to look:

| Stage | Who decides | Symptom | Evidence |
|-------|-------------|---------|----------|
| **Admission** | API server, LimitRange, quota | `apply` fails | The error text |
| **Scheduling** | Scheduler | `Pending` | `FailedScheduling` event |
| **Startup** | kubelet | `ImagePullBackOff`, config errors | Pod events |
| **Runtime** | Container / kernel | `CrashLoopBackOff`, `OOMKilled` | `logs --previous`, Last State |
| **Networking** | Service / EndpointSlice | Running but unreachable | `get endpoints` |

---

## Command Cheat Sheet

### First look

```
kubectl get pods -o wide                        # status, restarts, node, IP
kubectl get events --sort-by=.lastTimestamp     # chronological narrative
kubectl get events --field-selector type=Warning
```

### Narrowing down

```
kubectl describe pod <name>                     # events + config + last state
kubectl describe pod <name> | grep -A10 Events:
kubectl logs <name>                             # current container
kubectl logs <name> --previous                  # the one that died
kubectl logs -l app=<label> --tail=50           # by label, all replicas
```

### Getting inside

```
kubectl exec -it <pod> -- sh                    # shell in the container
kubectl exec <pod> -- printenv                  # what env did it actually get?
kubectl debug <pod> -it --image=busybox         # ephemeral container, no shell needed
```

### Networking

```
kubectl get endpoints <service>                 # the one command that matters
kubectl describe service <service>
kubectl get pods --show-labels                  # compare against the selector
```

### Limits and quotas

```
kubectl describe limitrange
kubectl describe resourcequota
kubectl top pod                                 # actual usage (needs metrics-server)
```

---

## What Wasn't Covered

This workshop stayed inside a single namespace, which is where most failures
live. Things you'll meet later:

- **Failing probes** — a readiness probe that never passes empties endpoints silently
- **Node problems** — `NotReady` nodes, disk pressure, evictions
- **RBAC denials** — `Forbidden` errors from an under-privileged ServiceAccount
- **DNS failures** — `nslookup` inside a Pod when name resolution breaks
- **Init containers** — `Init:0/1` stuck, a whole failure mode of its own

---

## Official Kubernetes Documentation

- [Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
- [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)
- [Debug Running Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/)
- [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

Thank you for completing this workshop! 🚀
