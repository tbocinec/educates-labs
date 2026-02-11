---
title: Updates & Rollbacks
---

# Updates & Rollbacks

One of the most powerful features of Kubernetes Deployments is the ability to **update applications with zero downtime** and **roll back** if something goes wrong.

> **Docs**: [Rolling Update Strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment)

## Rolling Update Strategy

By default, Deployments use the **RollingUpdate** strategy:
- New Pods are gradually created with the updated configuration
- Old Pods are gradually terminated
- At no point are all Pods unavailable

The key parameters controlling this behavior are:
- `maxSurge` — how many extra Pods can be created during the update (default: 25%)
- `maxUnavailable` — how many Pods can be unavailable during the update (default: 25%)

## Current State

Let's check the current state of our Deployment from the previous chapter:

```terminal:execute
command: kubectl get deployment nginx-deployment -o wide
```

Notice the `IMAGE` column — it should show `nginx:1.26`. Let's update to `nginx:1.27`.

First, scale back to 3 replicas for a clearer demonstration:

```terminal:execute
command: kubectl scale deployment nginx-deployment --replicas=3
```

## Updating with kubectl set image

The `kubectl set image` command is the quickest way to update a container image:

Start watching the Pods in the second terminal:

```terminal:execute
command: kubectl get pods -w
session: 2
```

Now trigger the rolling update in the first terminal:

```terminal:execute
command: kubectl set image deployment nginx-deployment nginx=nginx:1.27
```

Watch the output in the second terminal — you'll see new Pods being created and old Pods being terminated in a rolling fashion.

Press `Ctrl+C` in the second terminal when the update is complete.

Check the updated Deployment:

```terminal:execute
command: kubectl get deployment nginx-deployment -o wide
```

The `IMAGE` column should now show `nginx:1.27`.

## Updating with a YAML File

In practice, you would update the YAML manifest and apply the change. Open the updated manifest:

```editor:open-file
file: exercises/deployment/deployment-v2.yaml
```

Notice the image change:

```editor:select-matching-text
file: exercises/deployment/deployment-v2.yaml
text: image: nginx:1.27
```

This file has `nginx:1.27` (which we already applied). In a real workflow, you'd edit the YAML, commit to Git, and apply.

## Rollout Status

Check the status of a rollout at any time:

```terminal:execute
command: kubectl rollout status deployment nginx-deployment
```

## Rollout History

Every update creates a new revision. View the history of revisions:

```terminal:execute
command: kubectl rollout history deployment nginx-deployment
```

To see details of a specific revision:

```terminal:execute
command: kubectl rollout history deployment nginx-deployment --revision=1
```

```terminal:execute
command: kubectl rollout history deployment nginx-deployment --revision=2
```

Notice the image versions differ between revisions.

## Recording Changes

By default, the `CHANGE-CAUSE` column in rollout history is empty. You can add context using the `--record` flag (deprecated but still works) or by annotating the Deployment:

```terminal:execute
command: kubectl annotate deployment nginx-deployment kubernetes.io/change-cause="Updated image to nginx:1.27"
```

Check the history again:

```terminal:execute
command: kubectl rollout history deployment nginx-deployment
```

## Simulating a Bad Update

Let's simulate a failed update by setting an image that doesn't exist:

```terminal:execute
command: kubectl set image deployment nginx-deployment nginx=nginx:99.99.99
```

```terminal:execute
command: kubectl annotate deployment nginx-deployment kubernetes.io/change-cause="Updated to non-existent image nginx:99.99.99" --overwrite
```

Watch the Pods:

```terminal:execute
command: kubectl get pods
```

You'll see new Pods stuck in `ImagePullBackOff` or `ErrImagePull` — Kubernetes can't find image `nginx:99.99.99`.

Check the rollout status:

```terminal:execute
command: kubectl rollout status deployment nginx-deployment --timeout=30s
```

The rollout will not complete because the new Pods can't start. But note that some of the **old Pods** are still running — the rolling update strategy ensures availability during the transition.

## Rolling Back

This is where rollbacks shine. Undo the last update:

```terminal:execute
command: kubectl rollout undo deployment nginx-deployment
```

Check the Pods:

```terminal:execute
command: kubectl get pods
```

The failing Pods are terminated and the previous working version is restored.

Verify the image:

```terminal:execute
command: kubectl get deployment nginx-deployment -o wide
```

You should see `nginx:1.27` again (the previous working revision).

## Rolling Back to a Specific Revision

You can also roll back to a specific revision number:

```terminal:execute
command: kubectl rollout history deployment nginx-deployment
```

To roll back to revision 1 (the original `nginx:1.26`):

```terminal:execute
command: kubectl rollout undo deployment nginx-deployment --to-revision=1
```

Check the result:

```terminal:execute
command: kubectl get deployment nginx-deployment -o wide
```

## Understanding ReplicaSets During Updates

Each update creates a new ReplicaSet. Let's see them all:

```terminal:execute
command: kubectl get replicasets
```

Notice:
- One ReplicaSet has the current desired Pod count
- Previous ReplicaSets have `DESIRED` = 0 but are **kept** for rollback purposes

This is how Kubernetes tracks revision history — each revision is a ReplicaSet.

## Cleanup

Let's clean up the Deployment before the next chapter:

```terminal:execute
command: kubectl delete deployment nginx-deployment
```

Verify everything is cleaned up:

```terminal:execute
command: kubectl get pods
```

## Summary

In this chapter you learned:
- **Rolling updates** — zero-downtime image updates with `kubectl set image` or `kubectl apply -f`
- `kubectl rollout status` — monitor a rolling update
- `kubectl rollout history` — view update history and revisions
- `kubectl rollout undo` — roll back to the previous version
- `kubectl rollout undo --to-revision=N` — roll back to a specific revision
- Each update creates a new **ReplicaSet** (old ones are kept for rollback)
- Rolling updates protect availability during bad deployments

Next, let's learn about **ConfigMaps** — the Kubernetes way to manage application configuration!
