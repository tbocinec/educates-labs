# Container Setup

Before we can install Kafka, we need to set up our isolated Ubuntu environment.

---
## Why Use a Container?

Running Kafka in a Docker container provides:
- **Security**: Isolated environment that doesn't affect the workshop platform
- **Root access**: Full control inside the container to install packages
- **Clean state**: Easy to restart with a fresh environment
- **Port mapping**: Kafka brokers and UI accessible through the workshop interface

---
## Alternative Kafka Deployment Methods

While we use a custom Ubuntu container in this workshop for learning purposes, Kafka can be deployed in various ways:

### Platform Independence

Apache Kafka is a **Java-based application** and is not tied to any specific operating system. Kafka can run on any platform that supports **Java 11 or later** (Java 21 is recommended for optimal performance and security).

**Supported Platforms:**
- **Linux** - Ubuntu, Debian, RHEL, CentOS, Fedora, or any distribution with Java runtime
- **macOS** - Intel or Apple Silicon with Java installed
- **Windows** - Native installation or WSL2 with Java runtime
- **Unix-based systems** - Solaris, FreeBSD, or other Unix variants

The only requirement is a compatible Java Virtual Machine (JVM). Kafka binaries are distributed as platform-independent JAR files, making deployment flexible across different environments.

### Docker & Kubernetes

**Official Kafka Images:**
- **Apache Kafka** - Official Docker images from Confluent or Bitnami
- **Kubernetes** - Deploy with Strimzi operator or Helm charts
- **Docker Compose** - Multi-broker clusters with one YAML file

**Why we don't use pre-built images in this workshop:**
We're using a bare Ubuntu container to:
- **Learn the manual installation process** step-by-step
- **Understand Kafka architecture** and components
- **Practice Linux system administration** skills
- **See how KRaft mode works** from the ground up

For production environments, you'd typically use official Docker images or Kubernetes operators!

---
## Launch Ubuntu Container

We'll start an Ubuntu container with:
- Interactive terminal access (`-it`)
- Port forwarding for Kafka and Kafka UI (`-p 9092:9092 -p 8080:8080`)
- Detached mode (`-d`) so it runs in background
- Named container (`--name kafka-workshop`) for easy access

```terminal:execute
command: docker run -d --name kafka-workshop -p 9092:9092 -p 9093:9093 -p 9094:9094 -p 8080:8080 ubuntu:latest sleep infinity
```

This command:
1. Downloads the Ubuntu image (if not already present)
2. Starts a container named `kafka-workshop` in background
3. Forwards ports for Kafka brokers (9092, 9093, 9094) and Kafka UI (8080)
4. Keeps the container running with `sleep infinity`

---
## Enter the Container

Now connect to the running container with an interactive bash shell:

```terminal:execute
command: docker exec -it kafka-workshop /bin/bash
```

You should see a prompt like `root@<container-id>:/#` - this means you're inside the container with **root privileges**.

**Important**: Inside the container, you have full administrative (root) access. This allows you to install packages and modify system configuration without restrictions. This is safe because the container is isolated from the host system.

---
## Verify Container Environment

Check you're in Ubuntu:

```terminal:execute
command: cat /etc/os-release
```

You should see output indicating Ubuntu Linux.

Check the working directory:

```terminal:execute
command: pwd
```

You're at `/` (root directory).

---
## Understanding the Container

**What's different inside the container:**
- You're running as `root` user (no `sudo` needed)
- Fresh Ubuntu installation with minimal packages
- Isolated filesystem (changes won't affect the host)
- Network accessible through port forwarding

**What stays the same:**
- Linux commands work normally
- You can install packages with `apt-get`
- File permissions work as expected
- Processes run independently

---
## Next Steps

Now that we have our isolated environment, we can safely install Java and Kafka!

> **Tip**: If you accidentally exit the container, just run `docker exec -it kafka-workshop /bin/bash` again to re-enter.
