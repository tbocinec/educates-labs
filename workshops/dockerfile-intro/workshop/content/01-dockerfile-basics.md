# Základy Dockerfile

**Dockerfile** je textový súbor obsahujúci sériu inštrukcií, ktoré Docker používa na zostavenie (build) image. Každá inštrukcia vytvára v image jednu **vrstvu (layer)**.

---

## Proces zostavenia (build)

Keď spustíte `docker build`, Docker:

1. Prečíta Dockerfile
2. Vykoná každú inštrukciu **v poradí**, zhora nadol
3. Pre každú inštrukciu vytvorí novú **vrstvu image (layer)**
4. Vytvorí výsledný image zložený zo všetkých vrstiev naskladaných na sebe

```
┌─────────────────────────────┐
│  Final Image                │
├─────────────────────────────┤
│  Layer 4: CMD ["nginx"...]  │  ← Runtime command
│  Layer 3: COPY index.html   │  ← Your custom content
│  Layer 2: RUN apt-get...    │  ← Install packages
│  Layer 1: FROM nginx:latest │  ← Base image
└─────────────────────────────┘
```

---

## Základné inštrukcie

Tu sú najčastejšie používané inštrukcie Dockerfile:

### `FROM` — základný image (base image)

Každý Dockerfile **musí začínať** inštrukciou `FROM`. Nastavuje základný image (base image):

```dockerfile
FROM nginx:latest
FROM python:3.12-slim
FROM alpine:latest
```

> Vždy používajte **konkrétny tag** (napr. `python:3.12-slim`) namiesto `latest`, aby boli buildy reprodukovateľné.

### `RUN` — vykonanie príkazov

Spustí príkaz **počas buildu** a výsledok uloží ako novú vrstvu:

```dockerfile
RUN apt-get update && apt-get install -y curl
RUN pip install flask
```

Každý `RUN` vytvára vrstvu. Súvisiace príkazy spájajte pomocou `&&`, aby ste minimalizovali počet vrstiev.

### `COPY` — kopírovanie súborov

Kopíruje súbory z vášho **build kontextu** (lokálneho adresára) do image:

```dockerfile
COPY index.html /usr/share/nginx/html/
COPY app.py /app/
COPY . /app/
```

### `CMD` — predvolený príkaz

Určuje príkaz, ktorý sa spustí pri **štarte** kontajnera z tohto image:

```dockerfile
CMD ["python", "app.py"]
CMD ["nginx", "-g", "daemon off;"]
```

> Môže existovať iba **jedna** inštrukcia `CMD`. Ak ich uvediete viac, uplatní sa iba posledná.

---

## Build kontext

Keď spustíte `docker build .`, znak `.` označuje **build kontext** — adresár, ktorého obsah sa odošle Docker daemonu. V inštrukciách `COPY` možno použiť iba súbory v rámci build kontextu.

```
project/
├── Dockerfile        ← Build instructions
├── index.html        ← Available for COPY
├── app.py            ← Available for COPY
└── node_modules/     ← Also sent (unless excluded!)
```

> Veľké adresáre v build kontexte spomaľujú buildy. Na vylúčenie nepotrebných súborov použite `.dockerignore` (preberieme neskôr).

---

## Referenčná tabuľka Dockerfile

| Inštrukcia | Účel | Build / Runtime |
|-------------|---------|-----------------|
| `FROM` | Nastaví base image | Build |
| `RUN` | Vykoná príkaz počas buildu | Build |
| `COPY` | Skopíruje súbory do image | Build |
| `ADD` | Skopíruje súbory (s podporou URL/tar) | Build |
| `WORKDIR` | Nastaví pracovný adresár | Build |
| `EXPOSE` | Zdokumentuje port kontajnera | Build (metadáta) |
| `ENV` | Nastaví premennú prostredia | Oboje |
| `ARG` | Nastaví premennú počas buildu | Build |
| `CMD` | Predvolený spúšťací príkaz | Runtime |
| `ENTRYPOINT` | Hlavný spustiteľný program | Runtime |
| `USER` | Nastaví runtime používateľa | Runtime |
| `LABEL` | Pridá metadáta | Build (metadáta) |

Každú inštrukciu preskúmame v priebehu tohto workshopu.
