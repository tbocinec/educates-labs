---
title: Secrets
---

# Level 2: Secrets

In the previous workshop you learned about **ConfigMaps** for non-sensitive configuration. But what about passwords, API keys, or TLS certificates? That's where **Secrets** come in.

> **Docs**: [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

## What Are Secrets?

A **Secret** is a Kubernetes object that stores sensitive data such as:
- Database passwords
- API tokens
- SSH keys
- TLS certificates

Secrets are similar to ConfigMaps but with important differences:

| Feature | ConfigMap | Secret |
|---------|-----------|--------|
| Purpose | Non-sensitive configuration | Sensitive data |
| Data storage | Plain text | Base64-encoded |
| Memory-backed | No | Optionally (`tmpfs`) |
| Size limit | 1 MiB | 1 MiB |

> **Important**: Kubernetes Secrets are base64-encoded, **not encrypted** by default. For production, consider enabling [encryption at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).

## Creating a Secret Imperatively

The quickest way to create a Secret:

```terminal:execute
command: kubectl create secret generic my-quick-secret --from-literal=username=admin --from-literal=password=s3cretP@ss
```

View the Secret:

```terminal:execute
command: kubectl get secret my-quick-secret -o yaml
```

Notice that the values are **base64-encoded**. You can decode them:

```terminal:execute
command: kubectl get secret my-quick-secret -o jsonpath='{.data.password}' | base64 -d && echo
```

Clean up:

```terminal:execute
command: kubectl delete secret my-quick-secret
```

## Creating a Secret from YAML

Let's create a Secret using a YAML manifest with `stringData` (which accepts plain text):

```editor:open-file
file: exercises/secrets/secret.yaml
```

```terminal:execute
command: cp -r ~/exercises/secrets ~/secrets && kubectl apply -f ~/secrets/secret.yaml
```

Notice the `stringData` field — it lets you write values in plain text. Kubernetes encodes them to base64 automatically.

Verify the Secret:

```terminal:execute
command: kubectl describe secret db-credentials
```

The `describe` output shows the keys and the size of values, but **not the values themselves** — this is a safety feature.

## Consuming Secrets as Environment Variables

The most common way to use Secrets is as environment variables. Open the exercise file:

```editor:open-file
file: exercises/secrets/pod-secret-env.yaml
```

Key configuration:

```editor:select-matching-text
file: exercises/secrets/pod-secret-env.yaml
text: envFrom
```

`envFrom` with `secretRef` injects **all** keys from the Secret as environment variables.

Apply and test:

```terminal:execute
command: kubectl apply -f ~/secrets/pod-secret-env.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/secret-env-pod --timeout=60s
```

```terminal:execute
command: kubectl exec secret-env-pod -- env | grep -E 'DB_USERNAME|DB_PASSWORD|DB_HOST'
```

The Secret values are available as environment variables inside the Pod.

## Consuming Secrets as Files (Volume Mount)

Sometimes you need Secret data as files — for example TLS certificates or config files. Open the exercise file:

```editor:open-file
file: exercises/secrets/pod-secret-volume.yaml
```

Key configuration — the Secret is mounted as a volume:

```editor:select-matching-text
file: exercises/secrets/pod-secret-volume.yaml
text: mountPath
```

Apply and test:

```terminal:execute
command: kubectl apply -f ~/secrets/pod-secret-volume.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/secret-volume-pod --timeout=60s
```

List the files in the mount:

```terminal:execute
command: kubectl exec secret-volume-pod -- ls /etc/secrets
```

Each key in the Secret becomes a **file**, and the file content is the **value**:

```terminal:execute
command: kubectl exec secret-volume-pod -- cat /etc/secrets/DB_USERNAME && echo
```

```terminal:execute
command: kubectl exec secret-volume-pod -- cat /etc/secrets/DB_PASSWORD && echo
```

## Env Vars vs Volume Mount — When to Choose Which?

| Approach | Best For | Limitation |
|----------|----------|------------|
| **Environment variables** | Simple key-value config (passwords, API keys) | Not auto-updated when Secret changes |
| **Volume mount** | Files (TLS certs, config files) | App needs to watch for file changes |

> **Tip**: Volume-mounted Secrets are automatically updated when the Secret changes (with a small delay). Environment variables are **not** — the Pod must be restarted.

## Updating a Secret

Let's update the Secret and see how it affects volume mounts:

```terminal:execute
command: kubectl patch secret db-credentials -p '{"stringData":{"DB_PASSWORD":"newP@ssw0rd!"}}'
```

Wait a moment for the update to propagate (up to ~60 seconds), then check the volume:

```terminal:execute
command: sleep 10 && kubectl exec secret-volume-pod -- cat /etc/secrets/DB_PASSWORD && echo
```

The file content is updated! But the environment variable in the other Pod is still the old value:

```terminal:execute
command: kubectl exec secret-env-pod -- printenv DB_PASSWORD
```

This demonstrates the key difference between volume-mounted and env-var-based Secrets.

## Cleanup

```terminal:execute
command: kubectl delete -f ~/secrets/ 2>/dev/null; echo "Cleanup done"
```

## Level 2 Summary

In this chapter you learned:
- **Secrets** store sensitive data like passwords, tokens, and certificates
- Values are **base64-encoded** (not encrypted!) in etcd
- Secrets can be created **imperatively** (`kubectl create secret`) or from **YAML** (`stringData`)
- Secrets can be consumed as **environment variables** (`envFrom`) or **volume mounts**
- **Volume-mounted** Secrets are auto-updated; **env-var** Secrets are NOT
- `kubectl describe secret` hides values for safety

| Command | Purpose |
|---------|---------|
| `kubectl create secret generic <name> --from-literal=key=val` | Create a Secret imperatively |
| `kubectl get secret <name> -o yaml` | View a Secret (base64-encoded) |
| `kubectl get secret <name> -o jsonpath='{.data.key}' \| base64 -d` | Decode a Secret value |
| `kubectl describe secret <name>` | Show Secret metadata (values hidden) |

Next, let's look at **Persistent Storage** — how to keep data alive even when Pods are deleted!
