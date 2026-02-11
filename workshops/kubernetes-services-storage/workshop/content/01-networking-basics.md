---
title: Pod Networking & DNS
---

# Level 1: Pod Networking & DNS

Before working with Services, let's understand how networking works inside a Kubernetes cluster.

## The Kubernetes Networking Model

Kubernetes has a simple but powerful networking model. Three fundamental rules:

1. **Every Pod gets its own IP address** — Pods don't share IPs like containers might on a single host
2. **All Pods can communicate with each other** — without NAT, regardless of which node they're on
3. **Agents on a node can communicate with all Pods on that node** — the kubelet and kube-proxy can reach any Pod

This means that at the network level, Pods behave like VMs on a flat network — every Pod can reach every other Pod by IP.

## Creating Test Pods

Let's deploy some Pods and see this in action. First, create a Deployment with 3 backend Pods:

```terminal:execute
command: cp -r ~/exercises/services ~/services
```

Open the Deployment manifest:

```editor:open-file
file: exercises/services/backend-deployment.yaml
```

```terminal:execute
command: kubectl apply -f ~/services/backend-deployment.yaml
```

Wait for all Pods to be ready:

```terminal:execute
command: kubectl get pods -l app=backend -o wide
```

Notice the `IP` column — each Pod has a unique cluster IP address.

## Pod-to-Pod Communication

Create a client Pod to test connectivity:

```editor:open-file
file: exercises/services/client-pod.yaml
```

```terminal:execute
command: kubectl apply -f ~/services/client-pod.yaml
```

Wait for it to be ready:

```terminal:execute
command: kubectl wait --for=condition=Ready pod/client --timeout=60s
```

Now exec into the client Pod and try to reach a backend Pod **directly by IP**. First get a backend Pod IP:

```terminal:execute
command: BACKEND_IP=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].status.podIP}') && echo "Backend Pod IP: $BACKEND_IP"
```

Test connectivity from the client Pod:

```terminal:execute
command: BACKEND_IP=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].status.podIP}') && kubectl exec client -- wget -qO- http://$BACKEND_IP:5678
```

It works! Pods can reach each other by IP address directly.

## The Problem with Pod IPs

But there's a problem. Pod IPs are **ephemeral** — they change every time a Pod is recreated.

Let's demonstrate. Delete one of the backend Pods:

```terminal:execute
command: POD=$(kubectl get pods -l app=backend -o name | head -1) && kubectl delete $POD
```

Because this is a Deployment, a replacement Pod is created automatically. Check the IPs again:

```terminal:execute
command: kubectl get pods -l app=backend -o wide
```

The new Pod has a **different IP address**! If your client was connecting to the old IP, it would now fail.

This is the core problem that **Services** solve — they provide a **stable endpoint** in front of a dynamic set of Pods.

## Cluster DNS

Kubernetes runs a DNS server inside the cluster (usually CoreDNS). It automatically creates DNS records for Kubernetes resources.

Let's see how DNS resolution works from inside a Pod:

```terminal:execute
command: kubectl exec client -- cat /etc/resolv.conf
```

Notice the `nameserver` line pointing to the cluster DNS service, and the `search` domains. These search domains let you use short names (like `backend-svc`) instead of the full name (`backend-svc.{{ session_namespace }}.svc.cluster.local`).

> **Docs**: [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)

## Level 1A Summary

In this chapter you learned:
- Every Pod gets a unique IP address within the cluster
- Pods can communicate with each other directly by IP
- Pod IPs are **ephemeral** — they change when Pods are recreated
- Kubernetes has built-in **cluster DNS** for name resolution
- **Services** solve the ephemeral IP problem (covered next!)

Next, let's create a Service that provides a stable endpoint for our backend Pods.
