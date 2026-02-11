---
title: Workshop Overview
---

# Kubernetes Services, Secrets & Storage

Welcome to this hands-on workshop! This is a **follow-up** to the *Kubernetes Fundamentals* workshop that covered kubectl, Pods, Deployments, ConfigMaps, and Labels.

In this workshop you'll learn how to **connect**, **secure**, and **persist** your applications in Kubernetes.

## What You Will Learn

This workshop is organized into four progressive levels:

| Level | Topic | What You Will Cover |
|-------|-------|-------------------|
| **1 — Networking** | Services & DNS | Pod networking model, ClusterIP Services, service discovery |
| **2 — Secrets** | Sensitive data | Creating Secrets, consuming as env vars and files |
| **3 — Storage** | Persistent data | PersistentVolumeClaims, data surviving Pod restarts |
| **4 — Reliability** | Probes & Jobs | Liveness/readiness health checks, Jobs, CronJobs |

## Prerequisites

You should be familiar with:
- `kubectl` basics (`get`, `apply`, `describe`, `delete`, `logs`, `exec`)
- Pods and Deployments
- Labels and selectors

These were covered in the *Kubernetes Fundamentals* workshop.

## Workshop Environment

Your workshop environment provides:

- **Two terminals** (split layout) — run commands side by side
- **Code editor** — view and edit YAML manifests
- **Kubernetes Dashboard** — visual cluster monitoring (Console tab)
- **Pre-built exercise files** — YAML manifests in `~/exercises/`

Your dedicated namespace is `{{ session_namespace }}`.

## Official Kubernetes Documentation

Throughout this workshop we'll reference the official docs. Key pages:

- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## Time Estimate

This workshop takes approximately **90 minutes** to complete.

Let's begin!
