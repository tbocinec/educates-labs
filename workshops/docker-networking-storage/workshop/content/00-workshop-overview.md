# Workshop Overview

Welcome to the **Docker: Networking, Ports & Storage** workshop! This hands-on lab covers three essential areas of Docker that go beyond the basics — port mapping, persistent storage, and container networking.

---

## What You Will Learn

By the end of this workshop, you will be able to:

- **Expose** container services to the host network using port mapping (`-p`)
- **Run** multiple instances of the same service on different host ports
- **Persist** data across container restarts using Docker volumes
- **Copy** files into and out of containers using `docker cp`
- **Understand** bind mounts and when to use them
- **Create** user-defined bridge networks with automatic DNS resolution
- **Isolate** containers on separate networks for security
- **Connect** containers to multiple networks simultaneously
- **Clean up** unused Docker resources efficiently

---

## Prerequisites

This workshop assumes you are familiar with:

- Running containers (`docker run`, `-d`, `--name`, `--rm`)
- Container lifecycle management (`docker stop`, `start`, `rm`)
- Executing commands inside containers (`docker exec -it`)
- Container logs (`docker logs`)
- Environment variables (`-e`)

If you haven't completed the **Introduction to Docker** workshop yet, we recommend doing that first.

---

## Workshop Environment

Your workshop environment comes pre-configured with:

- **Docker Engine** — ready to use from the terminal
- **Terminal** — split-pane terminal for running commands
- **Editor** — accessible via the **Editor** tab for viewing files
- **Nginx tab** — a browser tab to view services exposed on port 8080

---

## How to Use This Workshop

Throughout this workshop you will encounter executable command blocks. Simply click on them to execute the command in the terminal.

**Let's get started!**
