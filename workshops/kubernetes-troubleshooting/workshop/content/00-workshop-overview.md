---
title: Workshop Overview
---

# Kubernetes Troubleshooting

Welcome! Every other workshop shows you Kubernetes when it **works**. This one
shows you Kubernetes when it **doesn't** — which is how you will spend most of
your time in the real world.

You will be handed six broken workloads. For each one you'll see the symptom,
find the root cause with `kubectl`, fix it, and confirm the fix. By the end you
won't be memorising error messages — you'll have a **method** that works on
errors you've never seen before.

## What You Will Learn

| Level | Symptom | Failures You Will Diagnose |
|-------|---------|----------------------------|
| **1 — Method** | — | `get` → `describe` → events → logs, and when to use each |
| **2 — Never starts** | `0/1` forever | `ImagePullBackOff`, `CreateContainerConfigError` |
| **3 — Starts, then dies** | restart count climbing | `CrashLoopBackOff`, `OOMKilled` |
| **4 — Stays Pending** | no node assigned | unschedulable Pod, rejected by admission |
| **5 — Unreachable** | app doesn't answer | Service with no endpoints, wrong `targetPort` |

## Prerequisites

You should be comfortable with:
- `kubectl get`, `describe`, `logs`, `apply`, `delete`
- Pods, Deployments, Services, ConfigMaps

These were covered in *Kubernetes Fundamentals* and *Kubernetes Services, Secrets
& Storage*.

## Workshop Environment

Your workshop environment provides:

- **Two terminals** (split layout) — keep a `watch` running in one while you work in the other
- **Code editor** — read and fix the broken manifests
- **Headlamp** — a web UI where events and logs are one click away
- **Pre-built broken manifests** — in `~/exercises/`

Your dedicated namespace is `{{ session_namespace }}`.

## How Each Scenario Works

Every scenario follows the same four beats:

1. **Break it** — you apply a manifest that someone handed you
2. **Observe** — what does the cluster actually say?
3. **Diagnose** — narrow it down to one root cause
4. **Fix and verify** — change one thing, prove it worked

Resist the urge to skip to the fix. The diagnosis is the skill.

## Official Kubernetes Documentation

- [Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Debug Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)
- [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## Time Estimate

This workshop takes approximately **60 minutes** to complete.

Let's break some things!
