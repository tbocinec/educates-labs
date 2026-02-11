---
title: kubectl CLI Basics
---

# kubectl CLI Basics

`kubectl` (pronounced "kube-control" or "kube-cuddle") is the primary command-line tool for interacting with Kubernetes. Every operation — from deploying applications to inspecting cluster state — goes through `kubectl`.

> **Docs**: [kubectl Overview](https://kubernetes.io/docs/reference/kubectl/) | [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## Command Structure

The general syntax is:

```
kubectl [command] [resource-type] [name] [flags]
```

For example:
- `kubectl get pods` — list all Pods
- `kubectl describe pod my-nginx` — show details of a specific Pod
- `kubectl delete pod my-nginx` — delete a specific Pod

## Cluster Information

First, see what version of `kubectl` and the cluster you're running:

```terminal:execute
command: kubectl version --output=yaml
```

View detailed cluster information:

```terminal:execute
command: kubectl cluster-info
```

## Exploring API Resources

Kubernetes has many resource types. List all available resource types in the cluster:

```terminal:execute
command: kubectl api-resources --sort-by=name | head -30
```

This shows the short names, API group, whether the resource is namespaced, and the kind. Some commonly used short names:

| Short | Full Name |
|-------|-----------|
| `po`  | pods |
| `deploy` | deployments |
| `svc` | services |
| `cm`  | configmaps |
| `ns`  | namespaces |
| `no`  | nodes |
| `rs`  | replicasets |

You can use short names in any `kubectl` command. For example, `kubectl get po` is the same as `kubectl get pods`.

## The explain Command

One of the most useful commands when learning Kubernetes is `explain`. It shows the documentation for any resource type or field — right in the terminal.

Get documentation for a Pod:

```terminal:execute
command: kubectl explain pod
```

Drill into a specific field (use dot notation):

```terminal:execute
command: kubectl explain pod.spec.containers
```

Go even deeper:

```terminal:execute
command: kubectl explain pod.spec.containers.ports
```

> **Tip**: Use `--recursive` to see the entire structure at once:
> `kubectl explain pod.spec --recursive | head -50`

## The get Command

`kubectl get` lists resources. Let's explore the current state of the cluster.

List all namespaces:

```terminal:execute
command: kubectl get namespaces
```

List Pods in your namespace (should be empty for now):

```terminal:execute
command: kubectl get pods
```



## Common Output Formats

| Flag | Description |
|------|-------------|
| (default) | Human-readable table |
| `-o wide` | Table with additional columns |
| `-o yaml` | Full YAML representation |
| `-o json` | Full JSON representation |
| `-o name` | Just the resource name |
| `--no-headers` | Table without header row |

## Getting Help

Every `kubectl` command has built-in help:

```terminal:execute
command: kubectl --help | head -30
```

Get help for a specific command:

```terminal:execute
command: kubectl get --help | head -20
```

## Command Cheat Sheet

Here's a quick reference of the commands you'll use most in this workshop:

| Command | Purpose |
|---------|---------|
| `kubectl get` | List resources |
| `kubectl describe` | Show detailed info about a resource |
| `kubectl create` | Create a resource |
| `kubectl apply` | Create or update a resource from a file |
| `kubectl delete` | Delete a resource |
| `kubectl logs` | View container logs |
| `kubectl exec` | Execute a command in a container |
| `kubectl explain` | Show documentation for a resource |
| `kubectl scale` | Change replica count |
| `kubectl rollout` | Manage deployments (status, history, undo) |

Now that you know the essential `kubectl` commands, let's put them to use and run your first Pod!
