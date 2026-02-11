#!/bin/bash
set -eo pipefail

echo "Pre-pulling Docker images for the workshop..."

images=(
  "nginx:latest"
  "alpine:latest"
  "python:3.12-slim"
  "golang:1.23-alpine"
  "ubuntu:24.04"
)

for image in "${images[@]}"; do
  echo "Pulling ${image}..."
  docker pull "${image}" &
done

wait
echo "All images pre-pulled successfully."
