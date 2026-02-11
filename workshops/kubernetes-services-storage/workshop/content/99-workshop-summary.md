---
title: Workshop Summary
---

# Workshop Summary

Congratulations! You've completed the **Kubernetes Services, Secrets & Storage** workshop! 🎉

Here's a recap of everything you learned across the four levels.

---

## Level 1: Networking & Services

You learned how Pods communicate and how **Services** provide stable endpoints.

**Key concepts:**
- Every Pod gets its own IP, but Pod IPs are **ephemeral**
- **Services** provide a **stable IP and DNS name** for a set of Pods
- **ClusterIP** is the default Service type (internal only)
- Services use **label selectors** to find target Pods
- Cluster **DNS** resolves Service names automatically
- Services **load-balance** traffic across matching Pods

**Key commands:**
```
kubectl expose deployment <name> --port=<port>    # Create Service
kubectl get services                               # List Services
kubectl get endpoints <name>                       # Show Pod IPs behind Service
kubectl describe service <name>                    # Service details
```

---

## Level 2: Secrets

You learned how to manage **sensitive data** securely in Kubernetes.

**Key concepts:**
- **Secrets** store passwords, tokens, certificates (base64-encoded)
- Create with `kubectl create secret` or YAML (`stringData` for plain text)
- Consume as **environment variables** (`envFrom`) or **volume mounts**
- Volume-mounted Secrets **auto-update**; env-var Secrets do **NOT**

**Key commands:**
```
kubectl create secret generic <name> --from-literal=key=val
kubectl get secret <name> -o jsonpath='{.data.key}' | base64 -d
kubectl describe secret <name>
```

---

## Level 3: Persistent Storage

You learned how to **persist data** beyond the Pod lifecycle.

**Key concepts:**
- Pod storage is ephemeral by default
- **PersistentVolumeClaim (PVC)** requests storage from the cluster
- **PersistentVolume (PV)** is the actual storage resource
- Data in a PVC survives **Pod deletion**
- **StorageClasses** enable dynamic provisioning
- **Reclaim policies** control data fate on PVC deletion

**Key commands:**
```
kubectl get pvc                    # List PVCs
kubectl get pv                     # List PVs
kubectl describe pvc <name>        # PVC details
kubectl get storageclasses         # Available storage classes
```

---

## Level 4: Probes, Jobs & CronJobs

You learned Kubernetes **self-healing** and **batch processing** capabilities.

**Probes:**
- **Liveness probe** → restart container if unhealthy
- **Readiness probe** → stop routing traffic if not ready
- Methods: HTTP GET, TCP Socket, Exec (command)

**Jobs & CronJobs:**
- **Jobs** run to completion (batch tasks, data processing)
- `completions` + `parallelism` for parallel execution
- **CronJobs** create Jobs on a schedule (cron syntax)

**Key commands:**
```
kubectl get jobs                               # List Jobs
kubectl logs job/<name>                        # Job output
kubectl get cronjobs                           # List CronJobs
kubectl create job <name> --image=<img> -- cmd # Quick Job
```

---

## Complete kubectl Cheat Sheet

### Resources covered in this workshop

| Resource | List | Details | Create | Delete |
|----------|------|---------|--------|--------|
| Service | `kubectl get svc` | `kubectl describe svc <name>` | `kubectl expose` | `kubectl delete svc <name>` |
| Secret | `kubectl get secret` | `kubectl describe secret <name>` | `kubectl create secret` | `kubectl delete secret <name>` |
| PVC | `kubectl get pvc` | `kubectl describe pvc <name>` | `kubectl apply -f` | `kubectl delete pvc <name>` |
| Job | `kubectl get jobs` | `kubectl describe job <name>` | `kubectl create job` | `kubectl delete job <name>` |
| CronJob | `kubectl get cronjob` | `kubectl describe cronjob <name>` | `kubectl apply -f` | `kubectl delete cronjob <name>` |

### Common patterns

```
kubectl get <resource> -o wide          # More columns
kubectl get <resource> -o yaml          # Full YAML output
kubectl get <resource> -w               # Watch for changes
kubectl describe <resource> <name>      # Detailed info + events
kubectl logs <pod>                      # Container logs
kubectl exec <pod> -- <command>         # Run command in Pod
kubectl apply -f <file>                 # Create/update from YAML
kubectl delete -f <file>               # Delete resources from YAML
```

---

## Official Kubernetes Documentation

Bookmark these for reference:

- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

## What's Next?

With two workshops completed, you now have a solid Kubernetes foundation. Here are some topics to explore next:

- **Ingress** — expose HTTP/HTTPS routes to Services
- **NetworkPolicies** — control Pod-to-Pod traffic
- **RBAC** — role-based access control
- **Helm** — package manager for Kubernetes
- **StatefulSets** — for stateful applications (databases)
- **Operators** — automate complex application management

Thank you for completing this workshop! 🚀
