# Exploring Docker Images

Docker images are the foundation of containers. In this section, you will learn how to search for images, understand image layers, work with tags, and inspect image metadata.

---

## Searching for Images

**Search Docker Hub for images from the command line:**

```terminal:execute
command: docker search nginx --limit 5
```

The output shows image names, descriptions, star ratings, and whether they are official images. **Official images** are curated and maintained by Docker in partnership with upstream maintainers.

**Search for a database image:**

```terminal:execute
command: docker search postgres --limit 5
```

> **Tip:** For more detailed information (available tags, Dockerfile, documentation), visit [Docker Hub](https://hub.docker.com) directly.

---

## Listing Local Images

**View all locally available images:**

```terminal:execute
command: docker images
```

**Filter images by repository name:**

```terminal:execute
command: docker images nginx
```

**Show image IDs only (useful for scripting):**

```terminal:execute
command: docker images -q
```

---

## Understanding Image Tags

Tags identify specific versions of an image. The format is `repository:tag`:

- `nginx:latest` — The most recent version (default if no tag specified)
- `nginx:1.27` — A specific minor version
- `nginx:1.27-alpine` — A variant built on Alpine Linux (smaller size)

**Pull multiple tags of the same image to compare:**

```terminal:execute
command: docker pull nginx:latest
```

```terminal:execute
command: docker pull nginx:alpine
```

**Compare sizes:**

```terminal:execute
command: docker images nginx
```

The `alpine` variant is significantly smaller because Alpine Linux is a minimal distribution (~7 MB base). Choosing the right base image tag is an important decision for production deployments.

---

## Inspecting Image Details

The `docker inspect` command reveals detailed metadata about an image:

```terminal:execute
command: docker inspect nginx:latest --format '{{.Os}}/{{.Architecture}}'
```

**View exposed ports defined in the image:**

```terminal:execute
command: docker inspect nginx:latest --format '{{json .Config.ExposedPorts}}' | python3 -m json.tool
```

**View the default command:**

```terminal:execute
command: docker inspect nginx:latest --format '{{json .Config.Cmd}}' | python3 -m json.tool
```

**View all environment variables baked into the image:**

```terminal:execute
command: docker inspect nginx:latest --format '{{range .Config.Env}}{{println .}}{{end}}'
```

---

## Understanding Image Layers

Docker images are built from a stack of **read-only layers**. Each layer represents a filesystem change (adding files, installing packages, etc.). This layer architecture enables:

- **Efficient storage** — Layers shared between images are stored only once
- **Fast builds** — Only changed layers need to be rebuilt
- **Fast pulls** — Only missing layers need to be downloaded

**View the layers (history) of an image:**

```terminal:execute
command: docker history nginx:latest
```

Each row represents a layer. The `CREATED BY` column shows the Dockerfile instruction that produced it. Notice that some layers are very small (just metadata changes) while others are larger (installing packages).

**Compare the history of the Alpine variant:**

```terminal:execute
command: docker history nginx:alpine
```

The Alpine variant has fewer and smaller layers.

---

## Disk Usage

Docker images can consume significant disk space over time. Check your Docker disk usage:

```terminal:execute
command: docker system df
```

This shows the space used by images, containers, volumes, and build cache. The `RECLAIMABLE` column indicates how much space can be freed.

**For a more detailed breakdown:**

```terminal:execute
command: docker system df -v
```

---

## Pulling Images from Other Registries

While Docker Hub is the default registry, you can pull images from any OCI-compatible registry:

```
docker pull ghcr.io/owner/image:tag       # GitHub Container Registry
docker pull quay.io/owner/image:tag        # Red Hat Quay
docker pull registry.example.com/image:tag # Private registry
```

The full image reference format is: `registry/repository:tag`

When no registry is specified, Docker defaults to `docker.io/library/`.

---

## Tagging Images

You can create additional tags (aliases) for an image without duplicating data:

```terminal:execute
command: docker tag nginx:latest my-nginx:v1
```

```terminal:execute
command: docker images | grep -E "nginx|my-nginx"
```

Notice that `my-nginx:v1` has the **same Image ID** as `nginx:latest` — it's just another pointer to the same image layers.

---

## Removing Images

**Remove an image by name:**

```terminal:execute
command: docker rmi my-nginx:v1
```

**Remove dangling images** (untagged layers left behind after rebuilds):

```terminal:execute
command: docker images -f "dangling=true"
```

```terminal:execute
command: docker image prune -f
```

> **Note:** You cannot remove an image if any container (even a stopped one) is using it. Remove the container first, then the image.
