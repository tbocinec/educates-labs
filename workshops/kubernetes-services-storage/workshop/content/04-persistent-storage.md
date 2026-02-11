---
title: Persistent Storage
---

# Level 3: Persistent Storage

By default, all data inside a Pod is **ephemeral** — it disappears when the Pod is deleted or restarted. For databases, logs, or any stateful application, you need **persistent storage**.

> **Docs**: [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

## Storage Concepts

Kubernetes storage has three key objects:

| Object | What It Does | Who Creates It |
|--------|-------------|----------------|
| **PersistentVolume (PV)** | Represents a piece of storage in the cluster | Cluster admin or dynamic provisioner |
| **PersistentVolumeClaim (PVC)** | A request for storage by a user | You (the developer) |
| **StorageClass** | Defines how storage is dynamically provisioned | Cluster admin |

The typical workflow:
1. You create a **PVC** requesting specific storage (e.g., "I need 100Mi of storage")
2. Kubernetes **dynamically provisions** a PV that matches your request
3. You **mount** the PVC in your Pod
4. The storage persists even if the Pod is deleted

```
You → PVC ("I need 100Mi") → StorageClass → PV (actual storage)
                                               ↓
                                          Pod (mounted at /data)
```

## Checking Available Storage Classes

Let's first see what StorageClasses are available:

```terminal:execute
command: kubectl get storageclasses
```

The `(default)` marker indicates which StorageClass is used when you don't specify one.

## Creating a PersistentVolumeClaim

Open the PVC exercise file:

```editor:open-file
file: exercises/storage/pvc.yaml
```

Key fields:
- `accessModes: [ReadWriteOnce]` — the volume can be mounted as read-write by a **single** node
- `resources.requests.storage: 100Mi` — requesting 100 MiB of storage

Common access modes:

| Mode | Short | Description |
|------|-------|-------------|
| `ReadWriteOnce` | RWO | Read-write by a single node |
| `ReadOnlyMany` | ROX | Read-only by many nodes |
| `ReadWriteMany` | RWX | Read-write by many nodes |

Create the PVC:

```terminal:execute
command: cp -r ~/exercises/storage ~/storage && kubectl apply -f ~/storage/pvc.yaml
```

Check the PVC status:

```terminal:execute
command: kubectl get pvc my-data
```

The status should be `Bound` — meaning storage has been allocated. You can also see the PV that was created:

```terminal:execute
command: kubectl get pv
```

## Using a PVC in a Pod

Now let's create a Pod that uses this storage. Open the exercise file:

```editor:open-file
file: exercises/storage/pod-with-pvc.yaml
```

Key configuration:

```editor:select-matching-text
file: exercises/storage/pod-with-pvc.yaml
text: claimName
```

- `volumes` — references the PVC by name (`my-data`)
- `volumeMounts` — mounts the volume at `/data` inside the container
- The container writes the current date to `/data/log.txt` every 5 seconds

Apply the Pod:

```terminal:execute
command: kubectl apply -f ~/storage/pod-with-pvc.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/writer-pod --timeout=60s
```

Wait a moment for some data to be written, then check the file:

```terminal:execute
command: sleep 10 && kubectl exec writer-pod -- cat /data/log.txt
```

The Pod is writing data to the persistent volume.

## Proving Data Persistence

Now let's prove that the data survives even after the Pod is deleted.

**Step 1**: Note how much data we have:

```terminal:execute
command: kubectl exec writer-pod -- wc -l /data/log.txt
```

**Step 2**: Delete the writer Pod:

```terminal:execute
command: kubectl delete pod writer-pod
```

**Step 3**: Verify the Pod is gone:

```terminal:execute
command: kubectl get pods
```

**Step 4**: Create a new Pod that reads the same PVC:

```editor:open-file
file: exercises/storage/pod-with-pvc-reader.yaml
```

```terminal:execute
command: kubectl apply -f ~/storage/pod-with-pvc-reader.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/reader-pod --timeout=60s
```

**Step 5**: Read the data — it's still there!

```terminal:execute
command: kubectl exec reader-pod -- cat /data/log.txt
```

The data persisted across Pod deletion! This is the power of persistent storage — the lifecycle of the data is **decoupled** from the lifecycle of the Pod.

## Inspecting PVC and PV Details

Describe the PVC to see detailed information:

```terminal:execute
command: kubectl describe pvc my-data
```

Key details:
- **Status**: `Bound` — storage is allocated
- **Volume**: the name of the PV
- **Capacity**: how much storage was actually allocated
- **Access Modes**: RWO
- **Used By**: lists the Pod(s) currently using this PVC

## Reclaim Policies

When a PVC is deleted, what happens to the underlying data? That depends on the **reclaim policy**:

| Policy | What Happens | Typical Use |
|--------|-------------|-------------|
| **Delete** | PV and data are deleted | Dynamic provisioning (default) |
| **Retain** | PV is kept, data preserved | Manual data recovery |

Check the policy on your PV:

```terminal:execute
command: kubectl get pv -o custom-columns='NAME:.metadata.name,RECLAIM-POLICY:.spec.persistentVolumeReclaimPolicy,STATUS:.status.phase'
```

## Cleanup

```terminal:execute
command: kubectl delete -f ~/storage/ 2>/dev/null; echo "Cleanup done"
```

Delete the PVC:

```terminal:execute
command: kubectl delete pvc my-data 2>/dev/null; echo "PVC deleted"
```

## Level 3 Summary

In this chapter you learned:
- Pod storage is **ephemeral** by default — data is lost when the Pod is deleted
- **PersistentVolumeClaims (PVC)** request storage from the cluster
- **PersistentVolumes (PV)** are the actual storage resources
- PVCs are **mounted** in Pods via `volumes` and `volumeMounts`
- Data in a PVC survives **Pod deletion** — new Pods can access the same data
- **StorageClasses** enable dynamic provisioning of PVs
- **Reclaim policies** control what happens to data when PVCs are deleted

| Command | Purpose |
|---------|---------|
| `kubectl get pvc` | List PersistentVolumeClaims |
| `kubectl get pv` | List PersistentVolumes |
| `kubectl describe pvc <name>` | Show PVC details (capacity, status, used by) |
| `kubectl get storageclasses` | List available StorageClasses |

Next, let's learn about **Liveness and Readiness Probes** — how Kubernetes monitors your application's health!
