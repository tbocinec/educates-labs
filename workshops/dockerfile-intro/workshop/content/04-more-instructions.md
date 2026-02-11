# Dockerfile Instructions Deep Dive

Let's explore additional Dockerfile instructions that give you more control over how images are built and containers behave.

**Copy all exercise files for this chapter:**

```terminal:execute
command: cp -r ~/exercises/instructions-demo ~/instructions-demo
```

---

## `WORKDIR` — Set Working Directory

Sets the working directory for all subsequent instructions (`RUN`, `COPY`, `CMD`, etc.):

```dockerfile
WORKDIR /app
COPY . .         # Files are copied to /app/
RUN make build   # Runs in /app/
CMD ["./server"] # Starts in /app/
```

If the directory doesn't exist, Docker creates it automatically. You can use `WORKDIR` multiple times.

**Open the demo Dockerfile in the editor:**

```editor:open-file
file: ~/instructions-demo/workdir/Dockerfile
```

The comments in the file explain the purpose. Let's build and run it:

```terminal:execute
command: cd ~/instructions-demo/workdir && docker build -t workdir-test . && docker run --rm workdir-test
```

The output shows `/myapp` — confirming that `RUN` executed inside the `WORKDIR`.

---

## `EXPOSE` — Document Ports

`EXPOSE` **documents** which port the application listens on. It does **not** publish the port — that's done with `docker run -p`:

```dockerfile
EXPOSE 5000
EXPOSE 8080/tcp
EXPOSE 8125/udp
```

It serves as documentation for users of your image and is used by `docker run -P` (publish all exposed ports to random host ports).

---

## `ENTRYPOINT` vs `CMD`

Both define what runs when a container starts, but they behave differently:

### `CMD` — Default Command (Can Be Overridden)

```dockerfile
CMD ["python", "app.py"]
```

The user can override it completely:

```terminal:execute
command: docker run --rm my-nginx:v1 echo "I replaced the default CMD"
```

### `ENTRYPOINT` — Fixed Executable

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

The user **cannot** easily override the entrypoint. `CMD` becomes the default **argument**.

**Open the demo Dockerfile:**

```editor:open-file
file: ~/instructions-demo/entrypoint/Dockerfile
```

The comments explain how `ENTRYPOINT` and `CMD` work together. Build and run:

```terminal:execute
command: cd ~/instructions-demo/entrypoint && docker build -t ep-test . && docker run --rm ep-test
```

**Override only the CMD argument:**

```terminal:execute
command: docker run --rm ep-test "print('Hello from entrypoint!')"
```

The entrypoint (`python -c`) stays fixed; only the argument changes.

### When to Use Which

| Use Case | Recommendation |
|----------|----------------|
| General application | `CMD ["python", "app.py"]` |
| CLI tool wrapper | `ENTRYPOINT ["mytool"]` + `CMD ["--help"]` |
| Need both fixed + overridable | `ENTRYPOINT` + `CMD` combo |

---

## `ENV` — Environment Variables

Sets environment variables available both during build **and** at runtime.

**Open the demo Dockerfile:**

```editor:open-file
file: ~/instructions-demo/env/Dockerfile
```

**Build and run:**

```terminal:execute
command: cd ~/instructions-demo/env && docker build -t env-test . && docker run --rm env-test
```

The container prints the values set by `ENV`. Now **override at runtime:**

```terminal:execute
command: docker run --rm -e APP_ENV=development env-test
```

---

## `ARG` — Build-Time Variables

`ARG` defines variables that exist **only during the build** — they are not available at runtime.

**Open the demo Dockerfile:**

```editor:open-file
file: ~/instructions-demo/arg/Dockerfile
```

Read the comments — they explain the key difference from `ENV`. Build with a `--build-arg`:

```terminal:execute
command: cd ~/instructions-demo/arg && docker build -t arg-test --build-arg BUILD_DATE=$(date +%Y-%m-%d) . && docker run --rm arg-test
```

Notice that `BUILD_DATE` is **not available** at runtime, but it was used during the build to set the label.

**Check the label:**

```terminal:execute
command: docker inspect arg-test --format '{{index .Config.Labels "build_date"}}'
```

### `ARG` vs `ENV` Summary

| Feature | `ARG` | `ENV` |
|---------|-------|-------|
| Available during build | Yes | Yes |
| Available at runtime | No | Yes |
| Set from CLI | `--build-arg` | `-e` |
| Stored in image | No | Yes |

---

## `LABEL` — Image Metadata

Adds metadata to your image as key-value pairs:

```dockerfile
LABEL maintainer="team@example.com"
LABEL version="1.0"
LABEL description="My production web server"
```

**Inspect labels:**

```terminal:execute
command: docker inspect my-nginx:v1 --format '{{json .Config.Labels}}' | python3 -m json.tool 2>/dev/null || docker inspect my-nginx:v1 --format '{{json .Config.Labels}}'
```

---

## `.dockerignore` — Exclude Files from Build Context

Like `.gitignore`, a `.dockerignore` file excludes files from being sent to the Docker daemon.

**First, open the Dockerfile for this demo:**

```editor:open-file
file: ~/instructions-demo/ignore/Dockerfile
```

It simply copies everything from the build context into `/app/` and lists it. Let's create some test files:

```terminal:execute
command: cd ~/instructions-demo/ignore && echo "needed" > app.py && echo "secret" > password.txt && mkdir -p .git && echo "git data" > .git/config && echo "big file" > huge-log.txt
```

**Build without .dockerignore — everything is copied:**

```terminal:execute
command: cd ~/instructions-demo/ignore && docker build -t noignore-test . && docker run --rm noignore-test
```

All files ended up in the image — including `password.txt`! Now let's add a `.dockerignore` file:

**Open the prepared .dockerignore (with comments explaining each pattern):**

```editor:open-file
file: ~/instructions-demo/ignore/dockerignore
```

**Activate it by copying to `.dockerignore`:**

```terminal:execute
command: cp ~/instructions-demo/ignore/dockerignore ~/instructions-demo/ignore/.dockerignore
```

**Rebuild — excluded files are gone:**

```terminal:execute
command: cd ~/instructions-demo/ignore && docker build -t ignore-test . && docker run --rm ignore-test
```

Only `app.py` remains. The `.git` directory, `.txt` files, and `Dockerfile` itself are excluded.

### Common `.dockerignore` Patterns

```
.git
.gitignore
node_modules
*.md
Dockerfile
docker-compose.yml
.env
__pycache__
*.pyc
.vscode
```

---

## `COPY` vs `ADD`

Both copy files into the image, but they differ:

| Feature | `COPY` | `ADD` |
|---------|--------|-------|
| Copy local files | Yes | Yes |
| Auto-extract `.tar.gz` | No | Yes |
| Download from URL | No | Yes |
| Recommended | **Yes** | Only when you need extraction |

> **Best practice:** Always use `COPY` unless you specifically need `ADD`'s tar extraction feature.

---

## Cleanup

```terminal:execute
command: docker rmi workdir-test ep-test env-test arg-test noignore-test ignore-test 2>/dev/null; rm -rf ~/instructions-demo
```
