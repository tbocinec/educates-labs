---
title: Pod nikdy nenaštartuje
---

# Úroveň 2: Pod nikdy nenaštartuje

Príznak: aplikovali ste manifest a Pod visí večne na `0/1`. Nikdy sa nedostane do
stavu `Running` a `kubectl logs` nevracia nič použiteľné.

Vedú k tomu dve úplne odlišné príčiny a `describe` ich okamžite rozlíši.

## Scenár 1: Image, ktorý neexistuje

Kolega vám podá tento manifest so slovami „mne to funguje".

```editor:open-file
file: broken/01-image/pod-bad-image.yaml
```

Aplikujte ho:

```terminal:execute
command: kubectl apply -f ~/broken/01-image/pod-bad-image.yaml
```

### Pozorovanie

```terminal:execute
command: kubectl get pod web-server
```

Dajte tomu pár sekúnd a pozrite znova — stav sa posunie z `ContainerCreating` na
`ErrImagePull` a ustáli sa na `ImagePullBackOff`:

```terminal:execute
command: kubectl get pod web-server -w
```

Keď sa stav prestane meniť, sledovanie zastavte:

```terminal:interrupt
```

> **`BackOff` znamená, že Kubernetes skúša znova s narastajúcimi odstupmi.** Nie
> je to trvalé zlyhanie — bude to skúšať donekonečna. Preto vie preklep potichu
> blokovať jedno miesto celé popoludnie.

### Diagnostika

Najprv logy, nech je zrejmé, o čom bola predchádzajúca kapitola:

```terminal:execute
command: kubectl logs web-server
```

Nič — nie je odkiaľ logy čítať, container neexistuje. Teraz poriadne:

```terminal:execute
command: kubectl describe pod web-server | grep -A8 Events:
```

Prečítajte si udalosť `Failed`. Pomenúva image a hovorí, že manifest je neznámy
alebo sa nenašiel. Klaster vám hovorí, že odkaz na image je zlý.

Overte, čo bolo presne požadované:

```terminal:execute
command: kubectl get pod web-server -o jsonpath='{.spec.containers[0].image}{"\n"}'
```

### Príčina

`nginx:1.99-does-not-exist` — taký tag neexistuje. V praxi sa rovnaká udalosť
objaví zo štyroch rôznych dôvodov a text udalosti ich rozlíši:

| Udalosť hovorí | Skutočná príčina |
|----------------|------------------|
| `manifest unknown` / `not found` | Preklep v názve alebo tagu image |
| `unauthorized` / `authentication required` | Privátny registry, chýbajúce `imagePullSecrets` |
| `no such host` / `timeout` | Registry je z nodu nedostupný |
| `toomanyrequests` | Limit registry (časté pri Docker Hube) |

### Oprava a overenie

Opravte tag v editore — zmeňte `1.99-does-not-exist` na `1.27`:

```editor:select-matching-text
file: broken/01-image/pod-bad-image.yaml
text: "image: nginx:1.99-does-not-exist"
```

Image Podu sa **nedá zmeniť za behu**, takže Pod zmažte a vytvorte nanovo:

```terminal:execute
command: kubectl delete pod web-server --ignore-not-found
```

```terminal:execute
command: kubectl run web-server --image=nginx:1.27
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/web-server --timeout=90s
```

```terminal:execute
command: kubectl get pod web-server
```

`1/1 Running`. Upracte:

```terminal:execute
command: kubectl delete pod web-server
```

## Scenár 2: Kľúč v ConfigMape, ktorý tam nie je

Rovnaký príznak, úplne iná príčina. Táto aplikácia si číta režim z ConfigMapy.

```editor:open-file
file: broken/02-config/configmap.yaml
```

```editor:open-file
file: broken/02-config/pod-bad-key.yaml
```

Aplikujte oboje:

```terminal:execute
command: kubectl apply -f ~/broken/02-config/
```

### Pozorovanie

```terminal:execute
command: kubectl get pod config-app
```

`CreateContainerConfigError`. Image sa stiahol v poriadku — Kubernetes sa dostal
až k zostaveniu konfigurácie containera a tam to vzdal.

### Diagnostika

```terminal:execute
command: kubectl describe pod config-app | grep -A8 Events:
```

Udalosť je príjemne konkrétna: `couldn't find key mode in ConfigMap`.

Pozrite sa, čo ConfigMap naozaj obsahuje:

```terminal:execute
command: kubectl get configmap app-settings -o jsonpath='{.data}{"\n"}'
```

A o čo Pod žiadal:

```terminal:execute
command: kubectl get pod config-app -o jsonpath='{.spec.containers[0].env[0].valueFrom.configMapKeyRef}{"\n"}'
```

### Príčina

ConfigMap definuje `app_mode`. Pod žiada `mode`. Kubernetes to neuhádne.

> **Prečo je to chyba *konfigurácie* a nie chýbajúceho súboru?** Lebo odkaz
> rozlišuje kubelet *pred* spustením containera. Rovnaký stav sa objaví pri
> chýbajúcom Secrete, úplne chýbajúcej ConfigMape aj pri `secretKeyRef`
> ukazujúcom na zlý kľúč.

### Oprava a overenie

Zmeňte v manifeste Podu kľúč z `mode` na `app_mode`:

```editor:select-matching-text
file: broken/02-config/pod-bad-key.yaml
text: "key: mode"
```

Prepíšte `mode` na `app_mode`, uložte a vytvorte Pod nanovo:

```terminal:execute
command: kubectl delete pod config-app --ignore-not-found && kubectl apply -f ~/broken/02-config/pod-bad-key.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/config-app --timeout=90s
```

Dokážte, že premenná prostredia dorazila:

```terminal:execute
command: kubectl exec config-app -- printenv APP_MODE
```

`production`. Upracte:

```terminal:execute
command: kubectl delete -f ~/broken/02-config/ --ignore-not-found
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- `ImagePullBackOff` — odkaz na image je zlý, privátny alebo nedostupný; text udalosti povie, čo z toho
- `CreateContainerConfigError` — odkaz na ConfigMap alebo Secret sa nedá rozlíšiť
- Ani jeden Pod nikdy nevyprodukoval logy, lebo žiadny container nebežal
- `describe` → Events v oboch prípadoch pomenoval presnú príčinu
- Image a env Podu sa nedajú meniť za behu — treba zmazať a vytvoriť nanovo

Ďalej: Pody, ktoré **naštartujú** a aj tak zomrú.
