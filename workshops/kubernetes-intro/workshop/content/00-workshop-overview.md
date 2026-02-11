---
title: Workshop Overview
---

# Kubernetes Fundamentals

Welcome to this hands-on workshop on **Kubernetes fundamentals**! You will learn how to work with the core building blocks of Kubernetes — from running your first Pod to managing application updates with Deployments.

## What You Will Learn

This workshop is organized into four progressive levels:

| Level | Topic | What You Will Cover |
|-------|-------|-------------------|
| **1 — Getting Started** | Architecture & kubectl | Kubernetes components, cluster exploration, kubectl commands |
| **2 — Pods** | Running workloads | Creating Pods imperatively and declaratively with YAML |
| **3 — Deployments** | Managing applications | Deployments, scaling, rolling updates, rollbacks |
| **4 — Configuration** | Config & organization | ConfigMaps, Labels, Selectors, Namespaces |

## Workshop Environment

Your workshop environment provides:

- **Two terminals** (split layout) — run commands side by side
- **Code editor** — view and edit YAML manifests
- **Kubernetes Dashboard** — visual cluster monitoring (Console tab)
- **Pre-built exercise files** — YAML manifests in the `exercises/` directory

The terminals are already configured with `kubectl` and have access to your dedicated Kubernetes namespace: `{{ session_namespace }}`.

## Time Estimate

This workshop takes approximately **90 minutes** to complete.

## Official Kubernetes Documentation

- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

Let's get started!
