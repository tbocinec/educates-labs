---
title: A Method That Works
---

# Level 1: A Method That Works

Before touching anything broken, let's agree on the method. Almost every Pod
problem is solved by the same four steps, in this order:

| Step | Command | Answers |
|------|---------|---------|
| **1. Status** | `kubectl get pods` | What state is it in? How many restarts? |
| **2. Description** | `kubectl describe pod <name>` | Why did Kubernetes make that decision? |
| **3. Events** | `kubectl get events --sort-by=.lastTimestamp` | What happened, in what order? |
| **4. Logs** | `kubectl logs <name>` | What did the *application* say? |

The single most common mistake is jumping straight to step 4. If a container
never started, it has **no logs** — and you'll stare at an empty output
wondering what went wrong. Steps 1–3 tell you whether logs even exist yet.

> **Docs**: [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)

## Reading the STATUS Column

`kubectl get pods` shows a STATUS that already narrows the problem down a lot:

| STATUS | Meaning | Where to look next |
|--------|---------|--------------------|
| `Pending` | Not scheduled onto a node yet | `describe` → Events (scheduler) |
| `ContainerCreating` | Scheduled, kubelet is preparing it | `describe` → Events (kubelet) |
| `ImagePullBackOff` | The image could not be pulled | `describe` → Events, check image name |
| `CreateContainerConfigError` | A ConfigMap/Secret reference is wrong | `describe` → Events |
| `CrashLoopBackOff` | It started, exited, and is being restarted | `logs --previous` |
| `Running` but `0/1` ready | Readiness probe failing | `describe` → probe config, `logs` |
| `OOMKilled` | Exceeded its memory limit | `describe` → Last State, raise limit or fix leak |

Keep this table open. You'll use every row in this workshop.

## Setting Up

Copy the broken manifests into your home directory so you can edit them freely:

```terminal:execute
command: cp -r ~/exercises ~/broken && ls ~/broken
```

## A Healthy Baseline

Let's start with something that works, so you know what "normal" looks like.

```terminal:execute
command: kubectl create deployment healthy --image=nginx:1.27 --replicas=1
```

```terminal:execute
command: kubectl get pods -l app=healthy
```

A healthy Pod reads `1/1  Running  0` — one of one containers ready, running,
zero restarts. Anything else is a story worth reading.

Look at what `describe` tells you about a working Pod, so the broken ones are
easier to contrast:

```terminal:execute
command: kubectl describe deployment healthy | tail -12
```

The **Events** section at the bottom is the part people skip. It's the cluster
narrating its own decisions in chronological order.

## Events Are the Cluster's Diary

Events are separate objects with a short lifetime (about an hour by default).
List them for the whole namespace, oldest first:

```terminal:execute
command: kubectl get events --sort-by=.lastTimestamp
```

This single command is often enough to spot the problem without describing
anything. Two variants worth remembering:

```terminal:execute
command: kubectl get events --field-selector type=Warning
```

Warnings only — the signal, without the noise of every successful pull and
schedule.

## Four Commands to Keep Handy

```terminal:execute
command: kubectl get pods -o wide
```

`-o wide` adds the node and Pod IP — useful when only *some* replicas misbehave.

```terminal:execute
command: kubectl describe pod -l app=healthy | grep -A10 Events:
```

Jump straight to the Events section of a Pod.

```terminal:execute
command: kubectl logs -l app=healthy --tail=20
```

Logs by label, so you don't need the generated Pod name.

```terminal:execute
command: kubectl exec deploy/healthy -- nginx -v
```

Run a command *inside* the container — the last resort when the cluster looks
fine but the app disagrees.

## Clean Up

```terminal:execute
command: kubectl delete deployment healthy
```

## Summary

In this chapter you learned:
- The order that works: **status → describe → events → logs**
- A container that never started has **no logs** — don't start there
- The STATUS column already narrows the cause to a handful of options
- `kubectl get events --sort-by=.lastTimestamp` is the fastest first look
- `--field-selector type=Warning` filters events down to the problems

Now let's apply it. In the next chapter, a Pod that never starts at all.
