# Podrobný pohľad na inštrukcie Dockerfile

Poďme preskúmať ďalšie inštrukcie Dockerfile, ktoré vám dávajú väčšiu kontrolu nad tým, ako sa images zostavujú a ako sa kontajnery správajú.

**Skopírujte všetky súbory cvičenia pre túto kapitolu:**

```terminal:execute
command: cp -r ~/exercises/instructions-demo ~/instructions-demo
```

---

## `WORKDIR` — nastavenie pracovného adresára

Nastavuje pracovný adresár pre všetky nasledujúce inštrukcie (`RUN`, `COPY`, `CMD` atď.):

```dockerfile
WORKDIR /app
COPY . .         # Files are copied to /app/
RUN make build   # Runs in /app/
CMD ["./server"] # Starts in /app/
```

Ak adresár neexistuje, Docker ho vytvorí automaticky. `WORKDIR` môžete použiť viackrát.

**Otvorte demo Dockerfile v editore:**

```editor:open-file
file: ~/instructions-demo/workdir/Dockerfile
```

Komentáre v súbore vysvetľujú jeho účel. Poďme ho zostaviť a spustiť:

```terminal:execute
command: cd ~/instructions-demo/workdir && docker build -t workdir-test . && docker run --rm workdir-test
```

Výstup zobrazuje `/myapp` — čo potvrdzuje, že `RUN` sa vykonal vo vnútri `WORKDIR`.

---

## `EXPOSE` — dokumentovanie portov

`EXPOSE` **dokumentuje**, na ktorom porte aplikácia počúva. Port však **nepublikuje** — to sa robí pomocou `docker run -p`:

```dockerfile
EXPOSE 5000
EXPOSE 8080/tcp
EXPOSE 8125/udp
```

Slúži ako dokumentácia pre používateľov vášho image a využíva ho `docker run -P` (publikovanie všetkých exposnutých portov na náhodné porty hostiteľa).

---

## `ENTRYPOINT` vs `CMD`

Obe definujú, čo sa spustí pri štarte kontajnera, ale správajú sa odlišne:

### `CMD` — predvolený príkaz (možno prepísať)

```dockerfile
CMD ["python", "app.py"]
```

Používateľ ho môže úplne prepísať:

```terminal:execute
command: docker run --rm my-nginx:v1 echo "I replaced the default CMD"
```

### `ENTRYPOINT` — pevne daný spustiteľný program

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

Používateľ **nemôže** entrypoint jednoducho prepísať. `CMD` sa stáva predvoleným **argumentom**.

**Otvorte demo Dockerfile:**

```editor:open-file
file: ~/instructions-demo/entrypoint/Dockerfile
```

Komentáre vysvetľujú, ako `ENTRYPOINT` a `CMD` spolupracujú. Zostavte a spustite:

```terminal:execute
command: cd ~/instructions-demo/entrypoint && docker build -t ep-test . && docker run --rm ep-test
```

**Prepíšte iba argument CMD:**

```terminal:execute
command: docker run --rm ep-test "print('Hello from entrypoint!')"
```

Entrypoint (`python -c`) zostáva pevný; mení sa iba argument.

### Kedy použiť ktorú

| Prípad použitia | Odporúčanie |
|----------|----------------|
| Bežná aplikácia | `CMD ["python", "app.py"]` |
| Obal (wrapper) pre CLI nástroj | `ENTRYPOINT ["mytool"]` + `CMD ["--help"]` |
| Potreba pevnej aj prepísateľnej časti | kombinácia `ENTRYPOINT` + `CMD` |

---

## `ENV` — premenné prostredia

Nastavuje premenné prostredia dostupné počas buildu **aj** pri behu (runtime).

**Otvorte demo Dockerfile:**

```editor:open-file
file: ~/instructions-demo/env/Dockerfile
```

**Zostavte a spustite:**

```terminal:execute
command: cd ~/instructions-demo/env && docker build -t env-test . && docker run --rm env-test
```

Kontajner vypíše hodnoty nastavené cez `ENV`. Teraz ich **prepíšte pri behu (runtime):**

```terminal:execute
command: docker run --rm -e APP_ENV=development env-test
```

---

## `ARG` — premenné počas buildu

`ARG` definuje premenné, ktoré existujú **iba počas buildu** — pri behu (runtime) nie sú dostupné.

**Otvorte demo Dockerfile:**

```editor:open-file
file: ~/instructions-demo/arg/Dockerfile
```

Prečítajte si komentáre — vysvetľujú kľúčový rozdiel oproti `ENV`. Zostavte s parametrom `--build-arg`:

```terminal:execute
command: cd ~/instructions-demo/arg && docker build -t arg-test --build-arg BUILD_DATE=$(date +%Y-%m-%d) . && docker run --rm arg-test
```

Všimnite si, že `BUILD_DATE` **nie je dostupný** pri behu (runtime), ale počas buildu sa použil na nastavenie labelu.

**Skontrolujte label:**

```terminal:execute
command: docker inspect arg-test --format '{{index .Config.Labels "build_date"}}'
```

### Zhrnutie `ARG` vs `ENV`

| Vlastnosť | `ARG` | `ENV` |
|---------|-------|-------|
| Dostupné počas buildu | Áno | Áno |
| Dostupné pri behu (runtime) | Nie | Áno |
| Nastavenie z CLI | `--build-arg` | `-e` |
| Uložené v image | Nie | Áno |

---

## `LABEL` — metadáta image

Pridáva do image metadáta ako dvojice kľúč-hodnota:

```dockerfile
LABEL maintainer="team@example.com"
LABEL version="1.0"
LABEL description="My production web server"
```

**Zobrazte labely:**

```terminal:execute
command: docker inspect my-nginx:v1 --format '{{json .Config.Labels}}' | python3 -m json.tool 2>/dev/null || docker inspect my-nginx:v1 --format '{{json .Config.Labels}}'
```

---

## `.dockerignore` — vylúčenie súborov z build kontextu

Podobne ako `.gitignore`, súbor `.dockerignore` vylučuje súbory z odosielania Docker daemonu.

**Najprv otvorte Dockerfile pre toto demo:**

```editor:open-file
file: ~/instructions-demo/ignore/Dockerfile
```

Jednoducho skopíruje všetko z build kontextu do `/app/` a vypíše obsah. Vytvorme si niekoľko testovacích súborov:

```terminal:execute
command: cd ~/instructions-demo/ignore && echo "needed" > app.py && echo "secret" > password.txt && mkdir -p .git && echo "git data" > .git/config && echo "big file" > huge-log.txt
```

**Build bez .dockerignore — skopíruje sa všetko:**

```terminal:execute
command: cd ~/instructions-demo/ignore && docker build -t noignore-test . && docker run --rm noignore-test
```

V image skončili všetky súbory — vrátane `password.txt`! Teraz pridajme súbor `.dockerignore`:

**Otvorte pripravený .dockerignore (s komentármi, ktoré vysvetľujú jednotlivé vzory):**

```editor:open-file
file: ~/instructions-demo/ignore/dockerignore
```

**Aktivujte ho skopírovaním do `.dockerignore`:**

```terminal:execute
command: cp ~/instructions-demo/ignore/dockerignore ~/instructions-demo/ignore/.dockerignore
```

**Znova zostavte — vylúčené súbory sú preč:**

```terminal:execute
command: cd ~/instructions-demo/ignore && docker build -t ignore-test . && docker run --rm ignore-test
```

Zostáva len `app.py`. Adresár `.git`, súbory `.txt` aj samotný `Dockerfile` sú vylúčené.

### Bežné vzory `.dockerignore`

```
.git
.gitignore
node_modules
*.md
Dockerfile
docker-compose.yml
.env
__pycache__
*.pyc
.vscode
```

---

## `COPY` vs `ADD`

Obe kopírujú súbory do image, ale líšia sa:

| Vlastnosť | `COPY` | `ADD` |
|---------|--------|-------|
| Kopírovanie lokálnych súborov | Áno | Áno |
| Automatické rozbalenie `.tar.gz` | Nie | Áno |
| Stiahnutie z URL | Nie | Áno |
| Odporúčané | **Áno** | Iba keď potrebujete rozbalenie |

> **Osvedčený postup:** Vždy používajte `COPY`, pokiaľ konkrétne nepotrebujete funkciu rozbaľovania tar archívov od `ADD`.

---

## Vyčistenie (cleanup)

```terminal:execute
command: docker rmi workdir-test ep-test env-test arg-test noignore-test ignore-test 2>/dev/null; rm -rf ~/instructions-demo
```
