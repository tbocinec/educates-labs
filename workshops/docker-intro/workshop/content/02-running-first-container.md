# Spustenie vášho prvého containera

Je čas spustiť váš úplne prvý Docker container. V tejto časti stiahnete image z Docker Hubu a spustíte z nej container.

---

## Stiahnutie image (pull)

Skôr než spustíte container, potrebujete image. Začnime stiahnutím oficiálnej image webového servera **Nginx**:

```terminal:execute
command: docker pull nginx:latest
```

Docker sťahuje image vrstvu po vrstve (layer by layer) z Docker Hubu. Každá vrstva sa ukladá do lokálnej cache, takže ďalšie sťahovania tej istej image (alebo images zdieľajúcich vrstvy) budú oveľa rýchlejšie.

**Overte, že image bola stiahnutá:**

```terminal:execute
command: docker images
```

V zozname by ste mali vidieť image `nginx` spolu s jej tagom, image ID, dátumom vytvorenia a veľkosťou.

---

## Spustenie containera v režime popredia (foreground)

Najjednoduchší spôsob, ako spustiť container, je v režime **popredia (foreground / attached)**. Tento režim pripojí štandardný vstup, výstup a chybový výstup vášho terminálu k procesu containera:

```terminal:execute
command: docker run --name my-nginx nginx:latest
```

Priamo v termináli uvidíte log výstup Nginxu. Container beží v popredí a váš terminál je zablokovaný.

**Stlačte `Ctrl+C`** v termináli, čím container zastavíte.

---

## Spustenie containera v režime na pozadí (detached)

Vo väčšine reálnych scenárov chcete, aby containers bežali na **pozadí (detached mode)** pomocou prepínača `-d`:

```terminal:execute
command: docker run -d --name my-nginx-bg nginx:latest
```

Docker vypíše úplné **container ID** a okamžite vráti kontrolu vášmu terminálu. Container ďalej beží na pozadí.

**Vypíšte bežiace containers:**

```terminal:execute
command: docker ps
```

V zozname by ste mali vidieť `my-nginx-bg` spolu s jeho container ID, názvom image, príkazom, časom vytvorenia, stavom (status) a zverejnenými portmi.

---

## Ako čítať výstup `docker ps`

Príkaz `docker ps` poskytuje základné informácie o bežiacich containers:

| Stĺpec | Popis |
|--------|-------------|
| **CONTAINER ID** | Unikátny 12-znakový hash identifikujúci container |
| **IMAGE** | Image, z ktorej bol container vytvorený |
| **COMMAND** | Predvolený príkaz, ktorý container spúšťa |
| **CREATED** | Kedy bol container vytvorený |
| **STATUS** | Aktuálny stav (napr. `Up 2 minutes`) |
| **PORTS** | Mapovanie portov medzi hostiteľom a containerom |
| **NAMES** | Ľudsky čitateľný názov containera |

**Vypíšte VŠETKY containers** (vrátane zastavených):

```terminal:execute
command: docker ps -a
```

Všimnite si, že `my-nginx` (foreground container, ktorý ste zastavili predtým) sa tu objaví so stavom `Exited`.

---

## Spustenie jednorazového containera (one-shot)

Nie všetky containers bežia ako dlhotrvajúce služby. Môžete spustiť container, ktorý vykoná jediný príkaz a potom skončí:

```terminal:execute
command: docker run --rm alpine:latest echo 'Hello from Docker!'
```

Rozoberme si jednotlivé prepínače:
- `--rm` — automaticky odstráni container po jeho ukončení (cleanup)
- `alpine:latest` — image minimálnej Linuxovej distribúcie (iba ~7 MB)
- `echo 'Hello from Docker!'` — príkaz, ktorý sa vykoná vo vnútri containera

Container sa spustí, vypíše správu a okamžite sa odstráni.

**Spustite ďalší jednorazový príkaz na zobrazenie informácií o OS containera:**

```terminal:execute
command: docker run --rm alpine:latest cat /etc/os-release
```

Toto demonštruje, že container beží vo vlastnom izolovanom Linuxovom prostredí — Alpine Linux — bez ohľadu na to, aký OS beží na hostiteľovi.

---

## Pomenovanie containers

V predvolenom nastavení Docker prideľuje containers náhodné názvy (napríklad `eager_newton` alebo `happy_darwin`). Prepínač `--name` ste už videli v akcii. Pomenované containers sa spravujú jednoduchšie:

```terminal:execute
command: docker run -d --name webserver nginx:latest
```

Na tento container sa teraz môžete vo všetkých ďalších príkazoch odvolávať jeho názvom (`webserver`) namiesto container ID.

**Overte, že beží:**

```terminal:execute
command: docker ps --filter "name=webserver"
```

> **Poznámka:** Názvy containers musia byť unikátne. Ak container s rovnakým názvom už existuje (aj keď je zastavený), musíte ho pred vytvorením nového s tým istým názvom odstrániť.
