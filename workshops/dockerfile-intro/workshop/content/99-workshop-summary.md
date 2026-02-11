# Workshop Summary

Congratulations! You've learned how to write efficient, production-ready Dockerfiles.

---

## What You Learned

| Chapter | Key Concepts |
|---------|-------------|
| **Dockerfile Basics** | `FROM`, `RUN`, `COPY`, `CMD`, build context |
| **First Image** | `docker build`, `-t` tagging, `docker run -p` |
| **Image Layers** | Layer caching, cache invalidation, ordering |
| **Instructions Deep Dive** | `WORKDIR`, `EXPOSE`, `ENTRYPOINT` vs `CMD`, `ENV`, `ARG`, `.dockerignore` |
| **Best Practices** | Slim base images, non-root user, combined `RUN`, pip `--no-cache-dir` |
| **Multi-Stage Builds** | Build vs runtime stages, `COPY --from`, dramatic size reduction |

---

## Dockerfile Quick Reference

```dockerfile
# Base image
FROM python:3.12-slim

# Build-time variables
ARG APP_VERSION=1.0.0

# Metadata
LABEL maintainer="team@example.com"
LABEL version="${APP_VERSION}"

# Set working directory
WORKDIR /app

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install dependencies (cached layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Runtime environment variables
ENV APP_ENV=production

# Switch to non-root user
USER appuser

# Document the port
EXPOSE 8080

# Start the application
CMD ["python", "app.py"]
```

---

## Image Size Reference

| Approach | Typical Size |
|----------|-------------|
| `ubuntu` + install manually | 400-800 MB |
| `python:3.12` (full) | ~350 MB |
| `python:3.12-slim` | ~130 MB |
| `python:3.12-alpine` | ~50 MB |
| Go multi-stage → `alpine` | ~15 MB |
| Go multi-stage → `scratch` | ~7 MB |

---

## Final Cleanup

Remove all images and containers created during this workshop:

```terminal:execute
command: docker stop $(docker ps -q) 2>/dev/null; docker system prune -af 2>/dev/null; echo "Cleanup complete!"
```

---

## Next Steps

Continue your Docker learning journey:

- **Docker Compose** — Define and run multi-container applications
- **Docker Networking & Storage** — Connect containers and persist data
- **Container registries** — Push and pull images from Docker Hub, GHCR, or private registries
- **CI/CD pipelines** — Automate building and deploying images

