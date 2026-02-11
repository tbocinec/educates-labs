# Dockerfile Basics

A **Dockerfile** is a text file containing a series of instructions that Docker uses to build an image. Each instruction creates a **layer** in the final image.

---

## The Build Process

When you run `docker build`, Docker:

1. Reads the Dockerfile
2. Executes each instruction **in order**, from top to bottom
3. Creates a new **image layer** for each instruction
4. Produces the final image consisting of all layers stacked together

```
┌─────────────────────────────┐
│  Final Image                │
├─────────────────────────────┤
│  Layer 4: CMD ["nginx"...]  │  ← Runtime command
│  Layer 3: COPY index.html   │  ← Your custom content
│  Layer 2: RUN apt-get...    │  ← Install packages
│  Layer 1: FROM nginx:latest │  ← Base image
└─────────────────────────────┘
```

---

## Core Instructions

Here are the most commonly used Dockerfile instructions:

### `FROM` — Base Image

Every Dockerfile **must start** with a `FROM` instruction. It sets the base image:

```dockerfile
FROM nginx:latest
FROM python:3.12-slim
FROM alpine:latest
```

> Always use a **specific tag** (e.g., `python:3.12-slim`) instead of `latest` for reproducible builds.

### `RUN` — Execute Commands

Runs a command **during the build** and saves the result as a new layer:

```dockerfile
RUN apt-get update && apt-get install -y curl
RUN pip install flask
```

Each `RUN` creates a layer. Combine related commands with `&&` to minimize layers.

### `COPY` — Copy Files

Copies files from your **build context** (local directory) into the image:

```dockerfile
COPY index.html /usr/share/nginx/html/
COPY app.py /app/
COPY . /app/
```

### `CMD` — Default Command

Specifies the command to run when a container **starts** from this image:

```dockerfile
CMD ["python", "app.py"]
CMD ["nginx", "-g", "daemon off;"]
```

> There can be only **one** `CMD` instruction. If you specify multiple, only the last one takes effect.

---

## Build Context

When you run `docker build .`, the `.` refers to the **build context** — the directory whose contents are sent to the Docker daemon. Only files within the build context can be used in `COPY` instructions.

```
project/
├── Dockerfile        ← Build instructions
├── index.html        ← Available for COPY
├── app.py            ← Available for COPY
└── node_modules/     ← Also sent (unless excluded!)
```

> Large directories in the build context slow down builds. Use `.dockerignore` to exclude unnecessary files (covered later).

---

## Dockerfile Reference Table

| Instruction | Purpose | Build / Runtime |
|-------------|---------|-----------------|
| `FROM` | Set base image | Build |
| `RUN` | Execute command during build | Build |
| `COPY` | Copy files into image | Build |
| `ADD` | Copy files (with URL/tar support) | Build |
| `WORKDIR` | Set working directory | Build |
| `EXPOSE` | Document container port | Build (metadata) |
| `ENV` | Set environment variable | Both |
| `ARG` | Set build-time variable | Build |
| `CMD` | Default run command | Runtime |
| `ENTRYPOINT` | Main executable | Runtime |
| `USER` | Set runtime user | Runtime |
| `LABEL` | Add metadata | Build (metadata) |

We will explore each instruction throughout this workshop.
