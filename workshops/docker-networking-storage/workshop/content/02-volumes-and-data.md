# Volumes a perzistentné dáta

Predvolene sa všetky dáta vnútri kontajnera ukladajú do jeho **zapisovateľnej vrstvy** (writable layer) a pri odstránení kontajnera sa stratia. **Volumes** poskytujú mechanizmus na uchovanie dát nad rámec životného cyklu kontajnera a na zdieľanie dát medzi kontajnermi.

---

## Problém: dočasné úložisko kontajnera

Ukážme si, prečo sú volumes potrebné:

```terminal:execute
command: docker run -d --name ephemeral-demo nginx:latest
```

**Zapíšte nejaké dáta vnútri kontajnera:**

```terminal:execute
command: docker exec ephemeral-demo bash -c 'echo "Important data" > /tmp/mydata.txt && cat /tmp/mydata.txt'
```

**Odstráňte a znovu vytvorte kontajner:**

```terminal:execute
command: docker rm -f ephemeral-demo
```

```terminal:execute
command: docker run -d --name ephemeral-demo nginx:latest
```

**Skúste prečítať dáta:**

```terminal:execute
command: docker exec ephemeral-demo cat /tmp/mydata.txt 2>&1 || echo "File not found — data was lost!"
```

Súbor je preč. Toto je očakávané správanie — nový kontajner štartuje z čistej vrstvy image.

```terminal:execute
command: docker rm -f ephemeral-demo
```

---

## Docker volumes

**Docker volume** je adresár spravovaný Dockerom, uložený mimo súborového systému kontajnera na hostiteľovi. Volumes prežijú odstránenie kontajnera, dajú sa zdieľať medzi kontajnermi a ponúkajú lepší výkon než bind mounts.

### Vytvorenie volume

```terminal:execute
command: docker volume create workshop-data
```

**Vypíšte všetky volumes:**

```terminal:execute
command: docker volume ls
```

**Preskúmajte volume, aby ste zistili, kde je uložený na hostiteľovi:**

```terminal:execute
command: docker volume inspect workshop-data
```

---

## Použitie volume s kontajnerom

Volume pripojíte do kontajnera pomocou prepínača `-v`:

```
-v VOLUME_NAME:CONTAINER_PATH
```

```terminal:execute
command: docker run -d --name vol-demo1 -v workshop-data:/app/data alpine:latest sh -c 'echo "Hello from container 1" > /app/data/message.txt && sleep 3600'
```

**Overte, že sa dáta zapísali:**

```terminal:execute
command: docker exec vol-demo1 cat /app/data/message.txt
```

**Teraz spustite druhý kontajner zdieľajúci ten istý volume:**

```terminal:execute
command: docker run --rm -v workshop-data:/app/data alpine:latest cat /app/data/message.txt
```

Druhý kontajner prečíta dáta zapísané prvým — volumes umožňujú **zdieľanie dát medzi kontajnermi**.

---

## Perzistencia dát po odstránení kontajnera

Dokážme, že dáta vo volume prežijú odstránenie kontajnera:

```terminal:execute
command: docker rm -f vol-demo1
```

**Spustite nový kontajner a skontrolujte, či sú dáta stále k dispozícii:**

```terminal:execute
command: docker run --rm -v workshop-data:/app/data alpine:latest cat /app/data/message.txt
```

Dáta pretrvávajú, pretože žijú vo volume, nie v kontajneri.

---

## Kopírovanie súborov do kontajnerov pomocou `docker cp`

Ďalším spôsobom, ako vložiť súbory do bežiaceho kontajnera, je príkaz `docker cp`. Funguje tak, že kopíruje súbory priamo medzi hostiteľom a súborovým systémom kontajnera:

```
docker cp HOST_PATH CONTAINER:CONTAINER_PATH
docker cp CONTAINER:CONTAINER_PATH HOST_PATH
```

**Spustite Nginx kontajner:**

```terminal:execute
command: docker run -d --name cp-demo -p 8090:80 nginx:latest
```

**Vytvorte vlastný HTML súbor a skopírujte ho do kontajnera:**

```terminal:execute
command: echo "<h1>Custom Page via docker cp</h1>" > /tmp/custom-index.html
```

```terminal:execute
command: docker cp /tmp/custom-index.html cp-demo:/usr/share/nginx/html/index.html
```

**Overte, že sa doručuje vlastná stránka:**

```terminal:execute
command: curl -s http://localhost:8090
```

Mali by ste vidieť svoj vlastný HTML obsah.

**Skopírujte súbor z kontajnera na hostiteľa:**

```terminal:execute
command: docker cp cp-demo:/etc/nginx/nginx.conf /tmp/nginx.conf && cat /tmp/nginx.conf | head -10
```

Toto je užitočné na vytiahnutie konfiguračných súborov alebo logov z kontajnera na preskúmanie.

> **Poznámka:** `docker cp` vytvorí jednorazovú kópiu — zmeny v zdroji sa **automaticky** neprejavia. Pre živú synchronizáciu sa používajú **bind mounts** (namapovanie adresára hostiteľa priamo do kontajnera pomocou `-v /host/path:/container/path`). Bind mounts sa bežne používajú v lokálnych vývojových prostrediach, kde má Docker daemon priamy prístup k súborovému systému hostiteľa.

---

## Bind mounts (teória)

**Bind mount** mapuje konkrétny adresár na súborovom systéme hostiteľa priamo do kontajnera:

```
docker run -v /host/path:/container/path nginx:latest
```

Napríklad na pripojenie lokálneho adresára projektu ako web root Nginxu:

```
mkdir -p /tmp/my-site
echo "<h1>Hello from Host</h1>" > /tmp/my-site/index.html
docker run -d -p 8080:80 -v /tmp/my-site:/usr/share/nginx/html:ro nginx:latest
```

Prípona `:ro` robí mount **read-only** vnútri kontajnera. Akékoľvek zmeny súborov na hostiteľovi sa vnútri kontajnera prejavia **okamžite** — nedochádza k žiadnemu kopírovaniu. Práve preto sú bind mounts ideálne pre vývojové postupy, kde chcete upravovať kód na hostiteľovi a vidieť zmeny v reálnom čase.

> **Poznámka:** Bind mounts nie je možné v tomto prostredí workshopu predviesť, pretože Docker beží ako Docker-in-Docker (DinD) — Docker daemon beží v samostatnom kontajneri a nemá prístup k súborovému systému session. Na štandardnej inštalácii Dockeru (napr. na vašom notebooku) bind mounts fungujú tak, ako je opísané vyššie.

---

## Volumes vs bind mounts vs docker cp

| Vlastnosť | Volume | Bind Mount | docker cp |
|---------|--------|------------|-----------|
| **Spravované Dockerom** | Áno | Nie | N/A |
| **Živá synchronizácia** | Áno | Áno | Nie (jednorazová kópia) |
| **Prenositeľnosť** | Vysoká | Nízka — závisí od ciest na hostiteľovi | Vysoká |
| **Výkon** | Optimalizovaný Dockerom | Závisí od súborového systému hostiteľa | N/A |
| **Použitie** | Databázy, perzistentné dáta | Vývoj, konfiguračné súbory | Rýchle vloženie/vytiahnutie súboru |
| **Zálohovanie** | Cez Docker CLI alebo volume drivery | Štandardné nástroje súborového systému | Manuálne |

---

## Praktický príklad: PostgreSQL s perzistentným úložiskom

Spustime PostgreSQL s pomenovaným volume, aby dáta prežili reštarty kontajnera:

```terminal:execute
command: docker volume create pg-data
```

```terminal:execute
command: docker run -d --name pg-vol-demo -e POSTGRES_PASSWORD=workshop -v pg-data:/var/lib/postgresql/data postgres:17
```

**Počkajte na inicializáciu a vytvorte nejaké dáta:**

```terminal:execute
command: sleep 5 && docker exec pg-vol-demo psql -U postgres -c "CREATE TABLE demo (id serial, name text); INSERT INTO demo (name) VALUES ('persisted data');"
```

**Odstráňte kontajner a znovu ho vytvorte:**

```terminal:execute
command: docker rm -f pg-vol-demo
```

```terminal:execute
command: docker run -d --name pg-vol-demo -e POSTGRES_PASSWORD=workshop -v pg-data:/var/lib/postgresql/data postgres:17
```

**Overte, že dáta prežili:**

```terminal:execute
command: sleep 5 && docker exec pg-vol-demo psql -U postgres -c "SELECT * FROM demo;"
```

Dáta sú neporušené. Presne takto by sa mali databázy v Dockeri prevádzkovať.

---

## Upratanie

```terminal:execute
command: docker rm -f cp-demo pg-vol-demo
```

```terminal:execute
command: docker volume rm workshop-data pg-data
```

```terminal:execute
command: rm -f /tmp/custom-index.html /tmp/nginx.conf
```
