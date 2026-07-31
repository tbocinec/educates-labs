# Zhrnutie workshopu

Gratulujeme! Absolvovali ste workshop **Introduction to Docker**. Zopakujme si kľúčové pojmy a zručnosti, ktoré ste získali.

---

## Čo ste sa naučili

### Základy Dockeru
- Docker používa architektúru typu **klient-server** s Docker klientom, daemonom a registries
- **Images** sú read-only šablóny; **containers** sú bežiace inštancie images
- Príkazy Dockeru majú tvar: `docker [management-command] [sub-command] [options]`

### Spúšťanie containers
- `docker run` vytvorí a spustí container z image
- Prepínač `-d` slúži pre režim na pozadí (**detached**)
- Prepínač `--rm` na automatické odstránenie (**auto-remove**) containera po ukončení
- Prepínač `--name` na priradenie **zmysluplných názvov** containers

### Životný cyklus containera
- **Stop** (`docker stop`) posiela SIGTERM pre čisté ukončenie
- **Start** (`docker start`) spustí zastavený container
- **Restart** (`docker restart`) container zastaví a znova spustí
- **Pause/Unpause** zmrazí a obnoví procesy containera
- **Kill** (`docker kill`) posiela SIGKILL pre okamžité ukončenie
- **Remove** (`docker rm`) odstráni zastavený container; pre bežiaci použite `-f`

### Vykonávanie príkazov
- `docker exec` spúšťa príkazy v bežiacom containeri
- Prepínače `-it` poskytujú interaktívnu shell reláciu (**interactive shell**)
- Prepínač `-u` určuje **používateľa**, `-w` nastavuje **pracovný adresár**
- Ukončenie exec shellu container **nezastaví**

### Logy
- `docker logs` získa výstup containera
- Prepínač `-f` **sleduje (follow)** logy v reálnom čase
- Prepínač `--tail N` obmedzí výstup na posledných N riadkov
- Prepínače `--since` a `--until` filtrujú podľa času

### Konfigurácia
- Prepínač `-e` nastavuje **environment variables** vo vnútri containera
- Prepínač `--env-file` načíta premenné zo súboru
- Rôzne images používajú rôzne konfiguračné mechanizmy

### Správa images
- `docker pull` sťahuje images z registries
- `docker history` zobrazuje vrstvy image
- `docker inspect` odhalí metadáta image
- Images postavené na Alpine sú výrazne menšie

---

## Ďalšie kroky

Teraz, keď rozumiete základom Dockeru, tu sú odporúčané smery pre ďalšie vzdelávanie:

| Téma | Popis |
|-------|-------------|
| **Docker: Networking, Ports & Storage** | Mapovanie portov, volumes, perzistentné dáta a sieťovanie containers |
| **Dockerfiles** | Zostavovanie vlastných images pomocou `FROM`, `RUN`, `COPY`, `CMD` a ďalších inštrukcií |
| **Docker Compose** | Definovanie a správa viackontajnerových aplikácií jediným YAML súborom |
| **Multi-Stage Builds** | Optimalizácia veľkosti images oddelením build a runtime prostredia |
| **Orchestrácia containers** | Škálovanie a správa containers pomocou Kubernetes alebo Docker Swarm |
| **CI/CD s Dockerom** | Integrácia Dockeru do pipeline pre kontinuálnu integráciu a doručovanie |
| **Bezpečnosť containers** | Skenovanie images, rootless containers, seccomp profily a AppArmor |

---

## Karta rýchleho prehľadu

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

**Ďakujeme, že ste absolvovali tento workshop!**
