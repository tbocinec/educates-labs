# Demonstrates .dockerignore
# This Dockerfile copies EVERYTHING from the build context into /app/
# Without .dockerignore — all files (including secrets!) end up in the image.
# With .dockerignore — excluded files are never sent to Docker daemon.

FROM alpine:latest

COPY . /app/

CMD ls -la /app/
