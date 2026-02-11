# Docker Basics & Architecture

Before we dive into running containers, let's understand what Docker is and how it works under the hood.

---

## What is Docker?

**Docker** is an open-source platform that automates the deployment, scaling, and management of applications using **containerization**. A container is a lightweight, standalone, executable package that includes everything needed to run a piece of software — code, runtime, system tools, libraries, and settings.

Unlike virtual machines, containers share the host operating system's kernel, making them significantly more efficient in terms of resource usage and startup time.

---

## Docker Architecture

Docker follows a **client-server architecture** with three core components:

| Component | Description |
|-----------|-------------|
| **Docker Client** | The CLI tool (`docker`) you use to interact with Docker. It sends commands to the Docker daemon. |
| **Docker Daemon** (`dockerd`) | The background service that manages Docker objects — images, containers, networks, and volumes. |
| **Docker Registry** | A storage and distribution system for Docker images. **Docker Hub** is the default public registry. |

### How They Work Together

```
┌──────────────┐     REST API     ┌──────────────────┐
│ Docker Client │ ──────────────► │  Docker Daemon    │
│   (docker)    │                 │   (dockerd)       │
└──────────────┘                 │                    │
                                  │  ┌─────────────┐  │
                                  │  │ Containers   │  │
                                  │  ├─────────────┤  │
                                  │  │ Images       │  │
                                  │  ├─────────────┤  │
                                  │  │ Volumes      │  │
                                  │  ├─────────────┤  │
                                  │  │ Networks     │  │
                                  │  └─────────────┘  │
                                  └──────────────────┘
```

---

## Key Concepts

### Images vs Containers

- **Image** — A read-only template containing the application code, runtime, libraries, and dependencies. Think of it as a *blueprint* or a *class* in object-oriented programming.
- **Container** — A running instance of an image. Think of it as an *object* instantiated from a class. You can create multiple containers from the same image.

### Docker Registry and Docker Hub

- A **registry** is a service that stores Docker images. 
- **Docker Hub** (`hub.docker.com`) is the default public registry with millions of pre-built images.
- Images follow the naming convention: `registry/repository:tag` (e.g., `docker.io/library/nginx:latest`).

---

## Verifying Docker Installation

Let's confirm Docker is available and working in your environment:

**Check the Docker version:**

```terminal:execute
command: docker version
```

This displays both the client and server (daemon) version information.

**View detailed system information:**

```terminal:execute
command: docker info
```

This command reveals the number of containers, images, storage driver, and other system-level details about your Docker installation.

---

## Docker Command Structure

Docker commands follow a consistent pattern:

```
docker [management-command] [sub-command] [options] [arguments]
```

For example:
- `docker container ls` — List running containers
- `docker image pull nginx` — Pull the nginx image
- `docker container run --name web nginx` — Run a container named "web" from the nginx image

You can also use the **shorthand** syntax:
- `docker ps` (same as `docker container ls`)
- `docker pull nginx` (same as `docker image pull nginx`)
- `docker run nginx` (same as `docker container run nginx`)

**View all available commands:**

```terminal:execute
command: docker --help
```

Throughout this workshop, we will use both the full and shorthand command forms so you become familiar with both styles.
