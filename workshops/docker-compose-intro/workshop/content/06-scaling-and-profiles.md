# Škálovanie a profiles

Docker Compose vám umožňuje spúšťať viacero inštancií service a selektívne povoliť services pomocou profiles.

---

## Škálovanie services

Pomocou flagu `--scale` môžete spustiť viacero replík service.

### Príprava škálovateľnej service

Skopírujte pripravený Compose súbor:

```terminal:execute
command: mkdir -p ~/scaling-demo && cp ~/exercises/scaling-demo/compose.yaml ~/scaling-demo/
```

**Otvorte Compose súbor v záložke Editor:**

```editor:open-file
file: ~/scaling-demo/compose.yaml
```

### Škálovanie nahor

**Začnite s 3 inštanciami worker:**

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d --scale worker=3
```

**Zobrazte všetky bežiace kontajnery:**

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

Mali by ste vidieť 3 kontajnery `worker` a 1 kontajner `web`.

**Skontrolujte logy zo všetkých workerov:**

```terminal:execute
command: cd ~/scaling-demo && docker compose logs worker
```

Každý worker má jedinečný hostname.

---

### Dynamické škálovanie nahor a nadol

**Naškálujte workerov nahor na 5:**

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d --scale worker=5
```

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

**Naškálujte späť nadol na 2:**

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d --scale worker=2
```

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

Compose elegantne zastaví nadbytočné kontajnery.

> **Poznámka:** Nemôžete škálovať service, ktorá má nastavený `container_name`, alebo ktorá používa mapovanie portu hostiteľa (napr. `ports: "8080:80"`), pretože viaceré kontajnery by boli v konflikte na rovnakom názve/porte.

---

### Používanie `deploy.replicas` v Compose súbore

Namiesto flagu `--scale` môžete požadovaný počet replík definovať priamo v Compose súbore:

```terminal:execute
command: cd ~/scaling-demo && docker compose down
```

**Aplikujte verziu s `deploy.replicas`:**

```terminal:execute
command: cp ~/exercises/scaling-demo/compose-replicas.yaml ~/scaling-demo/compose.yaml
```

**Otvorte súbor v Editore — všimnite si sekciu `deploy.replicas`:**

```editor:open-file
file: ~/scaling-demo/compose.yaml
```

```editor:select-matching-text
file: ~/scaling-demo/compose.yaml
text: replicas: 3
```

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d
```

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

Tri workery sa spustia automaticky na základe nastavenia `deploy.replicas`.

---

## Profiles

Profiles vám umožňujú definovať services, ktoré sa majú **spustiť iba na výslovné vyžiadanie**. To je užitočné pre vývojárske nástroje, debugovacie sidecary alebo voliteľné komponenty.

### Definovanie profiles

```terminal:execute
command: cd ~/scaling-demo && docker compose down
```

**Aplikujte verziu s profiles:**

```terminal:execute
command: cp ~/exercises/scaling-demo/compose-profiles.yaml ~/scaling-demo/compose.yaml
```

**Otvorte súbor v Editore — prezrite si konfiguráciu profiles:**

```editor:open-file
file: ~/scaling-demo/compose.yaml
```

```editor:select-matching-text
file: ~/scaling-demo/compose.yaml
text: profiles
```

Services s `profiles` sa **predvolene nespúšťajú**.

---

### Spustenie bez profiles

```terminal:execute
command: cd ~/scaling-demo && docker compose up -d
```

```terminal:execute
command: cd ~/scaling-demo && docker compose ps
```

Bežia iba `web` a `cache` — services `debug` a `monitoring` sú preskočené.

---

### Aktivácia profile

**Spustite services vrátane profile debug:**

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug up -d
```

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug ps
```

Teraz bežia `web`, `cache` a `debug`.

**Aktivujte viacero profiles:**

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug --profile monitoring up -d
```

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug --profile monitoring ps
```

Teraz bežia všetky štyri services.

---

### Kedy použiť profiles

| Prípad použitia | Príklad |
|----------|---------|
| **Vývojárske nástroje** | Admin UI databázy, debugovacie kontajnery |
| **Testovanie** | Test runnery, mock services |
| **Monitoring** | Metrics exportéry, agregátory logov |
| **CI/CD** | Services potrebné iba v konkrétnych pipeline |

---

## Vyčistenie

```terminal:execute
command: cd ~/scaling-demo && docker compose --profile debug --profile monitoring down
```

```terminal:execute
command: rm -rf ~/scaling-demo
```
