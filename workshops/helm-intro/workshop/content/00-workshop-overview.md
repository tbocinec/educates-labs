---
title: Workshop Overview
---

# Helm Fundamentals

Welcome! By now you've written a fair amount of YAML by hand — a Deployment
here, a Service there, a ConfigMap to tie them together. It works, until you
need the same application in dev, staging and production with three different
configurations.

**Helm** is the package manager for Kubernetes. It turns a pile of manifests
into a versioned, configurable, installable unit — and gives you an undo button.

## What You Will Learn

| Level | Topic | What You Will Cover |
|-------|-------|---------------------|
| **1 — Concepts** | Charts & releases | Repositories, charts, releases, where Helm stores state |
| **2 — Install** | Your first release | `helm install`, inspecting what it created |
| **3 — Configure** | Values | `--set`, values files, `helm template` |
| **4 — Operate** | Upgrade & rollback | Release history, rolling back a bad deploy, `--atomic` |
| **5 — Author** | Your own chart | `helm create`, templates, `helm lint` |

## Prerequisites

You should be familiar with:
- `kubectl` basics (`get`, `describe`, `apply`, `delete`)
- Deployments, Services and ConfigMaps
- Reading YAML manifests

These were covered in *Kubernetes Fundamentals* and *Kubernetes Services, Secrets
& Storage*.

## Workshop Environment

Your workshop environment provides:

- **Two terminals** (split layout) — run commands side by side
- **Code editor** — read and edit charts and values files
- **Headlamp** — see what Helm actually created in your namespace
- **Helm, already installed** — no setup needed

Your dedicated namespace is `{{ session_namespace }}`.

Confirm the version you're working with:

```terminal:execute
command: helm version
```

> **This workshop uses Helm 4.** Nearly everything here works identically on
> Helm 3. Where the two differ, the text says so.

## A Note on Permissions

You are an administrator **inside your own namespace** and nowhere else. That
matters for Helm: many public charts install cluster-scoped objects
(ClusterRoles, CRDs, webhooks) and would be refused here.

The charts in this workshop are deliberately namespace-only. If you later try a
chart of your own and see `Forbidden` errors, that's usually the reason — not a
broken chart.

## Official Documentation

- [Helm documentation](https://helm.sh/docs/)
- [Using Helm](https://helm.sh/docs/intro/using_helm/)
- [Charts](https://helm.sh/docs/topics/charts/)
- [Values files](https://helm.sh/docs/chart_template_guide/values_files/)

## Time Estimate

This workshop takes approximately **60 minutes** to complete.

Let's install something!
