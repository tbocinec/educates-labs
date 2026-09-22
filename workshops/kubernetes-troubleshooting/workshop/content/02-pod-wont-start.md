---
title: The Pod Never Starts
---

# Level 2: The Pod Never Starts

Symptom: you applied a manifest, and the Pod sits at `0/1` forever. It never
reaches `Running`, and `kubectl logs` returns nothing useful.

Two very different causes produce this, and `describe` tells them apart
immediately.

## Scenario 1: The Image That Doesn't Exist

A colleague hands you this manifest and says "it works on my machine".

```editor:open-file
file: broken/01-image/pod-bad-image.yaml
```

Apply it:

```terminal:execute
command: kubectl apply -f ~/broken/01-image/pod-bad-image.yaml
```

### Observe

```terminal:execute
command: kubectl get pod web-server
```

Give it a few seconds and look again — the status moves from
`ContainerCreating` to `ErrImagePull`, then settles on `ImagePullBackOff`:

```terminal:execute
command: kubectl get pod web-server -w
```

Once the status stops changing, stop the watch:

```terminal:interrupt
```

> **`BackOff` means Kubernetes is retrying with increasing delays.** It is not a
> permanent failure — it will keep trying forever. That's why a typo can quietly
> burn a Pod slot all afternoon.

### Diagnose

Logs first, to prove the point from the last chapter:

```terminal:execute
command: kubectl logs web-server
```

Nothing — there is no container to read logs from. Now do it properly:

```terminal:execute
command: kubectl describe pod web-server | grep -A8 Events:
```

Read the `Failed` event. It names the image and says the manifest is unknown or
not found. The cluster is telling you the image reference is wrong.

Confirm exactly what was requested:

```terminal:execute
command: kubectl get pod web-server -o jsonpath='{.spec.containers[0].image}{"\n"}'
```

### Root Cause

`nginx:1.99-does-not-exist` — there is no such tag. In the real world the same
event appears for four distinct reasons, and the event text distinguishes them:

| Event says | Real cause |
|------------|------------|
| `manifest unknown` / `not found` | Typo in the image name or tag |
| `unauthorized` / `authentication required` | Private registry, missing `imagePullSecrets` |
| `no such host` / `timeout` | Registry unreachable from the node |
| `toomanyrequests` | Registry rate limit (common with Docker Hub) |

### Fix and Verify

Fix the tag in the editor — change `1.99-does-not-exist` to `1.27`:

```editor:select-matching-text
file: broken/01-image/pod-bad-image.yaml
text: "image: nginx:1.99-does-not-exist"
```

A Pod's image **cannot be patched in place**, so delete and re-apply:

```terminal:execute
command: kubectl delete pod web-server --ignore-not-found
```

```terminal:execute
command: kubectl run web-server --image=nginx:1.27
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/web-server --timeout=90s
```

```terminal:execute
command: kubectl get pod web-server
```

`1/1 Running`. Clean up:

```terminal:execute
command: kubectl delete pod web-server
```

## Scenario 2: The ConfigMap Key That Isn't There

Same symptom, completely different cause. This app reads its mode from a
ConfigMap.

```editor:open-file
file: broken/02-config/configmap.yaml
```

```editor:open-file
file: broken/02-config/pod-bad-key.yaml
```

Apply both:

```terminal:execute
command: kubectl apply -f ~/broken/02-config/
```

### Observe

```terminal:execute
command: kubectl get pod config-app
```

`CreateContainerConfigError`. The image pulled fine — Kubernetes got all the way
to building the container's configuration and then gave up.

### Diagnose

```terminal:execute
command: kubectl describe pod config-app | grep -A8 Events:
```

The event is refreshingly specific: `couldn't find key mode in ConfigMap`.

Now check what the ConfigMap actually contains:

```terminal:execute
command: kubectl get configmap app-settings -o jsonpath='{.data}{"\n"}'
```

And what the Pod asked for:

```terminal:execute
command: kubectl get pod config-app -o jsonpath='{.spec.containers[0].env[0].valueFrom.configMapKeyRef}{"\n"}'
```

### Root Cause

The ConfigMap defines `app_mode`. The Pod asks for `mode`. Kubernetes does not
guess.

> **Why is this a *config* error and not a missing-file error?** Because the
> reference is resolved by the kubelet *before* the container starts. The same
> status appears for a missing Secret, a missing ConfigMap entirely, or a
> `secretKeyRef` pointing at the wrong key.

### Fix and Verify

Change the key in the Pod manifest from `mode` to `app_mode`:

```editor:select-matching-text
file: broken/02-config/pod-bad-key.yaml
text: "key: mode"
```

Replace `mode` with `app_mode`, save, then re-create the Pod:

```terminal:execute
command: kubectl delete pod config-app --ignore-not-found && kubectl apply -f ~/broken/02-config/pod-bad-key.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/config-app --timeout=90s
```

Prove the environment variable arrived:

```terminal:execute
command: kubectl exec config-app -- printenv APP_MODE
```

`production`. Clean up:

```terminal:execute
command: kubectl delete -f ~/broken/02-config/ --ignore-not-found
```

## Summary

In this chapter you learned:
- `ImagePullBackOff` — the image reference is wrong, private, or unreachable; the event text says which
- `CreateContainerConfigError` — a ConfigMap or Secret reference cannot be resolved
- Neither Pod ever produced logs, because no container ever ran
- `describe` → Events named the exact cause both times
- A Pod's image and env cannot be patched in place — delete and re-create

Next: Pods that *do* start, and then die anyway.
