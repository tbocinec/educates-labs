# Základné Compose príkazy

Teraz, keď ste postavili a spustili viackontajnerové aplikácie, poďme si osvojiť kompletnú sadu príkazov `docker compose` na správu vašich stackov.

---

## Príprava cvičného stacku

Skopírujte pripravený Compose súbor:

```terminal:execute
command: mkdir -p ~/compose-commands && cp ~/exercises/compose-commands/compose.yaml ~/compose-commands/
```

**Prezrite si Compose súbor v záložke Editor:**

```editor:open-file
file: ~/compose-commands/compose.yaml
```

```terminal:execute
command: cd ~/compose-commands && docker compose up -d
```

---

## Zobrazenie services

**Zobrazte bežiace services:**

```terminal:execute
command: cd ~/compose-commands && docker compose ps
```

**Zobrazte všetky services (vrátane zastavených):**

```terminal:execute
command: cd ~/compose-commands && docker compose ps -a
```

---

## Zobrazenie logov

**Streamujte logy zo všetkých services:**

```terminal:execute
command: cd ~/compose-commands && docker compose logs --tail 10
```

Flag `--tail 10` zobrazí iba posledných 10 riadkov na service. Bez neho môžete dostať veľa výstupu.

**Zobrazte logy konkrétnej service:**

```terminal:execute
command: cd ~/compose-commands && docker compose logs web --tail 5
```

**Sledujte logy v reálnom čase (Ctrl+C na zastavenie):**

```terminal:execute
command: cd ~/compose-commands && docker compose logs -f web --tail 3
session: 2
```

Vygenerujte nejaké záznamy v logu odoslaním požiadavky:

```terminal:execute
command: curl -s http://localhost:8080 > /dev/null && echo "Request sent!"
```

V Termináli 2 by ste mali vidieť, ako sa objaví záznam v access logu. Stlačením **Ctrl+C** v Termináli 2 zastavíte sledovanie.

---

## Spúšťanie príkazov vnútri kontajnerov

**Spustite interaktívny shell vnútri service:**

```terminal:execute
command: cd ~/compose-commands && docker compose exec web bash -c 'echo "Hello from $(hostname)"'
```

**Spustite príkaz v databázovej service:**

```terminal:execute
command: cd ~/compose-commands && docker compose exec db psql -U demo -d demo -c '\l'
```

**Spustite jednorazový príkaz pomocou `run` (vytvorí nový kontajner):**

```terminal:execute
command: cd ~/compose-commands && docker compose run --rm cache redis-cli --version
```

> **`exec` vs `run`:** `exec` spúšťa príkaz vnútri **existujúceho, bežiaceho** kontajnera. `run` vytvorí **nový** kontajner pre príkaz. Použite `--rm` s `run`, aby sa kontajner po dokončení automaticky odstránil.

---

## Zastavenie, spustenie a reštart

**Zastavte services (bez odstránenia kontajnerov):**

```terminal:execute
command: cd ~/compose-commands && docker compose stop web
```

**Skontrolujte zastavenú service:**

```terminal:execute
command: cd ~/compose-commands && docker compose ps -a
```

Service `web` sa zobrazuje ako "exited", zatiaľ čo ostatné naďalej bežia.

**Spustite zastavenú service:**

```terminal:execute
command: cd ~/compose-commands && docker compose start web
```

**Reštartujte service (stop + start):**

```terminal:execute
command: cd ~/compose-commands && docker compose restart cache
```

---

## Sťahovanie a opätovné vytváranie

**Stiahnite najnovšie images pre všetky services:**

```terminal:execute
command: cd ~/compose-commands && docker compose pull
```

**Znova vytvorte kontajnery bez sťahovania (užitočné po zmenách konfigurácie):**

```terminal:execute
command: cd ~/compose-commands && docker compose up -d --force-recreate
```

---

## Zobrazenie konfigurácie

**Overte a zobrazte vyriešený Compose súbor:**

```terminal:execute
command: cd ~/compose-commands && docker compose config
```

Toto zobrazí úplne vyriešený YAML po spracovaní premenných, predvolených hodnôt a zlúčení. Užitočné pri ladení problémov s konfiguráciou.

---

## Pozastavenie a obnovenie

**Pozastavte všetky procesy v service (zmrazí bez zastavenia):**

```terminal:execute
command: cd ~/compose-commands && docker compose pause web
```

```terminal:execute
command: curl -s --max-time 3 http://localhost:8080 || echo "Connection timed out — web is paused!"
```

**Obnovte (unpause):**

```terminal:execute
command: cd ~/compose-commands && docker compose unpause web
```

```terminal:execute
command: curl -s http://localhost:8080 | head -3
```

---

## Rýchly prehľad príkazov

| Príkaz | Popis |
|---------|-------------|
| `docker compose up -d` | Spustí všetky services na pozadí |
| `docker compose down` | Zastaví a odstráni všetky kontajnery + networks |
| `docker compose ps` | Zobrazí bežiace services |
| `docker compose logs` | Zobrazí logy services |
| `docker compose exec <svc> <cmd>` | Spustí príkaz v bežiacom kontajneri |
| `docker compose run --rm <svc> <cmd>` | Spustí jednorazový príkaz v novom kontajneri |
| `docker compose stop [svc]` | Zastaví service bez odstránenia |
| `docker compose start [svc]` | Spustí zastavené services |
| `docker compose restart [svc]` | Reštartuje services |
| `docker compose pull` | Stiahne najnovšie images |
| `docker compose config` | Overí a zobrazí vyriešenú konfiguráciu |
| `docker compose pause/unpause` | Zmrazí/rozmrazí procesy service |

---

## Vyčistenie

```terminal:execute
command: cd ~/compose-commands && docker compose down
```
