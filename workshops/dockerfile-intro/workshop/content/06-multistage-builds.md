# Multi-Stage Builds

Multi-stage builds are one of Docker's most powerful features. They let you use **separate stages** for building and running your application — keeping build tools out of the final image.

---

## The Problem

When you build a compiled application (Go, Java, C, Rust, etc.), you need:

| Stage | Tools Needed | Size |
|-------|-------------|------|
| **Build** | Compiler, SDK, build tools | Large (hundreds of MB) |
| **Run** | Just the compiled binary | Tiny (a few MB) |

Without multi-stage builds, your production image includes all build tools — wasting space and increasing the attack surface.

---

## Setup

**Copy the exercise files:**

```terminal:execute
command: cp -r ~/exercises/multistage ~/multistage && cd ~/multistage
```

**Look at the Go application:**

```editor:open-file
file: ~/multistage/main.go
```

This is a simple HTTP server written in Go. When compiled, it produces a **single static binary** — no runtime dependencies needed.

---

## Single-Stage Build (The Old Way)

First, let's see what happens with a standard single-stage build. We'll build inside the `golang` image:

```terminal:execute
command: cd ~/multistage && printf 'FROM golang:1.23-alpine\nWORKDIR /app\nCOPY go.mod main.go ./\nRUN go build -o server main.go\nEXPOSE 8080\nCMD ["./server"]' | docker build -t go-single -f - .
```

**Check the image size:**

```terminal:execute
command: docker images go-single --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

The image is **~250 MB** — mostly the Go compiler and SDK that we no longer need at runtime.

---

## Multi-Stage Build

Now let's use a multi-stage Dockerfile:

```editor:open-file
file: ~/multistage/Dockerfile
```

**Key concepts:**

```editor:select-matching-text
file: ~/multistage/Dockerfile
text: FROM golang
```

1. **Stage 1** (`builder`) — Uses the full Go SDK to compile the application

```editor:select-matching-text
file: ~/multistage/Dockerfile
text: FROM alpine
```

2. **Stage 2** — Starts fresh from a tiny `alpine` image

```editor:select-matching-text
file: ~/multistage/Dockerfile
text: COPY --from=builder
```

3. **`COPY --from=builder`** — Copies **only the compiled binary** from the build stage

Everything else from the build stage (Go compiler, source code, build cache) is **discarded**.

**Build it:**

```terminal:execute
command: cd ~/multistage && docker build -t go-multi .
```

**Check the size:**

```terminal:execute
command: docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E 'go-single|go-multi'
```

The multi-stage image is **~15 MB** — about **95% smaller** than the single-stage build!

---

## Test the Application

```terminal:execute
command: docker run --rm -d -p 8080:8080 --name go-app go-multi
```

Click the **App Preview** tab to see the Go application running. It shows the Go version and system architecture.

**Stop the container:**

```terminal:execute
command: docker stop go-app
```

---

## Going Even Smaller with `scratch`

`alpine` is already tiny (~7 MB), but we can go further. The `scratch` image is a completely **empty** image — 0 bytes:

```editor:open-file
file: ~/multistage/Dockerfile.scratch
```

**Key differences:**

```editor:select-matching-text
file: ~/multistage/Dockerfile.scratch
text: CGO_ENABLED=0
```

- `CGO_ENABLED=0` — Produces a **statically linked** binary (no C library dependency)
- `-ldflags="-s -w"` — Strips debug symbols to reduce binary size

```editor:select-matching-text
file: ~/multistage/Dockerfile.scratch
text: FROM scratch
```

- `FROM scratch` — Starts from an **empty** image (no shell, no OS, nothing)

**Build it:**

```terminal:execute
command: cd ~/multistage && docker build -t go-scratch -f Dockerfile.scratch .
```

---

## Compare All Three Approaches

```terminal:execute
command: docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E 'go-single|go-multi|go-scratch'
```

| Image | Base | Approximate Size |
|-------|------|-----------------|
| `go-single` | golang:1.23-alpine | ~320 MB |
| `go-multi` | alpine | ~15 MB |
| `go-scratch` | scratch | ~7 MB |

That's a **97% reduction** from single-stage to scratch!

**Verify the scratch image works:**

```terminal:execute
command: docker run --rm -d -p 8080:8080 --name go-scratch-app go-scratch
```

Click the **App Preview** tab — same application, fraction of the size.

```terminal:execute
command: docker stop go-scratch-app
```

---

## How Multi-Stage Builds Work

```
┌──────────────────────────┐
│  Stage 1: builder        │
│  FROM golang:1.23-alpine │
│  ┌────────────────────┐  │
│  │  Go compiler       │  │
│  │  Source code        │  │
│  │  Build cache        │  │
│  │  ┌──────────────┐  │  │
│  │  │ server binary │──┼──┼──► COPY --from=builder
│  │  └──────────────┘  │  │
│  └────────────────────┘  │
│         DISCARDED        │
└──────────────────────────┘

┌──────────────────────────┐
│  Stage 2: runtime        │
│  FROM alpine:latest      │
│  ┌────────────────────┐  │
│  │  server binary     │  │  ← Only this ends up
│  └────────────────────┘  │    in the final image
└──────────────────────────┘
```

---

## When to Use Multi-Stage Builds

| Language | Build Image | Runtime Image |
|----------|------------|---------------|
| **Go** | `golang:alpine` | `alpine` or `scratch` |
| **Java** | `maven` or `gradle` | `eclipse-temurin:*-jre` |
| **Node.js** | `node` (install + build) | `node:*-slim` (run) |
| **Rust** | `rust` | `alpine` or `scratch` |
| **C/C++** | `gcc` | `alpine` or `scratch` |

Multi-stage builds are useful for **any** application where build requirements differ from runtime requirements.

---

## Cleanup

```terminal:execute
command: docker stop $(docker ps -q) 2>/dev/null; docker rmi go-single go-multi go-scratch 2>/dev/null; rm -rf ~/multistage
```

