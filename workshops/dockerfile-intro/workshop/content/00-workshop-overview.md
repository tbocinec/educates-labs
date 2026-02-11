# Workshop Overview

Welcome to the **Building Docker Images with Dockerfiles** workshop!

In this workshop, you will learn how to create your own custom Docker images using Dockerfiles — the standard way to define, build, and distribute containerized applications.

---

## What You Will Learn

- What a Dockerfile is and how the build process works
- Core Dockerfile instructions: `FROM`, `RUN`, `COPY`, `CMD`, and more
- How image **layers** work and how to optimize build **caching**
- Advanced instructions: `WORKDIR`, `EXPOSE`, `ENTRYPOINT`, `ARG`, `ENV`
- Dockerfile **best practices** for production-ready images
- **Multi-stage builds** to create minimal, secure images

---

## Prerequisites

Before starting this workshop, you should be familiar with:

- Running and managing Docker containers (`docker run`, `docker ps`, `docker stop`)
- Basic command line operations

> If you haven't completed the **Introduction to Docker** workshop yet, we recommend doing so first.

---

## Workshop Environment

Your environment includes:

- **Terminal** — for running Docker commands (split into two panes)
- **Editor** — for viewing and editing Dockerfiles and application code
- **App Preview** — a browser tab for testing built images via port 8080

All exercise files are pre-loaded in the `~/exercises/` directory. You will copy them to working directories throughout the workshop.

---

## Duration

This workshop takes approximately **60 minutes** to complete.

Let's start building Docker images!
