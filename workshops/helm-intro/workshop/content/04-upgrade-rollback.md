---
title: Upgrades & Rollbacks
---

# Level 4: Upgrades & Rollbacks

This is the chapter that justifies Helm's existence. Plain `kubectl apply` gives
you no memory of what the previous state was. Helm keeps every revision, and
going back is one command.

## Release History

```terminal:execute
command: helm history my-app
```

Every install and upgrade you've run is a numbered **revision**. One is
`deployed`; the rest are `superseded`.

```terminal:execute
command: kubectl get secrets -l owner=helm
```

One Secret per revision — that's where the history physically lives.

> **Docs**: [Helm Rollback](https://helm.sh/docs/helm/helm_rollback/)

## Breaking It on Purpose

Let's ship a bad release, the way it happens in real life — a typo in an image
tag:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --set image.tag=6.99-does-not-exist --wait --timeout 90s
```

The command sits there and eventually fails, because `--wait` won't return until
the Pods are ready — and they never will be.

See the damage:

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

`ImagePullBackOff`. And the release:

```terminal:execute
command: helm history my-app
```

The newest revision is marked `failed`.

> **A failed upgrade still creates a revision.** Helm records the attempt. That's
> deliberate — you need the history to be honest about what was tried.

## Rolling Back

One command, and you're back:

```terminal:execute
command: helm rollback my-app --wait --timeout 5m
```

With no revision number, Helm goes back to the previous one. Confirm:

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

```terminal:execute
command: helm history my-app
```

Note what the history shows: the rollback is itself a **new revision**, described
as "Rollback to N". Helm never rewrites history — it only appends.

Roll back to a specific revision instead:

```terminal:execute
command: helm rollback my-app 1 --wait --timeout 5m
```

```terminal:execute
command: helm get values my-app
```

Revision 1 was the bare install, so the overrides are gone — rolling back
restores the values of that revision too, not just the images.

Return to your configured state:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --wait --timeout 5m
```

## Preventing the Mess: --atomic

Rolling back manually is fine, but leaving a broken release sitting there while
you notice is not. `--atomic` makes an upgrade all-or-nothing:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --set image.tag=6.99-does-not-exist --atomic --timeout 90s
```

Wait for it to fail, then give the rollback a few seconds to finish replacing
Pods:

```terminal:execute
command: kubectl rollout status deployment/my-app-podinfo --timeout=120s
```

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

Healthy Pods — Helm rolled itself back automatically. Compare the two approaches:

| Flag | On failure |
|------|-----------|
| (none) | Broken state stays; you notice later |
| `--wait` | Command fails, broken state stays |
| `--atomic` | Command fails **and** the release rolls back automatically |

`--atomic` implies `--wait`. In CI pipelines it should be your default.

```terminal:execute
command: helm history my-app
```

The failed attempt and its automatic rollback are both recorded.

## Upgrading the Chart Itself

So far you've changed values. You can also move to a different chart version:

```terminal:execute
command: helm search repo podinfo --versions | head -5
```

```terminal:execute
command: helm upgrade my-app podinfo/podinfo --version 6.14.0 -f ~/exercises/podinfo-values.yaml --atomic --timeout 5m
```

```terminal:execute
command: helm list
```

The CHART column now shows the older version. Pinning `--version` in production
is strongly recommended — otherwise a deploy months from now silently picks up
whatever is newest.

Go back to the latest:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --atomic --timeout 5m
```

## Cleaning Up

```terminal:execute
command: helm uninstall my-app
```

```terminal:execute
command: helm list
```

```terminal:execute
command: kubectl get all -l app.kubernetes.io/managed-by=Helm
```

Everything is gone, including the history Secrets.

> **`helm uninstall --keep-history`** retains the release record so you can
> `helm rollback` a deleted release back into existence. Useful, and surprising
> the first time you see it.

## Summary

In this chapter you learned:
- Every install and upgrade creates a numbered revision, stored as a Secret
- Failed upgrades are recorded too — the history stays honest
- `helm rollback` with no number goes back one revision
- A rollback **appends** a new revision rather than deleting anything
- Rolling back restores that revision's **values**, not just its images
- `--atomic` rolls back automatically on failure — the right default for CI
- Pin `--version` in production so deploys stay reproducible

Next: building a chart of your own.
