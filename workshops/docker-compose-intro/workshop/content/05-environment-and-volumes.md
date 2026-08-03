# Environment variables a volumes

Docker Compose poskytuje výkonné mechanizmy na konfiguráciu services pomocou environment variables a na perzistenciu dát pomocou volumes.

---

## Environment variables v Compose

Existuje niekoľko spôsobov, ako odovzdať environment variables vašim services.

### Inline `environment` blok

Najjednoduchší prístup — definujte premenné priamo v Compose súbore. Skopírujte pripravený súbor:

```terminal:execute
command: mkdir -p ~/env-volumes && cp ~/exercises/env-volumes/compose.yaml ~/env-volumes/
```

**Otvorte Compose súbor v záložke Editor:**

```editor:open-file
file: ~/env-volumes/compose.yaml
```

Všimnite si blok `environment` s natvrdo zadanými hodnotami pre `POSTGRES_USER`, `POSTGRES_PASSWORD` a `POSTGRES_DB`.

```terminal:execute
command: cd ~/env-volumes && docker compose up -d
```

**Overte environment variables vnútri kontajnera:**

```terminal:execute
command: cd ~/env-volumes && docker compose exec db env | grep POSTGRES
```

---

### Používanie `.env` súborov

Natvrdo zadávať heslá do vášho Compose súboru nie je ideálne. Lepší prístup je použiť **environment súbor**.

**Skopírujte pripravený `.env` súbor:**

```terminal:execute
command: cp ~/exercises/env-volumes/env ~/env-volumes/.env
```

**Otvorte `.env` súbor v záložke Editor a pozrite si jeho obsah:**

```editor:open-file
file: ~/env-volumes/.env
```

**Teraz aplikujte Compose súbor, ktorý namiesto natvrdo zadaných hodnôt používa variable substitution:**

```terminal:execute
command: cp ~/exercises/env-volumes/compose-substitution.yaml ~/env-volumes/compose.yaml
```

**Otvorte aktualizovaný Compose súbor — všimnite si syntax `${VARIABLE}`:**

```editor:open-file
file: ~/env-volumes/compose.yaml
```

```editor:select-matching-text
file: ~/env-volumes/compose.yaml
text: ${DB_USER}
```

**Overte vyriešenú konfiguráciu:**

```terminal:execute
command: cd ~/env-volumes && docker compose config | grep -A5 environment
```

Syntax `${VARIABLE}` číta zo súboru `.env` v tom istom adresári. Toto je **Compose-level** `.env` súbor — načíta sa automaticky.

**Znova vytvorte service s novými premennými:**

> **Poznámka:** Volume `dbdata` sme predtým inicializovali s pôvodnými prihlasovacími údajmi (`myuser` / `workshop`). PostgreSQL inicializuje databázu iba pri prvom spustení nad prázdnym data adresárom, preto najprv pomocou `docker compose down -v` odstránime starý volume, aby sa nové prihlasovacie údaje (`admin` / `production`) skutočne použili.

```terminal:execute
command: cd ~/env-volumes && docker compose down -v && docker compose up -d
```

```terminal:execute
command: cd ~/env-volumes && docker compose exec db env | grep POSTGRES
```

---

### Používanie direktívy `env_file`

Service môžete tiež nasmerovať na konkrétny environment súbor pomocou `env_file`. Toto načíta premenné **do kontajnera** (na rozdiel od `.env`, ktorý sa používa na Compose-level substitúciu).

**Skopírujte pripravený `app.env` súbor:**

```terminal:execute
command: cp ~/exercises/env-volumes/app.env ~/env-volumes/
```

**Otvorte `app.env` súbor v Editore:**

```editor:open-file
file: ~/env-volumes/app.env
```

Teraz aplikujte aktualizovaný Compose súbor, ktorý obsahuje direktívu `env_file`:

```terminal:execute
command: cp ~/exercises/env-volumes/compose-envfile.yaml ~/env-volumes/compose.yaml
```

**Otvorte aktualizovaný Compose súbor a všimnite si sekciu `env_file`:**

```editor:open-file
file: ~/env-volumes/compose.yaml
```

```editor:select-matching-text
file: ~/env-volumes/compose.yaml
text: env_file
```

```terminal:execute
command: cd ~/env-volumes && docker compose up -d
```

**Overte, že sú prítomné oba zdroje premenných:**

```terminal:execute
command: cd ~/env-volumes && docker compose exec db env | grep -E 'POSTGRES|APP_MODE|LOG_LEVEL|MAX_CONNECTIONS'
```

> **Zhrnutie:** Použite `.env` na Compose-level substitúciu (tagy images, čísla portov). Použite `env_file` na načítanie konfigurácie aplikácie do kontajnerov.

---

## Volumes v Docker Compose

Volumes zachovávajú dáta aj po skončení životného cyklu kontajnerov.

### Named volumes

Náš Compose súbor už používa named volume `dbdata`. Overme si perzistenciu dát.

**Začnime s čistou databázou a počkajme, kým PostgreSQL naozaj prijíma spojenia ako `admin`:**

```terminal:execute
command: cd ~/env-volumes && docker compose down -v && docker compose up -d && until docker compose exec -T db psql -U admin -d production -c 'SELECT 1' >/dev/null 2>&1; do sleep 1; done
```

> **Poznámka:** Kľúčové je počkať na pripravenosť — `docker compose up -d` vráti riadenie hneď po štarte kontajnera, ale PostgreSQL potrebuje ešte pár sekúnd na inicializáciu databázy (vytvorenie roly `admin` a databázy `production`). Cyklus čaká, kým `psql` skutočne prejde.

**Vložte nejaké dáta do PostgreSQL:**

```terminal:execute
command: cd ~/env-volumes && docker compose exec db psql -U admin -d production -c "CREATE TABLE notes (id SERIAL PRIMARY KEY, text VARCHAR(255)); INSERT INTO notes (text) VALUES ('Compose volumes work');"
```

> **Poznámka:** Prihlasovacie údaje `admin` / `production` pochádzajú zo súboru `.env` (`DB_USER`, `DB_NAME`). PostgreSQL nevyžaduje heslo pri lokálnom pripojení vnútri kontajnera.

**Reštartujte kontajnery (volume ponecháme) a počkajte na pripravenosť:**

```terminal:execute
command: cd ~/env-volumes && docker compose down && docker compose up -d && until docker compose exec -T db psql -U admin -d production -c 'SELECT 1' >/dev/null 2>&1; do sleep 1; done
```

**Skontrolujte, že dáta pretrvali:**

```terminal:execute
command: cd ~/env-volumes && docker compose exec db psql -U admin -d production -c "SELECT * FROM notes;"
```

Dáta sú stále tam — named volume pretrváva medzi reštartmi a opätovným vytvorením kontajnera.

---

### Viaceré volumes

Services môžu používať viacero volumes. Aplikujme verziu, ktorá pridáva volume pre logy:

```terminal:execute
command: cp ~/exercises/env-volumes/compose-multi-volumes.yaml ~/env-volumes/compose.yaml
```

**Otvorte súbor a pozrite si nový volume `dblogs`:**

```editor:open-file
file: ~/env-volumes/compose.yaml
```

```editor:select-matching-text
file: ~/env-volumes/compose.yaml
text: dblogs
```

```terminal:execute
command: cd ~/env-volumes && docker compose up -d
```

**Zobrazte volumes spravované týmto Compose projektom:**

```terminal:execute
command: docker volume ls --filter "name=env-volumes"
```

Mali by ste vidieť `env-volumes_dbdata` aj `env-volumes_dblogs`.

---

### Odstraňovanie volumes

**Odstráňte kontajnery, ale ponechajte volumes (predvolené):**

```terminal:execute
command: cd ~/env-volumes && docker compose down
```

**Overte, že volumes stále existujú:**

```terminal:execute
command: docker volume ls --filter "name=env-volumes"
```

**Odstráňte kontajnery AJ volumes:**

```terminal:execute
command: cd ~/env-volumes && docker compose down -v
```

**Overte, že volumes sú preč:**

```terminal:execute
command: docker volume ls --filter "name=env-volumes"
```

> **Osvedčený postup:** Počas vývoja používajte `docker compose down` na zachovanie dát. Použite `docker compose down -v` na čisté resetovanie alebo keď ste s projektom hotoví.

---

## Vyčistenie

```terminal:execute
command: cd ~/env-volumes && docker compose down -v 2>/dev/null; rm -rf ~/env-volumes
```
