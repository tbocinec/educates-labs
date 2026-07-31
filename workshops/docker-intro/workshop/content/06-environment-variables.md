# Environment variables a konfigurácia

Environment variables sú štandardným mechanizmom na odovzdávanie konfigurácie do Docker containers. Umožňujú prispôsobiť správanie containera bez úpravy samotnej image — čo je základný princíp návrhu **twelve-factor app**.

---

## Nastavenie environment variables prepínačom `-e`

Prepínač `-e` (alebo `--env`) nastaví environment variable vo vnútri containera:

```terminal:execute
command: docker run --rm alpine:latest env
```

Toto zobrazí predvolené environment variables vo vnútri Alpine containera. Teraz pridajme vlastné:

```terminal:execute
command: docker run --rm -e MY_NAME="Docker Workshop" -e MY_ROLE="Student" alpine:latest env
```

Všimnite si, že `MY_NAME` a `MY_ROLE` sa vo výstupe objavia popri predvolených premenných.

---

## Praktický príklad: konfigurácia databázy

Mnoho oficiálnych Docker images používa na konfiguráciu environment variables. Spustime databázu **PostgreSQL** a nakonfigurujme ju výhradne cez environment variables:

```terminal:execute
command: docker run -d --name my-postgres -e POSTGRES_USER=workshop -e POSTGRES_PASSWORD=secret123 -e POSTGRES_DB=myapp postgres:17
```

**Počkajte, kým sa PostgreSQL inicializuje, a potom overte, že beží:**

```terminal:execute
command: until docker exec my-postgres pg_isready -U workshop -d myapp >/dev/null 2>&1; do sleep 1; done; docker exec my-postgres psql -U workshop -d myapp -c "SELECT current_database(), current_user;"
```

PostgreSQL použil environment variables na to, aby:
- vytvoril používateľa s názvom `workshop`
- nastavil heslo na `secret123`
- vytvoril databázu s názvom `myapp`

A to všetko bez úpravy akýchkoľvek konfiguračných súborov.

> **Poznámka:** Príkaz vyššie najprv počká pomocou `pg_isready`, kým databáza neprijíma spojenia, a až potom spustí dotaz. Prvá inicializácia PostgreSQL môže trvať niekoľko sekúnd.

---


## Použitie environment súboru (env file)

Keď máte veľa environment variables, ich udržiavanie v príkazovom riadku sa stáva ťažkopádnym. Použite namiesto toho **env file**:

**Vytvorte environment súbor:**

```terminal:execute
command: printf 'APP_NAME=MyDockerApp\nAPP_ENV=development\nAPP_DEBUG=true\nAPP_PORT=3000\nDATABASE_HOST=db.example.com\nDATABASE_PORT=5432\n' > /tmp/app.env
```

**Overte obsah súboru:**

```terminal:execute
command: cat /tmp/app.env
```

**Spustite container s použitím env súboru:**

```terminal:execute
command: docker run --rm --env-file /tmp/app.env alpine:latest env
```

Všetky premenné definované v `app.env` sú dostupné vo vnútri containera. Tento prístup je prehľadnejší, umožňuje verzovanie a znižuje riziko preklepov v príkazovom riadku.

---

## Skúmanie environment variables containera

Environment variables bežiaceho containera si môžete zobraziť pomocou `docker inspect`:

```terminal:execute
command: docker inspect my-postgres --format '{{range .Config.Env}}{{println .}}{{end}}'
```

Toto odhalí všetky environment variables nastavené pri vytvorení containera vrátane používateľom definovaných aj predvolených premenných z image.

---

## Praktický príklad: spustenie Redis s vlastnou konfiguráciou

Spustime **Redis** s vlastnou konfiguráciou cez environment variables a argumenty príkazového riadka:

```terminal:execute
command: docker run -d --name my-redis redis:7 redis-server --maxmemory 64mb --maxmemory-policy allkeys-lru
```

**Overte, že Redis beží, a skontrolujte jeho konfiguráciu:**

```terminal:execute
command: docker exec my-redis redis-cli CONFIG GET maxmemory
```

```terminal:execute
command: docker exec my-redis redis-cli CONFIG GET maxmemory-policy
```

Hoci Redis používa na konfiguráciu servera argumenty príkazového riadka namiesto environment variables, tento príklad ukazuje, že rôzne images majú rôzne konfiguračné mechanizmy. Vždy si preštudujte dokumentáciu danej image na Docker Hube.

---

## Cleanup

```terminal:execute
command: docker rm -f my-postgres my-redis
```

```terminal:execute
command: rm -f /tmp/app.env
```
