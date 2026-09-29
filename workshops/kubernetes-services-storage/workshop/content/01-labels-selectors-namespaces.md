---
title: Labels, selektory a namespaces
---

# Úroveň 1: Labels, selektory a namespaces

V *Základoch Kubernetes* ste labels videli len okrajovo — Pod mal `app: web` a
`kubectl get pods -l app=web` podľa toho filtroval. To bol povrch.

Táto kapitola ide hlbšie, lebo labels práve prestávajú byť pohodlím a stávajú sa
nosnou konštrukciou. **Service**, ktorú budete stavať o dve kapitoly ďalej, si
nájde svoje Pody podľa label selektora a podľa ničoho iného. Keď selektor
pokazíte, Service potichu smeruje prevádzku do prázdna.

> **Dokumentácia**: [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) | [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

## Labels

**Labels** sú dvojice kľúč-hodnota pripojené k objektom v Kubernetes. Slúžia na
organizáciu a výber podmnožín objektov.

Bežné konvencie pomenovania:
- `app` — názov aplikácie (napr. `web`, `api`, `database`)
- `environment` — prostredie (napr. `dev`, `staging`, `prod`)
- `tier` — vrstva aplikácie (napr. `frontend`, `backend`)
- `version` — verzia aplikácie (napr. `1.0`, `2.0`)

### Vytvorenie Podov s labelmi

Poďme vytvoriť niekoľko Podov s rôznymi labelmi, aby sme mali s čím
experimentovať. Otvorte cvičný súbor:

```editor:open-file
file: exercises/labels/pod-multi-label.yaml
```

Súbor definuje tri Pody (oddelené `---` ako YAML dokumenty):
- `frontend-v1` — app=web, tier=frontend, version=1.0
- `frontend-v2` — app=web, tier=frontend, version=2.0
- `backend-v1` — app=api, tier=backend, version=1.0

Skopírujte a aplikujte:

```terminal:execute
command: cp -r ~/exercises/labels ~/labels && kubectl apply -f ~/labels/pod-multi-label.yaml
```

Overte, že všetky Pody bežia:

```terminal:execute
command: kubectl get pods --show-labels
```

## Selektory

**Selektory** sú mechanizmus na filtrovanie zdrojov podľa labelov. Používajú sa
vo veľkom v príkazoch `kubectl` aj v definíciách zdrojov (napr. keď si Deployment
vyberá svoje Pody).

### Selektory založené na rovnosti

Filtrovanie podľa presnej zhody labelu:

```terminal:execute
command: kubectl get pods -l app=web
```

Filtrovanie podľa konkrétnej vrstvy:

```terminal:execute
command: kubectl get pods -l tier=backend
```

Filtrovanie podľa nerovnosti:

```terminal:execute
command: kubectl get pods -l "tier!=frontend"
```

### Množinové selektory

Filtrovanie, kde hodnota labelu patrí do množiny:

```terminal:execute
command: kubectl get pods -l "version in (1.0, 2.0)"
```

Filtrovanie podľa toho, či label vôbec existuje (bez ohľadu na hodnotu):

```terminal:execute
command: kubectl get pods -l "app"
```

Kombinácia viacerých selektorov (logika AND):

```terminal:execute
command: kubectl get pods -l "app=web,version=2.0"
```

### Pridávanie a odoberanie labelov

Pridanie labelu k existujúcemu Podu:

```terminal:execute
command: kubectl label pod frontend-v1 status=healthy
```

Overenie:

```terminal:execute
command: kubectl get pod frontend-v1 --show-labels
```

Zmena existujúceho labelu (vyžaduje `--overwrite`):

```terminal:execute
command: kubectl label pod frontend-v1 version=1.1 --overwrite
```

Odobratie labelu (prípona mínus):

```terminal:execute
command: kubectl label pod frontend-v1 status-
```

Overenie:

```terminal:execute
command: kubectl get pod frontend-v1 --show-labels
```

## Namespaces

**Namespaces** rozdeľujú zdroje klastra do virtuálnych podklastrov. Hodia sa na:

- **Multi-tenancy** — izolácia tímov alebo projektov
- **Resource quotas** — obmedzenie spotreby zdrojov na namespace
- **Riadenie prístupu** — RBAC pravidlá sa dajú obmedziť na namespace

### Výpis namespaces

Zobrazte všetky namespaces v klastri:

```terminal:execute
command: kubectl get namespaces
```

Bežné predvolené namespaces:
- `default` — predvolený namespace pre objekty bez určeného namespace
- `kube-system` — systémové komponenty (API server, etcd a podobne)
- `kube-public` — verejne čitateľné zdroje

Svoj workshopový namespace vidíte v príkaze nižšie. Všetky príkazy `kubectl`
na tomto workshope idú predvolene do neho.

### Práca naprieč namespaces

> **Poznámka:** Nasledujúce príkazy nemusia fungovať v klastroch, kde nemáte
> práva vidieť zdroje v cudzích namespaces (napr. v zdieľaných prostrediach ako
> Educates). Ak príkaz vráti chybu „Forbidden", je to očakávané — RBAC vás
> obmedzuje na váš vlastný namespace.

Pody v konkrétnom namespace:

```terminal:execute
command: kubectl get pods -n kube-system
```

Pody vo všetkých namespaces:

```terminal:execute
command: kubectl get pods --all-namespaces | head -20
```

Alebo kratší prepínač:

```terminal:execute
command: kubectl get pods -A | head -20
```

### Kontrola aktuálneho kontextu

Zistite, ktorý namespace `kubectl` predvolene používa:

```terminal:execute
command: kubectl config view --minify | grep namespace
```

## Prečo na labeloch záleží

Labels neslúžia len na ručné filtrovanie. Sú chrbtovou kosťou toho, ako fungujú
controllery v Kubernetes:

1. **Deployments** si cez `selector.matchLabels` hľadajú svoje Pody
2. **Services** cez `selector` smerujú prevádzku na správne Pody
3. **Network Policies** definujú pravidlá prístupu cez label selektory
4. **Monitorovacie nástroje** podľa labelov agregujú metriky

Napríklad spomeňte si na Deployment z workshopu o základoch:

```yaml
spec:
  selector:
    matchLabels:
      app: nginx    # ← Deployment si vyberá Pody s týmto labelom
  template:
    metadata:
      labels:
        app: nginx  # ← Pody tento label dostanú pri vytvorení
```

Label selektor vytvára **väzbu** medzi Deploymentom a jeho Podmi. Ak sa labels
nezhodujú, Deployment tie Pody spravovať nebude!

## Upratanie

Odstráňte Pody:

```terminal:execute
command: kubectl delete -f ~/labels/pod-multi-label.yaml
```

Overte:

```terminal:execute
command: kubectl get pods
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- **Labels** sú dvojice kľúč-hodnota na organizáciu zdrojov
- **Selektory** filtrujú zdroje podľa labelov (`-l app=web`, `-l "version in (1.0, 2.0)"`)
- `kubectl label` — pridanie, zmena alebo odobratie labelu na existujúcom zdroji
- **Namespaces** rozdeľujú zdroje klastra do izolovaných virtuálnych klastrov
- `-n <namespace>` mieri na konkrétny namespace, `-A` zobrazí všetky
- Labels sú základ toho, ako si Deployments, Services a ďalšie controllery hľadajú svoje zdroje

Ďalej sa pozrieme na to, ako sa Pody dostanú k sebe po sieti — a prečo sú
selektory, ktoré ste si práve vyskúšali, tým, vďaka čomu Service vôbec funguje.
