# Správa životného cyklu containera

Pochopenie toho, ako spravovať životný cyklus containera, je nevyhnutné pre každodennú prácu s Dockerom. V tejto časti sa naučíte, ako containers zastaviť, spustiť, reštartovať, pozastaviť (pause) a odstrániť.

---

## Stavy containera

Docker container sa môže nachádzať vo viacerých stavoch:

```
Created ──► Running ──► Paused
                │           │
                │           ▼
                │       Unpaused (Running)
                │
                ▼
            Stopped (Exited) ──► Removed
```

| Stav | Popis |
|-------|-------------|
| **Created** | Container bol vytvorený, ale nikdy nespustený |
| **Running** | Container aktívne vykonáva svoj hlavný proces |
| **Paused** | Procesy containera sú pozastavené (zmrazené v pamäti) |
| **Stopped** | Hlavný proces containera skončil |
| **Removed** | Container bol zo systému odstránený |

---

## Zastavenie containera

Príkaz `docker stop` pošle hlavnému procesu containera signál **SIGTERM** a poskytne mu určitý čas (predvolene 10 sekúnd) na čisté ukončenie. Ak sa proces v tomto okne nezastaví, Docker pošle signál **SIGKILL** na vynútené ukončenie:

```terminal:execute
command: docker stop webserver
```

**Overte, že sa container zastavil:**

```terminal:execute
command: docker ps -a --filter "name=webserver"
```

Stav by teraz mal ukazovať `Exited`.

Čas na čisté ukončenie môžete prispôsobiť prepínačom `--time` alebo `-t`:

```
docker stop -t 30 webserver   # Počkaj 30 sekúnd pred SIGKILL
```

---

## Spustenie zastaveného containera

Zastavený container si zachováva svoj filesystem aj konfiguráciu. Môžete ho spustiť znova:

```terminal:execute
command: docker start webserver
```

```terminal:execute
command: docker ps --filter "name=webserver"
```

Container opäť beží s rovnakou konfiguráciou, dátami a rovnakým container ID ako predtým.

---

## Reštartovanie containera

Príkaz `docker restart` zastaví a následne spustí container v rámci jednej operácie. Hodí sa to vtedy, keď služba potrebuje čisté opätovné spustenie:

```terminal:execute
command: docker restart webserver
```

```terminal:execute
command: docker ps --filter "name=webserver"
```

Čas behu (**uptime**) containera sa vynuluje, ale container ID a všetky konfigurácie zostávajú rovnaké.

---

## Pozastavenie a obnovenie containera (pause / unpause)

Pozastavenie containera **zmrazí všetky procesy** pomocou Linux cgroup freezer. Container zostáva v pamäti, ale nespotrebúva žiadne CPU cykly. Hodí sa to na dočasné pozastavenie záťaže bez straty jej stavu:

**Pozastavte container:**

```terminal:execute
command: docker pause webserver
```

```terminal:execute
command: docker ps --filter "name=webserver"
```

Všimnite si, že stav ukazuje `(Paused)`.

**Obnovte container:**

```terminal:execute
command: docker unpause webserver
```

```terminal:execute
command: docker ps --filter "name=webserver"
```

Container obnoví svoju činnosť presne tam, kde ju prerušil.

---

## Vynútené ukončenie containera (kill)

Ak container neodpovedá a `docker stop` trvá príliš dlho, môžete ho vynútene ukončiť príkazom `docker kill`, ktorý okamžite pošle signál **SIGKILL** (bez času na čisté ukončenie):

```terminal:execute
command: docker kill my-nginx-bg
```

> **Tip:** Na čisté ukončenie používajte `docker stop` a `docker kill` iba vtedy, keď je to nevyhnutné. Vynútené ukončenie môže v niektorých aplikáciách viesť k poškodeniu dát.

---

## Odstraňovanie containers

Zastavené containers stále zaberajú miesto na disku. Zastavený container odstránite takto:

```terminal:execute
command: docker rm my-nginx
```

```terminal:execute
command: docker rm my-nginx-bg
```

**Odstránenie bežiaceho containera** (vynútené odstránenie):

Bežiaci container nie je možné odstrániť štandardným spôsobom. Prepínačom `-f` (force) ho zastavíte a odstránite v jednom kroku:

```terminal:execute
command: docker rm -f webserver
```

**Overte, že všetky containers sú vyčistené:**

```terminal:execute
command: docker ps -a
```

---

## Automatické odstránenie containera

Prepínač `--rm` ste už videli — automaticky odstráni container po jeho ukončení. Obzvlášť užitočný je pre krátkodobé alebo jednorazové containers:

```terminal:execute
command: docker run --rm --name temp-container alpine:latest echo "I will be removed automatically"
```

```terminal:execute
command: docker ps -a --filter "name=temp-container"
```

Container už neexistuje — bol odstránený v okamihu, keď skončil.

---

## Rýchly prehľad: príkazy životného cyklu

| Príkaz | Popis |
|---------|-------------|
| `docker run` | Vytvorí a spustí container |
| `docker stop` | Čisto zastaví bežiaci container |
| `docker start` | Spustí zastavený container |
| `docker restart` | Zastaví a znova spustí container |
| `docker pause` | Zmrazí procesy containera |
| `docker unpause` | Obnoví pozastavený container |
| `docker kill` | Vynútene zastaví container |
| `docker rm` | Odstráni zastavený container |
| `docker rm -f` | Vynútene odstráni bežiaci container |
