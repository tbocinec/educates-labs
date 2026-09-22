---
title: Building Your Own Chart
---

# Level 5: Building Your Own Chart

Consuming charts is half of Helm. The other half is packaging your own
application so someone else — or future you — can install it in one command.

## Scaffolding

Helm generates a working chart for you:

```terminal:execute
command: cd ~ && helm create hello-app && find hello-app -type f | sort
```

That is a complete, installable chart. Look at what you got:

| Path | Purpose |
|------|---------|
| `Chart.yaml` | Name, version, appVersion |
| `values.yaml` | Default values — your chart's API |
| `templates/deployment.yaml` | The Deployment, templated |
| `templates/service.yaml` | The Service |
| `templates/_helpers.tpl` | Naming and label helpers |
| `templates/NOTES.txt` | Printed after install |
| `templates/tests/` | Test Pods run by `helm test` |
| `.helmignore` | Files excluded from the package |

## Reading the Templates

```editor:open-file
file: hello-app/templates/deployment.yaml
```

Three kinds of expression appear here:

```
{{ .Values.replicaCount }}          → a value from values.yaml
{{ include "hello-app.fullname" . }} → a named template from _helpers.tpl
{{- if .Values.autoscaling.enabled }} → a conditional
```

The `{{-` with a dash trims preceding whitespace. Without it you get blank lines
and broken indentation — YAML is unforgiving about that.

```editor:open-file
file: hello-app/values.yaml
```

This is the file consumers of your chart will read. Treat it as documentation,
not just configuration.

## Checking Before Installing

Two commands catch most mistakes. First, static analysis:

```terminal:execute
command: helm lint ~/hello-app
```

Then render the templates and read the YAML you're about to apply:

```terminal:execute
command: helm template hello ~/hello-app | head -40
```

> **If `helm lint` passes but `helm template` produces something odd, trust
> `template`.** Lint checks structure; only rendering shows you the actual
> output with your values applied.

## Customising It

The scaffold runs nginx by default. Point it at podinfo instead, and give it a
sensible size.

```editor:open-file
file: exercises/hello-app-values.yaml
```

Render with those values to check the result before installing:

```terminal:execute
command: helm template hello ~/hello-app -f ~/exercises/hello-app-values.yaml | grep -E "image:|replicas:|containerPort:"
```

Notice that setting `service.port` moved the **container** port too. The scaffold
templates both from one value:

```terminal:execute
command: grep -n "containerPort" ~/hello-app/templates/deployment.yaml
```

That's a chart design decision, not a rule. Always check which value drives what
rather than assuming a knob exists.

## Installing Your Chart

Install from the local directory — no repository needed:

```terminal:execute
command: helm install hello ~/hello-app -f ~/exercises/hello-app-values.yaml --wait --timeout 5m
```

```terminal:execute
command: helm list
```

```terminal:execute
command: kubectl get deploy,svc -l app.kubernetes.io/instance=hello
```

Your own chart, installed like any other.

## Running the Chart's Tests

The scaffold includes a test Pod that checks the Service responds:

```terminal:execute
command: helm test hello --logs
```

`helm test` runs the Pods under `templates/tests/` and reports whether they
succeeded. It's a cheap smoke test after a deploy, and it's worth writing one for
any chart you ship.

## Editing a Template

Make a visible change — add a label to the Deployment.

```editor:open-file
file: hello-app/templates/deployment.yaml
```

Find the Deployment's `metadata.labels` block:

```editor:select-matching-text
file: hello-app/templates/deployment.yaml
text: "  labels:"
```

Add a line under it (mind the indentation — two spaces deeper than `labels:`):

```
    workshop: helm-intro
```

Render to confirm the change is valid before applying:

```terminal:execute
command: helm template hello ~/hello-app -f ~/exercises/hello-app-values.yaml | grep -B2 -A2 "workshop: helm-intro"
```

Now apply it:

```terminal:execute
command: helm upgrade hello ~/hello-app -f ~/exercises/hello-app-values.yaml --atomic --timeout 5m
```

```terminal:execute
command: kubectl get deploy -l workshop=helm-intro
```

## Packaging for Distribution

To hand the chart to someone else, package it:

```terminal:execute
command: cd ~ && helm package hello-app
```

That `.tgz` is exactly what a repository serves. It installs the same way:

```terminal:execute
command: ls ~/hello-app-*.tgz
```

Bump the version in `Chart.yaml` before packaging a change — repositories key on
the version, and re-publishing the same version with different content is a
reliable way to confuse everyone downstream.

## Cleaning Up

```terminal:execute
command: helm uninstall hello
```

```terminal:execute
command: helm list
```

## Summary

In this chapter you learned:
- `helm create` scaffolds a complete, installable chart
- `values.yaml` is your chart's public API — write it like documentation
- `{{-` trims whitespace, and YAML indentation depends on it
- `helm lint` checks structure; `helm template` shows the real output — use both
- Charts install straight from a local directory, no repository required
- `helm test` runs the chart's own smoke tests
- `helm package` produces the `.tgz` a repository serves; always bump the version

One chapter left — the summary and a command reference.
