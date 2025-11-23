# Grafana with Docker - Quick Start Workshop

This Educates workshop teaches how to run and configure Grafana using Docker and Docker Compose.

## Overview

Learn how to:
- Run Grafana using the official Docker image
- Configure Grafana with environment variables
- Persist data using Docker volumes
- Install plugins in containerized Grafana
- Use Docker Compose for deployment

## Duration

Approximately 30 minutes

## Workshop Structure

1. **Run Grafana with Docker** - Launch using official image
2. **Configure Grafana** - Environment variables and volumes
3. **Install Plugins** - Extend Grafana functionality
4. **Docker Compose** - Simplified deployment and multi-container setup

Content lives under `workshop/content/` following numbered steps.

## Resources

- [Grafana Docker Documentation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Grafana Plugin Catalog](https://grafana.com/grafana/plugins/)

To publish via GitHub Action ensure a tag `X.Y` is pushed and the action `publish-multiple-workshops` includes this directory.
