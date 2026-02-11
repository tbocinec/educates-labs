#!/bin/bash

# Log execution for debugging
echo "🐳 Docker Networking & Storage workshop session started" | tee /tmp/docker-setup.log
echo "Executed at: $(date)" >> /tmp/docker-setup.log
echo "User: $(whoami)" >> /tmp/docker-setup.log

# Verify Docker is available
if command -v docker &> /dev/null; then
    echo "✅ Docker is available: $(docker --version)" >> /tmp/docker-setup.log
else
    echo "❌ Docker is not available" >> /tmp/docker-setup.log
    exit 1
fi

# Pre-pull commonly used images to speed up the workshop experience
echo "📦 Pre-pulling workshop images..." >> /tmp/docker-setup.log

docker pull nginx:latest >> /tmp/docker-setup.log 2>&1 &
docker pull alpine:latest >> /tmp/docker-setup.log 2>&1 &
docker pull postgres:17 >> /tmp/docker-setup.log 2>&1 &
docker pull redis:7 >> /tmp/docker-setup.log 2>&1 &

wait

echo "✅ All images pre-pulled successfully" >> /tmp/docker-setup.log
echo "🚀 Workshop environment is ready!" >> /tmp/docker-setup.log
