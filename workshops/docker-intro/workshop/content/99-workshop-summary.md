# Workshop Summary

Congratulations! You have completed the **Introduction to Docker** workshop. Let's review the key concepts and skills you've acquired.

---

## What You Learned

### Docker Fundamentals
- Docker uses a **client-server architecture** with the Docker client, daemon, and registries
- **Images** are read-only templates; **containers** are running instances of images
- Docker commands follow the pattern: `docker [management-command] [sub-command] [options]`

### Running Containers
- `docker run` creates and starts a container from an image
- Use `-d` for **detached** (background) mode
- Use `--rm` to **auto-remove** containers on exit
- Use `--name` to assign **meaningful names** to containers

### Container Lifecycle
- **Stop** (`docker stop`) sends SIGTERM for graceful shutdown
- **Start** (`docker start`) restarts a stopped container
- **Restart** (`docker restart`) bounces a container
- **Pause/Unpause** freezes and resumes container processes
- **Kill** (`docker kill`) sends SIGKILL for immediate termination
- **Remove** (`docker rm`) deletes a stopped container; use `-f` for a running one

### Executing Commands
- `docker exec` runs commands in a running container
- `-it` flags provide an **interactive shell** session
- `-u` specifies the **user**, `-w` sets the **working directory**
- Exiting an exec shell does **not** stop the container

### Logs
- `docker logs` retrieves container output
- `-f` **follows** logs in real time
- `--tail N` limits output to the last N lines
- `--since` and `--until` filter by time

### Configuration
- `-e` sets **environment variables** inside the container
- `--env-file` loads variables from a file
- Different images use different configuration mechanisms

### Image Management
- `docker pull` downloads images from registries
- `docker history` shows image layers
- `docker inspect` reveals image metadata
- Alpine-based images are significantly smaller

---

## Next Steps

Now that you understand Docker fundamentals, here are recommended paths for continued learning:

| Topic | Description |
|-------|-------------|
| **Docker: Networking, Ports & Storage** | Port mapping, volumes, persistent data, and container networking |
| **Dockerfiles** | Build custom images with `FROM`, `RUN`, `COPY`, `CMD`, and other instructions |
| **Docker Compose** | Define and manage multi-container applications with a single YAML file |
| **Multi-Stage Builds** | Optimize image sizes by separating build and runtime environments |
| **Container Orchestration** | Scale and manage containers with Kubernetes or Docker Swarm |
| **CI/CD with Docker** | Integrate Docker into continuous integration and delivery pipelines |
| **Container Security** | Image scanning, rootless containers, seccomp profiles, and AppArmor |

---

## Quick Reference Card

```
# Images
docker pull image:tag          # Download an image
docker images                  # List local images
docker rmi image:tag           # Remove an image
docker image prune -a          # Remove unused images

# Containers
docker run -d --name X image   # Run in background
docker ps                      # List running containers
docker ps -a                   # List all containers
docker stop/start/restart X    # Lifecycle management
docker rm -f X                 # Force remove

# Interaction
docker exec -it X bash         # Interactive shell
docker logs -f X               # Follow logs
docker inspect X               # Detailed metadata

# Cleanup
docker system prune --volumes  # Remove all unused resources
```

---

**Thank you for completing this workshop!**
