---
title: Deployments
---

# Level 3: Deployments

In the previous chapters you created standalone Pods. But standalone Pods have limitations:

- **No self-healing** — if a Pod dies, it stays dead
- **No scaling** — you can't easily run multiple identical Pods
- **No rolling updates** — you must manually delete and recreate Pods to change the image

A **Deployment** solves all of these problems. It's the standard way to run stateless applications in Kubernetes.

> **Docs**: [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## What is a Deployment?

A Deployment manages a **ReplicaSet**, which in turn manages a set of identical **Pods**.

```
Deployment
  └── ReplicaSet
        ├── Pod 1
        ├── Pod 2
        └── Pod 3
```

The Deployment controller continuously ensures the actual state matches your desired state:
- Want 3 replicas? It creates and maintains exactly 3 Pods.
- A Pod crashes? The controller automatically creates a replacement.
- Need to update the image? It performs a rolling update with zero downtime.

## Creating a Deployment Imperatively

The fastest way to create a Deployment:

```terminal:execute
command: kubectl create deployment my-nginx --image=nginx:1.26 --replicas=2
```

Check the result:

```terminal:execute
command: kubectl get deployments
```

See the Pods created by the Deployment:

```terminal:execute
command: kubectl get pods
```

Notice the Pod names follow the pattern: `{deployment-name}-{replicaset-hash}-{pod-hash}`.

## Exploring the Deployment

View detailed information about the Deployment:

```terminal:execute
command: kubectl describe deployment my-nginx
```

Look at the key sections:
- **Replicas** — desired vs. current vs. available
- **StrategyType** — how updates are applied (RollingUpdate by default)
- **Pod Template** — the template used to create Pods
- **Events** — what Kubernetes has done

View the underlying ReplicaSet:

```terminal:execute
command: kubectl get replicasets
```

The ReplicaSet is the object that actually manages the Pod count. You rarely interact with ReplicaSets directly — the Deployment manages them for you.

## Creating a Deployment from YAML

Let's delete the imperative Deployment and use a YAML manifest instead:

```terminal:execute
command: kubectl delete deployment my-nginx
```

Open the exercise file in the editor:

```editor:open-file
file: exercises/deployment/deployment.yaml
```

Review the key sections:

```editor:select-matching-text
file: exercises/deployment/deployment.yaml
text: replicas: 3
```

- `replicas: 3` — run 3 identical Pods
- `selector.matchLabels` — how the Deployment finds its Pods
- `template` — the Pod template (metadata + spec)

> **Important**: The `selector.matchLabels` must match the `template.metadata.labels`. This is how the Deployment knows which Pods belong to it.

Copy and apply the manifest:

```terminal:execute
command: cp -r ~/exercises/deployment ~/deployment && kubectl apply -f ~/deployment/deployment.yaml
```

Watch the Pods come up (press Ctrl+C to stop):

```terminal:execute
command: kubectl get pods -w
session: 2
```

Check the Deployment status:

```terminal:execute
command: kubectl get deployment nginx-deployment
```

## Scaling a Deployment

Scale the Deployment to 5 replicas:

```terminal:execute
command: kubectl scale deployment nginx-deployment --replicas=5
```

Watch the new Pods appear:

```terminal:execute
command: kubectl get pods
```

Scale back down to 2:

```terminal:execute
command: kubectl scale deployment nginx-deployment --replicas=2
```

Check that the extra Pods are terminating:

```terminal:execute
command: kubectl get pods
```

> **Tip**: You can also scale by editing the Deployment:
> `kubectl edit deployment nginx-deployment` and changing the `replicas` field.

## Self-Healing in Action

Let's demonstrate Kubernetes self-healing. First, get the current Pod names:

```terminal:execute
command: kubectl get pods -o name
```

Now manually delete one of the Pods (replace the name if needed):

```terminal:execute
command: POD=$(kubectl get pods -l app=nginx -o name | head -1) && kubectl delete $POD
```

Immediately check the Pods:

```terminal:execute
command: kubectl get pods
```

Notice that Kubernetes has already started creating a **replacement Pod** to maintain the desired replica count of 2. This is self-healing in action!

## Deployment Status

Check the rollout status of the Deployment:

```terminal:execute
command: kubectl rollout status deployment nginx-deployment
```

This shows whether the Deployment has finished rolling out all its Pods.

## The Kubernetes Dashboard

Switch to the **Console** tab to see the Kubernetes Dashboard. You can visualize your Deployment, its ReplicaSet, and individual Pods in a graphical interface.

The Dashboard provides:
- Resource overview and health status
- Real-time events and logs
- YAML/JSON resource details

## Summary

In this chapter you learned:
- **Deployments** manage ReplicaSets which manage Pods
- `kubectl create deployment` — create imperatively
- `kubectl apply -f` — create from YAML manifest
- `kubectl scale deployment` — adjust replica count
- `kubectl describe deployment` — view Deployment details
- `kubectl rollout status` — check rollout progress
- Self-healing: Kubernetes automatically replaces failed Pods

In the next chapter, you'll learn how to update applications and perform rollbacks with zero downtime!
