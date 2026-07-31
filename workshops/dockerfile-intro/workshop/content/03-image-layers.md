# Pochopenie vrstiev image (layers)

Každá inštrukcia v Dockerfile vytvára jednu **vrstvu (layer)**. Pochopenie vrstiev je kľúčom k písaniu efektívnych Dockerfile s rýchlymi buildmi.

---

## Vizualizácia vrstiev

Poďme zostaviť image Python aplikácie a preskúmať jeho vrstvy.

**Skopírujte súbory cvičenia:**

```terminal:execute
command: cp -r ~/exercises/layers-demo ~/layers-demo && cd ~/layers-demo
```

**Otvorte Dockerfile v editore:**

```editor:open-file
file: ~/layers-demo/Dockerfile
```

**Otvorte kód aplikácie:**

```editor:open-file
file: ~/layers-demo/app.py
```

**Zostavte image:**

```terminal:execute
command: cd ~/layers-demo && docker build -t layers-demo:v1 .
```

---

## Skúmanie vrstiev pomocou `docker history`

```terminal:execute
command: docker history layers-demo:v1
```

Každý riadok je jedna vrstva. Vidíte:
- Inštrukciu, ktorá ju vytvorila
- Veľkosť, ktorú pridala do image
- Vrstvy zo základného image (`python:3.12-slim`)
- Vrstvy z vášho Dockerfile (`COPY`, `RUN pip install` atď.)

**Pre prehľadnejší pohľad:**

```terminal:execute
command: docker history layers-demo:v1 --format "table {{.CreatedBy}}\t{{.Size}}" --no-trunc | head -10
```

---

## Caching vrstiev

Docker **cachuje** každú vrstvu. Ak sa inštrukcia nezmenila, Docker použije cachovanú vrstvu namiesto jej opätovného zostavenia. Vďaka tomu sú ďalšie buildy oveľa rýchlejšie.

**Zostavte znova bez akýchkoľvek zmien:**

```terminal:execute
command: cd ~/layers-demo && docker build -t layers-demo:v1 .
```

Všimnite si, že výstup uvádza `CACHED` pri každom kroku — nič sa nezostavovalo nanovo.

---

## Invalidácia cache

Keď sa vrstva zmení, **všetky nasledujúce vrstvy** sa zneplatnia a zostavia nanovo. Toto je najdôležitejší koncept pre výkon buildu.

**Zmeňte iba kód aplikácie:**

```terminal:execute
command: sed -i 's/image layers/image layers v2/' ~/layers-demo/app.py
```

**Znova zostavte:**

```terminal:execute
command: cd ~/layers-demo && docker build -t layers-demo:v2 .
```

Pozorne sledujte výstup:
- `COPY requirements.txt .` → **CACHED** (requirements sa nezmenili)
- `RUN pip install ...` → **CACHED** (requirements sa nezmenili)
- `COPY app.py .` → **zostavené nanovo** (app.py sa zmenil)

Nanovo sa zostavia iba vrstvy **za** zmenou. Nákladný krok `pip install` sa preskočil.

---

## Prečo záleží na poradí

Práve preto náš Dockerfile kopíruje `requirements.txt` **pred** `app.py`:

```dockerfile
COPY requirements.txt .          # ← Changes rarely
RUN pip install -r requirements.txt  # ← Expensive, cached when deps unchanged
COPY app.py .                    # ← Changes often
```

Ak by sme skopírovali všetko naraz:

```dockerfile
COPY . .                         # ← ANY file change invalidates this
RUN pip install -r requirements.txt  # ← Rebuilds every time
```

> **Pravidlo:** Inštrukcie, ktoré sa menia **zriedka**, dávajte navrch, a inštrukcie, ktoré sa menia **často**, dávajte naspodok.


---

## Zdieľanie vrstiev medzi images

Vrstvy sú **zdieľané** medzi images, ktoré používajú rovnaký base image. Overme si to:

```terminal:execute
command: docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E 'layers-demo|my-nginx'
```

**Skontrolujte skutočné využitie disku:**

```terminal:execute
command: docker system df -v 2>/dev/null 
```

Zdieľané vrstvy (napríklad base image) sú na disku uložené iba raz, aj keď na ne odkazuje viacero images.

---

## Zhrnutie

| Koncept | Popis |
|---------|-------------|
| **Vrstvy (layers)** | Každá inštrukcia Dockerfile vytvára vrstvu |
| **Caching** | Nezmenené vrstvy sa použijú z cache |
| **Invalidácia** | Zmena vrstvy zneplatní všetky vrstvy pod ňou |
| **Poradie** | Zriedka sa meniace inštrukcie dávajte ako prvé |
| **Zdieľanie** | Images s rovnakým base zdieľajú vrstvy na disku |

---

## Vyčistenie (cleanup)

```terminal:execute
command: docker rmi layers-demo:v1 layers-demo:v2 2>/dev/null; rm -rf ~/layers-demo
```
