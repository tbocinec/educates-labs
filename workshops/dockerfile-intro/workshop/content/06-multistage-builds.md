# Multi-stage builds

Multi-stage builds sú jednou z najsilnejších funkcií Dockeru. Umožňujú použiť **samostatné stage** na zostavenie (build) a na beh aplikácie — čím sa build nástroje udržia mimo výsledného image.

---

## Problém

Keď zostavujete kompilovanú aplikáciu (Go, Java, C, Rust atď.), potrebujete:

| Stage | Potrebné nástroje | Veľkosť |
|-------|-------------|------|
| **Build** | Kompilátor, SDK, build nástroje | Veľká (stovky MB) |
| **Run** | Iba skompilovaný binárny súbor | Drobná (pár MB) |

Bez multi-stage buildov obsahuje váš produkčný image všetky build nástroje — čo plytvá miestom a zväčšuje plochu na útok.

---

## Príprava

**Skopírujte súbory cvičenia:**

```terminal:execute
command: cp -r ~/exercises/multistage ~/multistage && cd ~/multistage
```

**Pozrite sa na Go aplikáciu:**

```editor:open-file
file: ~/multistage/main.go
```

Toto je jednoduchý HTTP server napísaný v jazyku Go. Po skompilovaní vytvorí **jediný statický binárny súbor** — bez potreby akýchkoľvek runtime závislostí.

---

## Single-stage build (starý spôsob)

Najprv sa pozrime, čo sa stane pri štandardnom single-stage builde. Zostavíme aplikáciu vo vnútri image `golang`:

```terminal:execute
command: cd ~/multistage && printf 'FROM golang:1.23-alpine\nWORKDIR /app\nCOPY go.mod main.go ./\nRUN go build -o server main.go\nEXPOSE 8080\nCMD ["./server"]' | docker build -t go-single -f - .
```

**Skontrolujte veľkosť image:**

```terminal:execute
command: docker images go-single --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

Image má **~320 MB** — z veľkej časti tvorený Go kompilátorom a SDK, ktoré pri behu (runtime) už nepotrebujeme.

---

## Multi-stage build

Teraz použime multi-stage Dockerfile:

```editor:open-file
file: ~/multistage/Dockerfile
```

**Kľúčové koncepty:**

```editor:select-matching-text
file: ~/multistage/Dockerfile
text: FROM golang
```

1. **Stage 1** (`builder`) — použije plné Go SDK na skompilovanie aplikácie

```editor:select-matching-text
file: ~/multistage/Dockerfile
text: FROM alpine
```

2. **Stage 2** — začína nanovo z drobného `alpine` image

```editor:select-matching-text
file: ~/multistage/Dockerfile
text: COPY --from=builder
```

3. **`COPY --from=builder`** — skopíruje **iba skompilovaný binárny súbor** z build stage

Všetko ostatné z build stage (Go kompilátor, zdrojový kód, build cache) sa **zahodí**.

**Zostavte ho:**

```terminal:execute
command: cd ~/multistage && docker build -t go-multi .
```

**Skontrolujte veľkosť:**

```terminal:execute
command: docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E 'go-single|go-multi'
```

Multi-stage image má **~15 MB** — je približne **95 % menší** než single-stage build!

---

## Otestovanie aplikácie

```terminal:execute
command: docker run --rm -d -p 8080:8080 --name go-app go-multi
```

Kliknutím na záložku **App Preview** uvidíte bežiacu Go aplikáciu. Zobrazuje verziu Go a architektúru systému.

**Zastavte kontajner:**

```terminal:execute
command: docker stop go-app
```

---

## Ešte menšie s `scratch`

`alpine` je už teraz drobný (~7 MB), ale môžeme ísť ešte ďalej. Image `scratch` je úplne **prázdny** image — 0 bajtov:

```editor:open-file
file: ~/multistage/Dockerfile.scratch
```

**Kľúčové rozdiely:**

```editor:select-matching-text
file: ~/multistage/Dockerfile.scratch
text: CGO_ENABLED=0
```

- `CGO_ENABLED=0` — vytvorí **staticky zlinkovaný** binárny súbor (bez závislosti na C knižnici)
- `-ldflags="-s -w"` — odstráni ladiace symboly a tým zmenší veľkosť binárneho súboru

```editor:select-matching-text
file: ~/multistage/Dockerfile.scratch
text: FROM scratch
```

- `FROM scratch` — začína z **prázdneho** image (žiadny shell, žiadny OS, nič)

**Zostavte ho:**

```terminal:execute
command: cd ~/multistage && docker build -t go-scratch -f Dockerfile.scratch .
```

---

## Porovnanie všetkých troch prístupov

```terminal:execute
command: docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E 'go-single|go-multi|go-scratch'
```

| Image | Base | Približná veľkosť |
|-------|------|-----------------|
| `go-single` | golang:1.23-alpine | ~320 MB |
| `go-multi` | alpine | ~15 MB |
| `go-scratch` | scratch | ~7 MB |

To je **97 % úspora** oproti single-stage buildu až po scratch!

**Overte, že scratch image funguje:**

```terminal:execute
command: docker run --rm -d -p 8080:8080 --name go-scratch-app go-scratch
```

Kliknite na záložku **App Preview** — tá istá aplikácia, zlomok veľkosti.

```terminal:execute
command: docker stop go-scratch-app
```

---

## Ako fungujú multi-stage builds

```
┌──────────────────────────┐
│  Stage 1: builder        │
│  FROM golang:1.23-alpine │
│  ┌────────────────────┐  │
│  │  Go compiler       │  │
│  │  Source code        │  │
│  │  Build cache        │  │
│  │  ┌──────────────┐  │  │
│  │  │ server binary │──┼──┼──► COPY --from=builder
│  │  └──────────────┘  │  │
│  └────────────────────┘  │
│         DISCARDED        │
└──────────────────────────┘

┌──────────────────────────┐
│  Stage 2: runtime        │
│  FROM alpine:latest      │
│  ┌────────────────────┐  │
│  │  server binary     │  │  ← Only this ends up
│  └────────────────────┘  │    in the final image
└──────────────────────────┘
```

---

## Kedy použiť multi-stage builds

| Jazyk | Build image | Runtime image |
|----------|------------|---------------|
| **Go** | `golang:alpine` | `alpine` alebo `scratch` |
| **Java** | `maven` alebo `gradle` | `eclipse-temurin:*-jre` |
| **Node.js** | `node` (inštalácia + build) | `node:*-slim` (beh) |
| **Rust** | `rust` | `alpine` alebo `scratch` |
| **C/C++** | `gcc` | `alpine` alebo `scratch` |

Multi-stage builds sú užitočné pre **akúkoľvek** aplikáciu, kde sa požiadavky na build líšia od požiadaviek na beh (runtime).

---

## Vyčistenie (cleanup)

```terminal:execute
command: docker stop $(docker ps -q) 2>/dev/null; docker rmi go-single go-multi go-scratch 2>/dev/null; rm -rf ~/multistage
```
