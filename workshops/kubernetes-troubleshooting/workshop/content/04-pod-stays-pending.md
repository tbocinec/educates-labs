---
title: The Pod Stays Pending
---

# Level 4: The Pod Stays Pending

Symptom: `kubectl get pods` shows `Pending`, and it stays that way. No node, no
container, no logs.

`Pending` means the **scheduler** hasn't placed the Pod on a node. This is a
different subsystem from the previous failures, and it leaves its reasoning in
the events.

## Scenario 5: Nothing Will Schedule It

```editor:open-file
file: broken/05-pending/pod-nodeselector.yaml
```

```terminal:execute
command: kubectl apply -f ~/broken/05-pending/pod-nodeselector.yaml
```

### Observe

```terminal:execute
command: kubectl get pod picky-app
```

`Pending`, and no NODE assigned:

```terminal:execute
command: kubectl get pod picky-app -o wide
```

### Diagnose

```terminal:execute
command: kubectl describe pod picky-app | grep -A8 Events:
```

The scheduler reports `FailedScheduling` and — crucially — counts the nodes it
rejected and why: *"didn't match Pod's node affinity/selector"*.

Look at what the Pod demands:

```terminal:execute
command: kubectl get pod picky-app -o jsonpath='{.spec.nodeSelector}{"\n"}'
```

And what the cluster's nodes actually offer:

```terminal:execute
command: kubectl get nodes --show-labels
```

No node carries `disktype=ultra-fast-ssd`, so no node is eligible.

### Root Cause

A `nodeSelector` that matches nothing. The scheduler's message is a checklist —
it tells you how many nodes failed each predicate:

| Scheduler message | Cause |
|-------------------|-------|
| `didn't match Pod's node affinity/selector` | `nodeSelector`/affinity matches no node |
| `Insufficient cpu` / `Insufficient memory` | No node has room for the requests |
| `had untolerated taint` | Nodes are tainted, Pod has no toleration |
| `had volume node affinity conflict` | PV is in a zone the Pod can't be placed in |
| `pod has unbound immediate PersistentVolumeClaims` | PVC isn't bound yet |

> **`Pending` is not always a bug.** On a cluster with autoscaling — like this
> one — a Pod can sit `Pending` for a minute while a new node is created. Read
> the event before assuming something is broken.

### Fix and Verify

Drop the impossible requirement:

```terminal:execute
command: kubectl delete pod picky-app --ignore-not-found
```

```terminal:execute
command: kubectl apply -f ~/broken/05-pending/pod-nodeselector-fixed.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/picky-app-fixed --timeout=90s
```

```terminal:execute
command: kubectl get pod picky-app-fixed -o wide
```

Now it has a node. Clean up:

```terminal:execute
command: kubectl delete -f ~/broken/05-pending/pod-nodeselector-fixed.yaml --ignore-not-found
```

## Scenario 6: Rejected Before It Exists

Not every failure produces a Pod to inspect. Some are refused at the door.

```editor:open-file
file: broken/05-pending/pod-too-big.yaml
```

```terminal:execute
command: kubectl apply -f ~/broken/05-pending/pod-too-big.yaml
```

### Observe

Read the output carefully — there is no Pod to describe:

```terminal:execute
command: kubectl get pod greedy-app
```

`NotFound`. The API server rejected the object outright.

### Diagnose

The error from `apply` *was* the diagnosis: `maximum memory usage per Pod is
8Gi, but limit is 32Gi`. That's an **admission** rejection, enforced by objects
that live in your namespace.

See the rules you're playing by:

```terminal:execute
command: kubectl describe limitrange
```

```terminal:execute
command: kubectl describe resourcequota
```

`LimitRange` caps what a single Pod or container may ask for. `ResourceQuota`
caps the total across your whole namespace — and it also shows how much you've
already used.

### Root Cause

The manifest requested more than the namespace policy allows. The distinction
that matters:

| Where it fails | What you see | Where to look |
|----------------|--------------|---------------|
| **Admission** (`apply` errors) | No object is created | The error text, `LimitRange`, `ResourceQuota` |
| **Scheduling** (Pod is `Pending`) | Object exists, no node | `describe` → `FailedScheduling` |
| **Runtime** (Pod runs, then fails) | Restarts, `OOMKilled` | `logs --previous`, `Last State` |

If `kubectl apply` printed an error, stop reading Pod status — there is no Pod.

### Fix and Verify

Ask for something within the quota:

```terminal:execute
command: kubectl apply -f ~/broken/05-pending/pod-right-sized.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/greedy-app-fixed --timeout=90s
```

See your quota consumption change:

```terminal:execute
command: kubectl get resourcequota -o custom-columns=NAME:.metadata.name,USED:.status.used,HARD:.status.hard
```

Clean up:

```terminal:execute
command: kubectl delete -f ~/broken/05-pending/pod-right-sized.yaml --ignore-not-found
```

## Summary

In this chapter you learned:
- `Pending` means the **scheduler** couldn't place the Pod — the reason is in the events
- `FailedScheduling` counts nodes and names the predicate each one failed
- Common causes: unmatched `nodeSelector`, insufficient resources, untolerated taints
- An error from `kubectl apply` means **admission** rejected it — no Pod exists to debug
- `LimitRange` bounds a single Pod; `ResourceQuota` bounds the whole namespace

Next: the Pod is healthy, but nobody can reach it.
