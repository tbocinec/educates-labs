# Cleanup & Best Practices

Over time, Docker accumulates unused images, stopped containers, orphaned volumes, and unused networks. In this section, you will learn how to reclaim disk space and adopt best practices.

---

## Viewing Docker Resource Usage

**Get a quick overview of what's consuming space:**

```terminal:execute
command: docker system df
```

---

## Removing Stopped Containers

**List all stopped containers:**

```terminal:execute
command: docker ps -a --filter "status=exited"
```

**Remove all stopped containers at once:**

```terminal:execute
command: docker container prune -f
```

---

## Removing Unused Images

**Remove dangling images** (layers that are no longer referenced by any tagged image):

```terminal:execute
command: docker image prune -f
```

**Remove ALL unused images** (images not associated with any container):

```terminal:execute
command: docker image prune -a -f
```

> **Warning:** The `-a` flag removes all images that don't have at least one container referencing them. Use with caution in environments where you want to keep cached images for faster startup.

---

## Removing Unused Volumes

Orphaned volumes are volumes that are no longer attached to any container. These are a common source of hidden disk usage:

```terminal:execute
command: docker volume ls
```

**Remove all orphaned volumes:**

```terminal:execute
command: docker volume prune -f
```

> **Important:** Volume data is permanently deleted. Always verify what volumes contain before pruning.

---

## Removing Unused Networks

```terminal:execute
command: docker network prune -f
```

This removes all user-defined networks that are not currently in use by any container.

---

## The Nuclear Option: System-Wide Prune

The `docker system prune` command removes **all** unused resources in a single command:

```terminal:execute
command: docker system prune -f
```

To also include **unused volumes** (not included by default):

```terminal:execute
command: docker system prune --volumes -f
```

**Verify everything is clean:**

```terminal:execute
command: docker system df
```

---

## Best Practices Summary

### Port Mapping
- Only expose ports that need to be accessible from outside
- Use specific interface binding (`127.0.0.1:8080:80`) for services that should not be publicly exposed
- Prefer explicit host port assignments in production over random ports

### Data Management
- Use **named volumes** for persistent data (databases, file stores)
- Use **bind mounts** for development workflows (live code reloading)
- Never store important data in a container's writable layer
- Back up named volumes regularly

### Networking
- Use **user-defined bridge networks** instead of the default bridge
- Leverage automatic DNS resolution by using container names
- Isolate sensitive services (databases) on separate networks
- Segment frontend and backend services on different networks

### Security
- Limit container resources with `--memory` and `--cpus` flags
- Use read-only filesystem mounts (`:ro`) where possible
- Never expose database ports to the public network
