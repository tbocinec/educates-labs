---
title: Labels, Selectors & Namespaces
---

# Labels, Selectors & Namespaces

As your Kubernetes environment grows, organizing resources becomes crucial. Kubernetes provides **Labels**, **Selectors**, and **Namespaces** as the primary tools for resource organization.

> **Docs**: [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) | [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

## Labels

**Labels** are key-value pairs attached to Kubernetes objects. They are used to organize and select subsets of objects.

Common labeling conventions:
- `app` — the application name (e.g., `web`, `api`, `database`)
- `environment` — the environment (e.g., `dev`, `staging`, `prod`)
- `tier` — the application tier (e.g., `frontend`, `backend`)
- `version` — the application version (e.g., `1.0`, `2.0`)

### Creating Pods with Labels

Let's create several Pods with different labels to experiment with. Open the exercise file:

```editor:open-file
file: exercises/labels/pod-multi-label.yaml
```

This file defines three Pods (using `---` as a YAML document separator):
- `frontend-v1` — app=web, tier=frontend, version=1.0
- `frontend-v2` — app=web, tier=frontend, version=2.0
- `backend-v1` — app=api, tier=backend, version=1.0

Copy and apply:

```terminal:execute
command: cp -r ~/exercises/labels ~/labels && kubectl apply -f ~/labels/pod-multi-label.yaml
```

Verify all Pods are running:

```terminal:execute
command: kubectl get pods --show-labels
```

## Selectors

**Selectors** are the mechanism for filtering resources by their labels. They are used extensively in `kubectl` commands and in resource definitions (e.g., Deployments selecting their Pods).

### Equality-Based Selectors

Filter Pods by an exact label match:

```terminal:execute
command: kubectl get pods -l app=web
```

Filter by a specific tier:

```terminal:execute
command: kubectl get pods -l tier=backend
```

Filter using inequality:

```terminal:execute
command: kubectl get pods -l "tier!=frontend"
```

### Set-Based Selectors

Filter where a label value is in a set:

```terminal:execute
command: kubectl get pods -l "version in (1.0, 2.0)"
```

Filter where a label exists (regardless of value):

```terminal:execute
command: kubectl get pods -l "app"
```

Combine multiple selectors (AND logic):

```terminal:execute
command: kubectl get pods -l "app=web,version=2.0"
```

### Adding and Removing Labels

Add a label to an existing Pod:

```terminal:execute
command: kubectl label pod frontend-v1 status=healthy
```

Verify:

```terminal:execute
command: kubectl get pod frontend-v1 --show-labels
```

Change an existing label (requires `--overwrite`):

```terminal:execute
command: kubectl label pod frontend-v1 version=1.1 --overwrite
```

Remove a label (use the minus suffix):

```terminal:execute
command: kubectl label pod frontend-v1 status-
```

Verify:

```terminal:execute
command: kubectl get pod frontend-v1 --show-labels
```

## Namespaces

**Namespaces** provide a way to divide cluster resources into virtual sub-clusters. They are useful for:

- **Multi-tenancy** — isolating teams or projects
- **Resource quotas** — limiting resource usage per namespace
- **Access control** — RBAC rules can be scoped to namespaces

### Listing Namespaces

View all namespaces in the cluster:

```terminal:execute
command: kubectl get namespaces
```

Common default namespaces:
- `default` — the default namespace for objects with no namespace
- `kube-system` — system components (API server, etcd, etc.)
- `kube-public` — publicly readable resources

Your workshop namespace is `{{ session_namespace }}`. All `kubectl` commands in this workshop run against this namespace by default.

### Working Across Namespaces

> **Note:** The following commands may not work in clusters where you don't have permissions to view resources in other namespaces (e.g., in shared environments like Educates). If a command returns a "Forbidden" error, that's expected — it means RBAC policies are restricting your access to your own namespace only.

See Pods in a specific namespace:

```terminal:execute
command: kubectl get pods -n kube-system
```

See Pods in all namespaces:

```terminal:execute
command: kubectl get pods --all-namespaces | head -20
```

Or use the shorter flag:

```terminal:execute
command: kubectl get pods -A | head -20
```

### Checking Your Current Context

See which namespace your `kubectl` is configured to use by default:

```terminal:execute
command: kubectl config view --minify | grep namespace
```

## Labels in Practice: Why They Matter

Labels are not just for manual filtering. They are the backbone of how Kubernetes controllers work:

1. **Deployments** use `selector.matchLabels` to find their Pods
2. **Services** use `selector` to route traffic to the right Pods
3. **Network Policies** use label selectors to define access rules
4. **Monitoring tools** use labels to aggregate metrics

For example, remember the Deployment from chapter 5:

```yaml
spec:
  selector:
    matchLabels:
      app: nginx    # ← Deployment selects Pods with this label
  template:
    metadata:
      labels:
        app: nginx  # ← Pods get this label when created
```

The label selector creates a **binding** between the Deployment and its Pods. If the labels don't match, the Deployment won't manage those Pods!

## Cleanup

Remove the Pods:

```terminal:execute
command: kubectl delete -f ~/labels/pod-multi-label.yaml
```

Verify:

```terminal:execute
command: kubectl get pods
```

## Summary

In this chapter you learned:
- **Labels** are key-value pairs for organizing resources
- **Selectors** filter resources by label (`-l app=web`, `-l "version in (1.0, 2.0)"`)
- `kubectl label` — add, modify, or remove labels on existing resources
- **Namespaces** partition cluster resources into isolated virtual clusters
- `-n <namespace>` targets a specific namespace; `-A` shows all namespaces
- Labels are the foundation of how Deployments, Services, and other controllers find their resources

This concludes the hands-on exercises! Head to the Summary for a recap of everything you've learned.
