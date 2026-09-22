---
title: Your First Release
---

# Level 2: Your First Release

Time to install something. The command is short; what it does behind the scenes
is worth watching closely.

## Dry Run First

Before changing anything, ask Helm what it *would* do:

```terminal:execute
command: helm install my-app podinfo/podinfo --dry-run=client | head -40
```

Nothing was created. Helm rendered every template with the default values and
printed the result. This is the single most useful habit in this workshop —
dry-run before any install or upgrade you're unsure about.

There are two modes, and the difference matters:

| Mode | What it does |
|------|--------------|
| `--dry-run=client` | Renders locally. Fast, no cluster validation. |
| `--dry-run=server` | Sends the manifests to the API server for validation without persisting them — catches schema errors and admission rejections. |

> **Helm 4 deprecated the bare `--dry-run`.** It still works but warns. Write the
> mode explicitly: `--dry-run=client` for a quick look, `--dry-run=server` when
> you want the cluster's opinion too.

Ask the cluster to validate the manifests without creating anything:

```terminal:execute
command: helm install my-app podinfo/podinfo --dry-run=server | head -20
```

On this cluster that also proves your namespace's LimitRange and quota would
accept the result — worth doing before a real install.

## Installing

```terminal:execute
command: helm install my-app podinfo/podinfo --wait --timeout 5m
```

The output has four parts worth reading: the release name, the status, the
revision number (`1`), and the chart's `NOTES.txt` telling you how to reach the
app.

`--wait` makes Helm block until the resources are actually ready, rather than
returning the moment the API server accepts them.

## What Exists Now?

List your releases:

```terminal:execute
command: helm list
```

One release, revision 1, status `deployed`.

Now look at it from Kubernetes' side:

```terminal:execute
command: kubectl get deploy,svc,pods -l app.kubernetes.io/managed-by=Helm
```

> **Filter by `managed-by=Helm`, not by chart name.** Helm prefixes object names
> with the release name — your Deployment is `my-app-podinfo`, not `podinfo`.
> The `managed-by` label is stable regardless of what you called the release.

Helm stamps every object it creates:

```terminal:execute
command: kubectl get deployment my-app-podinfo -o jsonpath='{.metadata.labels}{"\n"}'
```

Those labels are how Helm knows what belongs to which release.

## Inspecting a Release

Four commands, four different questions:

```terminal:execute
command: helm status my-app
```

*Is it healthy, and what did the notes say?*

```terminal:execute
command: helm get values my-app
```

*What did I override?* — empty, because we took all defaults.

```terminal:execute
command: helm get values my-app --all | head -20
```

*What values were actually used, including defaults?*

```terminal:execute
command: helm get manifest my-app | head -30
```

*What YAML was actually applied to the cluster?* This is the one to reach for
when the cluster doesn't look the way you expected.

## Where the State Lives

Remember the empty secret list from the last chapter:

```terminal:execute
command: kubectl get secrets
```

There's now a secret named `sh.helm.release.v1.my-app.v1`. That is the release —
the rendered manifests and metadata, gzipped and base64-encoded.

```terminal:execute
command: kubectl get secret -l owner=helm -o custom-columns=NAME:.metadata.name,TYPE:.type
```

Two consequences worth understanding:

- **Delete that Secret and Helm forgets the release**, even though the Deployment keeps running happily.
- **Release state is namespaced.** `helm list` in another namespace shows nothing. There is no global view.

## Reaching the Application

Podinfo serves HTTP on port 9898. Check it from inside the cluster:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 10 http://my-app-podinfo:9898/version
```

The app answers with its version — the same APP VERSION Helm reported.

## Installing the Same Chart Twice

To prove that releases are independent:

```terminal:execute
command: helm install my-second-app podinfo/podinfo --wait --timeout 5m
```

```terminal:execute
command: helm list
```

```terminal:execute
command: kubectl get deploy -l app.kubernetes.io/managed-by=Helm
```

Two releases, two Deployments, no collision — because every object name is
prefixed with its release name. Remove the second one:

```terminal:execute
command: helm uninstall my-second-app
```

```terminal:execute
command: helm list
```

`helm uninstall` removes every object the release created. No hunting for
leftovers.

## Summary

In this chapter you learned:
- `--dry-run=client` renders locally; `--dry-run=server` also validates against the cluster
- `--wait` blocks until resources are genuinely ready
- Helm prefixes object names with the release name and labels them `managed-by=Helm`
- `helm get manifest` shows exactly what was applied — the debugging command
- Release state lives in a Secret named `sh.helm.release.v1.<name>.v<revision>`
- Releases are namespaced and independent; the same chart installs many times

Next: making the chart do what *you* want.
