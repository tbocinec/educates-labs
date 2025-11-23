# Step 01 - Container Setup

Before we can install Grafana, we need to set up our isolated Ubuntu environment.

---
## Why Use a Container?

Running Grafana in a Docker container provides:
- **Security**: Isolated environment that doesn't affect the workshop platform
- **Root access**: Full control inside the container to install packages
- **Clean state**: Easy to restart with a fresh environment
- **Port forwarding**: Grafana UI accessible through the workshop interface

---
## Alternative Grafana Deployment Methods

While we use a custom Ubuntu container in this workshop for learning purposes, Grafana can be deployed in various ways:

### Operating System Installations

Grafana supports direct installation on multiple platforms:

**Linux Distributions:**
- **Ubuntu/Debian** - APT package manager (`.deb` packages)
- **RHEL/CentOS/Fedora** - YUM/DNF package manager (`.rpm` packages)
- **SUSE/openSUSE** - Zypper package manager
- **Arch Linux** - AUR (Arch User Repository)

**Other Platforms:**
- **macOS** - Homebrew package manager or standalone binary
- **Windows** - Windows installer (`.msi`) or standalone binary

Each platform has official Grafana packages and detailed installation guides in the [Grafana documentation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/).

### Docker Images

**Official Grafana Docker Image:**
Grafana provides official pre-built Docker images at `grafana/grafana`. These images:
- Come with Grafana pre-installed and configured
- Include all dependencies and plugins
- Are production-ready and regularly updated
- Support configuration via environment variables
- Are much smaller and faster to deploy than building from scratch

**Why we don't use it in this workshop:**
We're using a bare Ubuntu container to:
- **Learn the manual installation process** step-by-step
- **Understand all dependencies and configuration** that Grafana requires
- **Practice Linux system administration** skills
- **See what happens "under the hood"** of the official image

**Future workshops:**
In advanced workshops, you'll learn to:
- Use the official `grafana/grafana` Docker image
- Deploy Grafana on Kubernetes with Helm charts
- Set up high-availability Grafana clusters
- Configure Grafana with Docker Compose
- Build custom Grafana images with pre-installed plugins

For now, the manual approach gives you deeper understanding of how Grafana works!

---
## Launch Ubuntu Container

We'll start an Ubuntu container with:
- Interactive terminal access (`-it`)
- Port forwarding for Grafana UI (`-p 3000:3000`)
- Detached mode (`-d`) so it runs in background
- Named container (`--name grafana-workshop`) for easy access

```terminal:execute
command: docker run -d --name grafana-workshop -p 3000:3000 ubuntu:latest sleep infinity
```

This command:
1. Downloads the Ubuntu image (if not already present)
2. Starts a container named `grafana-workshop` in background
3. Forwards port 3000 from container to host (for Grafana UI)
4. Keeps the container running with `sleep infinity`

---
## Enter the Container

Now connect to the running container with an interactive bash shell:

```terminal:execute
command: docker exec -it grafana-workshop /bin/bash
```

You should see a prompt like `root@<container-id>:/#` - this means you're inside the container with **root privileges**.

**Important**: Inside the container, you have full administrative (root) access. This allows you to install packages and modify system configuration without restrictions. This is safe because the container is isolated from the host system.

---
## Verify Container Environment

Check you're in Ubuntu:

```terminal:execute
command: cat /etc/os-release
```

You should see Ubuntu version information.

**Important**: All following installation and configuration commands will be executed inside this container.

---
## Container Management Tips

- To exit the container shell: Type `exit` or press Ctrl+D (container keeps running)
- To re-enter the container: `docker exec -it grafana-workshop /bin/bash`
- To stop the container: `docker stop grafana-workshop`
- To start it again: `docker start grafana-workshop`
- To remove the container: `docker rm -f grafana-workshop`

Now you're ready to install Grafana!

Proceed to installation.