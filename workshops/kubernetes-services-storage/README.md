# Kubernetes Services, Secrets & Storage Workshop

A hands-on follow-up workshop covering Kubernetes networking, sensitive data management, persistent storage, health checks, and batch workloads.

## Duration

~90 minutes

## Prerequisites

- Completion of the **Kubernetes Fundamentals** workshop (or equivalent knowledge of kubectl, Pods, Deployments, ConfigMaps)

## Topics Covered

### Level 1 — Networking
- Pod networking model and cluster DNS
- Services (ClusterIP) — exposing and discovering applications

### Level 2 — Configuration & Secrets
- Secrets — managing sensitive data (env vars, volume mounts)
- Comparison with ConfigMaps

### Level 3 — Storage
- PersistentVolumeClaims (PVCs) — request and mount persistent storage
- Data persistence across Pod restarts

### Level 4 — Reliability & Batch
- Liveness and readiness probes — automatic health checks
- Jobs and CronJobs — one-off and scheduled batch workloads

## Features

- Kubernetes Dashboard enabled for visual cluster management
- Pre-built exercise YAML files with inline comments
- Integrated code editor for viewing and editing manifests
- Split terminal for running multiple commands

## Official Documentation Links

- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
