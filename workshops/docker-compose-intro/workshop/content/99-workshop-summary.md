# Zhrnutie workshopu

Gratulujeme! Dokončili ste workshop **Docker Compose Introduction**.

---

## Čo ste sa naučili

Počas tohto workshopu ste si precvičili nasledujúce zručnosti:

### Základy Compose
- Pochopenie účelu Docker Compose a formátu súboru `compose.yaml`
- Definovanie services, networks a volumes v deklaratívnom YAML súbore
- Používanie `docker compose up -d` a `docker compose down` na správu stackov aplikácií

### Viackontajnerové aplikácie
- Budovanie stackov s viacerými services (web, databáza, cache)
- Používanie `depends_on` so health checkmi pre správne poradie spúšťania
- Využitie automatického DNS Compose na komunikáciu medzi services

### Základné príkazy
- Správa services pomocou `ps`, `logs`, `exec`, `run`, `stop`, `start`, `restart`
- Sťahovanie images, opätovné vytváranie kontajnerov a overovanie konfigurácie
- Pozastavenie a obnovenie services

### Konfigurácia a dáta
- Nastavenie environment variables inline, cez `.env` súbory a pomocou `env_file`
- Používanie named volumes na perzistentné dáta medzi reštartmi kontajnerov
- Pochopenie `docker compose down -v` pre čisté resetovanie

### Škálovanie a profiles
- Horizontálne škálovanie services pomocou `--scale` a `deploy.replicas`
- Používanie profiles na selektívnu aktiváciu voliteľných services

---

## Karta rýchleho prehľadu

```
# Lifecycle
docker compose up -d                # Start all services
docker compose down                  # Stop and remove everything
docker compose down -v               # Also remove volumes

# Status & Logs
docker compose ps                    # List services
docker compose logs [service]        # View logs
docker compose logs -f [service]     # Follow logs

# Execute
docker compose exec <svc> <cmd>      # Run in existing container
docker compose run --rm <svc> <cmd>  # Run in new container

# Control
docker compose stop [service]        # Stop without removing
docker compose start [service]       # Start stopped service
docker compose restart [service]     # Restart service

# Configuration
docker compose config                # Show resolved config
docker compose pull                  # Pull latest images
docker compose up -d --force-recreate  # Recreate containers

# Scaling & Profiles
docker compose up -d --scale svc=N   # Scale service
docker compose --profile <p> up -d   # Activate profile
```

---

## Ďalšie kroky

Ak chcete pokračovať vo svojej ceste učenia sa Dockera, zvážte preskúmanie:

- **Docker Networking, Ports & Storage** — Hlbší pohľad na networking, mapovanie portov, bind mounts a volumes
- **Docker Compose in Production** — Používanie `docker compose` s vlastnými images postavenými z Dockerfiles
- **Docker Swarm** — Orchestrácia kontajnerov naprieč viacerými hostiteľmi
- **Kubernetes** — Orchestrácia kontajnerov vo veľkom rozsahu

---

## Záverečné vyčistenie

Uistite sa, že všetky prostriedky workshopu sú odstránené:

```terminal:execute
command: docker compose -f ~/first-compose/compose.yaml down 2>/dev/null; docker compose -f ~/multi-app/compose.yaml down -v 2>/dev/null; docker compose -f ~/env-volumes/compose.yaml down -v 2>/dev/null; docker compose -f ~/compose-commands/compose.yaml down 2>/dev/null; docker compose -f ~/scaling-demo/compose.yaml --profile debug --profile monitoring down 2>/dev/null; echo "All workshop resources cleaned up!"
```

```terminal:execute
command: rm -rf ~/first-compose ~/multi-app ~/env-volumes ~/compose-commands ~/scaling-demo
```

Ďakujeme, že ste dokončili tento workshop!
