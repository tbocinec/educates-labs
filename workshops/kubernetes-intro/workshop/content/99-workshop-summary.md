---
title: Workshop Summary
---

# Workshop Summary

Congratulations on completing the **Kubernetes Fundamentals** workshop! Here's a recap of everything you've learned.

## Level 1 — Getting Started

**Kubernetes Architecture:**
- Control Plane (API Server, etcd, Scheduler, Controller Manager) manages the cluster
- Worker Nodes (kubelet, kube-proxy, container runtime) run your workloads

**kubectl Basics:**
- `kubectl cluster-info` — cluster information
- `kubectl get` — list resources
- `kubectl describe` — detailed resource info
- `kubectl explain` — documentation for resource types
- `kubectl api-resources` — list all available resource types

## Level 2 — Pods

**Imperative Pod Management:**
- `kubectl run <name> --image=<image>` — create a Pod
- `kubectl logs <pod>` — view container logs
- `kubectl exec -it <pod> -- <command>` — execute commands in a container
- `kubectl port-forward <pod> <local>:<remote>` — access a Pod locally
- `kubectl delete pod <name>` — delete a Pod

**Declarative YAML Manifests:**
- Four required fields: `apiVersion`, `kind`, `metadata`, `spec`
- `kubectl apply -f <file>` — create or update from YAML (idempotent)
- `kubectl delete -f <file>` — delete resources defined in a file
- `--dry-run=client -o yaml` — generate YAML templates

## Level 3 — Deployments

**Creating and Scaling:**
- `kubectl create deployment` — create imperatively
- `kubectl scale deployment <name> --replicas=N` — scale up/down
- Deployments create and manage ReplicaSets, which manage Pods
- Self-healing: Kubernetes replaces failed Pods automatically

**Updates & Rollbacks:**
- `kubectl set image deployment <name> <container>=<image>` — rolling update
- `kubectl rollout status deployment <name>` — monitor update progress
- `kubectl rollout history deployment <name>` — view revision history
- `kubectl rollout undo deployment <name>` — roll back to previous version
- `kubectl rollout undo --to-revision=N` — roll back to a specific version

## Level 4 — Configuration & Organization

**ConfigMaps:**
- Store non-sensitive configuration as key-value pairs
- Create from literals (`--from-literal`), files (`--from-file`), or YAML
- Consume as environment variables (`envFrom` / `configMapRef`)
- Mount as files in a volume (`volumes` / `volumeMounts`)

**Labels & Selectors:**
- Labels are key-value metadata on resources
- Selectors filter by labels: `-l app=web`, `-l "version in (1.0, 2.0)"`
- `kubectl label` — add, modify, or remove labels
- Labels are the binding mechanism between Deployments and their Pods

**Namespaces:**
- Virtual cluster partitions for resource isolation
- `-n <namespace>` targets a specific namespace
- `-A` / `--all-namespaces` shows all namespaces

## kubectl Quick Reference

| Command | Purpose |
|---------|---------|
| `kubectl get <resource>` | List resources |
| `kubectl describe <resource> <name>` | Detailed info |
| `kubectl apply -f <file>` | Create/update from YAML |
| `kubectl delete -f <file>` | Delete from YAML |
| `kubectl logs <pod>` | View logs |
| `kubectl exec -it <pod> -- <cmd>` | Run command in container |
| `kubectl scale deployment <name> --replicas=N` | Scale |
| `kubectl set image deployment <name> <c>=<img>` | Update image |
| `kubectl rollout undo deployment <name>` | Rollback |
| `kubectl get <resource> -l <key>=<value>` | Filter by label |
| `kubectl explain <resource>` | Documentation |

## What's Next?

Now that you understand the fundamentals, here are topics to explore next:

- **Services** — expose and load-balance applications  
- **Ingress** — route external HTTP traffic to services
- **Secrets** — manage sensitive data (like ConfigMaps, but encrypted)
- **Persistent Volumes** — persistent storage for stateful apps
- **StatefulSets** — manage stateful applications (databases, etc.)
- **Helm** — package manager for Kubernetes applications
- **RBAC** — role-based access control for security

## Documentation

- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

Thank you for completing this workshop!
