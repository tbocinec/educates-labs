---
title: Kubernetes Architecture
---

# Level 1: Kubernetes Architecture

Before working with Kubernetes hands-on, let's understand what it is and how it's structured.

## What is Kubernetes?

**Kubernetes** (often abbreviated as **K8s**) is an open-source container orchestration platform. It automates the deployment, scaling, and management of containerized applications.

Key capabilities:
- **Self-healing** — restarts failed containers, replaces and reschedules them
- **Scaling** — scale applications up or down based on demand
- **Rolling updates** — update applications with zero downtime
- **Service discovery** — automatic DNS and load balancing for services
- **Configuration management** — manage application configuration separately from code

> **Docs**: [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)

## Cluster Architecture

A Kubernetes cluster consists of two main components:

### Control Plane (Master)

The control plane manages the overall cluster. Its key components are:

| Component | Role |
|-----------|------|
| **API Server** | Front-end for Kubernetes. All `kubectl` commands talk to this. |
| **etcd** | Key-value store that holds all cluster data and state. |
| **Scheduler** | Decides which node should run a new Pod. |
| **Controller Manager** | Runs controllers that handle routine tasks (e.g., ensuring desired replica count). |

### Worker Nodes

Worker nodes run your actual application workloads:

| Component | Role |
|-----------|------|
| **kubelet** | Agent on each node. Ensures containers are running in Pods. |
| **kube-proxy** | Handles networking — routes traffic to the correct Pods. |
| **Container Runtime** | Runs the actual containers (e.g., containerd, CRI-O). |

## Core Concepts

Here are the fundamental Kubernetes objects you will work with in this workshop:

| Object | Purpose |
|--------|---------|
| **Pod** | Smallest deployable unit. Wraps one or more containers. |
| **Deployment** | Manages a set of identical Pods. Handles scaling, updates, rollbacks. |
| **ConfigMap** | Stores non-sensitive configuration data (key-value pairs). |
| **Namespace** | Virtual cluster partition for resource isolation. |
| **Label** | Key-value metadata attached to objects for organization and selection. |

## The Declarative Model

Kubernetes uses a **declarative** approach: you describe the **desired state** (e.g., "I want 3 replicas of nginx") and Kubernetes continuously works to make the **actual state** match.

```
You declare:  "I want 3 nginx Pods"
    ↓
Kubernetes:   Creates and maintains exactly 3 Pods
    ↓
A Pod dies:   Kubernetes automatically creates a replacement
```

This is fundamentally different from imperative commands like "start this container on this server."

## Quick Cluster Check

Let's verify your cluster is working. Check the cluster information:

```terminal:execute
command: kubectl cluster-info
```

And verify the node(s) in the cluster:

```terminal:execute
command: kubectl get nodes
```

You should see your cluster components running and at least one node in `Ready` status.

In the next chapter, you'll learn the essential `kubectl` commands for interacting with this cluster.
