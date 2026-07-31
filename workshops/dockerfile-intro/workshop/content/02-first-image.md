# Vytvorenie prvého image

Poďme zostaviť váš prvý vlastný Docker image — personalizovaný Nginx webový server.

---

## Preskúmanie projektu

Skopírujte pripravené súbory cvičenia:

```terminal:execute
command: cp -r ~/exercises/first-image ~/first-image && cd ~/first-image
```

**Otvorte Dockerfile v editore:**

```editor:open-file
file: ~/first-image/Dockerfile
```

Tento Dockerfile má iba dve inštrukcie:

```dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
```

- `FROM nginx:latest` — vychádza z oficiálneho Nginx image
- `COPY index.html ...` — nahradí predvolenú uvítaciu stránku naším vlastným HTML

**Pozrite sa na vlastnú HTML stránku:**

```editor:open-file
file: ~/first-image/index.html
```

---

## Zostavenie image

```terminal:execute
command: cd ~/first-image && docker build -t my-nginx:v1 .
```

Rozoberme si tento príkaz:

| Časť | Význam |
|------|---------|
| `docker build` | Zostaví image z Dockerfile |
| `-t my-nginx:v1` | Označí image ako `my-nginx` s verziou `v1` |
| `.` | Použije aktuálny adresár ako build kontext |

Sledujte výstup — vidíte, ako Docker vykonáva jednotlivé inštrukcie a vytvára vrstvy.

---

## Spustenie image

```terminal:execute
command: docker run -d --name my-web -p 8080:80 my-nginx:v1
```

Kliknutím na záložku **App Preview** hore uvidíte svoju vlastnú stránku v prehliadači.

**Alebo otestujte pomocou curl:**

```terminal:execute
command: curl -s http://localhost:8080 | head -10
```

---

## Zobrazenie vašich images

```terminal:execute
command: docker images my-nginx
```

Vidíte názov image, tag (`v1`), ID image, čas vytvorenia a veľkosť.

---

## Tagy image

Tagy sú označenia verzií vašich images. Poďme zostaviť ďalšiu verziu:

**Upravte HTML stránku — zmeňte nadpis:**

```terminal:execute
command: sed -i 's/My First Docker Image/My Improved Image v2/' ~/first-image/index.html && sed -i 's/Hello from Docker!/Hello from Docker v2!/' ~/first-image/index.html
```

**Zostavte novú verziu:**

```terminal:execute
command: cd ~/first-image && docker build -t my-nginx:v2 .
```

**Teraz máte dve verzie:**

```terminal:execute
command: docker images my-nginx
```

Verzie `v1` aj `v2` existujú vedľa seba. Ktorúkoľvek verziu môžete kedykoľvek spustiť.

---

## Pridávanie tagov k existujúcim images

K existujúcemu image môžete pridať ďalšie tagy bez opätovného zostavenia:

```terminal:execute
command: docker tag my-nginx:v2 my-nginx:latest
```

```terminal:execute
command: docker images my-nginx
```

Všimnite si, že `v2` a `latest` majú **rovnaké ID image** — ukazujú na ten istý image. Tagy sú len označenia.

---

## Push do registry (koncept)

V reálnom workflowe by ste image poslali (push) do registry, aby ho mohli používať aj ostatní:

```
docker tag my-nginx:v2 registry.example.com/my-nginx:v2
docker push registry.example.com/my-nginx:v2
```

Medzi bežné registry patria Docker Hub, GitHub Container Registry (ghcr.io) a súkromné registry.

---

## Vyčistenie (cleanup)

```terminal:execute
command: docker stop my-web && docker rm my-web
```
