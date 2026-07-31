# Váš prvý Compose súbor

Vytvorme a spustime vašu úplne prvú Docker Compose aplikáciu — jednoduchý Nginx webový server.

---

## Vytvorenie adresára projektu

Pripravili sme pre vás Compose súbor. Skopírujme ho do pracovného adresára a preskúmajme ho:

```terminal:execute
command: mkdir -p ~/first-compose && cp ~/exercises/first-compose/compose.yaml ~/first-compose/
```

**Otvorte súbor v záložke Editor a prezrite si ho:**

```editor:open-file
file: ~/first-compose/compose.yaml
```

Toto je najjednoduchší možný Compose súbor — definuje jednu service s názvom `web`, ktorá spúšťa Nginx a mapuje port 8080 na hostiteľovi na port 80 v kontajneri.

---

## Spustenie aplikácie

```terminal:execute
command: cd ~/first-compose && docker compose up -d
```

Flag `-d` spúšťa všetky services v **detached mode** (na pozadí). Bez neho by sa logy vypisovali do terminálu a blokovali ho.

Compose vykoná:
1. Vytvorí predvolenú **network** pre projekt
2. Stiahne image `nginx:latest` (ak ešte nie je dostupný)
3. Vytvorí a spustí kontajner `web`

---

## Overenie aplikácie

**Skontrolujte bežiace services:**

```terminal:execute
command: cd ~/first-compose && docker compose ps
```

Mali by ste vidieť service `web` so stavom `running` a mapovaním portu `0.0.0.0:8080->80/tcp`.

**Otestujte webový server:**

```terminal:execute
command: curl -s http://localhost:8080 | head -5
```

Môžete tiež kliknúť na záložku **Web App** hore a zobraziť uvítaciu stránku Nginx vo svojom prehliadači.

---

## Zastavenie aplikácie

```terminal:execute
command: cd ~/first-compose && docker compose down
```

`docker compose down` zastaví a odstráni:
- Všetky kontajnery definované v Compose súbore
- Predvolenú network vytvorenú Compose

> **Poznámka:** Named volumes sa predvolene **neodstraňujú**. Použite `docker compose down -v` na odstránenie aj volumes.

**Overte, že je všetko vyčistené:**

```terminal:execute
command: docker ps -a --filter "name=first-compose"
```

Žiadne kontajnery nezostali.

---

## Cyklus `up` a `down`

Toto je základný pracovný postup Docker Compose:

```
docker compose up -d     # Start the entire stack
docker compose down       # Stop and remove everything
```

Je to také jednoduché. Tento cyklus budete používať počas celého zvyšku tohto workshopu.

---

## Opätovné vytvorenie po zmenách

Ak upravíte súbor `compose.yaml`, stačí znova spustiť `up` — Compose zistí, čo sa zmenilo, a znova vytvorí iba dotknuté services.

**Aplikujme aktualizovanú verziu, ktorá pridáva container name a restart policy:**

```terminal:execute
command: cp ~/exercises/first-compose/compose-updated.yaml ~/first-compose/compose.yaml
```

**Otvorte aktualizovaný súbor v Editore — všimnite si dva nové riadky:**

```editor:open-file
file: ~/first-compose/compose.yaml
```

```editor:select-matching-text
file: ~/first-compose/compose.yaml
text: container_name: my-web
```

```editor:select-matching-text
file: ~/first-compose/compose.yaml
text: restart: unless-stopped
```

Teraz aplikujte zmeny:

```terminal:execute
command: cd ~/first-compose && docker compose up -d
```

Compose znova vytvorí iba service `web`, pretože sa zmenila jej konfigurácia.

```terminal:execute
command: docker ps --filter "name=my-web"
```

---

## Vyčistenie

```terminal:execute
command: cd ~/first-compose && docker compose down
```
