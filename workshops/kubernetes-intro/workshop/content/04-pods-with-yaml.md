---
title: Pods with YAML Manifests
---

# Pods with YAML Manifests

In the previous chapter you created Pods **imperatively** with `kubectl run`. In practice, Kubernetes resources are typically defined **declaratively** using YAML manifests. This approach is:

- **Reproducible** — the same YAML always produces the same result
- **Version-controllable** — manifests can be stored in Git
- **Reviewable** — team members can review changes before applying
- **Self-documenting** — the YAML describes the full resource specification

> **Docs**: [Pod YAML Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/)

## Anatomy of a Pod Manifest

A Kubernetes YAML manifest has four required top-level fields:

```yaml
apiVersion: v1          # Which API version to use
kind: Pod               # What type of resource
metadata:               # Resource identity (name, labels, etc.)
  name: my-pod
spec:                   # Desired state specification
  containers:
  - name: my-container
    image: nginx:1.27
```

## Creating a Pod from YAML

Let's look at the pre-built exercise file. Open it in the editor:

```editor:open-file
file: exercises/pod-basic/pod.yaml
```

This file defines a Pod named `my-nginx` running the `nginx:1.27` image with port 80 exposed.

First, copy the exercise file to your working directory:

```terminal:execute
command: cp -r ~/exercises/pod-basic ~/pod-basic
```

Apply the manifest to create the Pod:

```terminal:execute
command: kubectl apply -f ~/pod-basic/pod.yaml
```

Verify the Pod is running:

```terminal:execute
command: kubectl get pods
```

## Viewing the Live YAML

You can view the full YAML of a running resource with `-o yaml`:

```terminal:execute
command: kubectl get pod my-nginx -o yaml | head -40
```

Notice how Kubernetes has added many fields beyond what you specified — things like `status`, `uid`, `creationTimestamp`, default `tolerations`, etc. Kubernetes fills in defaults for anything you don't explicitly set.

## Comparing Apply vs Create

Kubernetes has two commands for creating resources from files:

| Command | Behavior |
|---------|----------|
| `kubectl create -f` | Creates the resource. **Fails** if it already exists. |
| `kubectl apply -f` | Creates the resource if it doesn't exist. **Updates** it if it does. |

`apply` is generally preferred because it's idempotent — you can safely run it multiple times.

Try applying the same file again:

```terminal:execute
command: kubectl apply -f ~/pod-basic/pod.yaml
```

Notice the output says `unchanged` — Kubernetes detected no changes needed.

## Editing a Pod

You can modify a running resource using `kubectl edit`, which opens the live manifest in a terminal editor:

```terminal:execute
command: kubectl edit pod my-nginx
```

This opens the full YAML in `vi`. You could change a mutable field (e.g., add a label), save and exit (`:wq`). Press `:q!` to quit without saving.

> **Note**: Most Pod fields are **immutable** after creation. To change immutable fields (like the image), you need to delete and recreate the Pod. This is another reason Deployments are preferred — they handle this automatically.

## Labels in Manifests

Let's look at a Pod with rich label metadata. Open the exercise file:

```editor:open-file
file: exercises/pod-labels/pod-labels.yaml
```

Notice the `labels` and `annotations` sections under `metadata`. Copy and apply this manifest:

```terminal:execute
command: cp -r ~/exercises/pod-labels ~/pod-labels && kubectl apply -f ~/pod-labels/pod-labels.yaml
```

Now you can filter Pods by label:

```terminal:execute
command: kubectl get pods --show-labels
```

Filter only Pods with a specific label:

```terminal:execute
command: kubectl get pods -l app=web
```

## Deleting Resources by File

When you create resources from a file, you can also delete them using the same file:

```terminal:execute
command: kubectl delete -f ~/pod-labels/pod-labels.yaml
```

This is very convenient — Kubernetes reads the file and deletes the matching resource.

Clean up the first Pod too:

```terminal:execute
command: kubectl delete -f ~/pod-basic/pod.yaml
```

Verify all Pods are cleaned up:

```terminal:execute
command: kubectl get pods
```

## Generating YAML Templates

A handy trick: use `--dry-run=client -o yaml` to generate YAML templates for any resource, then redirect to a file:

```terminal:execute
command: kubectl run my-app --image=busybox:1.36 --dry-run=client -o yaml > ~/generated-pod.yaml
```

View the generated file:

```terminal:execute
command: cat ~/generated-pod.yaml
```

You can then edit this file and apply it. This saves time when writing manifests from scratch.

## Summary

In this chapter you learned:
- YAML manifests have four key fields: `apiVersion`, `kind`, `metadata`, `spec`
- `kubectl apply -f` creates or updates resources declaratively
- `kubectl delete -f` removes resources defined in a file
- `kubectl get -o yaml` shows the full live resource definition
- Labels in manifests enable powerful filtering and selection
- `--dry-run=client -o yaml` generates manifest templates

Now that you're comfortable with Pods, let's move to **Deployments** — the recommended way to manage application workloads in production!
