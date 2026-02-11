# Dockerfile Best Practices

Now that you know the instructions, let's learn how to write **production-quality** Dockerfiles. We'll compare a poorly written Dockerfile with an optimized one.

---

## Setup

**Copy the exercise files:**

```terminal:execute
command: cp -r ~/exercises/best-practices ~/best-practices && cd ~/best-practices
```

---

## The "Bad" Dockerfile

Let's start with a Dockerfile that works but violates several best practices:

```editor:open-file
file: ~/best-practices/Dockerfile.bad
```

**Build it:**

```terminal:execute
command: cd ~/best-practices && docker build -t app-bad -f Dockerfile.bad .
```

**Run it:**

```terminal:execute
command: docker run --rm app-bad
```

**Check the image size:**

```terminal:execute
command: docker images app-bad --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

This image is **large** — several hundred MB. Let's understand why and what we can improve.

---

## Problem 1: Too Many Layers

Each `RUN` instruction creates a separate layer:

```editor:select-matching-text
file: ~/best-practices/Dockerfile.bad
text: RUN apt-get update
```

There are **5 separate `RUN`** instructions. Each one adds a layer with its own overhead. The `apt-get update` cache is stored in one layer, and subsequent installs can't benefit from combining them.

**Best practice:** Combine related `RUN` commands with `&&`:

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*
```

This creates a **single layer** and the cleanup (`rm -rf`) actually saves space because it happens in the same layer.

> **Important:** If you run `apt-get update` and `rm -rf /var/lib/apt/lists/*` in separate `RUN` instructions, the cleanup has no effect — the data is already preserved in the previous layer.

---

## Problem 2: Wrong Base Image

```editor:select-matching-text
file: ~/best-practices/Dockerfile.bad
text: FROM ubuntu
```

Using `ubuntu:24.04` for a Python app is wasteful:
- It includes tools you don't need (bash completion, documentation, etc.)
- You have to manually install Python and pip
- The resulting image is much larger

**Best practice:** Use a **purpose-built** base image:

| Instead of... | Use... | Why |
|---------------|--------|-----|
| `ubuntu` + install python | `python:3.12-slim` | Python pre-installed, much smaller |
| `ubuntu` + install node | `node:22-alpine` | Node pre-installed, tiny base |
| `ubuntu` + install java | `eclipse-temurin:21-jre` | JRE only, optimized |

---

## Problem 3: No Specific Tag

```dockerfile
# Bad  — "latest" can change unexpectedly
FROM ubuntu:24.04

# Better — but still a full OS
FROM python:3.12

# Best  — slim variant, specific version
FROM python:3.12-slim
```

> **Best practice:** Always use a **specific version tag**. Avoid `:latest` in production Dockerfiles.

---

## Problem 4: Running as Root

```terminal:execute
command: docker run --rm app-bad whoami
```

The container runs as **root**. If an attacker exploits the application, they get root access inside the container.

---

## The "Good" Dockerfile

Now let's look at the optimized version:

```editor:open-file
file: ~/best-practices/Dockerfile.good
```

**Key improvements:**

```editor:select-matching-text
file: ~/best-practices/Dockerfile.good
text: FROM python
```

1. **Smaller base image** — `python:3.12-slim` instead of `ubuntu:24.04`

```editor:select-matching-text
file: ~/best-practices/Dockerfile.good
text: groupadd -r appuser
```

2. **Non-root user** — Creates and switches to `appuser`

```editor:select-matching-text
file: ~/best-practices/Dockerfile.good
text: COPY requirements.txt
```

3. **Smart COPY order** — Dependencies first, code second (for caching)

```editor:select-matching-text
file: ~/best-practices/Dockerfile.good
text: --no-cache-dir
```

4. **No pip cache** — Smaller image with `--no-cache-dir`

**Build it:**

```terminal:execute
command: cd ~/best-practices && docker build -t app-good -f Dockerfile.good .
```

**Run it:**

```terminal:execute
command: docker run --rm -p 8080:5000 app-good
```

Click the **App Preview** tab to see the running application. Notice it reports "Running as user: **appuser**" — not root!

**Stop the container:**

```terminal:execute
command: docker stop $(docker ps -q --filter ancestor=app-good) 2>/dev/null
```

---

## Compare Image Sizes

```terminal:execute
command: docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E 'app-bad|app-good'
```

The "good" image is typically **3-5x smaller** than the "bad" one!

---

## Verify Security

**Bad image — runs as root:**

```terminal:execute
command: docker run --rm app-bad whoami
```

**Good image — runs as non-root:**

```terminal:execute
command: docker run --rm app-good whoami
```

---

## Best Practices Checklist

| Practice | Why |
|----------|-----|
| Use **specific base image tags** | Reproducible builds |
| Use **slim/alpine** variants | Smaller images, less attack surface |
| **Combine `RUN`** commands | Fewer layers, effective cleanup |
| **`COPY` before `RUN`** for deps | Better layer caching |
| Use **`--no-cache-dir`** for pip | Smaller images |
| Clean up in the **same `RUN`** | Actually reduces layer size |
| Run as **non-root** user | Security best practice |
| Use **`.dockerignore`** | Faster builds, no secrets in image |
| Use **`COPY`** instead of `ADD` | Explicit, no surprises |

---

## Cleanup

```terminal:execute
command: docker stop $(docker ps -q --filter ancestor=app-good) 2>/dev/null; docker rmi app-bad app-good 2>/dev/null; rm -rf ~/best-practices
```

