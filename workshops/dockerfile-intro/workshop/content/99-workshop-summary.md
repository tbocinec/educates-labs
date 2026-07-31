# Zhrnutie workshopu

Gratulujeme! Naučili ste sa písať efektívne Dockerfile pripravené do produkcie.

---

## Čo ste sa naučili

| Kapitola | Kľúčové koncepty |
|---------|-------------|
| **Základy Dockerfile** | `FROM`, `RUN`, `COPY`, `CMD`, build kontext |
| **Prvý image** | `docker build`, tagovanie cez `-t`, `docker run -p` |
| **Vrstvy image** | Caching vrstiev, invalidácia cache, poradie |
| **Podrobný pohľad na inštrukcie** | `WORKDIR`, `EXPOSE`, `ENTRYPOINT` vs `CMD`, `ENV`, `ARG`, `.dockerignore` |
| **Osvedčené postupy** | Slim base images, používateľ mimo root, spájané `RUN`, pip `--no-cache-dir` |
| **Multi-stage builds** | Build a runtime stage, `COPY --from`, výrazné zmenšenie veľkosti |

---

## Rýchla referencia Dockerfile

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

## Referencia veľkostí image

| Prístup | Typická veľkosť |
|----------|-------------|
| `ubuntu` + ručná inštalácia | 400-800 MB |
| `python:3.12` (plný) | ~350 MB |
| `python:3.12-slim` | ~130 MB |
| `python:3.12-alpine` | ~50 MB |
| Go multi-stage → `alpine` | ~15 MB |
| Go multi-stage → `scratch` | ~7 MB |

---

## Záverečné vyčistenie (cleanup)

Odstráňte všetky images a kontajnery vytvorené počas tohto workshopu:

```terminal:execute
command: docker stop $(docker ps -q) 2>/dev/null; docker system prune -af 2>/dev/null; echo "Cleanup complete!"
```

---

## Ďalšie kroky

Pokračujte vo svojej ceste učenia sa Dockeru:

- **Docker Compose** — definujte a spúšťajte viackontajnerové aplikácie
- **Docker Networking & Storage** — prepájajte kontajnery a uchovávajte dáta
- **Kontajnerové registry** — push a pull images z Docker Hubu, GHCR alebo súkromných registry
- **CI/CD pipelines** — automatizujte zostavovanie a nasadzovanie images
```
