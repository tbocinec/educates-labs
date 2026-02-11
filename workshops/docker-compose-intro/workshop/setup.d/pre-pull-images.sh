#!/bin/bash
set -eo pipefail

echo "Pre-pulling Docker images for workshop..."

# Pull images used throughout the workshop
docker pull nginx:latest &
docker pull alpine:latest &
docker pull postgres:17 &
docker pull redis:7 &

# Wait for all background pulls to finish
wait

echo "All images pre-pulled successfully."
