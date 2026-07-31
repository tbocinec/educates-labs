# Vykonávanie príkazov vo vnútri containers

Jednou z najsilnejších vlastností Dockeru je možnosť spúšťať príkazy vo vnútri bežiaceho containera. Príkaz `docker exec` vám umožňuje pracovať s filesystemom containera, ladiť problémy a skúmať runtime prostredie.

---

## Spustenie containera na pozadí pre cvičenie

Spustime si nový Nginx container, ktorý budeme používať počas celej tejto časti:

```terminal:execute
command: docker run -d --name exec-demo nginx:latest
```

---

## Spustenie jedného príkazu

Príkaz `docker exec` použite na vykonanie jednorazového príkazu vo vnútri bežiaceho containera:

```terminal:execute
command: docker exec exec-demo hostname
```

Toto spustí príkaz `hostname` vo vnútri containera `exec-demo` a vypíše výsledok. Hostname containera je v predvolenom nastavení jeho container ID.

**Skontrolujte operačný systém vo vnútri containera:**

```terminal:execute
command: docker exec exec-demo cat /etc/os-release
```

**Vypíšte súbory v predvolenom web root adresári Nginxu:**

```terminal:execute
command: docker exec exec-demo ls -la /usr/share/nginx/html/
```

---

## Interaktívny prístup do shellu

Prepínače `-it` kombinujú dve možnosti:
- `-i` (**interactive**) — udržiava otvorený štandardný vstup
- `-t` (**tty**) — alokuje pseudo-TTY (terminál)

Spolu vám poskytnú plne interaktívnu shell reláciu vo vnútri containera:

```terminal:execute
command: docker exec -it exec-demo /bin/bash
```

Teraz ste **vo vnútri containera**. Prompt sa zmení tak, aby odrážal hostname containera. Vyskúšajte vo vnútri containera nasledujúce príkazy:

**Skontrolujte aktuálneho používateľa:**

```terminal:execute
command: whoami
```

**Preskúmajte filesystem:**

```terminal:execute
command: ls /
```

**Skontrolujte IP adresu containera:**

```terminal:execute
command: hostname -i
```

**Ukončite interaktívny shell:**

```terminal:execute
command: exit
```

> **Dôležité:** Ukončenie `exec` shellu container **nezastaví**. Hlavný proces containera (Nginx) beží ďalej. Ukončí sa iba shell relácia.

---

## Spustenie príkazov ako iný používateľ

V predvolenom nastavení `docker exec` spúšťa príkazy ako predvolený používateľ containera (často `root`). Iného používateľa môžete určiť prepínačom `-u`:

```terminal:execute
command: docker exec -u nobody exec-demo whoami
```

Toto vykoná príkaz ako používateľ `nobody` namiesto `root`.

---

## Nastavenie environment variables v exec

Do exec relácie môžete vložiť environment variables pomocou prepínača `-e`:

```terminal:execute
command: docker exec -e MY_VAR="Hello Workshop" exec-demo env | grep MY_VAR
```

Hodí sa to na odovzdanie dočasnej konfigurácie do ladiacej relácie bez ovplyvnenia hlavného procesu containera.

---

## Pracovný adresár (working directory)

Prepínačom `-w` nastavíte pracovný adresár pre vykonávaný príkaz:

```terminal:execute
command: docker exec -w /usr/share/nginx/html exec-demo ls -la
```

Toto vypíše obsah web root adresára Nginxu bez toho, aby ste v príkaze museli uvádzať celú cestu.

---

## Úprava súborov vo vnútri containera

Príkaz `exec` môžete použiť na úpravu súborov vo vnútri bežiaceho containera. Nahraďme predvolenú uvítaciu stránku Nginxu:

```terminal:execute
command: docker exec exec-demo bash -c 'echo "<h1>Hello from Docker Workshop!</h1>" > /usr/share/nginx/html/index.html'
```

**Overte zmenu:**

```terminal:execute
command: docker exec exec-demo cat /usr/share/nginx/html/index.html
```

> **Poznámka:** Zmeny vykonané vo vnútri containera sa ukladajú do zapisovateľnej vrstvy (**writable layer**) containera. Pri odstránení containera sa stratia. Na trvalé uchovanie dát poskytuje Docker **volumes** — tie sú preberané vo workshope **Docker: Networking, Ports & Storage**.

---

## Praktický príklad ladenia (debugging)

Nasimulujme si bežný ladiaci postup — zisťovanie, prečo konfigurácia Nginxu možno nefunguje:

**Zobrazte konfiguráciu Nginxu:**

```terminal:execute
command: docker exec exec-demo cat /etc/nginx/nginx.conf
```

**Otestujte syntax konfigurácie Nginxu:**

```terminal:execute
command: docker exec exec-demo nginx -t
```

**Skontrolujte, na ktorých portoch Nginx počúva:**

```terminal:execute
command: docker exec exec-demo bash -c 'apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq net-tools > /dev/null 2>&1 && netstat -tlnp'
```

Toto vo vnútri containera nainštaluje `net-tools` a zobrazí všetky počúvajúce TCP porty — bežná ladiaca technika.

---

## Cleanup

```terminal:execute
command: docker rm -f exec-demo
```
