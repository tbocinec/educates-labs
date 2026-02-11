---
title: Services
---

# Services

A **Service** is a Kubernetes abstraction that provides a **stable network endpoint** for a set of Pods. It solves the ephemeral Pod IP problem from the previous chapter.

> **Docs**: [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

## How Services Work

A Service works by:
1. **Selecting Pods** by label — the Service finds all Pods matching its `selector`
2. **Providing a stable IP** — the Service gets its own ClusterIP that never changes
3. **Load-balancing traffic** — requests to the Service are distributed across all matching Pods
4. **Creating a DNS name** — the Service is automatically registered in cluster DNS

```
Client → Service (stable IP + DNS) → load-balance → Pod 1
                                                   → Pod 2
                                                   → Pod 3
```

## Service Types

Kubernetes supports several Service types:

| Type | Description | Accessible From |
|------|-------------|-----------------|
| **ClusterIP** | Default. Stable internal IP. | Inside the cluster only |
| **NodePort** | Exposes on each node's IP at a static port. | Outside the cluster |
| **LoadBalancer** | Provisions an external load balancer (cloud). | Outside the cluster |
| **ExternalName** | Maps to a DNS name (no proxy). | Inside the cluster |

In this workshop we'll focus on **ClusterIP** — the most common type and the foundation for all others.

## Creating a Service Imperatively

The quickest way to create a Service is with `kubectl expose`:

```terminal:execute
command: kubectl expose deployment backend --name=backend-quick --port=5678 --target-port=5678
```

Check the Service:

```terminal:execute
command: kubectl get services
```

Notice:
- **CLUSTER-IP** — a stable internal IP address
- **PORT(S)** — the port the Service listens on

Test it from the client Pod:

```terminal:execute
command: kubectl exec client -- wget -qO- http://backend-quick:5678
```

It works! The Service resolves via cluster DNS and routes to one of the backend Pods.

Clean up the imperative Service:

```terminal:execute
command: kubectl delete service backend-quick
```

## Creating a Service from YAML

Let's create a Service using a YAML manifest. Open the exercise file:

```editor:open-file
file: exercises/services/backend-service.yaml
```

Key fields to notice:

```editor:select-matching-text
file: exercises/services/backend-service.yaml
text: type: ClusterIP
```

- `type: ClusterIP` — only accessible within the cluster
- `selector.app: backend` — selects Pods with label `app=backend`
- `port: 5678` — the port the Service listens on
- `targetPort: 5678` — the port on the target Pods

Apply the Service:

```terminal:execute
command: kubectl apply -f ~/services/backend-service.yaml
```

## Viewing Service Details

Describe the Service to see its configuration and endpoints:

```terminal:execute
command: kubectl describe service backend-svc
```

Look at the **Endpoints** line — it shows the IPs of all Pods that match the selector. These are the actual Pod IPs that traffic is routed to.

You can also view endpoints directly:

```terminal:execute
command: kubectl get endpoints backend-svc
```

## Testing Service Discovery via DNS

From the client Pod, test access using the Service name:

```terminal:execute
command: kubectl exec client -- wget -qO- http://backend-svc:5678
```

The Service name works because Kubernetes DNS resolves `backend-svc` to the Service's ClusterIP.

### DNS Formats

Services can be reached using several DNS formats:

| Format | Example |
|--------|---------|
| `<service>` | `backend-svc` (same namespace) |
| `<service>.<namespace>` | `backend-svc.{{ session_namespace }}` |
| `<service>.<namespace>.svc.cluster.local` | `backend-svc.{{ session_namespace }}.svc.cluster.local` |

Test the fully qualified domain name:

```terminal:execute
command: kubectl exec client -- wget -qO- http://backend-svc.{{ session_namespace }}.svc.cluster.local:5678
```

## Load Balancing in Action

Run multiple requests and notice the responses come from different Pod replicas:

```terminal:execute
command: for i in 1 2 3 4 5 6; do kubectl exec client -- wget -qO- http://backend-svc:5678; done
```

The Service distributes requests across all backend Pods — this is automatic **round-robin load balancing**.

## Services and Labels — the Connection

Services find their Pods via **label selectors**. Let's verify this connection:

```terminal:execute
command: echo "--- Service selector ---" && kubectl get service backend-svc -o jsonpath='{.spec.selector}' && echo && echo "--- Pod labels ---" && kubectl get pods -l app=backend --show-labels
```

The Service's selector (`app=backend`) matches the labels on the backend Pods. If a Pod doesn't have the matching label, the Service won't route traffic to it.

## Removing a Pod from a Service

You can remove a Pod from a Service without deleting it — just change its label:

```terminal:execute
command: POD=$(kubectl get pods -l app=backend -o name | head -1) && kubectl label $POD app=backend-debug --overwrite && echo "Relabeled $POD"
```

Check the endpoints:

```terminal:execute
command: kubectl get endpoints backend-svc
```

One less endpoint! The relabeled Pod still runs but is no longer part of the Service. This is useful for debugging a specific Pod in isolation.

Restore the label:

```terminal:execute
command: POD=$(kubectl get pods -l app=backend-debug -o name | head -1) && kubectl label $POD app=backend --overwrite && echo "Restored $POD"
```

## Cleanup

Let's clean up all resources from Level 1:

```terminal:execute
command: kubectl delete -f ~/services/
```

Verify everything is cleaned up:

```terminal:execute
command: kubectl get pods,services
```

## Level 1 Summary

In this chapter you learned:
- **Services** provide a stable IP and DNS name for a dynamic set of Pods
- **ClusterIP** is the default Service type — accessible within the cluster
- Services use **label selectors** to find their target Pods
- Kubernetes **DNS** automatically resolves Service names (e.g., `backend-svc` → ClusterIP)
- Services **load-balance** traffic across all matching Pods
- You can remove a Pod from a Service by changing its labels (useful for debugging)

| Command | Purpose |
|---------|---------|
| `kubectl expose deployment <name>` | Create a Service imperatively |
| `kubectl get services` | List Services |
| `kubectl describe service <name>` | Show Service details and endpoints |
| `kubectl get endpoints <name>` | Show the Pod IPs behind a Service |

Next, let's learn about **Secrets** — the secure way to manage sensitive data in Kubernetes!
