---
title: Charts, Releases & Repositories
---

# Level 1: Charts, Releases & Repositories

Three words carry most of Helm's meaning. Get them straight now and the rest of
the tool follows.

| Term | What it is | Analogy |
|------|-----------|---------|
| **Chart** | A package: templated manifests + default values | The `.deb` file |
| **Release** | One installation of a chart, with a name and a version history | The installed program |
| **Repository** | An index of charts you can fetch | The package archive |

The crucial one is **release**. You can install the same chart five times in one
namespace under five names, and Helm tracks each independently.

> **Docs**: [Three Big Concepts](https://helm.sh/docs/intro/using_helm/#three-big-concepts)

## Adding a Repository

Helm ships with no repositories configured. Add one:

```terminal:execute
command: helm repo add podinfo https://stefanprodan.github.io/podinfo
```

`podinfo` is a small demo web application, purpose-built for exactly this kind of
exercise. Confirm the repo is registered:

```terminal:execute
command: helm repo list
```

Fetch the latest index:

```terminal:execute
command: helm repo update
```

## Finding Charts

```terminal:execute
command: helm search repo podinfo
```

Two version numbers appear, and they mean different things:

- **CHART VERSION** — the version of the packaging
- **APP VERSION** — the version of the software inside

They often move together, but not always. A chart fix that changes no
application code bumps only the chart version.

See the full history of the chart:

```terminal:execute
command: helm search repo podinfo --versions | head -10
```

## Reading a Chart Before Installing It

Never install a chart you haven't looked at. Start with its documentation:

```terminal:execute
command: helm show chart podinfo/podinfo
```

This is the chart's metadata — name, version, description, maintainers.

Now the part that actually matters, the knobs you can turn:

```terminal:execute
command: helm show values podinfo/podinfo | head -40
```

Every line here is something you can override at install time. This is the
chart's public API, and it's the first thing to read when evaluating any chart.

You can also pull the chart apart locally without installing anything:

```terminal:execute
command: helm pull podinfo/podinfo --untar --untardir ~/charts && ls ~/charts/podinfo
```

Look at what a chart is made of:

```terminal:execute
command: ls ~/charts/podinfo/templates
```

| File / directory | Purpose |
|------------------|---------|
| `Chart.yaml` | Metadata: name, version, appVersion |
| `values.yaml` | Default values — the chart's API |
| `templates/` | Manifests with Go template placeholders |
| `templates/_helpers.tpl` | Reusable template snippets |
| `templates/NOTES.txt` | The message printed after install |
| `charts/` | Bundled dependencies (subcharts) |

Open the deployment template and see the templating in action:

```editor:open-file
file: charts/podinfo/templates/deployment.yaml
```

Notice expressions like `{{ .Values.replicaCount }}`. That's the whole idea: a
manifest with holes in it, and `values.yaml` filling them.

## Where Helm Keeps Its State

A common misconception is that Helm runs a server. It doesn't — not since Helm 3.
Release state lives in **Secrets in your namespace**, which you'll see for
yourself in the next chapter.

```terminal:execute
command: kubectl get secrets
```

Nothing Helm-related yet. Remember this — you'll run the same command after
installing.

## Summary

In this chapter you learned:
- **Chart** = package, **release** = one installation of it, **repository** = index
- The same chart can be installed many times under different release names
- `helm show values` reveals the chart's configurable surface — read it first
- `helm pull --untar` lets you inspect a chart without installing it
- CHART VERSION and APP VERSION are different things
- Helm 3+ is client-only; release state lives in Secrets in your namespace

Next: let's actually install something.
