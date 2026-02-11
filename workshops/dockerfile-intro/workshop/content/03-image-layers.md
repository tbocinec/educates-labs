# Understanding Image Layers

Every instruction in a Dockerfile creates a **layer**. Understanding layers is key to writing efficient Dockerfiles with fast builds.

---

## Visualizing Layers

Let's build a Python application image and examine its layers.

**Copy the exercise files:**

```terminal:execute
command: cp -r ~/exercises/layers-demo ~/layers-demo && cd ~/layers-demo
```

**Open the Dockerfile in the Editor:**

```editor:open-file
file: ~/layers-demo/Dockerfile
```

**Open the application code:**

```editor:open-file
file: ~/layers-demo/app.py
```

**Build the image:**

```terminal:execute
command: cd ~/layers-demo && docker build -t layers-demo:v1 .
```

---

## Inspecting Layers with `docker history`

```terminal:execute
command: docker history layers-demo:v1
```

Each row is a layer. You can see:
- The instruction that created it
- The size it added to the image
- Layers from the base image (`python:3.12-slim`)
- Layers from your Dockerfile (`COPY`, `RUN pip install`, etc.)

**For a cleaner view:**

```terminal:execute
command: docker history layers-demo:v1 --format "table {{.CreatedBy}}\t{{.Size}}" --no-trunc | head -10
```

---

## Layer Caching

Docker **caches** each layer. If an instruction hasn't changed, Docker reuses the cached layer instead of rebuilding it. This makes subsequent builds much faster.

**Build again without changes:**

```terminal:execute
command: cd ~/layers-demo && docker build -t layers-demo:v1 .
```

Notice the output says `CACHED` for every step — nothing was rebuilt.

---

## Cache Invalidation

When a layer changes, **all subsequent layers** are invalidated and rebuilt. This is the most important concept for build performance.

**Change only the application code:**

```terminal:execute
command: sed -i 's/image layers/image layers v2/' ~/layers-demo/app.py
```

**Rebuild:**

```terminal:execute
command: cd ~/layers-demo && docker build -t layers-demo:v2 .
```

Watch the output carefully:
- `COPY requirements.txt .` → **CACHED** (requirements didn't change)
- `RUN pip install ...` → **CACHED** (requirements didn't change)
- `COPY app.py .` → **rebuilt** (app.py changed)

Only the layers **after** the change are rebuilt. The expensive `pip install` step was skipped

---

## Why Order Matters

This is why our Dockerfile copies `requirements.txt` **before** `app.py`:

```dockerfile
COPY requirements.txt .          # ← Changes rarely
RUN pip install -r requirements.txt  # ← Expensive, cached when deps unchanged
COPY app.py .                    # ← Changes often
```

If we had copied everything at once:

```dockerfile
COPY . .                         # ← ANY file change invalidates this
RUN pip install -r requirements.txt  # ← Rebuilds every time
```

> **Rule of thumb:** Put instructions that change **rarely** at the top, and instructions that change **frequently** at the bottom.


---

## Layer Sharing Between Images

Layers are **shared** between images that use the same base. Let's verify:

```terminal:execute
command: docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E 'layers-demo|my-nginx'
```

**Check actual disk usage:**

```terminal:execute
command: docker system df -v 2>/dev/null 
```

Shared layers (like the base image) are stored only once on disk, even if multiple images reference them.

---

## Summary

| Concept | Description |
|---------|-------------|
| **Layers** | Each Dockerfile instruction creates a layer |
| **Caching** | Unchanged layers are reused from cache |
| **Invalidation** | Changing a layer invalidates all layers below it |
| **Ordering** | Place rarely-changing instructions first |
| **Sharing** | Images with the same base share layers on disk |

---

## Cleanup

```terminal:execute
command: docker rmi layers-demo:v1 layers-demo:v2 2>/dev/null; rm -rf ~/layers-demo
```
