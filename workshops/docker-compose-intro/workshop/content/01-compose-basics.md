# Čo je Docker Compose?

Docker Compose je nástroj na definovanie a spúšťanie viackontajnerových aplikácií. Používa deklaratívny YAML súbor na opis services, networks a volumes vašej aplikácie — a následne spustí všetko jediným príkazom.

---

## Prečo Docker Compose?

Predstavte si spustenie typickej webovej aplikácie pomocou `docker run`:

```
# Create a network
docker network create myapp

# Start a database
docker run -d --name db --network myapp \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:17

# Start a cache
docker run -d --name cache --network myapp redis:7

# Start the web app
docker run -d --name web --network myapp \
  -p 8080:80 \
  -e DATABASE_URL=postgres://postgres:secret@db:5432 \
  nginx:latest
```

To sú štyri samostatné príkazy a zakaždým si musíte pamätať presné flagy, názvy networks a názvy volumes. S Docker Compose sa ten istý stack stane jediným súborom:

```yaml
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - pgdata:/var/lib/postgresql/data

  cache:
    image: redis:7

  web:
    image: nginx:latest
    ports:
      - "8080:80"
    environment:
      DATABASE_URL: postgres://postgres:secret@db:5432

volumes:
  pgdata:
```

A všetko to spustíte pomocou: `docker compose up -d`

---

## Štruktúra Compose súboru

Compose súbor má tri hlavné sekcie:

| Sekcia | Účel |
|---------|---------|
| **services** | Kontajnery, ktoré tvoria vašu aplikáciu |
| **volumes** | Named volumes pre perzistentné dáta |
| **networks** | Vlastné networks (voliteľné — Compose automaticky vytvorí predvolenú network) |

Predvolený názov súboru je `compose.yaml` (alebo `docker-compose.yml` pre staršie verzie).

---

## Overenie dostupnosti Compose

Overme, že je Docker Compose nainštalovaný:

```terminal:execute
command: docker compose version
```

Docker Compose v2 je integrovaný priamo do Docker CLI ako plugin (`docker compose`) — nie je potrebný samostatný binárny súbor `docker-compose`.

---

## Compose vs Docker CLI

| Vlastnosť | Docker CLI | Docker Compose |
|---------|-----------|----------------|
| **Rozsah** | Jeden kontajner | Celý stack aplikácie |
| **Konfigurácia** | Flagy na príkazovom riadku | Deklaratívny YAML súbor |
| **Networking** | Manuálny (`docker network create`) | Automatický (predvolená network na projekt) |
| **Reprodukovateľnosť** | Ťažko replikovať presné flagy | Súbor možno verzovať |
| **Životný cyklus** | Spravovať kontajnery jednotlivo | `up` / `down` pre celý stack |

---

## Compose projekt

Keď spustíte `docker compose up`, Compose vytvorí **projekt**. Predvolene sa názov projektu odvodí od názvu adresára. Všetky prostriedky (kontajnery, networks, volumes) majú predponu s názvom projektu, aby sa predišlo konfliktom.

Napríklad v adresári s názvom `myapp`:
- Názvy kontajnerov: `myapp-web-1`, `myapp-db-1`
- Názov network: `myapp_default`
- Názov volume: `myapp_pgdata`

Túto konvenciu pomenovania uvidíte v praxi počas celého workshopu.
