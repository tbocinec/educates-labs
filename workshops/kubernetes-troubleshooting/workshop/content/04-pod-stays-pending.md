---
title: Pod ostáva v Pending
---

# Úroveň 4: Pod ostáva v Pending

Príznak: `kubectl get pods` ukazuje `Pending` a nemení sa to. Žiadny node, žiadny
container, žiadne logy.

`Pending` znamená, že **scheduler** Pod neumiestnil na node. Je to iný subsystém
než pri predchádzajúcich poruchách a svoje úvahy necháva v udalostiach.

## Scenár 5: Nič ho nechce naplánovať

```editor:open-file
file: broken/05-pending/pod-nodeselector.yaml
```

```terminal:execute
command: kubectl apply -f ~/broken/05-pending/pod-nodeselector.yaml
```

### Pozorovanie

```terminal:execute
command: kubectl get pod picky-app
```

`Pending` a žiadny pridelený NODE:

```terminal:execute
command: kubectl get pod picky-app -o wide
```

### Diagnostika

```terminal:execute
command: |
  kubectl describe pod picky-app | grep -A8 Events:
```

Scheduler hlási `FailedScheduling` a — čo je kľúčové — spočíta nody, ktoré
odmietol, aj prečo: *„didn't match Pod's node affinity/selector"*.

Pozrite sa, čo Pod vyžaduje:

```terminal:execute
command: kubectl get pod picky-app -o jsonpath='{.spec.nodeSelector}{"\n"}'
```

A čo nody klastra naozaj ponúkajú:

```terminal:execute
command: kubectl get nodes --show-labels
```

Žiadny node nemá `disktype=ultra-fast-ssd`, takže žiadny nevyhovuje.

### Príčina

`nodeSelector`, ktorému nič nezodpovedá. Hláška schedulera je vlastne kontrolný
zoznam — povie vám, koľko nodov zlyhalo na ktorej podmienke:

| Hláška schedulera | Príčina |
|-------------------|---------|
| `didn't match Pod's node affinity/selector` | `nodeSelector`/affinity nevyhovuje žiadnemu nodu |
| `Insufficient cpu` / `Insufficient memory` | Žiadny node nemá miesto pre požadované zdroje |
| `had untolerated taint` | Nody sú otagované taintom, Pod nemá toleráciu |
| `had volume node affinity conflict` | PV je v zóne, kde sa Pod nedá umiestniť |
| `pod has unbound immediate PersistentVolumeClaims` | PVC ešte nie je naviazané |

> **`Pending` nie je vždy chyba.** V klastri s autoscalingom — ako je tento —
> môže Pod minútu čakať, kým vznikne nový node. Prečítajte si udalosť skôr, než
> usúdite, že je niečo pokazené.

### Oprava a overenie

Odstráňte nesplniteľnú požiadavku:

```terminal:execute
command: kubectl delete pod picky-app --ignore-not-found
```

```terminal:execute
command: kubectl apply -f ~/broken/05-pending/pod-nodeselector-fixed.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/picky-app-fixed --timeout=90s
```

```terminal:execute
command: kubectl get pod picky-app-fixed -o wide
```

Teraz má node. Upracte:

```terminal:execute
command: kubectl delete -f ~/broken/05-pending/pod-nodeselector-fixed.yaml --ignore-not-found
```

## Scenár 6: Odmietnutý skôr, než vznikol

Nie každá porucha po sebe zanechá Pod, ktorý sa dá skúmať. Niektoré sú odmietnuté
už pri dverách.

```editor:open-file
file: broken/05-pending/pod-too-big.yaml
```

```terminal:execute
command: kubectl apply -f ~/broken/05-pending/pod-too-big.yaml
```

### Pozorovanie

Prečítajte si výstup pozorne — nie je tu žiadny Pod na popísanie:

```terminal:execute
command: kubectl get pod greedy-app
```

`NotFound`. API server objekt rovno odmietol.

### Diagnostika

Chyba z `apply` *bola* tou diagnózou: `maximum memory usage per Pod is 8Gi, but
limit is 32Gi`. Je to odmietnutie pri **admission**, vynútené objektmi, ktoré
žijú vo vašom namespace.

Pozrite si pravidlá, podľa ktorých hráte:

```terminal:execute
command: kubectl describe limitrange
```

```terminal:execute
command: kubectl describe resourcequota
```

`LimitRange` obmedzuje, o čo si smie pýtať jeden Pod alebo container.
`ResourceQuota` obmedzuje súčet za celý váš namespace — a zároveň ukazuje, koľko
ste už spotrebovali.

### Príčina

Manifest si vypýtal viac, než politika namespace dovoľuje. Rozdiel, na ktorom
záleží:

| Kde to zlyhá | Čo vidíte | Kam sa pozrieť |
|--------------|-----------|----------------|
| **Admission** (`apply` vráti chybu) | Žiadny objekt nevznikne | Text chyby, `LimitRange`, `ResourceQuota` |
| **Scheduling** (Pod je `Pending`) | Objekt existuje, nemá node | `describe` → `FailedScheduling` |
| **Runtime** (Pod beží a potom padne) | Reštarty, `OOMKilled` | `logs --previous`, `Last State` |

Ak `kubectl apply` vypísal chybu, prestaňte skúmať stav Podu — žiadny Pod
neexistuje.

### Oprava a overenie

Vypýtajte si niečo, čo sa do kvóty zmestí:

```terminal:execute
command: kubectl apply -f ~/broken/05-pending/pod-right-sized.yaml
```

```terminal:execute
command: kubectl wait --for=condition=Ready pod/greedy-app-fixed --timeout=90s
```

Pozrite sa, ako sa zmenila spotreba kvóty:

```terminal:execute
command: kubectl get resourcequota -o custom-columns=NAME:.metadata.name,USED:.status.used,HARD:.status.hard
```

Upracte:

```terminal:execute
command: kubectl delete -f ~/broken/05-pending/pod-right-sized.yaml --ignore-not-found
```

## Zhrnutie

V tejto kapitole ste sa naučili:
- `Pending` znamená, že **scheduler** Pod neumiestnil — dôvod je v udalostiach
- `FailedScheduling` spočíta nody a pomenuje podmienku, na ktorej každý zlyhal
- Bežné príčiny: nevyhovujúci `nodeSelector`, nedostatok zdrojov, netolerované tainty
- Chyba z `kubectl apply` znamená odmietnutie pri **admission** — nie je čo debugovať
- `LimitRange` obmedzuje jeden Pod, `ResourceQuota` celý namespace

Ďalej: Pod je zdravý, ale nikto sa k nemu nedostane.
