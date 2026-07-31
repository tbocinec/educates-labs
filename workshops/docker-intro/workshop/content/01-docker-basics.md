# Základy a architektúra Dockeru

Skôr než sa pustíme do spúšťania containers, pochopme, čo Docker je a ako funguje v pozadí.

---

## Čo je Docker?

**Docker** je open-source platforma, ktorá automatizuje nasadzovanie, škálovanie a správu aplikácií pomocou **kontajnerizácie (containerization)**. Container je odľahčený, samostatný a spustiteľný balík, ktorý obsahuje všetko potrebné na spustenie softvéru — kód, runtime, systémové nástroje, knižnice a nastavenia.

Na rozdiel od virtuálnych strojov zdieľajú containers kernel hostiteľského operačného systému, čo ich robí výrazne efektívnejšími z hľadiska spotreby zdrojov aj rýchlosti spúšťania.

---

## Architektúra Dockeru

Docker využíva architektúru typu **klient-server** s tromi hlavnými komponentmi:

| Komponent | Popis |
|-----------|-------------|
| **Docker Client** | CLI nástroj (`docker`), ktorý používate na prácu s Dockerom. Odosiela príkazy Docker daemonu. |
| **Docker Daemon** (`dockerd`) | Služba bežiaca na pozadí, ktorá spravuje objekty Dockeru — images, containers, siete a volumes. |
| **Docker Registry** | Systém na ukladanie a distribúciu Docker images. **Docker Hub** je predvolený verejný registry. |

### Ako spolupracujú

```
┌──────────────┐     REST API     ┌──────────────────┐
│ Docker Client │ ──────────────► │  Docker Daemon    │
│   (docker)    │                 │   (dockerd)       │
└──────────────┘                 │                    │
                                  │  ┌─────────────┐  │
                                  │  │ Containers   │  │
                                  │  ├─────────────┤  │
                                  │  │ Images       │  │
                                  │  ├─────────────┤  │
                                  │  │ Volumes      │  │
                                  │  ├─────────────┤  │
                                  │  │ Networks     │  │
                                  │  └─────────────┘  │
                                  └──────────────────┘
```

---

## Kľúčové pojmy

### Images vs Containers

- **Image** — read-only šablóna obsahujúca kód aplikácie, runtime, knižnice a závislosti. Predstavte si ju ako *plán (blueprint)* alebo *triedu (class)* v objektovo orientovanom programovaní.
- **Container** — bežiaca inštancia image. Predstavte si ho ako *objekt* vytvorený z triedy. Z rovnakej image môžete vytvoriť viacero containers.

### Docker Registry a Docker Hub

- **Registry** je služba, ktorá ukladá Docker images.
- **Docker Hub** (`hub.docker.com`) je predvolený verejný registry s miliónmi vopred pripravených images.
- Images sa pomenúvajú podľa konvencie: `registry/repository:tag` (napr. `docker.io/library/nginx:latest`).

---

## Overenie inštalácie Dockeru

Overme si, že Docker je vo vašom prostredí dostupný a funguje:

**Zistite verziu Dockeru:**

```terminal:execute
command: docker version
```

Tento príkaz zobrazí informácie o verzii klienta aj servera (daemon).

**Zobrazte podrobné systémové informácie:**

```terminal:execute
command: docker info
```

Tento príkaz odhalí počet containers, images, storage driver a ďalšie systémové detaily o vašej inštalácii Dockeru.

---

## Štruktúra príkazov Dockeru

Príkazy Dockeru majú konzistentný tvar:

```
docker [management-command] [sub-command] [options] [arguments]
```

Napríklad:
- `docker container ls` — vypíše bežiace containers
- `docker image pull nginx` — stiahne image nginx
- `docker container run --name web nginx` — spustí container s názvom "web" z image nginx

Môžete použiť aj **skrátenú** syntax:
- `docker ps` (to isté ako `docker container ls`)
- `docker pull nginx` (to isté ako `docker image pull nginx`)
- `docker run nginx` (to isté ako `docker container run nginx`)

**Zobrazte všetky dostupné príkazy:**

```terminal:execute
command: docker --help
```

Počas celého workshopu budeme používať plný aj skrátený tvar príkazov, aby ste si zvykli na oba štýly.
