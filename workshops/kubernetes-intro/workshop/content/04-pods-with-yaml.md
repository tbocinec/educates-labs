---
title: Pody cez YAML manifesty
---

# Pody cez YAML manifesty

V predchádzajúcej kapitole ste Pody vytvárali **imperatívne** cez `kubectl run`.
V praxi sa však zdroje v Kubernetes definujú **deklaratívne** pomocou YAML
manifestov. Tento prístup je:

- **Reprodukovateľný** — rovnaký YAML vždy vytvorí rovnaký výsledok
- **Verzovateľný** — manifesty sa dajú držať v Gite
- **Kontrolovateľný** — kolegovia vedia zmeny pred nasadením prejsť v review
- **Samodokumentujúci** — YAML popisuje kompletnú špecifikáciu zdroja

> **Dokumentácia**: [Pod YAML Reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/)

## Anatómia Pod manifestu

YAML manifest v Kubernetes má štyri povinné polia najvyššej úrovne:

```yaml
apiVersion: v1          # Ktorá verzia API sa použije
kind: Pod               # Aký typ zdroja
metadata:               # Identita zdroja (názov, labels a pod.)
  name: my-pod
spec:                   # Špecifikácia požadovaného stavu
  containers:
  - name: my-container
    image: nginx:1.27
```

## Vytvorenie Podu z YAML

Pozrime sa na pripravený cvičný súbor. Otvorte si ho v editore:

```editor:open-file
file: exercises/pod-basic/pod.yaml
```

Súbor definuje Pod s názvom `my-nginx`, ktorý beží na image `nginx:1.27`
s vystaveným portom 80.

Najprv si cvičný súbor skopírujte do pracovného adresára:

```terminal:execute
command: cp -r ~/exercises/pod-basic ~/pod-basic
```

Aplikujte manifest a vytvorte Pod:

```terminal:execute
command: kubectl apply -f ~/pod-basic/pod.yaml
```

Overte, že Pod beží:

```terminal:execute
command: kubectl get pods
```

## Zobrazenie živého YAML

Kompletný YAML bežiaceho zdroja si zobrazíte cez `-o yaml`:

```terminal:execute
command: kubectl get pod my-nginx -o yaml | head -40
```

Všimnite si, koľko polí Kubernetes doplnil nad rámec toho, čo ste zadali — napr.
`status`, `uid`, `creationTimestamp`, predvolené `tolerations` a ďalšie.
Kubernetes doplní predvolené hodnoty všade, kde ste nič neurčili.

## Apply vs create

Kubernetes má na vytváranie zdrojov zo súborov dva príkazy:

| Príkaz | Správanie |
|--------|-----------|
| `kubectl create -f` | Vytvorí zdroj. **Zlyhá**, ak už existuje. |
| `kubectl apply -f` | Vytvorí zdroj, ak neexistuje. Ak existuje, **aktualizuje** ho. |

`apply` sa vo všeobecnosti uprednostňuje, lebo je idempotentný — môžete ho
bezpečne spustiť opakovane.

Skúste aplikovať ten istý súbor ešte raz:

```terminal:execute
command: kubectl apply -f ~/pod-basic/pod.yaml
```

Všimnite si výstup `unchanged` — Kubernetes zistil, že nie je čo meniť.

## Úprava Podu

Bežiaci zdroj sa dá upraviť príkazom `kubectl edit`, ktorý otvorí živý manifest
v terminálovom editore:

```terminal:execute
command: kubectl edit pod my-nginx
```

Otvorí sa kompletný YAML vo `vi`. Mohli by ste zmeniť meniteľné pole (napr.
pridať label), uložiť a ukončiť (`:wq`). Cez `:q!` ukončíte bez uloženia.

> **Poznámka**: Väčšina polí Podu je po vytvorení **nemenná (immutable)**. Na
> zmenu nemenného poľa (napríklad image) treba Pod zmazať a vytvoriť nanovo. To
> je ďalší dôvod, prečo sa uprednostňujú Deployments — riešia to za vás.

## Labels v manifestoch

Pozrime sa na Pod s bohatšími labelmi. Otvorte cvičný súbor:

```editor:open-file
file: exercises/pod-labels/pod-labels.yaml
```

Všimnite si sekcie `labels` a `annotations` pod `metadata`. Skopírujte a
aplikujte tento manifest:

```terminal:execute
command: cp -r ~/exercises/pod-labels ~/pod-labels && kubectl apply -f ~/pod-labels/pod-labels.yaml
```

Teraz viete Pody filtrovať podľa labelov:

```terminal:execute
command: kubectl get pods --show-labels
```

Vyfiltrujte iba Pody s konkrétnym labelom:

```terminal:execute
command: kubectl get pods -l app=web
```

## Mazanie zdrojov cez súbor

Ak ste zdroje vytvorili zo súboru, tým istým súborom ich viete aj zmazať:

```terminal:execute
command: kubectl delete -f ~/pod-labels/pod-labels.yaml
```

Je to veľmi pohodlné — Kubernetes súbor prečíta a zmaže zodpovedajúci zdroj.

Upracte aj prvý Pod:

```terminal:execute
command: kubectl delete -f ~/pod-basic/pod.yaml
```

Overte, že sú všetky Pody upratané:

```terminal:execute
command: kubectl get pods
```

## Generovanie YAML šablón

Šikovný trik: cez `--dry-run=client -o yaml` si vygenerujete YAML šablónu pre
ľubovoľný zdroj a presmerujete ju do súboru:

```terminal:execute
command: kubectl run my-app --image=busybox:1.36 --dry-run=client -o yaml > ~/generated-pod.yaml
```

Pozrite si vygenerovaný súbor:

```terminal:execute
command: cat ~/generated-pod.yaml
```

Ten si potom upravíte a aplikujete. Šetrí to čas pri písaní manifestov od nuly.

## Zhrnutie

V tejto kapitole ste sa naučili:
- YAML manifest má štyri kľúčové polia: `apiVersion`, `kind`, `metadata`, `spec`
- `kubectl apply -f` vytvára alebo aktualizuje zdroje deklaratívne
- `kubectl delete -f` maže zdroje definované v súbore
- `kubectl get -o yaml` zobrazí kompletnú živú definíciu zdroja
- Labels v manifestoch umožňujú filtrovanie a výber
- `--dry-run=client -o yaml` generuje šablóny manifestov

Keď ste už s Podmi zžití, poďme na **Deployments** — odporúčaný spôsob, ako
prevádzkovať aplikácie v produkcii!
