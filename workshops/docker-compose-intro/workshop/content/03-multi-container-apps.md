# Viackontajnerové aplikácie

Skutočná sila Docker Compose spočíva v orchestrácii **viacerých services**, ktoré spolupracujú. V tejto časti postavíte kompletný stack aplikácie s webovým frontendom, backendovým API a databázou.

---

## Stack aplikácie

Vytvoríme stack s tromi services:

```
┌─────────────────────────────────────────────────┐
│                 Compose Project                   │
│                                                   │
│  ┌──────────┐   ┌──────────┐   ┌──────────────┐ │
│  │  Nginx   │──►│  Redis   │   │  PostgreSQL  │ │
│  │  (web)   │   │  (cache) │   │  (db)        │ │
│  │ :8080→80 │   │  :6379   │   │  :5432       │ │
│  └──────────┘   └──────────┘   └──────────────┘ │
│                                                   │
│              default network                      │
└─────────────────────────────────────────────────┘
```

---

## Vytvorenie projektu

Skopírujte pripravený Compose súbor do pracovného adresára:

```terminal:execute
command: mkdir -p ~/multi-app && cp ~/exercises/multi-app/compose.yaml ~/multi-app/
```

Toto je väčší Compose súbor. **Otvorte ho v záložke Editor a prezrite si celú štruktúru:**

```editor:open-file
file: ~/multi-app/compose.yaml
```

**Zvýraznite definíciu health check:**

```editor:select-matching-text
file: ~/multi-app/compose.yaml
text: healthcheck
```

**Zvýraznite konfiguráciu závislostí:**

```editor:select-matching-text
file: ~/multi-app/compose.yaml
text: depends_on
```

Preskúmajme kľúčové koncepty:

### `depends_on` so health checkmi

Direktíva `depends_on` riadi **poradie spúšťania**. V kombinácii s `condition: service_healthy` Compose počká, kým závislosť neprejde svojím health checkom, a až potom spustí závislú service.

Bez health checkov `depends_on` garantuje iba to, že sa kontajner **spustil** — nie že je service vnútri pripravená. Health check zabezpečí, že databáza skutočne prijíma spojenia predtým, než sa spustí webová vrstva.

### Named volumes

Volume `pgdata` je deklarovaný na konci súboru. Compose ho automaticky vytvorí a pripojí do kontajnera `db`. Dáta pretrvávajú aj po `docker compose down` (pokiaľ nepoužijete flag `-v`).

---

## Spustenie stacku

```terminal:execute
command: cd ~/multi-app && docker compose up -d
```

Sledujte, ako Compose sťahuje images, vytvára network, spúšťa services v poradí podľa závislostí a čaká na úspešné health checky.

**Skontrolujte stav všetkých services:**

```terminal:execute
command: cd ~/multi-app && docker compose ps
```

Services `db` a `cache` by mali mať stav `running (healthy)`. Service `web` (Nginx) nemá definovaný health check, takže sa zobrazí jednoducho ako `running`.

---

## Overenie konektivity medzi services

Services na tej istej Compose network sa navzájom dosiahnu podľa **názvu service**. Overme si to:

**Z kontajnera web sa pripojte k Redisu podľa názvu:**

```terminal:execute
command: docker compose -f ~/multi-app/compose.yaml exec web bash -c 'apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq redis-tools > /dev/null 2>&1 && redis-cli -h cache ping'
```

**Z kontajnera web sa pripojte k PostgreSQL podľa názvu:**

```terminal:execute
command: docker compose -f ~/multi-app/compose.yaml exec web bash -c 'apt-get install -y -qq postgresql-client > /dev/null 2>&1 && PGPASSWORD=secret123 psql -h db -U workshop -d myapp -c "SELECT 1 as connected;"'
```

Obe services sú dosiahnuteľné podľa svojich Compose názvov (`cache`, `db`) — bez potreby akýchkoľvek IP adries. Compose automaticky vytvorí DNS záznam pre každú service.

---

## Preskúmanie network

Compose vytvorí predvolenú network pomenovanú podľa adresára projektu:

```terminal:execute
command: docker network ls --filter "name=multi-app"
```

**Preskúmajte network, aby ste videli všetky pripojené kontajnery:**

```terminal:execute
command: docker network inspect multi-app_default --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'
```

Všetky tri kontajnery zdieľajú rovnakú network a môžu medzi sebou voľne komunikovať.

---

## Vyčistenie

```terminal:execute
command: cd ~/multi-app && docker compose down -v
```

Flag `-v` odstráni aj volume `pgdata`, keďže dáta už nepotrebujeme.
