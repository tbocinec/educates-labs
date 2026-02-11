# Container Networking

Docker provides built-in networking capabilities that allow containers to communicate with each other, with the host, and with external networks. Understanding networking is essential for building multi-container applications.

---

## Default Docker Networks

Docker creates three networks automatically:

```terminal:execute
command: docker network ls
```

| Network | Driver | Purpose |
|---------|--------|---------|
| **bridge** | bridge | Default network for containers. Provides NAT-based isolation. |
| **host** | host | Container shares the host's network stack directly. |
| **none** | null | No networking — complete isolation. |

---

## The Default Bridge Network

When you run a container without specifying a network, it connects to the default **bridge** network:

```terminal:execute
command: docker run -d --name net-demo1 alpine:latest sleep 3600
```

```terminal:execute
command: docker run -d --name net-demo2 alpine:latest sleep 3600
```

**Inspect the IP addresses:**

```terminal:execute
command: docker inspect net-demo1 --format '{{.NetworkSettings.IPAddress}}'
```

```terminal:execute
command: docker inspect net-demo2 --format '{{.NetworkSettings.IPAddress}}'
```

**Test connectivity between containers by IP address:**

```terminal:execute
command: docker exec net-demo1 ping -c 3 $(docker inspect net-demo2 --format '{{.NetworkSettings.IPAddress}}')
```

Containers on the default bridge can communicate via IP addresses, but **DNS-based name resolution does not work** on the default bridge.

```terminal:execute
command: docker exec net-demo1 ping -c 1 net-demo2 2>&1 || echo "DNS resolution failed on default bridge — this is expected!"
```

---

## User-Defined Bridge Networks

User-defined bridge networks provide **automatic DNS resolution** between containers — a critical feature for multi-container applications:

**Create a custom network:**

```terminal:execute
command: docker network create workshop-net
```

**Inspect the network:**

```terminal:execute
command: docker network inspect workshop-net
```

---

## Running Containers on a Custom Network

```terminal:execute
command: docker rm -f net-demo1 net-demo2
```

```terminal:execute
command: docker run -d --name web-app --network workshop-net nginx:latest
```

```terminal:execute
command: docker run -d --name test-client --network workshop-net alpine:latest sleep 3600
```

**Test DNS resolution — containers can now reach each other by name:**

```terminal:execute
command: docker exec test-client ping -c 3 web-app
```

**Access the Nginx service by container name:**

```terminal:execute
command: docker exec test-client wget -qO- http://web-app:80 | head -5
```

This is how multi-container applications communicate in Docker — services reference each other by container name, not by IP address.

---

## Connecting a Container to Multiple Networks

A container can be connected to multiple networks simultaneously:

**Create a second network:**

```terminal:execute
command: docker network create backend-net
```

**Connect the web-app container to both networks:**

```terminal:execute
command: docker network connect backend-net web-app
```

**Verify the container has interfaces on both networks:**

docker inspect web-app 


The container now has an IP address on both `workshop-net` and `backend-net`.

---

## Network Isolation

Containers on different networks **cannot** communicate with each other unless explicitly connected:

```terminal:execute
command: docker run -d --name isolated-app --network backend-net alpine:latest sleep 3600
```

**Test: `isolated-app` (backend-net) cannot reach `test-client` (workshop-net):**

```terminal:execute
command: docker exec isolated-app ping -c 1 -W 2 test-client 2>&1 
```

**But `isolated-app` can reach `web-app` (which is on both networks):**

```terminal:execute
command: docker exec isolated-app ping -c 3 web-app
```

This network segmentation is a powerful security feature — you can isolate database containers from public-facing web servers while still allowing application containers to connect to both.

---

## Disconnecting from a Network

```terminal:execute
command: docker network disconnect backend-net web-app
```

**Verify the container is no longer on the backend network:**


docker inspect web-app


---

## Host Network Mode

In **host** network mode, the container shares the host's network namespace directly — no port mapping is needed:

```terminal:execute
command: docker rm -f web-app
```

```terminal:execute
command: docker run -d --name host-net-demo --network host nginx:latest
```

**Nginx is now accessible directly on the host's port 80:**

```terminal:execute
command: curl -s http://localhost:80 | head -3
```

> **Note:** Host networking removes network isolation. The container has full access to the host's network interfaces. Use it only when the performance overhead of bridge networking is unacceptable.

---

## Cleanup

```terminal:execute
command: docker rm -f test-client isolated-app host-net-demo
```

```terminal:execute
command: docker network rm workshop-net backend-net
```
