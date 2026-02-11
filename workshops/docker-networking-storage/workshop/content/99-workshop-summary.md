# Workshop Summary

Congratulations! You have completed the **Docker: Networking, Ports & Storage** workshop. Let's review the key concepts and skills you've acquired.

---

## What You Learned

### Port Mapping
- `-p HOST:CONTAINER` maps ports between host and container
- Containers are isolated by default — port mapping exposes services
- Multiple containers can use the same internal port on different host ports
- Use `-p 127.0.0.1:PORT:PORT` to restrict access to localhost only

### Volumes & Data Persistence
- **Volumes** (`-v name:/path`) persist data beyond container lifecycle
- Volumes can be **shared** between multiple containers
- `docker cp` copies files between host and container (one-time copy)
- **Bind mounts** (`-v /host:/container`) provide live sync for development (requires direct Docker daemon access)
- Use `:ro` for **read-only** mounts

### Networking
- **User-defined bridge networks** provide automatic DNS resolution
- Containers on the same network communicate by **name**
- Containers on different networks are **isolated** by default
- `docker network connect/disconnect` manages network memberships
- **Host networking** removes isolation but eliminates NAT overhead

---

## Quick Reference Card

```
# Port Mapping
docker run -p 8080:80 image    # Map host:container port
docker run -p 80 image         # Random host port
docker port CONTAINER          # Show port mappings

# Volumes
docker volume create V         # Create a volume
docker run -v V:/path image    # Mount a volume
docker volume ls               # List volumes
docker volume inspect V        # Volume details
docker volume prune            # Remove unused volumes

# Docker cp
docker cp file.txt X:/path    # Copy file into container
docker cp X:/path file.txt    # Copy file from container

# Networking
docker network create N        # Create a network
docker run --network N image   # Connect to a network
docker network connect N X     # Add container to network
docker network disconnect N X  # Remove from network
docker network inspect N       # Network details
docker network prune           # Remove unused networks

# Cleanup
docker system prune --volumes  # Remove all unused resources
```

---

## Next Steps

| Topic | Description |
|-------|-------------|
| **Docker Compose** | Define multi-container applications with networking and volumes in a single YAML file |
| **Dockerfiles** | Build custom images with `FROM`, `RUN`, `COPY`, `CMD`, and other instructions |
| **Multi-Stage Builds** | Optimize image sizes by separating build and runtime environments |
| **Container Orchestration** | Scale and manage containers with Kubernetes or Docker Swarm |

---

**Thank you for completing this workshop!**
