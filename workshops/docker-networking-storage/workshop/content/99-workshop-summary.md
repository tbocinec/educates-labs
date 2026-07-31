# Zhrnutie workshopu

Gratulujeme! Absolvovali ste workshop **Docker: Networking, Ports & Storage**. Zhrňme si kľúčové koncepty a zručnosti, ktoré ste získali.

---

## Čo ste sa naučili

### Mapovanie portov
- `-p HOST:CONTAINER` mapuje porty medzi hostiteľom a kontajnerom
- Kontajnery sú predvolene izolované — mapovanie portov sprístupňuje služby
- Viacero kontajnerov môže používať ten istý interný port na rôznych host portoch
- Použite `-p 127.0.0.1:PORT:PORT` na obmedzenie prístupu iba na localhost

### Volumes a perzistencia dát
- **Volumes** (`-v name:/path`) uchovávajú dáta nad rámec životného cyklu kontajnera
- Volumes sa dajú **zdieľať** medzi viacerými kontajnermi
- `docker cp` kopíruje súbory medzi hostiteľom a kontajnerom (jednorazová kópia)
- **Bind mounts** (`-v /host:/container`) poskytujú živú synchronizáciu pre vývoj (vyžadujú priamy prístup k Docker daemonu)
- Použite `:ro` pre **read-only** pripojenia

### Sieťovanie
- **Používateľom definované bridge siete** poskytujú automatické DNS rozlíšenie
- Kontajnery na tej istej sieti komunikujú podľa **mena**
- Kontajnery na rôznych sieťach sú predvolene **izolované**
- `docker network connect/disconnect` spravuje členstvo v sieťach
- **Host networking** odstraňuje izoláciu, ale eliminuje réžiu NAT

---

## Karta rýchlej referencie

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

## Ďalšie kroky

| Téma | Popis |
|-------|-------------|
| **Docker Compose** | Definujte viackontajnerové aplikácie so sieťovaním a volumes v jednom YAML súbore |
| **Dockerfiles** | Zostavte vlastné images pomocou inštrukcií `FROM`, `RUN`, `COPY`, `CMD` a ďalších |
| **Multi-Stage Builds** | Optimalizujte veľkosť images oddelením build a runtime prostredia |
| **Container Orchestration** | Škálujte a spravujte kontajnery pomocou Kubernetes alebo Docker Swarm |

---

**Ďakujeme, že ste absolvovali tento workshop!**
