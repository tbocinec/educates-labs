# Running Your First Container

It's time to run your very first Docker container. In this section, you will pull an image from Docker Hub and start a container from it.

---

## Pulling an Image

Before running a container, you need an image. Let's start by pulling the official **Nginx** web server image:

```terminal:execute
command: docker pull nginx:latest
```

Docker downloads the image layer by layer from Docker Hub. Each layer is cached locally, so subsequent pulls of the same image (or images sharing layers) will be much faster.

**Verify the image was downloaded:**

```terminal:execute
command: docker images
```

You should see the `nginx` image listed with its tag, image ID, creation date, and size.

---

## Running a Container in Foreground Mode

The simplest way to run a container is in **foreground** (attached) mode. This attaches your terminal's standard input, output, and error streams to the container process:

```terminal:execute
command: docker run --name my-nginx nginx:latest
```

You will see Nginx log output directly in your terminal. The container is running in the foreground and your terminal is blocked.

**Press `Ctrl+C`** in the terminal to stop the container.

---

## Running a Container in Detached Mode

In most real-world scenarios, you want containers to run in the **background** (detached mode) using the `-d` flag:

```terminal:execute
command: docker run -d --name my-nginx-bg nginx:latest
```

Docker prints the full **container ID** and returns control to your terminal immediately. The container continues running in the background.

**List running containers:**

```terminal:execute
command: docker ps
```

You should see `my-nginx-bg` in the list with its container ID, image name, command, creation time, status, and exposed ports.

---

## Understanding `docker ps` Output

The `docker ps` command provides essential information about running containers:

| Column | Description |
|--------|-------------|
| **CONTAINER ID** | A unique 12-character hash identifying the container |
| **IMAGE** | The image the container was created from |
| **COMMAND** | The default command the container is running |
| **CREATED** | When the container was created |
| **STATUS** | Current state (e.g., `Up 2 minutes`) |
| **PORTS** | Port mappings between host and container |
| **NAMES** | The human-readable name of the container |

**List ALL containers** (including stopped ones):

```terminal:execute
command: docker ps -a
```

Notice that `my-nginx` (the foreground container you stopped earlier) appears here with a status of `Exited`.

---

## Running a One-Shot Container

Not all containers run long-lived services. You can run a container that executes a single command and then exits:

```terminal:execute
command: docker run --rm alpine:latest echo "Hello from Docker!"
```

Let's break down the flags:
- `--rm` — Automatically removes the container after it exits (cleanup)
- `alpine:latest` — A minimal Linux distribution image (only ~7 MB)
- `echo "Hello from Docker!"` — The command to execute inside the container

The container starts, prints the message, and is immediately removed.

**Run another one-shot command to see the container's OS information:**

```terminal:execute
command: docker run --rm alpine:latest cat /etc/os-release
```

This demonstrates that the container is running its own isolated Linux environment — Alpine Linux — regardless of what the host OS is running.

---

## Naming Containers

By default, Docker assigns random names to containers (like `eager_newton` or `happy_darwin`). You've already seen the `--name` flag in action. Named containers are easier to manage:

```terminal:execute
command: docker run -d --name webserver nginx:latest
```

You can now refer to this container by its name (`webserver`) instead of its container ID in all subsequent commands.

**Verify it's running:**

```terminal:execute
command: docker ps --filter "name=webserver"
```

> **Note:** Container names must be unique. If a container with the same name already exists (even if stopped), you must remove it before creating a new one with that name.
