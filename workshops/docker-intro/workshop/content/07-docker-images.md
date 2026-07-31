# Skúmanie Docker images

Docker images sú základom containers. V tejto časti sa naučíte, ako vyhľadávať images, pochopíte vrstvy (layers) images, budete pracovať s tagmi a skúmať metadáta images.

---

## Vyhľadávanie images

**Vyhľadajte images na Docker Hube z príkazového riadka:**

```terminal:execute
command: docker search nginx --limit 5
```

Výstup zobrazuje názvy images, popisy, hodnotenia hviezdičkami a to, či ide o oficiálne images. **Oficiálne images** sú kurátorované a udržiavané Dockerom v spolupráci s pôvodnými (upstream) správcami.

**Vyhľadajte image databázy:**

```terminal:execute
command: docker search postgres --limit 5
```

> **Tip:** Podrobnejšie informácie (dostupné tagy, Dockerfile, dokumentácia) nájdete priamo na [Docker Hube](https://hub.docker.com).

---

## Výpis lokálnych images

**Zobrazte všetky lokálne dostupné images:**

```terminal:execute
command: docker images
```

**Filtrujte images podľa názvu repository:**

```terminal:execute
command: docker images nginx
```

**Zobrazte iba image ID** (užitočné pri skriptovaní):

```terminal:execute
command: docker images -q
```

---

## Porozumenie tagom images

Tagy identifikujú konkrétne verzie image. Formát je `repository:tag`:

- `nginx:latest` — najnovšia verzia (predvolená, ak nie je uvedený žiadny tag)
- `nginx:1.27` — konkrétna minor verzia
- `nginx:1.27-alpine` — variant postavený na Alpine Linuxe (menšia veľkosť)

**Stiahnite viacero tagov tej istej image na porovnanie:**

```terminal:execute
command: docker pull nginx:latest
```

```terminal:execute
command: docker pull nginx:alpine
```

**Porovnajte veľkosti:**

```terminal:execute
command: docker images nginx
```

Variant `alpine` je výrazne menší, pretože Alpine Linux je minimálna distribúcia (~7 MB základ). Výber správneho tagu základnej image je dôležité rozhodnutie pri nasadzovaní do produkcie.

---

## Skúmanie detailov image

Príkaz `docker inspect` odhalí podrobné metadáta o image:

```terminal:execute
command: docker inspect nginx:latest --format '{{.Os}}/{{.Architecture}}'
```

**Zobrazte porty (exposed ports) definované v image:**

```terminal:execute
command: docker inspect nginx:latest --format '{{json .Config.ExposedPorts}}' | python3 -m json.tool
```

**Zobrazte predvolený príkaz:**

```terminal:execute
command: docker inspect nginx:latest --format '{{json .Config.Cmd}}' | python3 -m json.tool
```

**Zobrazte všetky environment variables zabudované v image:**

```terminal:execute
command: docker inspect nginx:latest --format '{{range .Config.Env}}{{println .}}{{end}}'
```

---

## Porozumenie vrstvám image (layers)

Docker images sú zostavené zo stohu **read-only vrstiev (layers)**. Každá vrstva predstavuje zmenu vo filesysteme (pridanie súborov, inštalácia balíkov a pod.). Táto architektúra vrstiev umožňuje:

- **Efektívne ukladanie** — vrstvy zdieľané medzi images sa ukladajú len raz
- **Rýchle zostavovanie (builds)** — prebudovať treba len zmenené vrstvy
- **Rýchle sťahovanie (pulls)** — stiahnuť treba len chýbajúce vrstvy

**Zobrazte vrstvy (históriu) image:**

```terminal:execute
command: docker history nginx:latest
```

Každý riadok predstavuje jednu vrstvu. Stĺpec `CREATED BY` ukazuje inštrukciu z Dockerfile, ktorá ju vytvorila. Všimnite si, že niektoré vrstvy sú veľmi malé (len zmeny metadát), zatiaľ čo iné sú väčšie (inštalácia balíkov).

**Porovnajte históriu variantu Alpine:**

```terminal:execute
command: docker history nginx:alpine
```

Variant Alpine má menej a menších vrstiev.

---

## Využitie disku

Docker images môžu časom zaberať značné miesto na disku. Skontrolujte využitie disku Dockerom:

```terminal:execute
command: docker system df
```

Toto zobrazí miesto použité images, containers, volumes a build cache. Stĺpec `RECLAIMABLE` udáva, koľko miesta je možné uvoľniť.

**Pre podrobnejší rozpis:**

```terminal:execute
command: docker system df -v
```

---

## Sťahovanie images z iných registries

Hoci je Docker Hub predvolený registry, images môžete sťahovať z akéhokoľvek OCI-kompatibilného registry:

```
docker pull ghcr.io/owner/image:tag       # GitHub Container Registry
docker pull quay.io/owner/image:tag        # Red Hat Quay
docker pull registry.example.com/image:tag # Súkromný registry
```

Úplný formát odkazu na image je: `registry/repository:tag`

Ak nie je uvedený žiadny registry, Docker predvolene použije `docker.io/library/`.

---

## Tagovanie images

Pre image môžete vytvoriť ďalšie tagy (aliasy) bez duplikovania dát:

```terminal:execute
command: docker tag nginx:latest my-nginx:v1
```

```terminal:execute
command: docker images | grep -E "nginx|my-nginx"
```

Všimnite si, že `my-nginx:v1` má **rovnaké Image ID** ako `nginx:latest` — je to len ďalší ukazovateľ na tie isté vrstvy image.

---

## Odstraňovanie images

**Odstráňte image podľa názvu:**

```terminal:execute
command: docker rmi my-nginx:v1
```

**Odstráňte dangling images** (netagované vrstvy, ktoré zostali po prebudovaní):

```terminal:execute
command: docker images -f "dangling=true"
```

```terminal:execute
command: docker image prune -f
```

> **Poznámka:** Image nie je možné odstrániť, ak ju používa akýkoľvek container (aj zastavený). Najprv odstráňte container, potom image.
