---
title: Configuring with Values
---

# Level 3: Configuring with Values

A chart with no configuration would be useless. **Values** are how you adapt one
chart to dev, staging and production without copying a single file.

## The Precedence Chain

When Helm renders a template, a value can come from several places. Later wins:

```
chart's values.yaml   (defaults, lowest priority)
      ↓
-f my-values.yaml     (your file)
      ↓
-f more-values.yaml   (later files override earlier ones)
      ↓
--set key=value       (highest priority)
```

Knowing this order is what stops "but I set that!" arguments with yourself.

> **Docs**: [Values Files](https://helm.sh/docs/chart_template_guide/values_files/)

## Overriding with --set

The quickest way, good for one or two values:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo --set replicaCount=3 --wait --timeout 5m
```

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

Three replicas now. Check what Helm considers overridden:

```terminal:execute
command: helm get values my-app
```

Only `replicaCount` — your overrides, not the whole value set.

`--set` handles nested keys with dots, and lists with braces:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo --set replicaCount=3 --set resources.limits.memory=256Mi --dry-run=client | grep -A4 "limits:"
```

> **`--set` gets ugly fast.** Anything with dots in the key, commas in the value,
> or more than about three overrides belongs in a values file. That's the next
> section.

## Using a Values File

For anything real, put values in a file you can review and commit.

```editor:open-file
file: exercises/podinfo-values.yaml
```

This sets replica count, resource limits, a custom message and a readiness
probe. Apply it:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --wait --timeout 5m
```

```terminal:execute
command: helm get values my-app
```

Now the overrides come from your file. Confirm the app picked up the message —
podinfo reports its own configuration at `/api/info`:

```terminal:execute
command: kubectl run client --image=curlimages/curl:8.11.1 --restart=Never --rm -it --command -- curl -s -m 10 http://my-app-podinfo:9898/api/info
```

Look for the `message` field: `"Hello from the Helm workshop!"`. That string
travelled from your values file, through the chart's template, into an
environment variable (`PODINFO_UI_MESSAGE`), and out of the running container.
See the last hop for yourself:

```terminal:execute
command: kubectl get deployment my-app-podinfo -o jsonpath='{.spec.template.spec.containers[0].env[*].name}{"\n"}'
```

## Seeing the Result Before Applying It

The safest workflow is to render locally and read the diff before touching the
cluster:

```terminal:execute
command: helm template my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml | head -50
```

`helm template` never contacts the cluster. It's what CI pipelines use to lint
and validate charts.

Compare the rendered Deployment against what's actually running:

```terminal:execute
command: helm get manifest my-app | grep -A6 "resources:"
```

## Combining Files and Flags

Both, together — the file provides the baseline, `--set` overrides one thing:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --set replicaCount=1 --wait --timeout 5m
```

```terminal:execute
command: kubectl get pods -l app.kubernetes.io/managed-by=Helm
```

One replica — `--set` won, exactly as the precedence chain predicts. But the
resource limits from the file are still in place:

```terminal:execute
command: helm get values my-app
```

## The --reuse-values Trap

By default, every `helm upgrade` starts from the chart's defaults plus whatever
you pass **this time**. Values you set in a previous upgrade are *not* carried
over unless you ask.

Watch what happens with no values at all:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo --wait --timeout 5m
```

```terminal:execute
command: helm get values my-app
```

Empty — every override you'd built up is gone, and the app is back to chart
defaults. This surprises people at the worst possible moment.

Two ways to avoid it:

| Flag | Behaviour |
|------|-----------|
| `--reuse-values` | Merge the previous release's values with the new ones |
| `--reset-values` | Explicitly start from chart defaults (the default behaviour) |

The more robust habit is to **always pass your values file**, so the file is the
single source of truth rather than accumulated cluster state.

Restore the configuration:

```terminal:execute
command: helm upgrade my-app podinfo/podinfo -f ~/exercises/podinfo-values.yaml --wait --timeout 5m
```

## Summary

In this chapter you learned:
- Precedence: chart defaults → values files (in order) → `--set` wins
- `helm get values` shows your overrides; `--all` shows everything in effect
- `helm template` renders locally with no cluster involved
- `--set` is fine for one or two values; use a file beyond that
- **`helm upgrade` forgets previous overrides** unless you pass them again or use `--reuse-values`
- Keeping values in a committed file beats relying on cluster state

Next: what happens when an upgrade goes wrong.
