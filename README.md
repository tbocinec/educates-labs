# Educates Labs

This repository contains interactive workshops built for [Educates](https://educates.dev/), a platform for creating and delivering hands-on learning experiences.

## Available Workshops

### 1. Kafka Introduction (`kafka-intro`)
An introductory workshop covering Apache Kafka fundamentals, including:
- Docker Compose setup
- Kafka CLI tools
- Basic producer and consumer operations

### 2. Kafka UI Workshop (`kafka-ui`)
A comprehensive workshop focusing on Kafka UI management:
- Kafka installation and setup
- Kafka UI configuration
- Topic creation and management
- Message publishing and monitoring
- UI exploration and features

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- [Educates CLI](https://docs.educates.dev/getting-started/installing-educates-cli) installed
- Kubernetes cluster (for deploying workshops)

## Quick Start

### Installing Educates CLI

```bash
# Install Educates CLI (example for Linux/macOS)
curl -s https://docs.educates.dev/install.sh | bash
```

### Deploying a Workshop

To deploy any workshop from this repository, navigate to the workshop directory and use the `educates deploy-workshop` command:

```bash
# Deploy the Kafka Introduction workshop
cd kafka-intro
educates deploy-workshop resources/workshop.yaml

# Deploy the Kafka UI workshop
cd kafka-ui
educates deploy-workshop resources/workshop.yaml
```

### Accessing Workshops

After deployment, the CLI will provide you with a URL to access your workshop session.

## Workshop Development

Each workshop follows the standard Educates structure:
- `resources/workshop.yaml` - Workshop configuration and metadata
- `workshop/config.yaml` - Workshop runtime configuration
- `workshop/content/` - Workshop content in Markdown format

## Useful Links

- 📚 [Educates Documentation](https://docs.educates.dev/)
- 🌐 [Educates Website](https://educates.dev/)
- 🏗️ [Educates GitHub Repository](https://github.com/vmware-tanzu-labs/educates-training-platform)
- 📖 [Workshop Development Guide](https://docs.educates.dev/workshop-content/)



## Common Commands

```bash
# List available workshops
educates list-workshops

# Deploy workshop
educates deploy-workshop <workshop-file>

# Delete workshop
educates delete-workshop <workshop-name>

# Get workshop sessions
educates list-sessions

# Delete all workshops
educates delete-workshops
```

