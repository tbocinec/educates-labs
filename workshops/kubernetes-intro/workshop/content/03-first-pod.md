---
title: Running Your First Pod
---

# Level 2: Running Your First Pod

A **Pod** is the smallest deployable unit in Kubernetes. It represents a single instance of a running process — typically wrapping one container (though it can contain multiple).

> **Docs**: [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)

## Creating a Pod Imperatively

The quickest way to create a Pod is using the `kubectl run` command:

```terminal:execute
command: kubectl run hello-pod --image=nginx:1.27
```

This creates a Pod named `hello-pod` running the `nginx:1.27` container image.

## Checking Pod Status

List the Pods in your namespace:

```terminal:execute
command: kubectl get pods
```

You should see `hello-pod` with a status progressing from `ContainerCreating` to `Running`.

Add the `-o wide` flag to see additional details like the node and IP address:

```terminal:execute
command: kubectl get pods -o wide
```

## Describing a Pod

The `describe` command provides detailed information about a resource, including events:

```terminal:execute
command: kubectl describe pod hello-pod
```

Scroll through the output and notice the key sections:

- **Metadata** — name, namespace, labels
- **Containers** — image, ports, state
- **Conditions** — Pod readiness and scheduling status
- **Events** — chronological log of what happened (pull image, create container, start)

## Viewing Pod Logs

Check the container logs to see what Nginx has output:

```terminal:execute
command: kubectl logs hello-pod
```

To follow logs in real-time (like `tail -f`), use the `-f` flag. Run this in the second terminal:

```terminal:execute
command: kubectl logs hello-pod -f
session: 2
```

Press `Ctrl+C` in the second terminal to stop following logs when done.

## Executing Commands Inside a Pod

You can run commands inside a running container using `kubectl exec`:

```terminal:execute
command: kubectl exec hello-pod -- hostname
```

The `--` separates `kubectl` flags from the command to execute inside the container.

Run an interactive shell session:

```terminal:execute
command: kubectl exec -it hello-pod -- /bin/bash
```

You're now inside the Nginx container! Let's verify Nginx is serving content:

```terminal:execute
command: curl localhost:80
```

Check the Nginx version:

```terminal:execute
command: nginx -v
```

Exit the container shell:

```terminal:execute
command: exit
```

## Port Forwarding

First, make sure you have stopped the log follow from the earlier step. Press `Ctrl+C` in the second terminal if it's still running:

```terminal:execute
command: ""
session: 2
```

To access the Pod from your local environment, use `kubectl port-forward`. Run this in the second terminal:

```terminal:execute
command: kubectl port-forward hello-pod 8080:80 &
session: 2
```

Now test the connection from the first terminal:

```terminal:execute
command: curl localhost:8080
```

Stop the port-forward:

```terminal:execute
command: kill %1 2>/dev/null; echo "Port-forward stopped"
session: 2
```

## Deleting a Pod

Clean up the Pod when you're done:

```terminal:execute
command: kubectl delete pod hello-pod
```

Verify the Pod is gone:

```terminal:execute
command: kubectl get pods
```

> **Important**: When you delete a standalone Pod, it's gone permanently. There is no automatic recreation. This is why we use **Deployments** in practice (covered in Chapter 5).

## Quick Dry Run

Before creating a resource, you can preview what would be created using `--dry-run=client`:

```terminal:execute
command: kubectl run test-pod --image=nginx:1.27 --dry-run=client -o yaml
```

This outputs the YAML manifest **without** actually creating the Pod. Very useful for generating YAML templates!

## Summary

In this chapter you learned:
- `kubectl run` — create a Pod imperatively
- `kubectl get pods` — list Pods
- `kubectl describe pod` — show detailed Pod info
- `kubectl logs` — view container logs
- `kubectl exec` — run commands inside a container
- `kubectl port-forward` — access a Pod's port locally
- `kubectl delete pod` — remove a Pod
- `--dry-run=client -o yaml` — preview without creating

Next, let's learn how to define Pods using YAML manifests — the **declarative** way.
