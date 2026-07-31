# Osvedčené postupy pre Dockerfile

Teraz, keď poznáte jednotlivé inštrukcie, poďme sa naučiť písať Dockerfile v **produkčnej kvalite**. Porovnáme zle napísaný Dockerfile s optimalizovaným.

---

## Príprava

**Skopírujte súbory cvičenia:**

```terminal:execute
command: cp -r ~/exercises/best-practices ~/best-practices && cd ~/best-practices
```

---

## "Zlý" Dockerfile

Začnime Dockerfile, ktorý síce funguje, ale porušuje viacero osvedčených postupov:

```editor:open-file
file: ~/best-practices/Dockerfile.bad
```

**Zostavte ho:**

```terminal:execute
command: cd ~/best-practices && docker build -t app-bad -f Dockerfile.bad .
```

**Spustite ho:**

```terminal:execute
command: docker run --rm app-bad
```

**Skontrolujte veľkosť image:**

```terminal:execute
command: docker images app-bad --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

Tento image je **veľký** — niekoľko stoviek MB. Poďme pochopiť prečo a čo môžeme zlepšiť.

---

## Problém 1: príliš veľa vrstiev

Každá inštrukcia `RUN` vytvára samostatnú vrstvu:

```editor:select-matching-text
file: ~/best-practices/Dockerfile.bad
text: RUN apt-get update
```

Nachádza sa tu **5 samostatných inštrukcií `RUN`**. Každá pridáva vrstvu s vlastnou réžiou. Cache z `apt-get update` je uložená v jednej vrstve a nasledujúce inštalácie z ich spojenia nemôžu ťažiť.

**Osvedčený postup:** Súvisiace príkazy `RUN` spájajte pomocou `&&`:

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*
```

Takto vznikne **jediná vrstva** a čistenie (`rm -rf`) skutočne šetrí miesto, pretože prebieha v tej istej vrstve.

> **Dôležité:** Ak spustíte `apt-get update` a `rm -rf /var/lib/apt/lists/*` v samostatných inštrukciách `RUN`, čistenie nemá žiadny efekt — dáta sú už zachované v predchádzajúcej vrstve.

---

## Problém 2: nesprávny base image

```editor:select-matching-text
file: ~/best-practices/Dockerfile.bad
text: FROM ubuntu
```

Použitie `ubuntu:24.04` pre Python aplikáciu je plytvanie:
- Obsahuje nástroje, ktoré nepotrebujete (dopĺňanie príkazov v bashi, dokumentáciu atď.)
- Python a pip si musíte inštalovať ručne
- Výsledný image je oveľa väčší

**Osvedčený postup:** Použite **účelovo zostavený** base image:

| Namiesto... | Použite... | Prečo |
|---------------|--------|-----|
| `ubuntu` + inštalácia python | `python:3.12-slim` | Python predinštalovaný, oveľa menší |
| `ubuntu` + inštalácia node | `node:22-alpine` | Node predinštalovaný, drobný base |
| `ubuntu` + inštalácia java | `eclipse-temurin:21-jre` | Iba JRE, optimalizované |

---

## Problém 3: chýbajúci konkrétny tag

```dockerfile
# Bad  — "latest" can change unexpectedly
FROM ubuntu:24.04

# Better — but still a full OS
FROM python:3.12

# Best  — slim variant, specific version
FROM python:3.12-slim
```

> **Osvedčený postup:** Vždy používajte **konkrétny tag verzie**. V produkčných Dockerfile sa vyhýbajte `:latest`.

---

## Problém 4: beh pod používateľom root

```terminal:execute
command: docker run --rm app-bad whoami
```

Kontajner beží ako **root**. Ak útočník zneužije aplikáciu, získa vo vnútri kontajnera root prístup.

---

## "Dobrý" Dockerfile

Teraz sa pozrime na optimalizovanú verziu:

```editor:open-file
file: ~/best-practices/Dockerfile.good
```

**Kľúčové vylepšenia:**

```editor:select-matching-text
file: ~/best-practices/Dockerfile.good
text: FROM python
```

1. **Menší base image** — `python:3.12-slim` namiesto `ubuntu:24.04`

```editor:select-matching-text
file: ~/best-practices/Dockerfile.good
text: groupadd -r appuser
```

2. **Používateľ mimo root** — vytvorí používateľa `appuser` a prepne sa naň

```editor:select-matching-text
file: ~/best-practices/Dockerfile.good
text: COPY requirements.txt
```

3. **Šikovné poradie COPY** — najprv závislosti, potom kód (kvôli cachingu)

```editor:select-matching-text
file: ~/best-practices/Dockerfile.good
text: --no-cache-dir
```

4. **Bez pip cache** — menší image vďaka `--no-cache-dir`

**Zostavte ho:**

```terminal:execute
command: cd ~/best-practices && docker build -t app-good -f Dockerfile.good .
```

**Spustite ho:**

```terminal:execute
command: docker run --rm -d -p 8080:5000 --name app-good app-good
```

Kliknutím na záložku **App Preview** uvidíte bežiacu aplikáciu. Všimnite si, že hlási "Running as user: **appuser**" — nie root!

**Zastavte kontajner:**

```terminal:execute
command: docker stop app-good
```

---

## Porovnanie veľkostí image

```terminal:execute
command: docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E 'app-bad|app-good'
```

"Dobrý" image je zvyčajne **3- až 5-krát menší** než "zlý"!

---

## Overenie bezpečnosti

**Zlý image — beží ako root:**

```terminal:execute
command: docker run --rm app-bad whoami
```

**Dobrý image — beží mimo root:**

```terminal:execute
command: docker run --rm app-good whoami
```

---

## Kontrolný zoznam osvedčených postupov

| Postup | Prečo |
|----------|-----|
| Používať **konkrétne tagy base image** | Reprodukovateľné buildy |
| Používať varianty **slim/alpine** | Menšie images, menšia plocha na útok |
| **Spájať príkazy `RUN`** | Menej vrstiev, účinné čistenie |
| **`COPY` pred `RUN`** pri závislostiach | Lepší caching vrstiev |
| Používať **`--no-cache-dir`** pre pip | Menšie images |
| Čistiť v **rovnakom `RUN`** | Skutočne zmenší veľkosť vrstvy |
| Bežať pod používateľom **mimo root** | Bezpečnostný osvedčený postup |
| Používať **`.dockerignore`** | Rýchlejšie buildy, žiadne tajomstvá v image |
| Používať **`COPY`** namiesto `ADD` | Explicitné, bez prekvapení |

---

## Vyčistenie (cleanup)

```terminal:execute
command: docker stop app-good 2>/dev/null; docker rmi app-bad app-good 2>/dev/null; rm -rf ~/best-practices
```
